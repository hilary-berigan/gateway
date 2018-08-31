=begin
RestGateway Module: A library of functions used to call the Rest Gateway web service.
This class is required for all Ruby code making a call to Rest Gateway. Please refer to the gateway documentation web page for specifics on what parameters to use for each call.
version = 1.2.0
Last Revision: 6/23/2016
=end
require 'httparty'
# Due to issues with verifying server certificate, disable OpenSSL https verification for now
HTTParty::Basement.default_options.update(verify: false)
require 'json'

module RestGateway
class ServiceClient
	@@version = "1.2.0"
	attr_reader   :response_code, :result
	attr_accessor :data, :action


	def initialize(merchant_data,params)
#		@starter = { 'cardnumber' => ""}
		@api_url = "https://secure.1stpaygateway.net/secure/RestGW/Gateway/Transaction/"
		@test_mode = true
   	@data = merchant_data
    @params = params
		@status = "None"
		@result = {}
		@response_code = 0
		@action = action
	end

  def send_data(call_back_success=nil, call_back_failure=nil, action)
		request = @api_url + action
		@data = @data.merge(@params)
		self.perform_request(request, call_back_success, call_back_failure)
	end

	def switch_env
		# Switch between production and validation
		if @api_url == "https://secure.1stpaygateway.net/secure/RestGW/Gateway/Transaction/"
			@api_url = "https://secure-v.goemerchant.com/secure/RestGW/Gateway/Transaction/"
			@test_mode = true
		elsif @api_url == "https://secure-v.goemerchant.com/secure/RestGW/Gateway/Transaction/"
			@api_url = "https://secure.1stpaygateway.net/secure/RestGW/Gateway/Transaction/"
			@test_mode = false
		else
			@api_url = "https://secure.1stpaygateway.net/secure/RestGW/Gateway/Transaction/"
			@test_mode = false
		end
	end

	def perform_request(api_request, call_back_success, call_back_failure)
		@result.clear
		@response_code = 0
		@status = "None"
		header = {'Content-Type' => 'application/json', 'charset' => 'utf-8'}
		ws_response = HTTParty.post(api_request, body: @data.to_json, headers: header)
		@response_code = ws_response.code
		response = JSON.parse(ws_response.body)

		if (response.has_key? "isError" and response["isError"]==true)
			@status = "Error"
			@result = response

			unless call_back_failure.nil?
				call_back_failure.call(@status, @result)
			end
		elsif (response.has_key? "validationHasFailed" and response["validationHasFailed"]==true)
			@status = "Validation"
			@result = response
			unless call_back_failure.nil?
				call_back_failure.call(@status, @result)
			end
		elsif (response.has_key? "isSuccess" and response["isSuccess"]==true)
			@status = "Success"
			@result = response
			unless call_back_success.nil?
				call_back_success.call(@result)
			end
		else
			@status = "Unknown"
			@result = response
			# No callback, status wasn't recognized
		end
	end
	end


class QueryHandler
	attr_accessor :success, :errors_and_validation, :data, :output

	def initialize(input_array=[])
    $i = 0
		@input = input_array
		@data = {}
		@output = Array.new
    @success = lambda do |values|

			if values['data'].has_key? "creditCardRecords" and values['data']['creditCardRecords'].any? == true
			 data = values['data']['creditCardRecords'][0]
			 output[0] = "success"
       output[1] = data['id'] || ""
       output[2] = data['vaultKey'] || ""
       output[3] = data['cardNoLast4'] || ""
       output[4] = data['cardExpMM'] || ""
       output[5] = data['cardExpYY'] || ""
       output[6] = data['cardType']
       output[7] = data['name']
       output[8] = data['city']
       output[9] = data['state']
       output[10] = data['street']
       output[11] = data['street2']
       output[12] = data['zip']
			else
				output[0] = "noCreditCardwithThat"
				output[1] = values.to_s
       end
	end
     @errors_and_validation = lambda do |status,values|
    	x = 1
			if status == "Validation"
       output[0] = "validation"
       values['validationFailures'].each do |values2|
					 output[x]=values2.to_s
					 end
      elsif status == "Error"
				output[0] =  "error"

				 values['errorMessages'].each do |values2|
					 output[x] = values2.to_s
	         x += 1
  				end
     end
	 end
	 end

	def make_load(action)

		data['queryCCLast4'] = @input[2] ||= ''

    end


end

class VaultQueryHandler
	attr_accessor :success, :errors_and_validation, :data, :output

	def initialize(input_array=[])
    $i = 0
		@input = input_array
		@data = {}
		@output = Array.new
		$j=1
    @success = lambda do |values|
			if values['data'].has_key? "VaultContainers" and values['data']['VaultContainers'].any? == true
			   output[0] = 'success'
			   values['data']['VaultContainers'].each do |v_cont|
           v_cont['vaultCreditCards'].each do |data|
				  	output[$j] = [  data['id'].to_s,
														data['vaultKey'].to_s,
														data['cardNumberLast4'].to_s,
														data['expirationMonth'].to_s,
														data['expirationYear'].to_s,
														data['cardType'].to_s,
														data['name'].to_s,
														data['city'].to_s,
														data['state'].to_s,
														data['street'].to_s,
														data['street2'].to_s,
														data['zip'].to_s,
													'next',
													'success'
			             ]
					   $j+= 1
				  end
					end
			else
				output[0] = "noCreditCardwithThat"
				output[1] = values.to_s
       end
	end
     @errors_and_validation = lambda do |status,values|
    	x = 1
			if status == "Validation"
       output[0] = "validation"
       values['validationFailures'].each do |values2|
					 output[x]=values2.to_s
					 end
      elsif status == "Error"
				output[0] =  "error"

				 values['errorMessages'].each do |values2|
					 output[x] = values2.to_s
	         x += 1
  				end
     end
	 end
	 end

	def make_load(action)

		data['queryCCLast4'] = @input[2] ||= ''

    end


