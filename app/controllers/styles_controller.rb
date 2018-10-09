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
    if params[:style_name].empty? || params[:size].empty?
      flash[:error] = "Style name and/or size cannot be blank."
      redirect '/styles/new'
    else
      @style = Style.create(style_name: params[:style_name], size: params[:size], user_id: session[:user_id])
    end
      flash[:success] = "New style created successfully."
      redirect "/users/#{current_user.slug}"
  end

  get '/styles/:id' do
    if logged_in?
      @style = Style.find_by_id(params[:id])
      erb :'styles/show_style'
    else
      redirect '/login'
    end
  end

  get '/styles/:id/edit' do
    if logged_in?
      @style = Style.find_by_id(params[:id])

      if @style.user == current_user
        erb :'styles/edit_style'
      else
        flash[:error] = "You cannot edit another retailer's inventory."
        redirect "/styles/#{@style.id}"
      end

    else
      redirect '/login'
    end
  end

  patch '/styles/:id' do
    @style = Style.find_by_id(params[:id])
    if params[:style_name].empty? || params[:size].empty?
      flash[:error] = "Style name and/or size cannot be blank."
      redirect "/styles/#{@style.id}/edit"
    else
      @style.update(style_name: params[:style_name], size: params[:size])
      flash[:success] = "Style updated successfully."
      redirect "/users/#{current_user.slug}"
    end
  end

  delete '/styles/:id/delete' do
    if logged_in?
      @style = Style.find_by_id(params[:id])

      if @style.user == current_user
        @style.delete
        flash[:success] = "Style deleted successfully."
        redirect '/styles'
      else
        flash[:error] = "You cannot delete another retailer's inventory."
        redirect "/styles/#{@style.id}"
      end

    else
      redirect '/login'
    end
  end

end
