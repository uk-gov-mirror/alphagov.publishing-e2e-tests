require "sinatra"
require "sinatra/json"
require "nokogiri"
require "yaml"
require_relative "lib/event"

ERROR_LOG = ENV.fetch("ERROR_LOG", "/app/tmp/errors.log")
VERBOSE_ERROR_LOG = ENV.fetch("ERROR_LOG", "/app/tmp/errors-verbose.log")

get "/" do
  json greeting: "Hello, this is a quick lo-fi alternative to sentry for logging errors to a file."
end

post "/api/:project_id/store/" do
  event = Event.new(request.body.read.to_s)
  handle_event(event)

  # Respond with what airbrake is expecting
  status 201
  json id: 1, url: ""
end

def handle_event(event)
  log_errors(event.errors)
  write_to_log(event)
  write_to_verbose_log(event)
end

def log_errors(errors)
  errors.each do |e|
    logger.info("#{e[:type]} #{abridged_message(e[:message])}")
  end
end

def abridged_message(message)
  (message || "")[0...150]
end

def write_to_log(event)
  abridged_event = {
    timestamp: event.timestamp,
    errors: event.errors.map { |e| e.merge(message: abridged_message(e[:message])) },
    context: event.context,
    }
  File.open(ERROR_LOG, "a") { |f| f << abridged_event.to_yaml }
end

def write_to_verbose_log(event)
  File.open(VERBOSE_ERROR_LOG, "a") { |f| f << event.dump }
end
