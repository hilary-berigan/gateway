class ResponseToFPHandler

  def initialize(result)
    @result = result
    @output = []
  end

  def handle_response(action)
    is_error, status = error?(@result)

    if is_error == true
      errors_and_validation(status, @result)
    else
      handle_success(action, @result)
    end
  end
  
  def error?(result)
    return true, 'Error' if result.key?('isError') && result['isError'] == true   
    return true, 'Validation Issue' if result.key?('validationHasFailed') && result['validationHasFailed'] == true
    return false, 'Success'
  end

  def errors_and_validation(status,values)
    x = 2
    output = []
    output[0] = false

    if status == 'Validation Issue'
      output[1] = 'validation_issue'
      values['validationFailures'].each do |values2|
        output[x] = values2['message'].to_s
      end
    elsif status == 'Error'
      output[1] = 'error'
      values['errorMessages'].each do |values2|
        output[x] = values2.to_s
        x += 1
      end
    end
    output
  end

  def handle_success(action, result)
    case action
    when 'AuthUsingVault'
      action = 'Auth'

    when 'SaleUsingVault'
      action = 'Sale'

    when 'AchCreditUsingVault'
      action = 'AchCredit'

    when 'AchDebitUsingVault'
      action = 'AchDebit'

    when 'AchVoid'
      action = 'Void'

    when 'VaultUpdateAchRecord' || 'VaultUpdateCCRecord' || 'VaultUpdateContainer'
      action = 'VaultUpdate'

    when 'VaultDeleteAchRecord'
      action = 'VaultDeleteCCRecord'
    end
    output = send(action, result['data'])
    output = [false, 'ProblemIT', result.to_s] if output == false
    output
  end

###############Creation Methods ################

  def VaultCreateCCRecord(result)
    id = result['id'].to_s
    [true, 'CC_Created', id]
  end

  def VaultCreateAchRecord(result)
    ##not active yet
  end

  def AchCreateCategory(result)
    ##not active yet
  end

############## Transaction Methods ##############
  def Auth(result)
    [true,
     'approved',
     result['authResponse'],
     result['authCode'],
     result['referenceNumber'],
     result['orderId']]
  end

  def Sale(result)
    if result['cardDeclinedNo'].to_s != ''
      [false,
       'declined',
       result['declinedMessage']]
    else
      [true,
       'completed',
       result['authResponse'],
       result['authCode'],
       result['referenceNumber'],
       result['orderId']]
    end
  end

  def Settle(result)
    [true,
     'settled',
     result['authResponse'],
     result['authCode'],
     result['referenceNumber']]
  end

  def Credit(result)
    [true,
     'credited',
     result['authResponse'],
     result['creditAmount'],
     result['referenceNumber']]
  end

  def Void(result)
    [true,
     'voided',
     result['authResponse'],
     result['referenceNumber']]
  end

  def AchCredit(result)
    [true,
     'credited',
     result['authResponse'],
     result['creditAmount'],
     result['referenceNumber'],
     result['orderId']]
  end
  def AchDebit(result)
    [true,
     'debited',
     result['authResponse'],
     result['referenceNumber'],
     result['orderId']]
  end


############# Update Vault ##################

  def VaultUpdate(result)
    return false unless result.key? 'recordsUpdated'
    return false unless result['recordsUpdated'] > 0
    [true, "#{result['recordsUpdated']} Records Updated"]
  end

################## Deletion #######################

  def VaultDeleteCCRecord(result)
    if result['recordsDeleted'] > 0
      [true, 'Credit Card Deleted from Vault']
    else
      [false, 'Problem: Not Deleted in Vault']
    end
  end

  def VaultDeleteContainerAndAllAsscData(result)
    return false unless result['deletedCount'] > 0
    [true, 'Card and Vault Deleted']
  end

  def AchDeleteCategory(result)
    return false unless result['success'] == true
    [true, 'Record_Deleted']
  end

#################### Query ########################
  def Query(result)
  ##### query for transactions -- not sure what we would want returned
  end

  def VaultQueryCCRecord(result)
    output = [false, '', 'Card Not Found']
    return output unless result.key? 'creditCardRecords'
    return output unless result['creditCardRecords'].any? == true 
    data = result['creditCardRecords'][0]
    [true,
     'Card_Data_Found',
     data['id'] || '',
     data['vaultKey'] || '',
     data['cardNoLast4'] || '',
     data['cardExpMM'] || '',
     data['cardExpYY'] || '',
     data['cardType'] || '',
     data['name'] || '',
     data['city'] || '',
     data['state'] || '',
     data['street'] || '',
     data['street2'] || '',
     data['zip'] || '']
  end

  def VaultQueryVault(result)
    j = 2
    output = []
    ##may need to change if we start doing ACHs
    return unless result.key? 'VaultContainers'
    return unless result['VaultContainers'].any? == true
    result['VaultContainers'].each do |v_cont|
      next unless v_cont['vaultCreditCards'].any? == true
      output[0] = true
      output[1] = 'Card Deleted but Vault has Other Cards'
      v_cont['vaultCreditCards'].each do |data|
        output[j] = "vaultkey:#{data['vaultKey']}"
        j += 1
        output[j] = "token:#{data['id']}"
        j += 1
      end
    end
    output
  end

  def VaultQueryAchRecord(result)   end
   ##not active

  def AchGetCategories(result) end
   ##not active
end




