require 'uri'
require 'net/http'
require 'json'
require 'cgi'

class LoginController < ApplicationController
  def login
    if params[:service].nil?
      render plain: 'Error: no service'
      return
    end

    service = params[:service]

    # TODO: Check if service domain is SSL
    # TODO: Check if service domain is allowed

    session[:service] = service

    session[:state] = rand_string

    oauth_url = "%s/authorize?client_id=%s&response_type=code&redirect_uri=%s&state=%s&scope="
    oauth_url = oauth_url % [ENV['OAUTH_URL'], ENV['CLIENT_ID'], callback_url, session[:state]]

    redirect_to oauth_url
  end

  def callback
    if params[:error]
      render plain: 'Error: ' + params[:error]
      return
    end

    if params[:state] != session[:state]
      render plain: 'Error: state mismatch'
      return
    end

    if session[:service].nil?
      render plain: 'Error: miss service'
      return
    end

    session.delete(:state)

    if params[:code].nil?
      render plain: 'Error: miss code'
      return
    end

    post_body = {
        client_id: ENV['CLIENT_ID'],
        client_secret: ENV['CLIENT_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: callback_url,
        code: params[:code]
    }

    post_result = Net::HTTP.post_form(URI.parse(ENV['OAUTH_URL'] + '/access_token'), post_body)

    username = get_username post_result

    return if username.nil?

    ticket = 'ST-' + rand_string
    service = session[:service]

    Login.create(service: service, ticket: ticket, username: username)

    session.delete(:service)

    redirect_to service + "?ticket=" + ticket
  end

  def validate
    # TODO: Remove old ticket
    if params[:service].nil?
      render plain: 'no'
      return
    end

    if params[:ticket].nil?
      render plain: 'no'
      return
    end

    recoder = Login.find_by(service: params[:service], ticket: params[:ticket])

    if recoder.nil?
      render plain: 'no'
      return
    end

    render plain: "yes\n" + recoder.username

    recoder.destroy
  end

  def logout
  end
  
  def rand_string
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    (0...64).map { o[rand(o.length)] }.join
  end

  def callback_url
    URI.encode(request.protocol + request.host_with_port + '/callback')
  end

  def get_username(post_result)
    result = JSON.parse post_result.body

    if result['uid'].nil?
      render plain: 'Error: no uid found'
      return
    end

    get_result = Net::HTTP.get(URI.parse('http://hometown.scau.edu.cn/bbs/plugin.php?id=iltc_open:userinfo&uid=' + result['uid']))

    result = JSON.parse get_result

    if result['data']['username'].nil?
      render plain: 'Error: no username found'
      return
    end

    result['data']['username']
  end
end
