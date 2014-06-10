# encoding: UTF-8

module ZendeskTools
  class UploadFilesToTicket < Command

    def run
      ticket_id = @args.shift or raise ArgumentError, "sorry, jeg trenger en ticket id"
      files = @args

      raise ArgumentError, "trenger noen filer å laste opp" if files.empty?

      ticket = @client.tickets.find(:id => ticket_id)
      ticket or raise "fant ingen ticket med id #{ticket_id.inspect}"

      ticket.comment = ZendeskAPI::TicketComment.new(@client, :value => "Vedlegg fra #{ZendeskTools.config['username']}")

      files.each do |e|
        ticket.comment.uploads << e
      end

      print "Laster opp #{files.join ', '}..."
      ticket.save
      puts "ferdig."
    end

  end
end