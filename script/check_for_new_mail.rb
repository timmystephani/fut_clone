#!/usr/local/bin/ruby
require 'rubygems'
require 'highline/import'
require 'net/imap'
require 'date'
require 'mail'

# For access to rails environment
ENV['RAILS_ENV'] = "development"
require '../config/environment.rb'

SERVER = 'ballard.amazon.com'
PORT = 1993
USERNAME = 'timst@amazon.com'
NUM_HOURS_IN_DAY = 24.0
NUM_MINUTES_IN_HOUR = 60

def add_delay_to_sent_datetime(delay, message_sent_datetime) 
  # only support days, hours minutes for now

  number = delay.gsub(/[^\d]/, '').to_i

  if delay.match(/day/)
    return message_sent_datetime + number
  elsif delay.match(/hour/)
    return message_sent_datetime + (number / NUM_HOURS_IN_DAY)
  elsif delay.match(/minute/)
    return message_sent_datetime + (number / (NUM_HOURS_IN_DAY * NUM_MINUTES_IN_HOUR))
  end

  raise "Couldn't match time delay"
end

password = ask('Enter your password: ') { |q| q.echo = "*" }

source = Net::IMAP.new(SERVER, { :port => PORT, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE } } )
source.login(USERNAME, password)
#p source.list('','*') # list all folders

source.select 'Inbox/FUT/Unprocessed'

source.search(["ALL"]).each do |message_id|
  envelope = source.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
  body = source.fetch(message_id,'RFC822')[0].attr['RFC822']
  mail = Mail.read_from_string body

  message = Message.new

  message.to_email = envelope.from[0].mailbox + '@' + envelope.from[0].host
  message.body = mail.html_part.body.to_s

  message_sent_datetime = DateTime.strptime(envelope.date, '%a, %e %b %Y %H:%M:%S %z')
  delay = envelope.to[0].mailbox[envelope.to[0].mailbox.index('+')+1..-1]
  message.send_at = add_delay_to_sent_datetime(delay, message_sent_datetime)
  message.subject = envelope.subject
  message.message_id = envelope.message_id

  message.save

  source.copy(message_id, 'Inbox/FUT/Processed')
  source.store(message_id, "+FLAGS", [:Deleted])


  # p envelope
  #<struct Net::IMAP::Envelope date="Mon, 10 Aug 2015 15:21:10 -0700", subject="test follow up email subject", from=[#<struct Net::IMAP::Address name="Stephani, Timothy", route=nil, mailbox="timst", host="amazon.com">], sender=nil, reply_to=nil, to=[#<struct Net::IMAP::Address name="timst+3hours@amazon.com", route=nil, mailbox="timst+3hours", host="amazon.com">], cc=nil, bcc=nil, in_reply_to=nil, message_id="<5D9DDCA6CE749747B6260F06477AE59EB7A054@ex10-mbx-36008.ant.amazon.com>">
end
source.expunge # similar to flush -- actually deletes mail in source.store call
 
source.logout
source.disconnect
