require 'open-uri'

class ApiController < ApplicationController
  API_URL = "https://www.usgo.org/mm/api/members/"

  def search_members
    print('search members')
    print(params)
    print('api key: ' + ENV['AGA_MEMBERS_API_KEY'])

    if !!(params[:search] =~ /^[1-9]+[0-9]*$/)
      action = "#{params[:search]}?api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
    else
      action = "all?query=#{ERB::Util.url_encode('type != chapter ')}#{params[:search]}&limit=10&api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
    end

    print(action)
    buffer = open("#{API_URL}#{action}").read
    result = JSON.parse(buffer)

    render json: result
  end

  # Convert markdown into html
  def markdown
    html = helpers.markdown(params['markdown'])
    render json: { html: html }
  end
end