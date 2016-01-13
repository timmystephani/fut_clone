## About

* This was made to be a clone of followupthen.com so I could use a private server instead of FollowUpThen's. Currently only works with Microsoft Exchange, but should be easy enough to port it to another mail server.
* Most of the "interesting" logic is in two files inside the script/ folder. I created the Rails project just to create a quick and easy way to save to the database and use the models provided by Rails.

## Setup

* Make sure your MS Exchange mailbox has folders of Inbox/FUT/Processed and Inbox/FUT/Unprocessed
* Set up rule to redirect messages with to address containing "+" to Inbox/FUT/Unprocessed
* Send email to your username+3hours@amazon.com


## TODO

* Make tests for various dates (i.e. 7days@amazon.com)
* Handle BCC and CC
* Set up cron jobs for both scripts


