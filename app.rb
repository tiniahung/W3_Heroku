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

get '/' do
Hello
end

get "/from" do
  #401
  "+14126936852"
end

# Test sending an SMS
# change the to to your number 

get '/send_sms/' do 

  client.account.messages.create(
    :from => "+14126936852",
    :to => "+14128166195",
    :body => "Hey there. This is a test"
  )

  "Sent message".to_s
  
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

get '/incoming_sms' do
  
  session["last_context"] ||= nil
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip
  
  if body == "hi" or body == "hello" or body == "hey"
    message = get_about_message
  elsif body == "play"
    session["last_context"] = "play"
    session["guess_it"] = rand(1...5)
    message = "Guess what number I'm thinking of. It's between 1 and 5"
  elsif session["last_context"] == "play"
    
    # if it's not a number 
    if not body.to_i.to_s == body
      message = "Cheater cheater that's not a number. Try again"
    elsif body.to_i == session["guess_it"]
      message = "Bingo! It was #{session["guess_it"]}"
      session["last_context"] = "correct_answer"
      session["guess_it"] = -1
    else
      message = "Wrong! Try again"
    end
    
  elsif body == "who"
    message = "I was made by Tina."
  elsif body == "what"
    message = "I don't do much but I do it well. You can ask me who what when where or why."
  elsif body == "when"    
    message = Time.now.strftime( "It's %A %B %e, %Y")
  elsif body == "where"    
    message = "I'm in Pittsburgh right now."
  elsif body == "why"    
    message = "For educational purposes."
  else 
    message = error_response
    session["last_context"] = "error"
  end
  
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  twiml.text
end



private 





GREETINGS = ["Hi","Yo", "Hey","Howdy", "Hello", "Ahoy", "‘Ello", "Aloha", "Hola", "Bonjour", "Hallo", "Ciao", "Konnichiwa"]

COMMANDS = "hi, who, what, where, when, why and play."

def get_commands
  error_prompt = ["I know how to: ", "You can say: ", "Try asking: "].sample
  
  return error_prompt + COMMANDS
end

def get_greeting
  return GREETINGS.sample
end

def get_about_message
  get_greeting + ", I\'m SMSBot 🤖. " + get_commands
end

def get_help_message
  "You're stuck, eh? " + get_commands
end

def error_response
  error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me? "].sample
  error_prompt + " " + get_commands
end
