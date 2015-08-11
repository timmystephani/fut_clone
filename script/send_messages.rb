#!/usr/local/bin/ruby
require 'rubygems'
require 'highline/import'
require 'net/imap'
require 'date'

# For access to rails environment
ENV['RAILS_ENV'] = "development"
require '../config/environment.rb'

FROM_EMAIL = 'timst@amazon.com'

message_count = 0
Net::SMTP.start('smtp.amazon.com', 25) do |smtp|

  Message.where('sent_at is null').each do |message|
    message_text = <<END_OF_MESSAGE
From: <#{FROM_EMAIL}>
To: <#{message.to_email}>
Subject: #{message.subject}


#{message.body}
END_OF_MESSAGE


    puts 'message text: '
    puts message_text
    smtp.send_message message_text, FROM_EMAIL, message.to_email

    message.sent_at = DateTime.now
    #message.save
    message_count += 1
  end

end

puts "Sent #{message_count} messages."


