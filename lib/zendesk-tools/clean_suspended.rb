module ZendeskTools
  class CleanSuspended < Command
    include Loggable

    DELETE_CAUSES = [
      "Detected email as being from a system user",
      "Detected as mail loop",
      "Automated response mail"
    ]

    DELETE_SUBJECTS = [
      "Returned mail: see transcript",
      "Delivery Status Notification (Failure)",
      "Undeliverable:",
      "Kan ikke leveres:",
      "Automatisk svar"
    ]

    def run
      @client.suspended_tickets.each do |suspended_ticket|
        if should_delete?(suspended_ticket)
          log.info "Deleting: #{suspended_ticket.subject}"
          suspended_ticket.destroy
        else
          log.info "Keeping: #{suspended_ticket.subject}"
        end
      end
    end

    private

    def should_delete?(suspended_ticket)
      cause   = suspended_ticket.cause
      subject = suspended_ticket.subject

      DELETE_CAUSES.any? { |delete_cause| cause.include?(delete_cause) } ||
        DELETE_SUBJECTS.any? { |delete_subject|  subject.include?(delete_subject) }
    end
  end
end