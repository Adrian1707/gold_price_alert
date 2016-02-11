  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'twilio-ruby'

  require 'dotenv'
  Dotenv.load

  TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID']
  TWILIO_AUTH_TOKEN  = ENV['TWILIO_AUTH_TOKEN']
  PHONE_NUMBER = ENV['PHONE_NUMBER']
  TWILIO_NUMBER = ENV['TWILIO_NUMBER']


  @twilio = Twilio::REST::Client.new TWILIO_ACCOUNT_SID,TWILIO_AUTH_TOKEN

  @price_inside_range = true
  
    def get_page
        @doc = Nokogiri::HTML(open("http://www.pmbull.com/gold-price/"))
    end

    def get_gold_price
        @gold_price =  @doc.css("span").inner_text[1...-44].to_f
    end


    def send_alert
      @twilio.messages.create(
        from: TWILIO_NUMBER, to: PHONE_NUMBER, body: "Gold is now at #{@gold_price}"
      )
    end

    def check_price
      if @gold_price < 1190 || @gold_price > 1200
        send_alert
        @price_inside_range = false
      end
    end

    while @price_inside_range
      get_page
      get_gold_price
      check_price
      sleep 1
    end
