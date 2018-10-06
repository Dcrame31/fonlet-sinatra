class StylesController < ApplicationController

  get '/styles' do
    @style = Style.all
    if logged_in?
      erb :'styles/styles'
    else
      redirect '/login'
    end
  end

  get '/styles/new' do
    if logged_in?
      erb :'styles/new'
    else
      redirect '/login'
    end
  end

  post '/styles' do
    if params[:style_name] == "" || params[:size] == ""
      redirect '/styles/new'
    else
      @style = Style.create(style_name: params[:style_name], size: params[:size], user_id: session[:user_id])
      # binding.pry
    end
      redirect '/styles'
  end

  # get '/styles/:id' do
  #   @style = Style.find_by_id(params[:id])
  #   erb :'styles/styles'
  # end

end
