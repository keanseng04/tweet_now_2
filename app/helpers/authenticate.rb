def user_logged
    user = nil
    if session[:user]
      user = TwitterUser.find_by(screen_name: session[:user])
    end
    user
  end

def current_user
  TwitterUser.find_by(screen_name: session[:user])
end