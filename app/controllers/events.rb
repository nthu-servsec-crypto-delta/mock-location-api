# frozen_string_literal: true

require 'roda'
require 'json'
require_relative 'app'

module ChitChat
  # Main App
  class Api < Roda
    route('events') do |routing|
      # GET api/v1/events/[id]
      routing.get String do |event_id|
        response.status = 200
        event = Event.first(id: event_id)
        event ? event.to_json : raise('Event not found')
      rescue StandardError => e
        routing.halt 404, { message: e.message }
      end

      # GET api/v1/events
      routing.get do
        response.status = 200
        { event_ids: Event.all.map(&:id) }
      end

      # POST api/v1/events
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_event = Event.create(new_data)

        if new_event
          response.status = 201
          { message: 'Event created', id: new_event.id }
        else
          routing.halt 400, { message: 'Could not create event' }
        end
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT(Events): #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }
      rescue StandardError => e
        Api.logging.error "UNKNOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown error' }
      end
    end
  end
end