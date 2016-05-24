class Bot
  def self.parse(text)
    if text =~ /教えて$/
      faq(text) 
    else
      talk(text)
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

  def self.talk(text)
    begin
      talk_api_url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'
      response = RestClient.post(talk_api_url, { params: { APIKEY: ENV['DOCOMO_APP_KEY'], utt: text } })
      p response
    rescue => e
      response = 'うまく認識できなかったよー'
      p e
    end
    response
  end
end
