module ZendeskTools
  class CleanSuspended < Command
    include Loggable

    # Array with delete causes. Defined in config file
    DELETE_CAUSES = config['delete_causes']

    # Array with delete subjects. Defined in config file
    DELETE_SUBJECTS = config['delete_subjects']

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