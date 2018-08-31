class PayloadCreator

  def make_load(action,input_array)
    load = send(action,input_array)
  end

###############Creation Methods ################
  def VaultCreateCCRecord(input)
		data = {
			'vaultKey' => input[1] || "",
			'cardNumber' => input[2] || "", # || '36438999960016'
			'cardExpMonth' => input[3] || "", # || '08'
			'cardExpYear' => input[4] || "", # || '17'
			'cVV' => input[5] || "",# ||   '123'
			'cardType' => input[6] || "", #|| "AMEX"
			'ownerName' => input[7] || "", #|| "hilary berigan"
			'ownerStreet' => input[8] || "",# || "1 smile st"
			'ownerStreet2' =>  input[9] || "",# || ""
			'ownerCity' => input[10] || "", #|| "burlington"
			'ownerState' => input[11] || "", #|| "WI"
			'ownerZip' => input[12] || "", #|| "53105"
			'ownerCountry' => input[13] || ""# || "USA"
		}
  end

	def VaultCreateAchRecord(input)
		data = {
      'vaultKey' => input[1] || "",
			'aba' => input[2] || "",
			'accountType' => input[3] || "",
			'dda' => input[4] || "",
			'ownerName' => input[5] || "",
			'ownerStreet' => input[6] || "",
			'ownerStreet2' => input[7] || "",
			'ownerCity' => input[8] || "",
			'ownerState' => input[9] || "",
			'ownerZip' => input[10] || "",
			'ownerCountry' => input[11] || "",
			'ownerEmail' => input[12] || "",
			'ownerPhone' => input[13] || ""
		 }
  end

	def AchCreateCategory(input)
		data = {
      'achCategoryText' => input[1] || "",
			'achClassCode' => input[2] || "",
			'achEntry' => input[3] || ""
		 }
  end

############## Transaction Methods ##############

  def Auth(input)
		#not in use yet - would be used for processing Drs. cards if they paid on app
		data = 	{
		  'autoGenerateOrderId' => true,
	    'cardNumber' => input[1] || "",
      'cardExpMonth' => input[2] || "",
      'cardExpYear' => input[3] || "",
			'cVV' => input[4] || "",
		  'transactionAmount' => input[5] || "",
			'ownerName' => input[6] || "",
			'ownerStreet' => input[7] || "",
			'ownerStreet2' => input[8] || "",
			'ownerCity' => input[9] || "",
			'ownerState' => input[10] || "",
			'ownerZip' => input[11] || "",
			'ownerCountry' => input[12] || "",
			'preventPartial' => true
		}
  end
	def Sale(input)
		#not in use yet - would be used for processing Drs. cards if they paid on app
		data = 	{
		  'autoGenerateOrderId' => true,
	    'cardNumber' => input[1] || "",
      'cardExpMonth' => input[2] || "",
      'cardExpYear' => input[3] || "",
			'cvv' => input[4] || "",
		  'transactionAmount' => input[5] || "",
			'ownerName' => input[6] || "",
			'ownerStreet' => input[7] || "",
			'ownerStreet2' => input[8] || "",
			'ownerCity' => input[9] || "",
			'ownerState' => input[10] || "",
			'ownerZip' => input[11] || "",
			'ownerCountry' => input[12] || "",
			'preventPartial' => true
		}
  end

	def Settle(input)
		data = {
      'refNumber' => input[1] || "",
			'transactionAmount' => input[2] || ""
		 }
  end
	def Credit(input)
		data = {
      'refNumber' => input[1] || "",
			'transactionAmount' => input[2] || ""
		 }
  end

	def Void(input)
		data = {
      'refNumber' => input[1] || ""
		 }
  end
	def AchCredit(input)
		data = {
			'autoGenerateOrderId' => true,
			'transactionAmount' => input[1] || "",
			'aba' => input[2] || "",
			'accountType' => input[3] || "",
			'dda' => input[4] || "",
			'ownerName' => input[5] || "",
			'ownerStreet' => input[6] || "",
			'ownerStreet2' => input[7] || "",
			'ownerCity' => input[8] || "",
			'ownerState' => input[9] || "",
			'ownerZip' => input[10] || "",
			'ownerCountry' => input[11] || "",
			'ownerEmail' => input[12] || "",
			'ownerPhone' => input[13] || "",
			'categoryText' => input[14] || ""
		 }
  end
	def AchDebit(input)
		data = {
			'autoGenerateOrderId' => true,
			'transactionAmount' => input[1] || "",
			'aba' => input[2] || "",
			'accountType' => input[3] || "",
			'dda' => input[4] || "",
			'ownerName' => input[5] || "",
			'ownerStreet' => input[6] || "",
			'ownerStreet2' => input[7] || "",
			'ownerCity' => input[8] || "",
			'ownerState' => input[9] || "",
			'ownerZip' => input[10] || "",
			'ownerCountry' => input[11] || "",
			'ownerEmail' => input[12] || "",
			'ownerPhone' => input[13] || "",
			'categoryText' => input[14] || ""
		 }
  end
	def AchVoid(input)
		data = {
      'refNumber' => input[1]
		 }
  end

