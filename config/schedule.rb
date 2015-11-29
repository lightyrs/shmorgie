set :output, { error: 'log/cron.stderr.log', standard: 'log/cron.stdout.log' }

every 1.day, :at => '12:05 am' do
  runner 'ApiStatResetter.perform_async'
end

every 1.minute do
  runner 'GithubCommitLogger.perform_async'
end

every '4,14,24,34,44,54 * * * *' do
  runner 'RedditToTumblrPoster.perform_async'
end
