class Github::CommitWatcher

  attr_accessor :user, :repo, :branch, :since

  def initialize(options = {})
    @user   = options[:user]
    @repo   = options[:repo]
    @branch = options[:branch] || 'master'
    @since  = options[:since ] || last_checked
  end

  def log_most_recent_commits
    all_commits_since.each do |commit_object|
      Commit.find_or_create_by(sha: commit_object.sha) do |commit_model|
        commit_model.user         = @user
        commit_model.repo         = @repo
        commit_model.branch       = @branch
        commit_model.author       = commit_object.commit.author.name
        commit_model.author_email = commit_object.commit.author.email
        commit_model.message      = commit_object.commit.message
        commit_model.url          = commit_object.html_url
      end
    end
  end

  def last_checked
    Commit.where(user: @user, repo: @repo, branch: @branch)
          .order('created_at DESC')
          .limit(1)
          .take
          .try(:created_at) || 10.minutes.ago
  end

  def all_commits_since
    commits = Octokit.commits("#{@user}/#{@repo}", @branch, since: @since.iso8601)
    commits.sort_by { |commit| commit.commit.author.date }
  end
end
