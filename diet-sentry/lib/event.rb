class Event
  attr_reader :json, :timestamp

  def initialize(event_json)
    @json = JSON.parse(event_json.force_encoding("UTF-8"))
    @timestamp = Time.now
  end

  def errors
    json["errors"].map do |error|
      { type: error["type"], message: error["message"] }
    end
  end

  def context
    {
      environment: json["context"]["environment"],
      hostname: json["context"]["hostname"],
      url: json["context"]["url"],
      component: json["context"]["component"],
      action: json["context"]["action"],
    }
  end

  def dump
    "---\ntimestamp: #{timestamp.to_s}\n#{json.to_yaml}\n"
  end
end
