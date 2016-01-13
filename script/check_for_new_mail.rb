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

def add_delay_to_sent_datetime(delay, message_sent_datetime) 
  number = delay.gsub(/[^\d]/, '').to_i

  if delay.match(/year/)
    return message_sent_datetime.advance(:years => number)
  elsif delay.match(/month/)
    return message_sent_datetime.advance(:months => number)
  elsif delay.match(/week/)
    return message_sent_datetime.advance(:weeks => number)
  elsif delay.match(/day/)
    return message_sent_datetime.advance(:days => number)
  elsif delay.match(/hour/)
    return message_sent_datetime.advance(:hours => number)
  elsif delay.match(/minute/)
    return message_sent_datetime.advance(:minutes => number)
  end

  raise "Couldn't match time delay: #{delay}"
end

password = ask('Enter your password: ') { |q| q.echo = "*" }

source = Net::IMAP.new(SERVER, { :port => PORT, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE } } )
source.login(USERNAME, password)
source.select 'Inbox/FUT/Unprocessed'
#p source.list('','*') # list all folders

while true
  puts 'Checking mail...'

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
    puts 'Processed message: '
    p message
    puts ''

    source.copy(message_id, 'Inbox/FUT/Processed')
    source.store(message_id, "+FLAGS", [:Deleted])
  end
  # must be called outside of loop, after processing of messages
  # similar to flush -- actually deletes mail in source.store call
  source.expunge 

  sleep(60)
end
 
source.logout
source.disconnect


# p envelope
#<struct Net::IMAP::Envelope date="Mon, 10 Aug 2015 15:21:10 -0700", subject="test follow up email subject", from=[#<struct Net::IMAP::Address name="Stephani, Timothy", route=nil, mailbox="timst", host="amazon.com">], sender=nil, reply_to=nil, to=[#<struct Net::IMAP::Address name="timst+3hours@amazon.com", route=nil, mailbox="timst+3hours", host="amazon.com">], cc=nil, bcc=nil, in_reply_to=nil, message_id="<5D9DDCA6CE749747B6260F06477AE59EB7A054@ex10-mbx-36008.ant.amazon.com>">
