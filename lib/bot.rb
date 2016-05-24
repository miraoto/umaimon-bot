class Bot
  def self.parse(text)
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
end
