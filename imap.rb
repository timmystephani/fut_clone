#!/usr/local/bin/ruby
require 'rubygems'
require 'highline/import'
require 'net/imap'

SERVER = 'ballard.amazon.com'
PORT = 1993
USERNAME = 'timst@amazon.com'

password = ask('Enter your password: ') { |q| q.echo = "*" }

source = Net::IMAP.new(SERVER, { :port => PORT, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE } } )
source.login(USERNAME, password)
#p source.list('','*') # list all folders

source.examine 'Inbox/TODO/Urgent'

source.search(["ALL"]).each do |message_id|
  envelope = source.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
  puts "#{envelope.from[0].name}: \t#{envelope.subject}"
  #break
end
 
source.logout
source.disconnect
