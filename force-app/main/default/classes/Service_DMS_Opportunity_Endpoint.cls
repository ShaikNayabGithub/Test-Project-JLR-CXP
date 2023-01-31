@RestResource(urlMapping='/OpportunityOrders')
global class Service_DMS_Opportunity_Endpoint { 

    @HttpGet
    global static Service_DMS_Opportunity_Data.GetOpportunities_Response getWonOpportunities(){
        String dealerCode = RestContext.request.params.get('dealerCode');
        String version = RestContext.request.params.get('version');//?? what do we do with version

        Integration_Log__c log = new Integration_Log__c();
        log.service__c='NBS Integration';  
                
        Service_DMS_Opportunity_Data.GetOpportunities_Response response = new Service_DMS_Opportunity_Data.GetOpportunities_Response();
        if(String.isBlank(dealerCode)){
            response.Error = 'Please supply a dealer code';//LB - replace with label
            SaveLog(log,response);
            return response;
        }

        String retailerId = DecryptDealerCode(dealerCode );
        List<Account> retailerAccount = [SELECT Id
                                        FROM Account
                                        WHERE Id=:retailerId
                                        ];
                                        

        if(retailerAccount.isEmpty()){
            response.Error = 'Invalid dealer code';         
            SaveLog(log,response);
            return response;
        }           

        Service_DMS_Opportunity_DataBuilder builder = new Service_DMS_Opportunity_DataBuilder(retailerAccount[0].id);
        response.CXPSalesOrders = builder.Build();
        if(response.CXPSalesOrders != null){
            response.OpportunityCount = response.CXPSalesOrders.size();
        }

        SaveLog(log,response);
        return response;
    }

    private static String SaveLog(Integration_Log__c log, Service_RestResponse response){
        log.response__c = JSON.serialize(response);     
        
        if(String.isBlank(response.Error)){
            log.status__c = 'Success';
        }else{
            log.status__c = 'Error';
        }

        log.headers__c = JSON.serialize(RestContext.request.Headers);
        log.Http_Method__c = RestContext.request.httpMethod;
        log.requestURI__c = RestContext.request.requestURI;
        log.Resource_Path__c = RestContext.request.resourcePath;
        
        log.ip_address__c = RestContext.request.remoteAddress;    
        Database.insert(log,false);
        return log.Name;
    }
 
    @HttpPatch
    global static Service_DMS_Opportunity_Data.UpdateOpportunityResponse updateOpportunity(Service_DMS_Opportunity_Data.UpdateOpportunityRequest request){
        Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = new Service_DMS_Opportunity_Data.UpdateOpportunityResponse();
        Integration_Log__c log = new Integration_Log__c();
        log.service__c='NBS Integration';  

        try{    
            log.request__c = JSON.serialize(request);       

            Service_DMS_Opportunity_Updater opportunityUpdater = new Service_DMS_Opportunity_Updater(request);
            response = opportunityUpdater.UpdateOpportunities();
            SaveLog(log,response);
        }
        catch ( Exception e){
            String error =  e.getMessage() + '\n\n' + e.getStackTraceString() + '\n\n' + e.getLineNumber();
            log.System_Error__c = error;
            response.Error = 'System Error';
            String errorLog = SaveLog(log,response);

            response.Error += ' ' + errorLog;
        }
        
        return response;
    }


    public static Blob GetKey(){

        List<System_Settings__mdt> key = [SELECT Key__c from System_Settings__mdt 
                                            WHERE DeveloperName=    'DMS_BR_Encryption_Key'];

        if(!key.isEmpty()){
            return EncodingUtil.base64Decode(key[0].key__c);
        }
        return null;
    }

    public static String DecryptDealerCode(String encryptedValue){
        Blob decode = EncodingUtil.base64Decode(encryptedValue);

        Blob decrypted = Crypto.decryptWithManagedIV('AES256', GetKey(), decode );
        return decrypted.toString();
    }

    /*
    private static Map<String,Id> GetDealerCodes(String market){
        String cacheVariableName = 'dealerCodes' + market;
        Map<String,Id> dealerCodes = new Map<String,Id>();

        if(cache.Org.contains(cacheVariableName)){
            return ( Map<String,Id>)cache.Org.get(cacheVariableName);
        }
        else{
            List<Account> retailerAccounts = [SELECT id, Dealer_CI_Code__c, Dealer_CI_Code_2__c
                                                FROM Account 
                                                WHERE Queue_id__c != null 
                                                    AND Country_Iso_Code__c =: market
                                            ];
            
            for(Account account : retailerAccounts){
                if(!dealerCodes.containsKey(account.Dealer_CI_Code__c)){
                    dealerCodes.put(account.Dealer_CI_Code__c, account.Id);
                }
                if(!dealerCodes.containsKey(account.Dealer_CI_Code_2__c)){
                    dealerCodes.put(account.Dealer_CI_Code_2__c, account.Id);
                }
            }

            if(dealerCodes.size() > 0){
                Cache.Org.put(cacheVariableName, dealerCodes);
            }
        }
        return dealerCodes;      
    }
    */
}