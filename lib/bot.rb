require 'redis'

class Bot
  def self.parse(text)
    @redis = Redis.new(url: ENV["REDIS_URL"])
    if text =~ /教えて$/
      reply = faq(text) 
    else
      reply = talk(text)
    end
    reply
  end

  def self.faq(text)
    begin
      request_content = {
        params: {
          appid: ENV['YAHOO_APP_ID'],
          query: text,
          results: 1,
          condition: 'solved'
        }
      }
      chiebukuro_api_url = 'http://chiebukuro.yahooapis.jp/Chiebukuro/V1/questionSearch'
      response = RestClient.get(chiebukuro_api_url, request_content)
      doc = REXML::Document.new(response)
      reply = "#{doc.elements['ResultSet/Result/Question/BestAnswer'].text.slice(0, 30)}...#{doc.elements['ResultSet/Result/Question/Url'].text}"
    rescue => e
      p e
      reply = '質問内容をもう一度教えてもらえますか？'
    end
    reply
  end

  def self.talk(text)
    begin
      context = @redis.get('content')
      request_content = {
        utt: text,
        context: context
      }.to_json
      p request_content
      talk_api_url = "https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{ENV['DOCOMO_APP_KEY']}"
      response = RestClient.post(talk_api_url, request_content, {
        'Content-Type' => 'application/json; charset=UTF-8',
      })
      response = JSON.parse(response)
      @redis.set('content', response['context'])
      reply = response['utt']
    rescue => e
      p e
      reply = "#{text}っていいました？"
    end
    reply
  end
end
