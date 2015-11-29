class ApiStat < ActiveRecord::Base

  attr_accessible :todays_post_count, :todays_post_limit

  validates :api, presence: true, uniqueness: true

  def self.seed
    create(api: "Tumblr", todays_post_limit: 250)
  end

  def todays_post_limit_reached?
    todays_post_count >= todays_post_limit
  end
end
