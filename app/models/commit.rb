class Commit < ActiveRecord::Base

  attr_accessible :sha, :user, :repo, :branch, :author,
                  :author_email, :message, :url
end
