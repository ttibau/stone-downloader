require 'net/https'
require 'uri'
require 'colorize'
require 'date'
require 'fileutils'

class Service

  def yesterday_date
    yesterday = Time.now-86400
    yesterday = yesterday.to_s
    yesterday = DateTime.parse(yesterday).strftime("%Y%m%d")
  end

  def uri 
   URI.parse("https://conciliation.stone.com.br/conciliation-file/v2/")
  end

  def request_yesterday
    uri = self.uri + self.yesterday_date 
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = { "Authorization" => ARGV[3] }
    request = Net::HTTP::Get.new(uri.request_uri, headers)

      response = http.request(request)
      puts response.code
      path = ARGV[0] + "stone-" + yesterday_date + ".xml"
      handing(response, path, self.yesterday_date)

  end

  def request_dates(inicio, fim)
   data_inicial = Date.parse(inicio)
   data_final = Date.parse(fim)


   i = (data_final - data_inicial).to_i + 1

   while i > 0 do
      uri = self.uri + data_inicial.strftime("%Y%m%d")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      headers = { "Authorization" => ARGV[3] }
      request = Net::HTTP::Get.new(uri.request_uri, headers)


      response = http.request(request)
      data_inicial_string = data_inicial.to_s
      path = ARGV[0] + "stone-" + data_inicial_string + ".xml"
      handing(response, path, data_inicial.to_s)
      i -= 1
      data_inicial = data_inicial.to_date + 1

    end
  end

  def handing(response, path, nome)
    if (response.body.empty?)
      puts "O arquivo vindo está vazio".red
    elsif (response.code == "200")
      begin
        o = File.new(path, "w")
        o.write(response.body)
        o.close
        puts "Arquivo criado com sucesso: ".green + nome

      end
    else
      puts "Ocorreu um erro, abaixo o response code do erro: ".red + response.code

    end
  end

end


service = Service.new

  if ARGV[1].nil? && ARGV[2].nil?

    response = service.request_yesterday

  else
    response = service.request_dates(ARGV[1], ARGV[2])
  end






