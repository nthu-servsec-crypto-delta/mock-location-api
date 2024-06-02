# frozen_string_literal: true

require 'sequel'
require 'json'

module ChitChat
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_postits, class: :'ChitChat::Postit', key: :owner_id
    one_to_many :owned_events, class: :'ChitChat::Event', key: :organizer_id
    many_to_many  :co_organized_events,
                  class: :'ChitChat::Event',
                  join_table: :accounts_events,
                  left_key: :co_organizer_id, right_key: :event_id
    many_to_many  :participated_events,
                  class: :'ChitChat::Event',
                  join_table: :participations,
                  left_key: :account_id, right_key: :event_id
    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:
          }
        }, options
      )
    end

    def password=(new_password)
      self.password_digest = PasswordDigest.digest(new_password)
    end

    def password?(input)
      PasswordDigest.from_digest(password_digest).correct?(input)
    end
  end
end
