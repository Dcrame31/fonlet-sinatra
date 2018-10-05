class StylesController < ApplicationController

  get '/styles' do
    @style = Style.all
    if logged_in?
      erb :'styles/styles'
    else
      redirect '/users/login'
    end
  end

end
