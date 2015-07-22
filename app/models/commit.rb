class Commit < ActiveRecord::Base

  attr_accessible :sha, :user, :repo, :branch, :author,
                  :author_email, :message, :url

  after_commit :tweet, on: :create

  def tweet
    sleep 1
    twitter_client = Clients::TwitterClient.new
    puts tweet_text.inspect.red
    puts tweet_text.length.inspect.green
    twitter_client.tweet(tweet_text)
  end

  def tweet_text
    text = message.split(/\n/)[0].first(117) rescue message.first(117)
    "#{text}\n#{url}"
  end
end
