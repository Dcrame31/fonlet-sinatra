class StylesController < ApplicationController
  get '/styles' do
    erb :'styles/styles'
  end

end
