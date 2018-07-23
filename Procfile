worker: bundle exec sidekiq -c 5
redis: redis-server $REDIS_CONF_PATH
web: bundle exec puma -p $PORT
