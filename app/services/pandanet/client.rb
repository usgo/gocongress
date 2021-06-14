# frozen_string_literal: true

module Pandanet
  # We connect to Pandanet to get information about an `Attendee`. We connect
  # with telnet.
  #
  # ## Timeout during `login`
  #
  # If `PANDANET_USERNAME` has been used by a "client application", such
  # as `glGo`, the telent server will remember, and will use numeric codes
  # instead of speaking "English". So, for example, it'll print "1 1" and
  # we'll wait for it to print "Login: ". This is described in the docs
  # (http://www.pandanet.co.jp/English/sintro1.html)
  #
  # > If you use a client, your client will set your login to 'client mode',
  # > and should you later telnet to IGS without it, you may find that your
  # > familiar prompt has changed and looks like:
  # >
  # >   1 1  or  1 5
  # >
  # > Don't panic if you don't see your familiar prompt, just complete your
  # > login by entering your account name and password. After you enter IGS,
  # > enter toggle client.
  #
  # So, that's one way that "client mode" can be fixed manually. There may
  # be a more automatic way, perhaps when establishing the initial connection?
  class Client
    # Returns a String like:
    #
    # ```
    # Player:      cloudbrows
    # Game:        go (1)
    # Language:    default
    # Rating:      1d    0
    # Rated Games:      0
    # Rank:  1d  29
    # Wins:         0
    # Losses:       0
    # Last Access(GMT):   (Not on)    Sat May 29 13:56:48 2021
    # Last Access(local): (Not on)    Sat May 29 22:56:48 2021
    # Address:  panda@.us
    # Country:  USA
    # Community:  -
    # Reg date: Mon Jan  1 00:00:00 1900
    # Info:  <None>
    # Defaults (help defs):  time 90, size 19, byo-yomi time 10, byo-yomi stones 25
    # ```
    #
    # @return [nil | Stats]
    def stats(username)
      # Debugging tip: add the "Output_log" option.
      server = Net::Telnet.new(
        "Host" => "igs.joyjoy.net",
        "Port" => 7777,
        "Timeout" => 10,
        "Prompt" => /#> /
      )

      # If a timeout occurs during `login`, see notes above.
      server.login(ENV['PANDANET_USERNAME'], ENV['PANDANET_PASSWORD'])

      stats_result = nil
      server.cmd("stats #{username}") do |result|
        stats_result = result
      end

      server.cmd("quit")
      server.close

      Stats.parse(username, stats_result)
    end
  end
end
