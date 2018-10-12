require_relative "spec_helper"
require 'pry'

describe ApplicationController do

  describe "Signup Page" do
    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to styles index' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows",
        :confirmation => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include("/styles")
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
        :username => "skittles123",
        :email => "",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'creates a new user and logs them in on valid submission and does not let a logged in user view the signup page' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows",
        :confirmation => "rainbows"
      }
      post '/signup', params
      get '/signup'
      expect(last_response.location).to include('/styles')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the styles index after login' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Available Inventory")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/login'
      expect(last_response.location).to include("/styles")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/logout'
      expect(last_response.location).to include("/login")
    end

    it 'does not let a user logout if not logged in' do
      get '/logout'
      expect(last_response.location).to include("/")
    end

    it 'does not load /styles if user not logged in' do
      get '/styles'
      expect(last_response.location).to include("/login")
    end

    it 'does load /styles if user is logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")


      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'Submit'
      expect(page.current_path).to eq('/styles')
    end
  end

  describe 'user show page' do
    it 'shows all a single users styles' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      style1 = Style.create(:style_name => "Perfect T", :size => "M", :user_id => user.id)
      style2 = Style.create(:style_name => "Classic T", :size => "M", :user_id => user.id)
      get "/users/#{user.slug}"

      expect(last_response.body).to include("Perfect T")
      expect(last_response.body).to include("Classic T")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the styles index if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style1 = Style.create(:style_name => "Perfect T", :size => "M", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        style2 = Style.create(:style_name => "Classic T", :size => "L", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit "/styles"
        expect(page.body).to include(style1.style_name)
        expect(page.body).to include(style2.style_name)
      end
    end

    context 'logged out' do
      it 'does not let a user view the styles index if not logged in' do
        get '/styles'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets user view new style form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit '/styles/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a style if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'

        visit '/styles/new'
        fill_in(:style_name, :with => "leggings")
        fill_in(:size, :with => "TC2")
        click_button 'Submit'

        user = User.find_by(:username => "becky567")
        style = Style.find_by(:style_name => "leggings")
        expect(style).to be_instance_of(Style)
        expect(style.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user create style for another user' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'

        visit '/styles/new'

        fill_in(:style_name, :with => "leggings")
        fill_in(:size, :with => "TC2")
        click_button 'Submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        style = Style.find_by(:style_name => "leggings")
        expect(style).to be_instance_of(Style)
        expect(style.user_id).to eq(user.id)
        expect(style.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank style' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'

        visit '/styles/new'

        fill_in(:style_name, :with => "")
        fill_in(:size, :with => "")
        click_button 'Submit'

        expect(Style.find_by(:style_name => "")).to eq(nil)
        expect(Style.find_by(:size => "")).to eq(nil)
        expect(page.current_path).to eq("/styles/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new style form if not logged in' do
        get '/styles/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single style' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style = Style.create(:style_name => "unicorn", :size => "XXS", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'

        visit "/styles/#{style.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Sold/Delete")
        expect(page.body).to include(style.style_name)
        expect(page.body).to include(style.size)
        expect(page.body).to include("Edit")
      end
    end

    context 'logged out' do
      it 'does not let a user view a style' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style = Style.create(:style_name => "unicorn", :size => "XXS", :user_id => user.id)
        get "/styles/#{style.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view style edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style = Style.create(:style_name => "Perfect T", :size => "M", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit '/styles/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(style.style_name)
        expect(page.body).to include(style.size)
      end

      it 'does not let a user edit a style they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style1 = Style.create(:style_name => "Perfect T", :size => "M", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        style2 = Style.create(:style_name => "leggings", :size => "TC2", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit "/styles/#{style2.id}/edit"
        expect(page.current_path).to include('/styles')
      end

      it 'lets a user edit their own style if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style = Style.create(:style_name => "Perfect T", :size => "M", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit '/styles/1/edit'

        fill_in(:style_name, :with => "unicorn")

        click_button 'Submit'
        expect(Style.find_by(:style_name => "unicorn")).to be_instance_of(Style)
        expect(Style.find_by(:style_name => "Perfect T")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with a blank style name' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style = Style.create(:style_name => "Perfect T", :size => "M", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit '/styles/1/edit'

        fill_in(:style_name, :with => "")

        click_button 'Submit'
        expect(Style.find_by(:style_name => "unicorn")).to be(nil)
        expect(page.current_path).to eq("/styles/1/edit")
      end
    end

    context "logged out" do
      it 'does not load -- instead redirects to login' do
        get '/styles/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own style if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style = Style.create(:style_name => "Perfect T", :size => "M", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit 'styles/1'
        click_button "Sold/Delete"
        expect(page.status_code).to eq(200)
        expect(Style.find_by(:style_name => "Perfect T")).to eq(nil)
      end

      it 'does not let a user delete a style they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        style1 = Style.create(:style_name => "Perfect T", :size => "M", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        style2 = Style.create(:style_name => "look at this style", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'Submit'
        visit "styles/#{style2.id}"
        click_button "Sold/Delete"
        expect(page.status_code).to eq(200)
        expect(Style.find_by(:style_name => "look at this style")).to be_instance_of(Style)
        expect(page.current_path).to include('/styles')
      end
    end

    context "logged out" do
      it 'does not load let user delete a style if not logged in' do
        style = Style.create(:style_name => "Perfect T", :size => "M", :user_id => 1)
        visit '/styles/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
