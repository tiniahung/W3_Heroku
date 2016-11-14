require 'json'
require "sinatra"
require 'active_support/all'
require "active_support/core_ext"
require 'sinatra/activerecord'
require 'rake'

require 'twilio-ruby'
=begin
# ----------------------------------------------------------------------

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end


# require any models 
# you add to the folder
# using the following syntax:
# require_relative './models/<model_name>'


# enable sessions for this project
enable :sessions

# ----------------------------------------------------------------------
#     ROUTES, END POINTS AND ACTIONS
# ----------------------------------------------------------------------
=end

get "/" do
  "My Basic Application".to_s
  #401
end

# ----------------------------------------------------------------------
#     ERRORS
# ----------------------------------------------------------------------

error 401 do 
  "Not allowed!!!"
end

# ----------------------------------------------------------------------
#   METHODS
#   Add any custom methods below
# ----------------------------------------------------------------------

private

# for example 
def square_of int
  int * int
end



# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end


# enable sessions for this project

enable :sessions

# First you'll need to visit Twillio and create an account 
# you'll need to know 
# 1) your phone number 
# 2) your Account SID (on the console home page)
# 3) your Account Auth Token (on the console home page)
# then add these to the .env file 
# and use 
#   heroku config:set TWILIO_ACCOUNT_SID=XXXXX 
# for each environment variable

# CREATE A CLient
client = Twilio::REST::Client.new "AC3157cd21b96c6f0acb6d118749e10991", "61fe77acb422e0661439b16068ec5522"


# Use this method to check if your ENV file is set up

get "/from" do
  #401
  ENV["TWILIO_FROM"]
end

# Test sending an SMS
# change the to to your number 

get "/send_sms/" do 

  client.account.messages.create(
    :from => ENV["TWILIO_FROM"],
    :to => "+14126936852",
    :body => "Hey there. This is a test"
  )
  "Sent message"
  
end

# Hook this up to your Webhook for SMS/MMS through the console

get '/incoming_sms' do

  session["counter"] ||= 0
  count = session["counter"]
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  query = body.downcase.strip

  if session["counter"] < 1
    message = "Thanks for your first message. From #{sender} saying #{body}"
  else
    message = "Thanks for message number #{ count }. From #{sender} saying #{body}"
  end
  
  session["counter"] += 1
  
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  twiml.text

end





error 401 do 
  "Not allowed!!!"
end
