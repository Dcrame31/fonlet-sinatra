class UsersController < ApplicationController

  get '/signup' do
    if logged_in?
      redirect '/styles'
    else
      erb :'users/signup'
    end
  end

  post '/signup' do
    if params[:username].empty? || params[:email].empty? || params[:password].empty?
      flash[:error] = "Signup fields cannot be blank."
      redirect '/signup'
    elsif @user = User.find_by(username: params[:username])
      # @user.username.eql?(params[:username])
      flash[:error] = "Username already exists."
      redirect '/signup'
    elsif params[:password] != params[:confirmation]
      flash[:error] = "Passwords must match."
      redirect '/signup'
    else
      @user = User.create(username: params[:username], email: params[:email], password: params[:password])
      session[:user_id] = @user.id
      flash[:success] = "New user created successfully."
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
    flash[:success] = "Successfully logged out."
    redirect '/login'
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/styles'
    else
      flash[:error] = "Incorrect username and/or password."
      redirect '/login'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :"users/show"
  end

end
