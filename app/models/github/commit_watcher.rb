class Github::CommitWatcher

  def all_commits_since(user_name, repo_name, options = {})
    options[:branch] ||= 'master'
    options[:since ] ||= 1.day.ago

    Octokit.commits("#{user_name}/#{repo_name}", options[:branch], since: options[:since].iso8601)
  end
end
