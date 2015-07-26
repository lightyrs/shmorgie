class ReceiversController < ApplicationController

  def github
    @repo  = params[:repo]
    @event = params[:event]
  end
end
