module Clients
  class TumblrClient

    attr_reader :client

    def initialize(blog = nil)
      @client = Tumblr::Client.new(:client => :httpclient)
      @blog = blog || Rails.application.secrets.tumblr_blog
    end

    def make_video_post(url:, caption:, tags:)
      @client.video(@blog, { embed: url, caption: caption, tags: tags.join(',') })
    end

    def make_audio_post(url:, caption:, tags:)
      @client.audio(@blog, { external_url: url, caption: caption, tags: tags.join(',') })
    end

    def make_photo_post(url:, image_url:, caption:, tags:)
      @client.photo(@blog, { link: url, source: image_url, caption: caption, tags: tags.join(',') })
    end

    def make_link_post(title:, url:, description:, thumbnail:, excerpt:, author:, tags:)
      @client.link(@blog, { title: title, url: url, description: description, thumbnail: thumbnail, excerpt: excerpt, author: author, tags: tags.join(',') })
    end

    def make_text_post(title:, body:)
      @client.text(@blog, { title: title, body: body, tags: tags.join(',') })
    end
  end
end
