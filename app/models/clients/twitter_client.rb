module Clients
  class TwitterClient

    def initialize
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter_consumer_key
        config.consumer_secret     = Rails.application.secrets.twitter_consumer_secret
        config.access_token        = Rails.application.secrets.rorl_twitter_key
        config.access_token_secret = Rails.application.secrets.rorl_twitter_secret
      end
    end

    def tweet(text)
      @client.update("#{text}")
    end
  end
end