############## Transactions Using Vault #############

  def SaleUsingVault(input)
		data = {
			'vaultKey' => input[1] || "",
			'vaultId' => input[2] || "",
			'transactionAmount' => input[3] || "",
			'orderId' => input[4] || "",
			'preventPartial' => true
		}
  end
	def AuthUsingVault(input)
		data = {
			'vaultKey' => input[1] || "",
			'vaultId' => input[2] || "",
			'transactionAmount' => input[3] || "",
			'orderId' => input[4] || "",
			'preventPartial' => true
		 }
	end
  def AchCreditUsingVault(input)
		data = {
      'vaultKey' => input[1] || "",
			'vaultId' => input[2] || "",
			'categoryText' => input[3] || "",
			'autoGenerateOrderId' => true
		 }
  end
	def AchDebitUsingVault(input)
		data = {
      'vaultKey' => input[1] || "",
			'vaultId' => input[2] || "",
			'categoryText' => input[3] || "",
			'autoGenerateOrderId' => true
		 }
  end

############# Update Vault ##################

	def VaultUpdateContainer(input)
		data = {
      'vaultKey' => input[1] || "",
			'vaultPrimaryContactEmail' => input[2] || "",
			'vaultPrimaryContactName' => input[3] || "",
			'vaultPrimaryContactPhone' => input[4] || ""
		 }
  end
	def VaultUpdateCCRecord(input)
		data = {
      'vaultKey' => input[1] || "",
			'id' => input[2] || "",
			'cardExpMonth' => input[3] || "",
			'cardExpYear' => input[4] || "",
			'ownerName' => input[5] || "",
			'ownerStreet' => input[6] || "",
			'ownerStreet2' => input[7] || "",
			'ownerCity' => input[8] || "",
			'ownerState' => input[9] || "",
			'ownerZip' => input[10] || "",
			'ownerCountry' => input[11] || ""
		 }
  end
		def VaultUpdateAchRecord(input)
		data = {
      'vaultKey' => input[1] || "",
			'id' => input[2] || "",
			'accountType' => input[3] || "",
			'ownerName' => input[4] || "",
			'ownerStreet' => input[5] || "",
			'ownerStreet2' => input[6] || "",
			'ownerCity' => input[7] || "",
			'ownerState' => input[8] || "",
			'ownerZip' => input[9] || "",
			'ownerCountry' => input[10] || "",
			'ownerEmail' => input[11] || "",
			'ownerPhone' => input[12] || ""
		 }
  end
################## Deletion #######################

  def VaultDeleteCCRecord(input)
		data = {
			'vaultKey' => input[1].to_s || "",
		  'id' => input[2].to_s || ""
     }
  end
  def VaultDeleteContainerAndAllAsscData(input)
		data = {
			'vaultKey' => input[1] || ""
		}
  end
  def VaultDeleteAchRecord(input)
		data = {
      'vaultKey' => input[1] || "",
			'id' => input[2] || ""
		 }
  end
  def AchDeleteCategory(input)
		data = {
      'achCategoryText' => input[1] || ""
		 }
  end

#################### Query ########################
	def Query(input)
		data = {
      'queryTransType' => input[1] || "",
			'queryTransStatus' => input[2] || ""

			####need more here
		 }
  end
  def VaultQueryCCRecord(input)
    data = {
			'queryVaultKey' => input[1] ||= "",
			'queryCCLast4' => input[2] ||= ""
		}
  end

  def VaultQueryVault(input)
    data = {
			'queryVaultKey' => input[1] || "",
		}
  end

	def VaultQueryAchRecord(input)
		data = {
      'queryVaultKey' => input[1] || "",
			'queryAba' => input[2] || "",
			'queryDda' => input[3] || "",
		 }
  end

	def AchGetCategories(input)
		data = {
		 }
  end
end
