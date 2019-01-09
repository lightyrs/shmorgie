require 'descriptive_statistics'

class Tumblr::RedditReposter

  def initialize
    @reddit_client = Clients::RedditClient.new
    @tumblr_client = Clients::TumblrClient.new
    @posted_count  = 0
  end

  def auto_repost!
    submissions = new_submissions.flatten!.shuffle

    calculate_score_threshold(submissions)

    submissions.each do |submission|
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
    truemusic = @reddit_client.subreddits_from_multi('zippermouthface', 'truemusic')
    truemusic.push('Frisson').uniq
  end

  private

  def subreddit_weights
    h = Hash.new(1.0)
    h['metalcore'] = 0.4
    h['posthardcore'] = 0.5
    h['progmetal'] = 0.6
    h['mathrock'] = 0.8
    h['futurebeats'] = 1.1
    h['truemusic'] = 1.2
    h['listentothis'] = 1.2
    h['frisson'] = 1.2
    h['hiphopheads'] = 1.75
    h
  end

  def weighted_score(submission)
    subreddit = submission[:subreddit]
    submission[:score].try(:to_f) * subreddit_weights["#{subreddit.try(:downcase)}"]
  rescue StandardError => e
    submission[:score]
  end

  def new_submissions
    subreddits.map do |sub|
      @reddit_client.new_submissions(sub).tap do |submissions|
        sleep(rand(8))
      end
    end
  end

  def calculate_score_threshold(submissions)
    @threshold ||= submissions.map { |submission| weighted_score(submission) }.compact.percentile(95)
  end

  def postable?(submission)
    @posted_count < 10 &&
    (submission[:media].present? || submission[:is_image_post]) &&
    weighted_score(submission) >= @threshold
  end

  def post_submission_to_tumblr(submission)
    return false if RedditSubmission.exists?(fullname: submission[:fullname])

    if submission[:post_type] == "rich:video"
      res = post_video_submission_to_tumblr(submission)
    elsif submission[:post_type] == "link" && submission[:is_image_post]
      res = post_photo_submission_to_tumblr(submission)
    elsif submission[:post_type] == "link"
      res = post_audio_submission_to_tumblr(submission)
    else
      return false
    end

    if res && res['msg'] && res['msg'] == "Bad Request"
      return false
    else
      puts "Creating RedditSubmission #{submission.inspect}".green
      RedditSubmission.create(
        fullname: submission[:fullname],
        title: submission[:title],
        subreddit: submission[:subreddit],
        submitted_at_utc: submission[:submitted_at_utc],
        reposted_at: Time.now
      )
    end
  end

  def post_video_submission_to_tumblr(submission)
    @tumblr_client.make_video_post(
      url: submission[:url],
      caption: submission[:caption],
      tags: submission[:tags]
    )
  end

  def post_audio_submission_to_tumblr(submission)
    @tumblr_client.make_audio_post(
      url: submission[:url],
      caption: submission[:caption],
      tags: submission[:tags]
    )
  end

  def post_photo_submission_to_tumblr(submission)
    @tumblr_client.make_photo_post(
      url: submission[:url],
      image_url: submission[:url],
      caption: submission[:caption],
      tags: submission[:tags]
    )
  end
end
