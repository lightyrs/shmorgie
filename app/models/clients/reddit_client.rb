module Clients
  class RedditClient

    def initialize
      @client = Redd.it :userless,
                        Rails.application.config.reddit_client_id,
                        Rails.application.config.reddit_client_secret
    end

    # @option params [String] :after Return results after the given
    #   fullname.
    # @option params [String :before Return results before the given
    #   fullname.
    # @option params [Integer] :count (0) The number of items already seen
    #   in the listing.
    # @option params [1..100] :limit (25) The maximum number of things to
    #   return.
    # @option params [:hour, :day, :week, :month, :year, :all] :t The
    #   time period to consider when sorting.

    def new_links(options = {})
    end

    def hot_links(options = {})
    end

    def top_links(options = {})
    end
  end
end
