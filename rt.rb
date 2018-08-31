require_relative 'rest_gateway.rb'
require_relative 'MerchantInfo.rb'
require 'json'
require 'httparty'
require 'timeout'


HTTParty::Basement.default_options.update(verify: false)

$stderr = $stdout
counter = 1
#read standard input from filepro process

until(temp = gets.to_s.strip) == "timetogo"
  counter += 1

  if temp == nil || temp == "" || counter > 5000 ## must have input and should not reach higher than 5000
    puts "serious"
    $stdout.flush
    file = File.open("/www/RAILS/gateway/outputlog.txt", "a")
    file.puts "outer temp is blank/nil/or counter is 5000 - #{DateTime.now}"
    file.close unless file.nil?

    exit
  end


gwObject = RestGateway::ServiceClient.new($merchant,params={})
x=0
input_array = []

#keep pulling in more data until temp is "process"

until temp == "process"

##  if this counter gets to 50, something went wrong - pipe is interrupted
##  and broken. This loop is pulling in input on one transaction only,
##  so it would not reach 50 under normal circumstances.

  if x > 50 || temp == nil
    puts "serious"
    file = File.open("/www/RAILS/gateway/outputlog.txt", "a")
    file.puts "counter hit 50, or temp is nil - #{DateTime.now}"
    file.close unless file.nil?
    $stdout.flush
    exit
  end
    input_array[x] = temp
    x += 1
    temp = gets.to_s.strip

  if temp == "timetogo"
    puts "alldoneend"
    $stdout.flush
    exit(100)
  elsif temp == "process"
    break
  end

end


#########################################
#     functions
#########################################


def make_change(gwObject, input_array =[])
  if input_array.any? == true
    gwObject.send_data($success, $errors_and_validation, $action)
  end
end

def respond(gwObject, output=[], input_array)
  output.each do |data|
    if data.kind_of?(Array)
      data.each do |value|
        puts value
      end
    else
      puts data
    end
  $stdout.flush
  end

  puts "endthisone"
  $stdout.flush
end
#########################################
#     case statement
#########################################

case input_array[0]
  when "Token"
    handler = RestGateway::TokenHandler.new(input_array)
#      $action = "VaultQueryVault"
    gwObject.data['vaultKey'] = input_array[1]
    $action = "VaultCreateCCRecord"
  when "Sale"
    handler = RestGateway::SaleHandler.new(input_array)
    $action = "SaleUsingVault"
  when "Query"
    gwObject.data['queryVaultKey'] = input_array[1]
    handler = RestGateway::QueryHandler.new(input_array)
    $action = "VaultQueryCCRecord"
  when "QueryVault"
    handler = RestGateway::VaultQueryHandler.new(input_array)
    $action = "VaultQueryVault"
  when "DeleteCC"
    handler = RestGateway::DeletionHandler.new(input_array)
    $action = "VaultDeleteCCRecord"
  when "DeleteVault"
    handler = RestGateway::DeletionHandler.new(input_array)
    $action = "VaultDeleteContainerAndAllAsscData"
  when "Auth"
    handler = RestGateway::AuthHandler.new(input_array)
    $action = "Auth"
  else
    exit(1)

end


handler.make_load($action)

gwObject.data = gwObject.data.merge(handler.data)

$success = handler.success
$errors_and_validation = handler.errors_and_validation

make_change(gwObject, input_array)

respond(gwObject, handler.output, input_array)


input_array.clear
gwObject.data.clear
#puts gwObject.data.to_s
#puts inputArray.to_s
#puts "nextone"
#$stdout.flush


end

puts "alldoneend"
$stdout.flush
exit(0)


