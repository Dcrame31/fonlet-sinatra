class UsersController < ApplicationController

  get '/signup' do
    if logged_in?
      redirect '/styles'
    else
      erb :'users/signup'
    end
  end

  post '/signup' do
    if params[:username] == "" || params[:email] == "" || params[:password] == ""
      redirect '/signup'
    else
      @user = User.create(username: params[:username], email: params[:email], password: params[:password])
      session[:user_id] = @user.id
      redirect '/styles'
    end
  end

  get '/login' do
    if logged_in?
      redirect '/styles'
    else
      erb :'users/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/styles'
    else
      redirect '/login'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end


end
