# frozen_string_literal: true
module ChitChat
  # determine if an account
  class AccountPolicy
    def initialize(requestor, account)
      @requestor = requestor
      @this_account = account
    end

    def can_view?
      self_request?
    end

    def can_edit?
      self_request?
    end

    def can_delete?
      self_request?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def self_request?
      @requestor == @this_account
    end
  end
end