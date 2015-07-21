set :output, { error: 'log/cron.stderr.log', standard: 'log/cron.stdout.log' }

every 1.minute do
  runner 'GithubCommitLogger.perform_async'
end
