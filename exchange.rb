require_relative 'lib/viewpoint'

include Viewpoint::EWS

endpoint = 'https://exchange.amazon.com/EWS/Exchange.asmx'
user = "ant\timst"
pass = ''

cli = Viewpoint::EWSClient.new endpoint, user, pass, http_opts: {ssl_verify_mode: 0}

folders = cli.folders
p folders
