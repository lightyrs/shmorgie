class ApiStat < ActiveRecord::Base

  attr_accessible :todays_post_count

  validates :api, presence: true, uniqueness: true

  def self.seed
    create(api: "Tumblr")
  end
end
