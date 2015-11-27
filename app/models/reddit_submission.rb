class RedditSubmission < ActiveRecord::Base

  attr_accessible :fullname, :submitted_at_utc, :reposted_at

  validates :fullname, presence: true, uniqueness: true
end
