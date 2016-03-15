worker: bundle exec sidekiq -c 5
redis: leader --unless-port-in-use 6379 redis-server $REDIS_CONF_PATH
web: bundle exec puma -p $PORT
