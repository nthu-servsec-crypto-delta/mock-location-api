# frozen_string_literal: true

require_relative '../spec_common'

describe 'Test Participation Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]
    @another_account_data = DATA[:accounts][1]
    @wrong_account_data = DATA[:accounts][2]

    @account = ChitChat::Account.create(@account_data)
    @another_account = ChitChat::Account.create(@another_account_data)
    @wrong_account = ChitChat::Account.create(@wrong_account_data)

    ChitChat::CreateEventForOrganizer.call(
      organizer_id: @account.id,
      event_data: DATA[:events][0]
    )
    @event = ChitChat::Event.find(name: DATA[:events][0]['name'])

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Adding applicants to a event' do
    it 'HAPPY: should approve a application into a participant' do
      ChitChat::AddApplicant.call(
        event: @event,
        account: @another_account
      )
      header 'AUTHORIZATION', auth_header(@account_data)

      req_data = { email: @another_account.email }

      put "api/v1/events/#{@event.id}/participants", req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @another_account.username
    end

    it 'SAD: should not approve a application without authorization ' do
      header 'AUTHORIZATION', auth_header(@account_data)

      req_data = { email: @account.email }

      put "api/v1/events/#{@event.id}/participants", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'SAD: other roles should not be participants' do
      @account.add_owned_event(@event)
      @event.add_co_organizer(@another_account)

      header 'AUTHORIZATION', auth_header(@account_data)

      req_data = { email: @another_account.email }

      put "api/v1/events/#{@event.id}/participants", req_data.to_json

      _(last_response.status).must_equal 403
    end
  end
end
