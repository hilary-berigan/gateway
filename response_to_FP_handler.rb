class ResponseToFPHandler

def initialize(result)
	@result = result
	@output = []
end

def handle_response(action)
	is_error, status = error?(@result)

	if is_error == true
		errors_and_validation(status,@result)
	else
		handle_success(action,@result)
	end

  return @output
end
def error?(result)
		if (result.has_key? "isError" and result["isError"]==true)
			return true, status = "Error"
		elsif (result.has_key? "validationHasFailed" and result["validationHasFailed"]==true)
			return true, status = "Validation Issue"
		else
			return false, status = "Success"
		end
end
  def errors_and_validation(status,values)
			x = 2
			@output[0] = false

			if status == "Validation Issue"
				@output[1] = "validation_issue"
       values['validationFailures'].each do |values2|
					 @output[x]=values2['message'].to_s
					 end
      elsif status == "Error"
				@output[1] = "error"
				 values['errorMessages'].each do |values2|
					 @output[x] = values2.to_s
	         x += 1
  				end
     end
	 end
  def handle_success(action,result)
		case action
		  when "AuthUsingVault"
				action = "Auth"

			when "SaleUsingVault"
        action = "Sale"

			when "AchCreditUsingVault"
				action = "AchCredit"

			when "AchDebitUsingVault"
				action = "AchDebit"

			when "AchVoid"
				action = "Void"

			when "VaultUpdateAchRecord" || "VaultUpdateCCRecord" || "VaultUpdateContainer"
				action = "VaultUpdate"

			when "VaultDeleteAchRecord"
				action = "VaultDeleteCCRecord"
      end

		@output = [ false, "ProblemIT", result.to_s ]

    send(action,result['data'])
	end



###############Creation Methods ################

  def VaultCreateCCRecord(result)
		id = result['id'].to_s
		@output = [ true, "CC_Created",	id ]
  end
	def VaultCreateAchRecord(result)
		##not active yet
  end
	def AchCreateCategory(result)
		##not active yet
  end

############## Transaction Methods ##############
  def Auth(result)
		@output = [ true,
		            "approved",
		            result['authResponse'],
								result['authCode'],
								result['referenceNumber'],
								result['orderId']
							]
	end
  def Sale(result)
		if (result['cardDeclinedNo'].to_s != "")
			@output = [ false,
									"declined",
									result['declinedMessage']
								]
		else
			@output = [ true,
			            "completed",
									result['authResponse'],
									result['authCode'],
									result['referenceNumber'],
									result['orderId']
			          ]
	  end
  end
	def Settle(result)
    @output = [ true,
		            "settled",
								result['authResponse'],
								result['authCode'],
								result['referenceNumber']
			        ]
  end
	def Credit(result)
    @output = [ true,
		            "credited",
								result['authResponse'],
								result['creditAmount'],
								result['referenceNumber']
			        ]
  end

	def Void(result)
		@output = [ true,
								"voided",
								result['authResponse'],
								result['referenceNumber']
							]

  end
	def AchCredit(result)
		@output = [ true,
								"credited",
								result['authResponse'],
								result['creditAmount'],
								result['referenceNumber'],
								result['orderId']
							]
  end
	def AchDebit(result)
		@output = [ true,
								"debited",
								result['authResponse'],
								result['referenceNumber'],
						    result['orderId']
					    ]
  end


############# Update Vault ##################

	def VaultUpdate(result)
    if (result.has_key? 'recordsUpdated')
			if (result['recordsUpdated'] > 0)
				@output = [ true,
				            "#{result['recordsUpdated']} Records Updated"
									]
			end
    end
  end

################## Deletion #######################

  def VaultDeleteCCRecord(result)
		if result['recordsDeleted'] > 0
			@output = [ true,
									"Credit Card Deleted from Vault"
								]
		else
			@output = [ false, "Problem: Not Deleted in Vault"]
	  end

  end
  def VaultDeleteContainerAndAllAsscData(result)
    if result['deletedCount'] > 0
  		@output = [ true,
									"Card and Vault Deleted"
								]
    end

  end
  def AchDeleteCategory(result)
    if (result['success'] == true)
      @output = [ true,
			            "Record_Deleted"
								]
		end
  end

#################### Query ########################
	def Query(result)
  ##### query for transactions -- not sure what we would want returned
  end
  def VaultQueryCCRecord(result)
		@output = [ false, "", "Card Not Found" ]
    if (result.has_key? "creditCardRecords")
		  if (result['creditCardRecords'].any? == true )
        data = result['creditCardRecords'][0]
			  @output = [ true,
										"Card_Data_Found",
										data['id'] ||= "",
										data['vaultKey'] ||= "",
										data['cardNoLast4'] ||= "",
										data['cardExpMM'] ||= "",
										data['cardExpYY'] ||= "",
										data['cardType'] ||= "",
										data['name'] ||= "",
										data['city'] ||= "",
										data['state'] ||= "",
										data['street'] ||= "",
										data['street2'] ||= "",
										data['zip'] ||= "",
									]
      end
	  end
	end

  def VaultQueryVault(result)
		$j = 2

		##may need to change if we start doing ACHs
		if (result.has_key? "VaultContainers")
			if (result['VaultContainers'].any? == true)
				result['VaultContainers'].each do |v_cont|
					if (v_cont['vaultCreditCards'].any? == true)
						@output[0] = true
						@output[1] = "Card Deleted but Vault has Other Cards"
						v_cont['vaultCreditCards'].each do |data|
							@output[$j] = "vaultkey:#{data['vaultKey'].to_s}"
								$j+= 1
							@output[$j] = "token:#{data['id'].to_s}"
								$j+= 1
						end
				  end
			  end
			end
		end
  end

	def VaultQueryAchRecord(result)
 ##not active
  end

	def AchGetCategories(result)
 ##not active
end


end




