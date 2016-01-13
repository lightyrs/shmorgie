class AddSubredditToRedditSubmissions < ActiveRecord::Migration
  def change
    add_column :reddit_submissions, :subreddit, :text
  end
end
