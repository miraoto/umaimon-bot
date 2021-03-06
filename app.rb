require 'sinatra/base'
require 'json'
require 'rest-client'
require 'rexml/document'
require './lib/bot'

class App < Sinatra::Base
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    params['result'].each do |msg|
      msg['content']['text'] = Bot.parse(msg['content']['text'])
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: msg['content']
      }

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      })
    end
    "OK"
  end

  post '/facebookbot/callback' do
    params = JSON.parse(request.body.read)
    msg = params["entry"][0]["messaging"][0]    

    if msg.include?("message")
      sender = msg["sender"]["id"]
      text = Bot.parse(msg["message"]["text"])
      endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV["FACEBOOK_TOKEN"]}"
      request_content = {
        recipient: { id:sender },
        message: { text: text }
      }
      content_json = request_content.to_json

      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8'
      })
    end
  end
end
