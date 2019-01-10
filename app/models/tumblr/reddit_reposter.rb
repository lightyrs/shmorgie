require 'descriptive_statistics'
require 'ap'

class Tumblr::RedditReposter

  def initialize
    @reddit_client = Clients::RedditClient.new
    @tumblr_client = Clients::TumblrClient.new
    @posted_count  = 0
  end

  def auto_repost!
    @submissions = new_submissions.flatten!

    normalize_scores
    ap @normalized_scores
    calculate_score_threshold
    ap @threshold

    @posts = @submissions.select do |submission|
      begin
        postable?(submission)
      rescue StandardError => e
        puts "#{e.class}: #{e.message}".inspect.red
      end
    end
    ap @posts.count

    calculate_post_stats

    sub_counts = @post_stats[:subreddits].map{|k,v| v}
    min = sub_counts.min
    max = sub_counts.max
    revised_counts = sub_counts.map do |sc|
      normalize_value(sc, min, max, 1, 5).round
    end

    revised_posts = []

    puts @post_stats.inspect
    puts revised_counts.inspect

    @post_stats[:subreddits].each.with_index do |(k,v), i|
      posts = @posts.select { |post|
        post[:subreddit] == k
      }.sort_by { |post|
        post[:score]
      }.reverse.first(revised_counts[i])
      revised_posts.push(posts)
    end

    @posts = revised_posts.flatten.sort_by { |post| post[:normalized_score] }.reverse

    ap @posts

    @posts.each do |post|
      begin
        if post_submission_to_tumblr(post)
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

  def calculate_post_stats
    @post_stats ||= {
      subreddits: post_subreddits,
      hosts: post_hosts,
      types: post_reddit_types,
      scores: @normalized_scores
    }
  end

  def post_subreddits
    @posts.map{ |p| p[:subreddit] }.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }.sort_by{ |item| item[1] }.reverse
  end

  def post_hosts
    @posts.map { |post| URI.parse(post[:url]).host }.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }.sort_by{ |item| item[1] }.reverse
  end

  def post_reddit_types
    @posts.map { |post| post[:post_type] }.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }.sort_by{ |item| item[1] }.reverse
  end

  private

  def subreddit_weights
    h = Hash.new(1.0)
    h['metalcore'] = 0.4
    h['posthardcore'] = 0.45
    h['progmetal'] = 0.6
    h['mathrock'] = 0.75
    h['jazz'] = 0.95
    h['futurebeats'] = 1.1
    h['outrun'] = 1.15
    h['truemusic'] = 1.2
    h['listentothis'] = 1.2
    h['frisson'] = 1.2
    h['hiphopheads'] = 2.0
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

  def calculate_score_threshold
    @threshold ||= @normalized_scores.percentile(95)
  end

  def normalize_scores
    scores = @submissions.map { |submission| submission[:score].try(:to_f) }

    @score_stats = DescriptiveStatistics::Stats.new(scores)
    min = @score_stats.min
    max = @score_stats.max
    @submissions.each do |submission|
      submission[:normalized_score] = normalize_value(submission[:score].try(:to_f), min, max, 1, 100)
    end

    @normalized_scores = scores.map do |score|
      normalize_value(score, min, max, 1, 100)
    end
  end

  def normalize_value(x, xmin, xmax, ymin, ymax)
    xrange = xmax - xmin
    yrange = ymax - ymin
    ymin + (x - xmin) * (yrange.to_f / xrange)
  end

  def postable?(submission)
    @posted_count < 10 &&
    (submission[:media].present? || submission[:is_image_post]) &&
    submission[:normalized_score].try(:to_f) >= @threshold
  end

  def post_submission_to_tumblr(submission)
    return false if RedditSubmission.exists?(fullname: submission[:fullname]) || @posted_count >= 10

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
