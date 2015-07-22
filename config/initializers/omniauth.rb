Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.secrets.omniauth_provider_key, Rails.application.secrets.omniauth_provider_secret
  provider :twitter, Rails.application.secrets.twitter_consumer_key, Rails.application.secrets.twitter_consumer_secret
end
