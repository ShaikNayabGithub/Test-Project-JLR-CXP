global class DealerDBService {
    webservice static Response UpsertAccount(RetailerAccount retailerAccount)
    {
        Response response = new Response();
        
        try
        {
            DealerDB_UpsertAccountHandler upsertHandler = DealerDB_UpsertAccountHandler_Factory.Create();
            upsertHandler.UpsertAccount(retailerAccount);
        }
        catch (DealerDB_InvalidDataException e)
        {
            response.SetError(30001, e.getMessage());
            SendErrorEmail(retailerAccount,e);
        }
        catch (Exception e)
        {
            response.SetError(30002, e.getMessage());
            SendErrorEmail(retailerAccount,e);
        }
        Finally{
            
            List<Logger.Log> logs = Logger.getLogs();
            if(logs.size() > 0){
                for(Logger.Log l : logs){
                    if(response != null)
                        if(response.ResponseMessage == null ){
                            response.ResponseMessage = l.message;
                        }else{
                            response.ResponseMessage += l.message;
                        }
                }
            }
            
            
            Integration_log__c log= new Integration_log__c();
            log.request__c=String.valueOf(retailerAccount);
            log.response__c=String.valueOf(response);
            log.service__c='DDB';
            
            if(response.isSuccess==true)
                log.status__c='Success';
            else
                log.status__c='Error';
            
            insert log;
        }
        
        return response;
    }
    
    private static void SendErrorEmail(RetailerAccount retailerAccount, Exception ex){
        List<String> recipients = new List<String>();
        System_Settings__mdt errorRecipients = [Select Value__c from System_Settings__mdt
                                                Where DeveloperName = 'DealerDB_Email_Failure_Alert'];
        
        if(String.isNotBlank(errorRecipients.Value__c)){
            recipients.addAll((errorRecipients.Value__c).split(','));
        }
        if (recipients.size() == 0) return;
        
        String html = '<pre>'+ex.getMessage()+'</pre><hr/><pre>'+json.serializePretty(String.ValueOf(ex))+'</pre><br/><br/>';
        html += '<h3>Original Message</h3><pre>'+json.serialize(retailerAccount)+'</pre>';
        
        List<Logger.Log> logs = Logger.getLogs();
        
        if(logs.size() > 0){
            String logHtml = '<h3>Logs</h3><table>';
            
            for(Logger.Log l : logs){
                logHtml += '<tr><td>'+l.timestamp+'</td><td>' + l.level + '</td><td>' + l.message + '</td></tr>';
            }
            
            logHtml += '</table>';
            html += '<br/><br/>' + logHtml;
        }
        
        
        EmailUtility.SendEmail(recipients, 'DealerDBService Exception', 'DealerDBService.cls Exception - ' + system.now() + ' - ' + UserInfo.getUserName(),html);
        
    }
    
    global class RetailerAccount{
        webservice String Dealer_CI_Code;
        webservice String Brand;
        webservice String ISOCode;
        webservice String Distribution_Code;
        webservice String Name;
        webservice String Billing_Street;
        webservice String Billing_City;
        webservice String Billing_State;
        webservice String Billing_Postal_Code;
        webservice String Billing_Country;
        webservice String Phone;
        webservice String Fax;
        webservice String Website;
        webservice String Retailer_Type;
        webservice String Trading_Name;
        webservice String Trading_Partner_Type;
        webservice String Started_Trading_Date;//date yyyy-mm-dd
        webservice String Stopped_Trading_Date;//date yyyy-mm-dd
        webservice Boolean Other_Brands_Flag;
        webservice String Legal_Entity_Name;
        webservice String Legal_Entity_ID;
        webservice String Legal_Entity_Street;
        webservice String Legal_Entity_City;
        webservice String Legal_Entity_State;
        webservice String Legal_Entity_Postal_Code;
        webservice String Legal_Entity_Country;
        webservice String Legal_Entity_Start_Date;
        webservice String Legal_Entity_End_Date;
        webservice String UHC_Name;
        
        
        private String Retailer_Status { get {//workflow?
            if(String.isNotBlank(Stopped_Trading_Date)){
                return 'Not Trading';
            }
            return 'Trading';
        } 
                                       }
        
        public Account ToSFAccount()
        {
            Account account = new Account();
            
            account.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            account.Name = Name;
            account.BillingStreet = Billing_Street;
            account.BillingCity = Billing_City;
            account.BillingState = Billing_State;
            account.BillingPostalCode = Billing_Postal_Code;
            account.BillingCountry = Billing_Country;
            account.Phone = Phone;
            account.Fax = Fax;
            account.Website = Website;
            if(Retailer_Type != null && Retailer_Type.equalsIgnoreCase('Sales Dealer')){
                account.Retailer_Type__c = 'Main Dealer';
            }else{
                account.Retailer_Type__c = Retailer_Type;
            }
            system.debug('11--> '+account.Retailer_Type__c);
            account.Retailer_Status__c = Retailer_Status;//workflow?
            account.Trading_Name__c = Trading_Name;
            account.Trading_Partner_Type__c = Trading_Partner_Type;
            account.Started_Trading__c = ParseOptionalDate(Started_Trading_Date);
            account.Stopped_Trading__c = ParseOptionalDate(Stopped_Trading_Date);
            account.Country_ISO_Code__c = ISOCode;
            account.Record_Sub_Type__c = 'Branded';
            account.Region_or_Market__c = CountryMapping_Utilities.CountryMappingsByISOCode.get(ISOCode).aop_Region_or_Market__c;
            if(Other_Brands_Flag != null){ account.Other_Brands__c = Other_Brands_Flag; }
            
            if(Brand == 'J') {
                account.Dealer_CI_Code__c = Dealer_CI_Code;
            } else if(Brand == 'LR'){
                account.Dealer_CI_Code_2__c = Dealer_CI_Code;
            }
            account.Alternative_Key__c = ISOCode + Dealer_CI_Code;//new
            account.Primary_Dealer_Code__c = Brand + Distribution_Code + Dealer_CI_Code;
            account.Secondary_Dealer_Code__c = Brand + ISOCode + Dealer_CI_Code;
            account.Brand__c = DealerDB_BrandAdapter.GetSFValue(Brand);
            
            MarketDefaultOwnerMapping__c defaultOwnerMapping = MarketDefaultOwnerMapping__c.getInstance(account.Region_or_Market__c);
            if(defaultOwnerMapping != null) {
                List<User> defaultOwners = [Select Id From User Where Name=:defaultOwnerMapping.OwnerFullName__c];
                if(defaultOwners.Size() != 0) {
                    account.OwnerId = defaultOwners[0].Id;
                }
            }
            
            return account;
        }
        
        private Date ParseOptionalDate(String dateToParse){
            if(String.isEmpty(dateToParse)) { return null; }
            return Date.valueOf(dateToParse);
        }
    }
    
    global class Response{
        webservice boolean IsSuccess;
        webservice integer ErrorCode;
        webservice string ResponseMessage;
        
        public Response()
        {
            IsSuccess = true;
        }
        
        public void SetError(integer errorCode, string responseMessage)
        {
            this.IsSuccess = false;
            this.ErrorCode = errorCode;
            this.ResponseMessage = responseMessage;
        }
    }
}