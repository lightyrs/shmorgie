worker: bundle exec sidekiq
redis: leader --unless-port-in-use 6379 redis-server $REDIS_CONF_PATH
web: bundle exec puma -p $PORT
