# frozen_string_literal: true

module ChitChat
  # Create new configuration for a project
  class AddApplicant
    # Error for owner cannot be co-organizer
    class ForbiddenError < StandardError
      def message
        'You are not allowed to apply for this event'
      end
    end

    def self.call(account:, event:)
      policy = ApplicantRequestPolicy.new(event, account)

      raise ForbiddenError unless policy.can_apply?

      Participation.create(account_id: account.id, event_id: event.id, approved: false)

      account
    end
  end
end