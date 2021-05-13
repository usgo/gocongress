require 'open-uri'

class ApiController < ApplicationController
  # Our API controller provides endpoints that proxy to a number of external
  # APIs and services, some more official than others.
  #
  # Please note that our use of Pandanet and KGS in unorthodox ways to get
  # username validity was sanctioned by members of those organizations.

  def search_members
    api_url = "https://www.usgo.org/mm/api/members/"

    if !!(params[:search] =~ /^[1-9]+[0-9]*$/)
      action = "#{params[:search]}?api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
    else
      action = "all?query=#{ERB::Util.url_encode('type != chapter ')}#{params[:search]}&limit=10&api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
    end

    buffer = URI.open("#{api_url}#{action}").read
    result = JSON.parse(buffer)

    render json: result
  end

  # Convert markdown into html
  def markdown
    html = helpers.markdown(params['markdown'])
    render json: { html: html }
  end

  # Use telnet to access Pandanet to get member information
  def pandanet_username
    server = Net::Telnet::new("Host" => "igs.joyjoy.net", "Port" => 7777, "Timeout" => 10, "Prompt" => /#> /)
    server.login(ENV['PANDANET_USERNAME'], ENV['PANDANET_PASSWORD'])
    
    server.cmd("stats #{params['username']}") do |result|
      if result.start_with?("Cannot find player.")
        render json: '{"error": "not_found"}', status: :not_found
      else
        rating = result.match(/Rating:\s*([1-9][0-9]?[dk])/)[1]
        rank = result.match(/Rank:\s*([1-9][0-9]?[dk])/)[1]
        country = result.match(/Country:\s*([A-Za-z]+)/)[1]
        player_information = {
          :username => params['username'],
          :rating => rating,
          :rank => rank,
          :country => country
        }
        render json: player_information
      end
    end

    server.cmd("quit")
    server.close
  end

  # Use KGS's archives page to see if a username exists
  def kgs_username
    document = Nokogiri::HTML.parse(URI.open("http://gokgs.com/gameArchives.jsp?user=#{params["username"]}"))
    result = document.css("p")[0]

    if result.text.starts_with?("Sorry, there are no games")
      head :not_found
    else
      head :ok
    end
  end
end