module Clients
  class RedditClient

    def initialize
      @client = Redd.it :userless,
                        Rails.application.config.reddit_client_id,
                        Rails.application.config.reddit_client_secret
    end
  end
end
