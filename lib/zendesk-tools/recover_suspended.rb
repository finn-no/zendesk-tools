require 'net/http'
require 'tmpdir'
require 'fileutils'

module ZendeskTools
  class RecoverSuspended < Command
    include Loggable


    def initialize(*args)
      super

      @tmpdir = Dir.mktmpdir

      @recover_causes = ZendeskTools.config['recover_causes'] || [
        "End-user only allowed to update their own tickets"
      ]
    end

    def run
      @client.suspended_tickets.each { |suspended_ticket| process_ticket(suspended_ticket) }
    end

    private

    def process_ticket(suspended_ticket)
      if should_recover?(suspended_ticket)
        subject = suspended_ticket.subject
        user_id = get_user_id(suspended_ticket)
        content = suspended_ticket.content

        log.info "Recovering: #{subject}"

        # If there is no ticketID, we need to create a new ticket. Otherwise we update with new comment.
        if suspended_ticket.ticket_id.nil?
          ticket = create_ticket(user_id, content, subject)
        else
          ticket_id = suspended_ticket.ticket_id
          ticket = update_ticket(user_id, content, ticket_id)
        end

        # * Check for attachments and upload it to comment if it exists
        suspended_ticket.attachments.each do |attachment|
          url  = attachment.fetch('content_url')
          name = attachment.fetch('file_name')
          path = File.join(@tmpdir, name)

          log.info "downloading #{url}"

          File.open(path, 'wb') { |file| download(url, file) }
          ticket.comment.uploads << path
        end

        # * Save comment and upload it to zendesk.
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

    def should_recover?(suspended_ticket)
      cause = suspended_ticket.cause

      @recover_causes.any? { |recover_cause| cause.include?(recover_cause) }
    end

    def get_user_id(suspended_ticket)
      if suspended_ticket.author.id.nil?
        user_id = @client.users.search(:query => suspended_ticket.author.email).first.id
      else
        user_id = suspended_ticket.author.id
      end
      user_id
    end

    def create_ticket(user_id, content, subject)
      # Create a new ticket with info from suspended ticket
      @client.tickets.create(
        :subject => subject,
        :comment => { :value => content, :author_id => user_id },
        :submitter_id => user_id,
        :requester_id => user_id
        )
    end

    def update_ticket(user_id, content, ticket_id)
      # * Update ticket with info from suspended ticket
      ticket = @client.tickets.find(:id => ticket_id)
      ticket.comment = ZendeskAPI::Ticket::Comment.new(@client, :value => content, :author_id => user_id)
      ticket
    end

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

      case resp
      when Net::HTTPSuccess
        # ok
      when Net::HTTPRedirection
        url = resp['Location']
        log.info "redirecting to #{url}"
        retry
      else
        raise "ERROR:#{resp.code} for #{url}"
      end
    end

  end
end