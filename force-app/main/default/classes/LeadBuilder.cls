public class LeadBuilder {
    private final ModelRetriever modelRetriever;
    private Lead newLead;
    
    public LeadBuilder(ModelRetriever modelRetriever)
    {
        this.modelRetriever = modelRetriever;
    }
    
    
    public Lead Build(Request__c requestRecord, Account existingAccount, AvokaFormInformation avokaFormInformation)
    {
        System.debug('<<< Inside LeadBuilder >>> ' + requestRecord);
        this.newLead = new Lead();
        if(avokaFormInformation.RecordType != null) {
            newLead.RecordTypeId = avokaFormInformation.RecordType.Id; 
        }
        this.SetPersonalInformation(requestRecord, existingAccount, avokaFormInformation);
        this.SetPurchaseDetails(requestRecord);
        this.SetContactDetails(requestRecord);
        this.SetVehicleData(requestRecord, avokaFormInformation.Brand);
        this.SetOwner(requestRecord, avokaFormInformation);
        this.SetType(requestRecord);
        return newLead;
    }
    
    
    private void SetPersonalInformation(Request__c requestRecord, Account existingAccount, AvokaFormInformation avokaFormInformation)
    {
        newLead.Salutation = requestRecord.Salutation__c;
        newLead.FirstName = requestRecord.First_Name__c;
        newLead.LastName = requestRecord.Last_Name__c;
        newLead.Guest_Name__c = requestRecord.Guest_Name__c;
        newLead.Company = requestRecord.Company_Name__c;
        newLead.LeadSource = 'OEM Web & Digital';
        newLead.Account_Type__c = 'Private';
        
        newLead.Language__c = requestRecord.Language__c;
        newLead.City = requestRecord.City__c;
        
        newLead.Account__c = existingAccount.Id;
        newLead.CurrencyIsoCode = avokaFormInformation.RecordCurrency;
        newLead.Country_ISO_Code__c = avokaFormInformation.CountryISOCode;
    }
    
    
    private void SetPurchaseDetails(Request__c requestRecord)
    {
        newLead.In_Market_Date__c = requestRecord.Expected_Date_of_Purchase__c;
        newLead.Test_Drive_Preferred_Date_Time__c = requestRecord.Test_Drive_Date__c;
        newLead.Trade_In__c = requestRecord.Trade_In__c;
        
        newLead.Finance_Interest__c = requestRecord.Finance_Interest__c;
        newLead.Feedback__c = requestRecord.Feedback__c;
        
        newLead.Type__c = 'Product';
        newLead.Sub_Type__c = 'Retail';
        newLead.Purchase_Type__c = 'New Vehicle';
    }
    
    
    private void SetContactDetails(Request__c requestRecord)
    {
        newLead.MobilePhone = requestRecord.Mobile__c;
        newLead.Email = requestRecord.Email__c;
        
        newLead.HasOptedOutOfEmail = !requestRecord.Consent_Email__c;
        newLead.Whitemail_Opt_Out__c = !requestRecord.Consent_Post__c;
        newLead.DoNotCall = !requestRecord.Consent_Phone__c;
        newLead.et4ae5__HasOptedOutOfMobile__c = !requestRecord.Consent_SMS__c;
        
        //newLead.SMS_Opt_Out__c = True;
        
        newLead.Preferred_Contact_Time__c = requestRecord.Preferred_Contact_Time__c;
        newLead.Preferred_Retailer__c = requestRecord.Preferred_Retailer__c;
    }
    
    
    private void SetVehicleData(Request__c requestRecord, Vehicle_Specification__c brand)
    { 
        newLead.Current_Vehicle__c = requestRecord.Current_Vehicle__c;
        newLead.Current_Vehicle_Brand__c = requestRecord.Current_Vehicle_Brand__c;
        if(brand == null) { return; }
        newLead.Brand__c = brand.Id;
        
        newLead.Description = requestRecord.Description__c;
        if(!requestRecord.Request_Source__c.contains('peb')){
            newLead.Primary_Model_Interest__c = modelRetriever.RetrieveByName(requestRecord.Primary_Model_Of_Interest_Text__c, brand).Id;
        }else{
            newLead.Primary_Model_Interest__c = modelRetriever.RetrieveByBrandCode(requestRecord.Primary_Model_Of_Interest_Text__c, brand).Id;
        }
        
        if(newLead.Primary_Model_Interest__c == null){
            newLead.Primary_Model_Interest__c = null;
            return;
        }
        
    }
    
    private void SetOwner(Request__c requestRecord, AvokaFormInformation avokaFormInformation){
        String errors = '';
        try{
            string queueId = '';
            if(requestRecord.Assign_To_Queue__c == true){
                
                Avoka_Assign_to_Queue__mdt avokaCustomQueueSetting = [SELECT Queue_Name__c 
                                                                      FROM Avoka_Assign_to_Queue__mdt where DeveloperName =: avokaFormInformation.CountryISOCode limit 1];
                if(avokaCustomQueueSetting != null){
                    Id queueResult = [Select Id from Group Where Name=: avokaCustomQueueSetting.Queue_Name__c AND Type = 'Queue' limit 1].id;
                    queueId = queueResult;
                }else{
                    queueId ='';
                }            
                
            }else{
                if (requestRecord.Preferred_Retailer_Code__c != null && avokaFormInformation.AssignToRetailerQueue)
                {
                    string ciCode = requestRecord.Preferred_Retailer_Code__c;
                    string brandPrefix = '';           
                    if(ciCode != null && ciCode.length()==5){
                        if(requestRecord.Brand__c == 'Land Rover'){
                            brandPrefix = 'LR';
                        }else{
                            brandPrefix = 'J';
                        }
                        ciCode = brandprefix + avokaFormInformation.CountryISOCode + ciCode;
                    }
                    List<Account> preferredRetailer = [select Id, Parent.Queue_ID__c, Retailer_Status__c from Account where Parent.Queue_ID__c != null 
                                                       AND Secondary_Dealer_Code__c = :ciCode limit 1];
                    if(preferredRetailer.size() == 0){
                        queueId = '';                        
                    }
                    else if(preferredRetailer[0].Retailer_Status__c == 'Trading') {
                        queueId = preferredRetailer[0].Parent.Queue_ID__c;
                    }
                }else{
                    if(requestRecord.Preferred_Retailer_Code__c !=null){
                        queueId = retailerContactRequestRetriever.GetQueueId(requestRecord);
                    }
                }
            }
            
            if(String.isEmpty(queueId))
            {
                queueId = avokaFormInformation.NSCQueue.Id;
            }
            newLead.OwnerId = queueId;
        }catch (Exception e){
            errors += e.getMessage() + ' --- ' + e.getStackTraceString() + '\n';
        }
        
    }
    
    private void SetType(Request__c requestRecord)
    {
        if(String.isEmpty(newLead.Purchase_Type__c))
        {
            newLead.Type__c = '';
        }
    }
}