require 'open-uri'

# Our API controller provides endpoints that proxy to a number of external
# APIs and services, some more official than others.
#
# Please note that our use of Pandanet and KGS in unorthodox ways to get
# username validity was sanctioned by members of those organizations.
class ApiController < ApplicationController
  def search_members
    api_url_prefix = "https://www.usgo.org/mm/api/members/"
    if !!(params[:search] =~ /^[1-9]+[0-9]*$/)
      action = "#{params[:search]}?api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
    else
      action = "all?query=#{ERB::Util.url_encode('type != chapter ')}#{params[:search]}&limit=10&api_key=#{ENV['AGA_MEMBERS_API_KEY']}"
    end
    url = "#{api_url_prefix}#{action}"
    buffer = URI.parse(url).open(
      read_timeout: GENERIC_READ_TIMEOUT,
      open_timeout: GENERIC_OPEN_TIMEOUT
    ).read
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
    username = params.fetch('username')
    stats = Pandanet::Client.new.stats(username)
    if stats.nil?
      render json: '{"error": "not_found"}', status: :not_found
    else
      render json: stats.to_h
    end
  end

  # Use KGS's archives page to see if a username exists
  def kgs_username
    url = "http://gokgs.com/gameArchives.jsp?user=#{params['username']}"
    document = Nokogiri::HTML.parse(
      URI.parse(url).open(
        read_timeout: GENERIC_READ_TIMEOUT,
        open_timeout: GENERIC_OPEN_TIMEOUT
      ).read
    )
    result = document.css("p")[0]

    if result.text.starts_with?("Sorry, there are no games")
      head :not_found
    else
      head :ok
    end
  end
end
