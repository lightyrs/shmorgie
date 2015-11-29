class RedditToTumblrPoster
  include Sidekiq::Worker

  def perform
    api_stat = ApiStat.find_by(api: "Tumblr")

    unless api_stat.todays_post_limit_reached?
      reddit_client = Clients::RedditClient.new
      reddit_client.get_new_from_defaults
    end
  end
end
