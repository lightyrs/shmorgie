module Receivers
  class GithubReceiver

    def initialize(options = {})
      @owner = options[:owner]
      @repo  = options[:repo ]
      @event = options[:event]
    end

    def process_inbound_message(payload)
      branch  = payload['ref'].split("refs/heads/").last
      commits = payload['commits'].sort_by { |commit| DateTime.parse(commit['timestamp']) }

      commits.each do |commit_object|
        Commit.find_or_create_by(sha: commit_object['id']) do |commit_model|
          commit_model.user         = @owner
          commit_model.repo         = @repo
          commit_model.branch       = branch
          commit_model.author       = commit_object.fetch('author', {})['name']
          commit_model.author_email = commit_object.fetch('author', {})['email']
          commit_model.message      = commit_object['message']
          commit_model.url          = commit_object['url']
        end
      end
    end
  end
end
