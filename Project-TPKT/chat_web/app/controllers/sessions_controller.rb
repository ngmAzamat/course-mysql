class SessionsController < ApplicationController
    def create
      auth = request.env['omniauth.auth']
      session[:user_info] = auth['info']
      redirect_to root_path, notice: "Добро пожаловать, #{auth['info']['email']}!"
    end
  
    def failure
      redirect_to root_path, alert: "Ошибка авторизации."
    end
  
    def destroy
      session.delete(:user_info)
      redirect_to root_path, notice: "Вы вышли из системы."
    end
end