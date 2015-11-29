class CreateApiStats < ActiveRecord::Migration
  def change
    create_table :api_stats do |t|
      t.text     :api, null: false
      t.integer  :todays_post_count
      t.timestamps
    end
    add_index :api_stats, :api, :unique => true
  end
end
