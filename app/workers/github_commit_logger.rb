class GithubCommitLogger
  include Sidekiq::Worker

  def perform
    commit_watcher = Github::CommitWatcher.new(
      user:   'rails',
      repo:   'rails',
      branch: 'master'
    )

    commit_watcher.log_most_recent_commits
  end
end
