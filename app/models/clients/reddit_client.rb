module Clients
  class RedditClient

    attr_reader :client

    def initialize
      @client = Redd.it(:userless, Rails.application.secrets.reddit_client_id, Rails.application.secrets.reddit_client_secret)
      @client.authorize!
    end

    def multireddit(username, name)
      @client.multi_from_path("/user/#{username}/m/#{name}/")
    end

    def subreddits_from_multi(username, name)
      multireddit(username, name).try(:subreddits)
    end

    def default_subreddits
      subreddits_from_multi('evilnight', 'truemusic')
    end

    def get_hot_from_defaults
      unsorted = default_subreddits.map do |sub|
        hot_links(sub).tap do |hot|
          sleep 3
        end
      end
      unsorted.flatten.sort_by { |link| link[:score] }.reverse!
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

    def new_links(subreddit = 'all', options = {})
      options.merge!(limit: 100)
      links = @client.get_new(subreddit, options)
      links.map { |link| format_link(link) }
    end

    def hot_links(subreddit = 'all', options = {})
      options.merge!(limit: 100)
      links = @client.get_hot(subreddit, options)
      links.map { |link| format_link(link) }
    end

    def top_links(subreddit = 'all', options = {})
      options.merge!(limit: 100)
      links = @client.get_top(subreddit, options)
      links.map { |link| format_link(link) }
    end

    private

    def format_link(link)
      {
        score: link.score.try(:to_i),
        title: link.title,
        tags: [map_domain(link.try(:domain)), link.subreddit],
        url: link.try(:url),
        attribution: "https://www.reddit.com/user/#{link.author} posted this to https://www.reddit.com#{link.permalink} at #{Time.at(link.created_utc).utc}",
        post_type: link.try(:post_hint)
      }
    end

    def map_domain(domain = "")
      return nil unless domain.present?
      case
      when domain.match(/youtube\.com|youtu\.be/i)
        "YouTube"
      when domain.match(/soundcloud/i)
        "SoundCloud"
      when domain.match(/vimeo/i)
        "Vimeo"
      when domain.match(/facebook/i)
        "Facebook"
      when domain.match(/\Aself\./i)
        "Reddit"
      when domain.match(/spotify/i)
        "Spotify"
      when domain.match(/bandcamp/i)
        "Bandcamp"
      when domain.match(/mixcloud/i)
        "Mixcloud"
      else
        domain
      end
    end
  end
end
