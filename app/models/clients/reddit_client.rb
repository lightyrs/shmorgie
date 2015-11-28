require 'descriptive_statistics'

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
      subreddits_from_multi('evilnight', 'truemusic').push('frisson')
    end

    def get_new_from_defaults
      links = default_subreddits.map do |sub|
        new_links(sub).tap do |hot|
          sleep 3
        end
      end

      links.flatten!

      scores = links.map { |link| link[:score] }.compact
      threshold = scores.percentile(95)

      puts threshold.inspect.red

      links.each do |link|
        begin
          if (link[:media].present? || link[:is_image_post]) && link[:score] >= threshold
            post_link_to_tumblr(link)
          end
        rescue StandardError => e
          puts "#{e.class}: #{e.message}".inspect.red
        end
      end
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
      options = { t: :hour }.merge(options)
      if most_recent_submission
        options.merge!(after: most_recent_submission.try(:fullname))
      end
      links = @client.get_new(subreddit, options)
      links.map { |link| format_link(link) }
    end

    def hot_links(subreddit = 'all', options = {})
      { t: :hour }.merge!(options)
      links = @client.get_hot(subreddit, options)
      links.map { |link| format_link(link) }
    end

    def top_links(subreddit = 'all', options = {})
      { t: :hour }.merge!(options)
      links = @client.get_top(subreddit, options)
      links.map { |link| format_link(link) }
    end

    private

    def most_recent_submission
      @most_recent_submission ||= RedditSubmission.order("submitted_at_utc DESC").limit(1).take
    end

    def post_link_to_tumblr(link)
      @tumblr_client ||= Clients::TumblrClient.new
      if link[:post_type] == "rich:video"
        @tumblr_client.make_video_post(url: link[:url], caption: link[:attribution], tags: link[:tags])
      elsif link[:post_type] == "link"
        if link[:is_image_post]
          @tumblr_client.make_photo_post(url: link[:url], image_url: link[:url], caption: link[:attribution], tags: link[:tags])
        else
          @tumblr_client.make_audio_post(url: link[:url], caption: link[:attribution], tags: link[:tags])
        end
      else
        return
      end
      RedditSubmission.create(fullname: link[:fullname], submitted_at_utc: link[:submitted_at_utc], reposted_at: Time.now)
    end

    def format_link(link)
      {
        fullname: link.try(:name),
        subreddit: link.subreddit,
        media: link.try(:media),
        is_image_post: link.title.match(/\[image\]/i),
        score: link.score.try(:to_f),
        title: link.title,
        tags: [map_domain(link.try(:domain)).try(:downcase), link.subreddit].compact,
        url: link.try(:url),
        attribution: "<a target='_blank' href='https://www.reddit.com/user/#{link.author}'>#{link.author}</a> posted this to <a target='_blank' href='https://www.reddit.com#{link.permalink}'>r/#{link.subreddit}</a> at #{Time.at(link.created_utc).utc}",
        post_type: link.try(:post_hint),
        submitted_at_utc: Time.at(link.created_utc).utc
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
      when domain.match(/\Aself\.|reddit\.com/i)
        "Reddit"
      when domain.match(/spotify/i)
        "Spotify"
      when domain.match(/bandcamp/i)
        "Bandcamp"
      when domain.match(/mixcloud/i)
        "Mixcloud"
      when domain.match(/imgur/i)
        "Imgur"
      when domain.match(/wikipedia/i)
        "Wikipedia"
      when domain.match(/bbc\.com|bbc\.co\.uk/i)
        "BBC"
      when domain.match(/stereogum/i)
        "Stereogum"
      when domain.match(/pitchfork/i)
        "Pitchfork"
      when domain.match(/noisey\.vice\.com/i)
        "Noisey"
      when domain.match(/npr\.org/i)
        "NPR"
      when domain.match(/tumblr\.com/i)
        "Tumblr"
      when domain.match(/dailymotion\.com/i)
        "Dailymotion"
      when domain.match(/itunes\.apple\.com/i)
        "iTunes"
      when domain.match(/myspace\.com/i)
        "Myspace"
      when domain.match(/flickr\.com/i)
        "Flickr"
      when domain.match(/twitter\.com/i)
        "Twitter"
      else
        domain
      end
    end
  end
end
