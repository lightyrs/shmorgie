class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.text     :sha
      t.text     :user
      t.text     :repo
      t.text     :branch
      t.text     :author
      t.text     :author_email
      t.text     :message
      t.text     :url
      t.timestamps
    end
  end
end
