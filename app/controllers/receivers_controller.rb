class ReceiversController < ApplicationController

  skip_before_filter :verify_authenticity_token
       before_filter :verify_github_signature

  def github
    @receiver = Receivers::GithubReceiver.new(
      owner: params[:owner],
      repo:  params[:repo ],
      event: params[:event]
    )

    @receiver.process_inbound_message(@payload)

    head :ok
  end

  private

  def verify_github_signature
    request.body.rewind

    signature = "sha1=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), Rails.application.secrets.secret_key_base, request.body.read)}"

    if Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'].to_s)
      @payload = JSON.parse(params[:payload])
    else
      return head :unauthorized
    end
  end
end
