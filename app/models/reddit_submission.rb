class RedditSubmission < ActiveRecord::Base

  attr_accessible :fullname, :submitted_at_utc

  validates :fullname, presence: true, uniqueness: true
end
