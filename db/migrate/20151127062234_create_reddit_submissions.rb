class CreateRedditSubmissions < ActiveRecord::Migration
  def change
    create_table :reddit_submissions do |t|
      t.text     :fullname
      t.datetime :submitted_at_utc
      t.datetime :reposted_at
      t.timestamps
    end
    add_index :reddit_submissions, :fullname, :unique => true
  end
end
