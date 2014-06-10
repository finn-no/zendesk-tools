module ZendeskTools
  class RecoverSuspended < Command
    include Loggable

    RECOVER_CAUSES = [
      "Detected email as being from a system user",
      "Detected as mail loop",
      "Automated response mail"
    ]

    def run
      @client.suspended_tickets.each do |suspended_ticket|
        if should_recover?(suspended_ticket)
          log.info "Recovering: #{suspended_ticket.subject}"
          # Logic for recovering the tickets
          # Need to add logic for:
          # * Grab ticket_id
          # * Grab author_id
          # * Grab content (and check for attachment with own logic)
          # * Create new comment with the info from above
          # * delete/destroy the recovered ticket
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