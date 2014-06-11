require 'net/http'
require 'tmpdir'
require 'fileutils'

module ZendeskTools
  class RecoverSuspended < Command
    include Loggable

    # Array with recover causes. Defined in config file
    RECOVER_CAUSES = ZendeskTools.config['recover_causes'] || [
      "End-user only allowed to update their own tickets"
    ]

    def initialize(*args)
      super
      @tmpdir = Dir.mktmpdir
    end

    def run
      @client.suspended_tickets.each do |suspended_ticket|
        if should_recover?(suspended_ticket)
          log.info "Recovering: #{suspended_ticket.subject}"

          ticket_id = suspended_ticket.ticket_id
          author_id = suspended_ticket.author.id
          content = suspended_ticket.content

          # * Create new comment with correct author and content
          ticket = @client.tickets.find(:id => ticket_id)
          ticket.comment = ZendeskAPI::Ticket::Comment.new(@client, :value => content, :author_id => author_id)

          # * Check for attachments and upload it to comment if it exists
          suspended_ticket.attachments.each do |attachment|
            url  = attachment.fetch('content_url')
            name = attachment.fetch('file_name')
            path = File.join(@tmpdir, name)

            log.info "downloading #{url}"

            File.open(path, 'wb') { |file| download(url, file) }
            ticket.comment.uploads << path
          end

          # * Save comment and upload it to zendesk
          log.info "uploading"
          ticket.save

          # * delete/destroy the recovered ticket
          suspended_ticket.destroy
          log.info "cleaning up"
          FileUtils.rm_rf @tmpdir
        else
          log.info "Not recovering: #{suspended_ticket.subject}"
        end
      end
    end

    private

    def download(url, destination)
      uri = URI.parse(url)

      resp = Net::HTTP.get_response(uri) do |response|
        total = response.content_length
        progress = 0
        segment_count = 0

        response.read_body do |segment|
          progress += segment.length
          segment_count += 1

          if segment_count % 15 == 0
            percent = (progress.to_f / total.to_f) * 100
            print "\rDownloading #{url}: #{percent.to_i}% (#{progress} / #{total})"
            $stdout.flush
            segment_count = 0
          end

          destination.write(segment)
        end
      end

      unless resp.kind_of?(Net::HTTPSuccess)
        raise "ERROR:#{resp.code} for #{url}"
      end
    end

    def should_recover?(suspended_ticket)
      cause   = suspended_ticket.cause
      subject = suspended_ticket.subject

      RECOVER_CAUSES.any? { |recover_cause| cause.include?(recover_cause) }
    end
  end
end
