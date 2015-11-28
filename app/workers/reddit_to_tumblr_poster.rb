class RedditToTumblrPoster
  include Sidekiq::Worker

  def perform
    reddit_client = Clients::RedditClient.new
    reddit_client.get_new_from_defaults
  end
end
