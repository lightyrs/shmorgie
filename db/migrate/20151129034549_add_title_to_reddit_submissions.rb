class AddTitleToRedditSubmissions < ActiveRecord::Migration
  def change
    add_column :reddit_submissions, :title, :text
  end
end
