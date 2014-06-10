module ZendeskTools
  class RecoverSuspended < Command
    include Loggable

    RECOVER_CAUSES = [
      "End-user only allowed to update their own tickets"
    ]

    def run
      @client.suspended_tickets.each do |suspended_ticket|
        if should_recover?(suspended_ticket)
          log.info "Recovering: #{suspended_ticket.subject}"
          # Logic for recovering the tickets
          # Need to add logic for:
          # * Grab ticket_id
          ticket_id = suspended_ticket.ticket_id

          # * Grab author_id
          author_id = suspended_ticket.author.id

          # * Grab content
          content = suspended_ticket.content

          # * Create new comment with correct author and content
          ticket = client.tickets.find(:id => ticket_id)
          ticket.comment = { :value => content, :author_id => author_id }

          # * Check for attachments and logic around that

          # not done yet

          # * Ticket upload mechanic for the attachments

          # not done yet

          # * Save comment and upload it to zendesk
          ticket.save

          # * delete/destroy the recovered ticket
          suspended_ticket.destroy
        else
          log.info "Not recovering: #{suspended_ticket.subject}"
        end
      end
    end

    private

    def should_recover?(suspended_ticket)
      cause   = suspended_ticket.cause
      subject = suspended_ticket.subject

      RECOVER_CAUSES.any? { |recover_cause| cause.include?(recover_cause) }
    end
  end
end
