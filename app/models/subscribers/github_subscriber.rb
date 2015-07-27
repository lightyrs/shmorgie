module Subscribers
  class GithubSubscriber

    def initialize(options = {})
      @owner = options[:owner]
      @repo  = options[:repo ]
      @event = options[:event]
    end

    def subscribe!
      client.subscribe(subscribe_url, callback_url, Rails.application.secrets.secret_key_base)
    end

    def unsubscribe!
      client.unsubscribe(subscribe_url, callback_url)
    end

    private

    def subscribe_url
      "https://github.com/#{@owner}/#{@repo}/events/#{@event}"
    end

    def callback_url
      "#{Rails.application.secrets.base_url}/receivers/github/#{@owner}/#{@repo}/#{@event}"
    end

    def client
      @client ||= Octokit::Client.new(access_token: Rails.application.secrets.github_token)
    end
  end
end
