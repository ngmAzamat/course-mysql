class MessagesController < ApplicationController
    def create
        Message.create(
          nickname: params[:nickname],
          content: params[:content],
          client_id: cookies[:client_id]
        )
        ActionCable.server.broadcast("chat", render_to_string(partial: "messages/message", locals: { message: @message }))
        redirect_to root_path
      end
  end