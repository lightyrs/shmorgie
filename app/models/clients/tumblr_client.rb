module Clients
  class TumblrClient

    def initialize
      @client = Tumblr::Client.new
    end
  end
end
