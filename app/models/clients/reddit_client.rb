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

    def new_submissions(subreddit = 'all', options = {})
      Rails.logger.debug(subreddit)
      puts subreddit.inspect.blue
      submissions = @client.get_new(subreddit, options)
      submissions.map { |submission| format_submission(submission) }
    rescue Redd::Error::PermissionDenied => e
      Rails.logger.debug "Rescued #{e.class}: #{e.message}"
      []
    end

    def hot_submissions(subreddit = 'all', options = {})
      submissions = @client.get_hot(subreddit, options)
      submissions.map { |submission| format_submission(submission) }
    end

    def top_submissions(subreddit = 'all', options = {})
      { t: :hour }.merge!(options)
      submissions = @client.get_top(subreddit, options)
      submissions.map { |submission| format_submission(submission) }
    end

    private

    def format_submission(submission)
      {
        fullname: submission.try(:name),
        subreddit: submission.subreddit,
        media: submission.try(:media),
        is_image_post: submission.title.match(/\[image\]/i),
        score: submission.score.try(:to_f),
        title: submission.title,
        tags: [map_domain(submission.try(:domain)).try(:downcase), submission.subreddit, "reddit"].compact,
        url: submission.try(:url),
        attribution: composed_attribution(submission),
        post_type: submission.try(:post_hint),
        submitted_at_utc: Time.at(submission.created_utc).utc,
        caption: composed_caption(submission)
      }
    end

    def composed_attribution(submission)
      "<a target='_blank' href='https://www.reddit.com/user/#{submission.author}'>#{submission.author}</a> posted this to <a target='_blank' href='https://www.reddit.com#{submission.permalink}'>r/#{submission.subreddit}</a> at #{Time.at(submission.created_utc).utc}"
    end

    def composed_caption(submission)
      "<h1 class='hn-caption-title'>#{submission.title}&nbsp;</h1><span class='hn-caption-attribution'>#{composed_attribution(submission)}</span>"
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
