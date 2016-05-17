require 'sinatra/base'
require 'json'
require 'rest-client'
require 'rexml/document'

class App < Sinatra::Base
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    params['result'].each do |msg|
      msg['content']['text'] = Translate.dash(msg['content']['text'])
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: msg['content']
      }

      p request_content

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
end

class Translate
  def self.dash(text)
    if text =~ /教えて$/
      Translate.faq(text) 
    else
      "#{text}っていいました？"
    end
  end

  def self.faq(text)
    begin
      chiebukuro_api_url = 'http://chiebukuro.yahooapis.jp/Chiebukuro/V1/questionSearch'
      response = RestClient.get(chiebukuro_api_url, { params: { appid: ENV['YAHOO_APP_ID'], query: text, results: 1, condition: 'solved' } })
      doc = REXML::Document.new(response)
      response = "#{doc.elements['ResultSet/Result/Question/BestAnswer'].text.slice(0, 30)}...#{doc.elements['ResultSet/Result/Question/Url'].text}"
    rescue => e
      response = 'うまく認識できなかったよー'
      p e
    end
    response
  end

  # Ref https://github.com/rails/rails/blob/0e50b7bdf4c0f789db37e22dc45c52b082f674b4/actionview/lib/action_view/helpers/text_helper.rb#L92
  def self.truncate(text, options = {}, &block)
    if text
      length  = options.fetch(:length, 30)
      content = text.truncate(length, options)
      content << capture(&block) if block_given? && text.length > length
      content
    end
  end
end
