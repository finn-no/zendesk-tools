module ZendeskTools
  class CleanSuspended < Command
    include Loggable


    # Array with delete subjects. Defined in config file

    def initialize(*args)
      super

      @delete_causes = ZendeskTools.config['delete_causes'] || [
        "Detected email as being from a system user",
        "Detected as mail loop",
        "Automated response mail"
      ]

      @delete_subjects = ZendeskTools.config['delete_subjects'] || [
        "Returned mail: see transcript",
        "Delivery Status Notification (Failure)",
        "Undeliverable:",
        "Kan ikke leveres:",
        "Automatisk svar"
      ]
    end

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

      @delete_causes.any? { |delete_cause| cause.include?(delete_cause) } ||
        @delete_subjects.any? { |delete_subject|  subject.include?(delete_subject) }
    end
  end
end
