class RedditToTumblrPoster
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    api_stat = ApiStat.find_by(api: "Tumblr")

    unless api_stat.todays_post_limit_reached?
      reddit_reposter = Tumblr::RedditReposter.new
      reddit_reposter.auto_repost!
    end
  end
end
