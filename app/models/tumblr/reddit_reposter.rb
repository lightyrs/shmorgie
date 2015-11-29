require 'descriptive_statistics'

class Tumblr::RedditReposter

  def initialize
    @reddit_client = Clients::RedditClient.new
    @tumblr_client = Clients::TumblrClient.new
    @posted_count  = 0
  end

  def auto_repost!
    new_submissions.flatten!.shuffle.each do |submission|
      begin
        if postable?(submission) && post_submission_to_tumblr(submission)
          @tumblr_client.increment_todays_post_count!
          @posted_count += 1
        end
      rescue StandardError => e
        puts "#{e.class}: #{e.message}".inspect.red
      end
    end
  end

  def subreddits
    truemusic   = @reddit_client.subreddits_from_multi('evilnight', 'truemusic')
    thefirehose = @reddit_client.subreddits_from_multi('evilnight', 'thefirehose')
    truemusic.concat(thefirehose).push('frisson').uniq
  end

  private

  def new_submissions
    subreddits.map do |sub|
      @reddit_client.new_submissions(sub).tap { |submissions| sleep 3 }
    end
  end

  def score_threshold(submissions)
    @threshold ||= submissions.map { |submission| submission[:score] }.compact.percentile(95)
  end

  def postable?(submission)
    @posted_count < 5 &&
    (submission[:media].present? || submission[:is_image_post]) &&
    submission[:score] >= score_threshold
  end

  def post_submission_to_tumblr(submission)
    return false if RedditSubmission.exists?(fullname: submission[:fullname])

    if submission[:post_type] == "rich:video"
      post_video_submission_to_tumblr(submission)
    elsif submission[:post_type] == "link"
      post_audio_submission_to_tumblr(submission)
    elsif submission[:post_type] == "link" && submission[:is_image_post]
      post_photo_submission_to_tumblr(submission)
    else
      return false
    end

    RedditSubmission.create(
      fullname: submission[:fullname],
      submitted_at_utc: submission[:submitted_at_utc],
      reposted_at: Time.now
    )
  end

  def post_video_submission_to_tumblr(submission)
    @tumblr_client.make_video_post(
      url: submission[:url],
      caption: submission[:attribution],
      tags: submission[:tags]
    )
  end

  def post_audio_submission_to_tumblr(submission)
    @tumblr_client.make_audio_post(
      url: submission[:url],
      caption: submission[:attribution],
      tags: submission[:tags]
    )
  end

  def post_photo_submission_to_tumblr(submission)
    @tumblr_client.make_photo_post(
      url: submission[:url],
      image_url: submission[:url],
      caption: submission[:attribution],
      tags: submission[:tags]
    )
  end
end
