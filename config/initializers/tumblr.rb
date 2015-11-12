Tumblr.configure do |config|
  config.consumer_key = Rails.application.secrets.tumblr_consumer_key
  config.consumer_secret = Rails.application.secrets.tumblr_consumer_secret
  config.oauth_token = Rails.application.secrets.tumblr_oauth_token
  config.oauth_token_secret = Rails.application.secrets.tumblr_oauth_token_secret
end
