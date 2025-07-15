class MessagesController < ApplicationController
    def create
        Message.create(
          nickname: params[:nickname],
          content: params[:content],
          client_id: cookies[:client_id]
        )
        redirect_to root_path
      end
  end