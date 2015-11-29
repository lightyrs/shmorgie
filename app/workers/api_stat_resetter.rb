class ApiStatResetter
  include Sidekiq::Worker

  def perform
    tumblr_api_stat = ApiStat.find_by(api: "Tumblr")
    tumblr_api_stat.todays_post_count = 0
    tumblr_api_stat.save!
  end
end
