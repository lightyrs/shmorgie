module Receivers
  class GithubReceiver

    def initialize(options = {})
      @owner = options[:owner]
      @repo  = options[:repo ]
      @event = options[:event]
    end

    def process_inbound_message(payload)
      Rails.logger.debug(payload)
    end
  end
end
