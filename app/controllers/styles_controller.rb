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
    erb :'styles/new'
  end

  post '/styles' do
    @style = Style.create(style_name: params[:style_name], size: params[:size], user_id: session[:user_id])

    redirect '/styles'


  end

end