end

class TokenHandler
	attr_accessor :success, :errors_and_validation, :data, :output

	def initialize(input_array=[])
    @input = input_array
		@data = {}
		@output = Array.new
    @success = lambda do |values|
  #       output[] = values['data']['referenceNumber']
	   if values['data']['id'].to_s.empty? == false
				 output[0] = "success"
				 output[1] = values['data']['id'].to_s
		 else
		 output[0] = "problems"
		 output[1] = values.to_s
end
     end
		 @errors_and_validation = lambda do |status,values|

    	x = 1
			if status == "Validation"

       output[0] = "validation"
       output[1] = values['validationFailures'][0]['message'].to_s


      elsif status == "Error"
				output[0] =  "error"
				output[1] = values['errorMessages'][0].to_s
  				end
     end
	 end


	def make_load(action)
	    data['cardNumber'] = @input[2] # || '36438999960016'
      data['cardExpMonth'] = @input[3] # || '08'
      data['cardExpYear'] = @input[4] # || '17'
      data['cVV'] = @input[5]# ||   '123'
      data['cardType'] = @input[6] #|| "AMEX"
      data['ownerName'] = @input[7] #|| "hilary berigan"
      data['ownerStreet'] = @input[8]# || "1 smile st"
      data['ownerStreet2'] =  @input[9]# || ""
      data['ownerCity'] = @input[10] #|| "burlington"
      data['ownerState'] = @input[11] #|| "WI"
      data['ownerZip'] = @input[12] #|| "53150"
      data['ownerCountry'] = @input[13]# || "USA"
    end


end
class SaleHandler
	attr_accessor :success, :errors_and_validation, :data, :output

	def initialize(input_array=[])
	@input = input_array
	@data = {}
	@output = Array.new
	@success = lambda do |values|

         if (values['data']['cardDeclinedNo'].to_s != "")
					  output[0] = "declined"
						output[1] = values['data']['declinedMessage']


	       elsif (values['data']['authCode'].to_s != "")

			   output[0] = "success"
         output[3] = values['data']['referenceNumber']
				 output[4] = values['data']['orderId']
				 output[1] = values['data']['authResponse']
				 output[2] = values['data']['authCode']

         else
					 output[0] = puts "nope"
					 #need something better here
					 output[1] = values.to_s

         end

	   end

  @errors_and_validation = lambda do |status,values|
			$x = 1

			if status == "Validation"
       output[0] = "validation"
       output[1] = values['validationFailures'][0]['message']


      elsif status == "Error"
				output[0] =  "error"

				 values['errorMessages'].each do |values2|
					 output[$x] = values2.to_s
	         $x += 1
  				end
     end

	 end
end
  def make_load(action)
	    data['vaultKey'] = @input[1]
      data['vaultId'] = @input[2]
      data['transactionAmount'] = @input[3]
			data['orderId'] = @input[4]
			data['preventPartial'] = true
end
end
class DeletionHandler
	attr_accessor :success, :errors_and_validation, :data, :output

	def initialize(input_array=[])
	@input = input_array
	@data = {}
	@output = Array.new
	@success = lambda do |values|

		 if values['data']['deletedCount'] == 1
					output[0] = "true"
          output[1] = "deleted"
					else
						output[0] = "false"
						output[1] = values.to_s
     end
		 end
   @errors_and_validation = lambda do |status,values|
    	x = 1
			if status == "Validation"
       output[0] = "false"
       output[1] = values['validationFailures'][0]['message'].to_s


      elsif status == "Error"
				output[0] =  "false"
				output[1] = values['errorMessages'][0].to_s
  				end
end
end
  def make_load(action)
	  data['vaultKey'] = @input[1]
    if action == "DeleteCC"
			data['id'] = @input[2]
    end
  end

end

class AuthHandler
	attr_accessor :success, :errors_and_validation, :data, :output

	def initialize(input_array=[])
	@input = input_array
	@data = {}
	@output = Array.new
	@success = lambda do |values|
         if (values['data']['cardDeclinedNo']).to_i > 0
					  output[0] = "declined"
						output[1] = values ['data']['declinedMessage']


		elsif (values["isPartial"])
         else

					 output[0] = values.to_s

         end
		   end

  @errors_and_validation = lambda do |status,values|
			$x = 1

			if status == "Validation"
       output[0] = "validation"
       output[1] = values['validationFailures'][0]['message']


      elsif status == "Error"
				output[0] =  "error"
        output[1] = values.to_s

  				end
     end

end
  def make_load(action)
			data['autoGenerateOrderId'] = true
			data['cardNumber'] = input_array[1]
      data['cardExpMonth'] = input_array[2]
      data['cardExpYear'] = input_array[3]
      data['cVV'] = input_array[4]
      data['cardType'] = input_array[5]
      data['ownerName'] = input_array[6]
      data['ownerCity'] = input_array[7]
      data['ownerState'] = input_array[8]
      data['ownerCountry'] = input_array[9]
      data['ownerStreet'] = input_array[10]
      data['ownerZip'] = input_array[11]
      data['transactionAmount'] = input_array[12]
end
end
end


