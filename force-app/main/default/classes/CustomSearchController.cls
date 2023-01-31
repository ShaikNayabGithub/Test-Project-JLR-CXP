public without sharing class CustomSearchController {
    
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();    
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id corporateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    public static Id opportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Process_with_RDA').getRecordTypeId();
    public static User loggedinUser = [SELECT Id, AccountId,Market__c, Contact.AccountId,ContactId,Contact.Account.Is_Accounts_Not_Available_to_All__c,CurrencyIsoCode,Country  FROM User WHERE Id = :userinfo.getUserId() 
                                       AND ContactId != null];
    Public static PickList_Value_Settings__mdt pickListValueList = [SELECT Opportunity_PurchaseType_Values__c,Opportunity_Stage_Values__c FROM PickList_Value_Settings__mdt LIMIT 1];
    
    @AuraEnabled
    public static List< Map<String,String>> searchModelList(){
        List< Map<String,String>> optionsList= new List<Map<String,String>>();         
        List<String> modelNamesList = getModelAlternativeValues();
        String maket = '%'+loggedinUser.Market__c+'%';
        for(Vehicle_Specification__c model: [SELECT Id, Name FROM Vehicle_Specification__c WHERE Recordtype.name = 'Model' AND Name IN :modelNamesList AND
                                             Is_Currently_Sold__c= true AND (Make__r.Name = 'Jaguar' OR Make__r.Name = 'Land Rover') AND ( Not Not_Sold_Market_List__c LIKE :maket ) ORDER BY Sequence_Order__c ASC NULLS LAST]){
                                                 Map<String,String> optionsmap= new Map<String,String>();
                                                 optionsmap.put('label', model.Name);
                                                 optionsmap.put('value', model.Id);           
                                                 optionsList.add(optionsmap);
                                             } 
        return optionsList;        
    }
    
     @AuraEnabled
    public static List<String> getModelAlternativeValues(){
        List<String> optionsList= new List<String>();         
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get('Product2');
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap(); 
        Schema.DescribeFieldResult fieldResult = fieldMap.get('Model_Alternative__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){           
                optionsList.add(pickListVal.getValue());
        } 
        return optionsList;        
    }
    
    @AuraEnabled
    public static List< Map<String,String>> getPriceBookList(){
        List< Map<String,String>> optionsList= new List<Map<String,String>>();
        for(CountryToPricebook__mdt pb: [SELECT Id, Label,DeveloperName,Pricebook_Name__c FROM CountryToPricebook__mdt WHERE DeveloperName = :loggedinUser.Country] ){
            for(String pbName: pb.Pricebook_Name__c.split(';') ){
                Map<String,String> optionsmap= new Map<String,String>();
                optionsmap.put('label', pbName);
                optionsmap.put('value', pbName);           
                optionsList.add(optionsmap);
            }
            
        } 
        return optionsList;        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getPurchaseTypePickListValues(){
        String valueList =''+pickListValueList.Opportunity_PurchaseType_Values__c;
        List<String> purchaseTypeValues = valueList.split(',');
        List< Map<String,String>> optionsList= new List<Map<String,String>>();
        Map<String,String> prickListValuesMap = SchemaUtility.getPickListValues('Opportunity', 'Purchase_Type__c');
        for(String picklistValues: prickListValuesMap.keySet()){
            if(purchaseTypeValues.contains(prickListValuesMap.get(picklistValues))){                
                Map<String,String> optionsmap= new Map<String,String>();
                optionsmap.put('label', picklistValues);
                optionsmap.put('value', prickListValuesMap.get(picklistValues));           
                optionsList.add(optionsmap);
            }
        } 
        return optionsList;        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getStageTypePickListValues(){
        String valueList =''+pickListValueList.Opportunity_Stage_Values__c;
        List<String> stageTypeValues = valueList.split(',');
        List< Map<String,String>> optionsList= new List<Map<String,String>>();
        // Map<String,String> prickListValuesMap = SchemaUtility.getPickListValues('Opportunity', 'StageName');
        // for(String picklistValues: prickListValuesMap.keySet()){
        for(opportunitystage picklistValues : [select Id,MasterLabel,ApiName,DefaultProbability from opportunitystage order By DefaultProbability ASC]){
            if(stageTypeValues.contains(picklistValues.ApiName)){                
                Map<String,String> optionsmap= new Map<String,String>();
                optionsmap.put('label', picklistValues.MasterLabel);
                optionsmap.put('value', picklistValues.ApiName);           
                optionsList.add(optionsmap);
            }
        } 
        return optionsList;        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getLanguagePickListValues(){
        List< Map<String,String>> optionsList= new List<Map<String,String>>();
        Map<String,String> prickListValuesMap = SchemaUtility.getPickListValues('Contact', 'Language__c');
        for(String picklistValues: prickListValuesMap.keySet()){               
            Map<String,String> optionsmap= new Map<String,String>();
            optionsmap.put('label', picklistValues);
            optionsmap.put('value', prickListValuesMap.get(picklistValues));           
            optionsList.add(optionsmap);
        } 
        return optionsList;        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getRecordTypeList(){
        List< Map<String,String>> optionsList= new List<Map<String,String>>();
        Map<String,String> optionsmap= new Map<String,String>();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        optionsmap.put('label', rtMapByName.get('Individual').getName());
        optionsmap.put('value', rtMapByName.get('Individual').getDeveloperName());                
        optionsList.add(optionsmap);
        Map<String,String> optionsmap1= new Map<String,String>();
        optionsmap1.put('label', rtMapByName.get('Corporate').getName());
        optionsmap1.put('value', rtMapByName.get('Corporate').getDeveloperName());                
        optionsList.add(optionsmap1);
        
        return optionsList;        
    }
    
    @AuraEnabled
    public static SearchResultWrapper searchForAccounts(String searchText, String searchType) {
        List<List<SObject>> results = new List<List<SObject>>();
        SearchResultWrapper searchResults = new SearchResultWrapper();
        String finalSearchText ='';
        for(String searchT: searchText.split(' ')){
            finalSearchText += '*'+searchT+'*'+' OR ';
        }
        finalSearchText = finalSearchText.substring(0,finalSearchText.length()-3);
        String searchQuery;
        system.debug('finalSearchText'+finalSearchText);
        if(searchType.endsWithIgnoreCase('customer') ){ 
            if(loggedinUser.Contact.Account.Is_Accounts_Not_Available_to_All__c){       
                searchQuery= 'FIND {'+finalSearchText +'} IN ALL FIELDS  RETURNING Account(Id,Name,PersonMailingStreet,BillingStreet,Phone,PersonEmail WHERE Is_Primary__c= false '+
                    ' AND IsPersonAccount = true LIMIT 102), Contact(Id,Name,MailingStreet,Phone,Email,Account.Name,'+
                    ' Account.BillingStreet  WHERE Account.recordtype.developername=\'Corporate\' LIMIT 102)';       
            } else{                
                searchQuery= 'FIND {'+finalSearchText +'} IN ALL FIELDS  RETURNING Account(Id,Name,PersonMailingStreet,BillingStreet,Phone,PersonEmail WHERE Is_Primary__c= false '+
                    ' AND IsPersonAccount = true AND  Owner_Retailer__c =\''+loggedinUser.AccountId+'\' LIMIT 102), Contact(Id,Name,MailingStreet,Phone,Email,Account.Name,'+
                    ' Account.BillingStreet  WHERE Account.recordtype.developername=\'Corporate\' AND Account.Owner_Retailer__c =\''+loggedinUser.AccountId+'\' LIMIT 102)'; 
            }
            
        } else if(searchType.endsWithIgnoreCase('vehicle')){
            searchQuery = 'FIND {'+searchText +'} IN ALL FIELDS  RETURNING Asset(Id,Name,Account.Name,Owner.Name,Brand__r.Name,Chassis_Number__c, Registration_Number__c, VIN__c)';            
        }
        
        if(loggedinUser.Contact.Account.Is_Accounts_Not_Available_to_All__c){              
            results = SearchAccountHelper.getSearchRecords(searchQuery);
        }else{
            results = search.query(searchQuery); 
        }
        for (List<SObject> sobjs : results) {
            for (SObject sobj : sobjs) {
                if(sobj.getSObjectType() == Account.getSObjectType() ){
                    searchResults.resultAccountList.add((Account)sobj );                        
                }else if(sobj.getSObjectType() == Contact.getSObjectType()){
                    searchResults.resultContactList.add((Contact)sobj );
                }  else if(sobj.getSObjectType() == Asset.getSObjectType()){
                    system.debug('finalSearchText'+finalSearchText);
                    searchResults.resultAssetList.add((Asset)sobj );
                }
            } 
        }
        return searchResults;
    }
    
    @AuraEnabled
    public static String getNavigationId(Id accountId){
        
        String getRelatedId ='null';
        if(accountId.getSobjectType() == Account.getSObjectType()){            
            List<Opportunity> relatedOpportunity = [SELECT Id,Name FROM Opportunity WHERE AccountId =:accountId];
            if(relatedOpportunity.size() >0 ){
                getRelatedId = relatedOpportunity[0].Id;
            }
        }else if(accountId.getSobjectType() == Contact.getSObjectType()){
            getRelatedId =[SELECT Id, AccountId FROM Contact WHERE Id =:accountId].AccountId;
            accountId = getRelatedId;
        }
        if(accountId != null && ![SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId = :accountId].HasEditAccess){
            AccountShare thisAccountShare = new AccountShare(userorgroupid=userinfo.getUserId(),Accountid=accountId,
                                                             Accountaccesslevel='Edit',OpportunityAccessLevel='Edit'); 
            Insert thisAccountShare;
        }
        return getRelatedId;
    }
    @AuraEnabled
    public static Opportunity saveOpportunity(Id newAccountId, String OpportunityStage, DateTime preferreddate, String model, String priceBookName, String PurchaseType){
        
        PriceBook2 localPriceBook = new PriceBook2();
        if(OpportunityStage == 'Vehicle Selection')
            localPriceBook = [SELECT Id, Name FROM PriceBook2 WHERE Name =:priceBookName Limit 1];
        Account newAccount = [SELECT Id,Name FROM Account WHERE Id =:newAccountId];
        Vehicle_Specification__c primaryIntrestModel = [SELECT Id,Make__c FROM Vehicle_Specification__c WHERE Id=:model];
        Opportunity opportunity = new Opportunity(AccountId = newAccount.Id, 
                                                  Name= newAccount.Name , 
                                                  StageName =OpportunityStage,
                                                  Test_Drive_Preferred_Date_Time__c = preferreddate,
                                                  Primary_Model_Interest__c = primaryIntrestModel.Id,
                                                  Brand__c = primaryIntrestModel.Make__c,
                                                  Is_New_RDA_Process__c = true,
                                                  RecordtypeId = opportunityRecordType,
                                                  closedate = system.today().adddays(30),
                                                  Purchase_Type__c = PurchaseType,
                                                  Type = 'Product',
                                                  Sub_Type__c = PurchaseType == 'Used Vehicle' ? 'AUV' : 'Retail' );
        if(OpportunityStage == 'Vehicle Selection'){
            opportunity.pricebook2id=localPriceBook.Id;
        }
        
        insert opportunity;
        return opportunity;
    }
    @AuraEnabled
    public static newAccountWrapper saveAccount(Account newAccount, Account corporateAccount, String OpportunityStage, DateTime preferreddate,
                                                String model, String priceBookName, String PurchaseType, String accountType, String language){
        PriceBook2 localPriceBook = new Pricebook2();
        newAccountWrapper duplicateAccountWrapper = new newAccountWrapper();
        if(OpportunityStage == 'Vehicle Selection')
            localPriceBook = [SELECT Id, Name FROM PriceBook2 WHERE Name =:priceBookName AND IsActive = true LIMIT 1];
       try {
                Database.SaveResult saveResult;
            if(accountType == 'Individual'){
                newAccount.RecordTypeId = individualRecordType;
                saveResult = Database.insert(newAccount, false);
            }else if(accountType == 'Corporate'){
                corporateAccount.RecordTypeId = corporateRecordType;
                saveResult = Database.insert(corporateAccount, false);                
            }
            if (saveResult.isSuccess()) {
                  Id newcontactId ;
                Vehicle_Specification__c primaryIntrestModel = [SELECT Id,Make__c FROM Vehicle_Specification__c WHERE Id=:model];
                 if(accountType == 'Corporate'){
                    Contact corporateContact = new Contact();
                    corporateContact.FirstName = newAccount.FirstName;
                    corporateContact.LastName = newAccount.LastName;
                    corporateContact.Phone = newAccount.Phone;
                    corporateContact.Email = newAccount.PersonEmail;
                    corporateContact.RecordTypeId = corporateContactRecordTypeId;
                    corporateContact.Language__c = language;
                    corporateContact.AccountId = corporateAccount.Id;                      
                    Database.SaveResult saveContactResult =  Database.insert(corporateContact, false);
                              system.debug('newcontactId'+saveContactResult);
                    if(saveContactResult.isSuccess()){
                        newcontactId = corporateContact.Id;
                        system.debug('newcontactId'+newcontactId);
                    }else{  
                        for (Database.Error error : saveContactResult.getErrors()) {                    
                            duplicateAccountWrapper.resultString ='Failed To Create Contact.'+error.getMessage();
                        system.debug('error'+error.getMessage());
                        }
                    }
                    
                }
                
                Opportunity opportunity = new Opportunity(AccountId = newAccount.Id, 
                                                          Name= newAccount.FirstName + newAccount.LastName , 
                                                          StageName =OpportunityStage,
                                                          Test_Drive_Preferred_Date_Time__c = preferreddate,
                                                          Primary_Model_Interest__c = primaryIntrestModel.Id,
                                                          Brand__c = primaryIntrestModel.Make__c,
                                                          Is_New_RDA_Process__c = true,
                                                          RecordtypeId = opportunityRecordType,
                                                          closedate = system.today().adddays(30),
                                                          Purchase_Type__c = PurchaseType,
                                                          Type = 'Product',
                                                          Sub_Type__c = PurchaseType == 'Used Vehicle' ? 'AUV' : 'Retail' );
                if(OpportunityStage == 'Vehicle Selection'){
                    opportunity.pricebook2id=localPriceBook.Id;
                }
                  if(accountType == 'Individual'){
                    opportunity.AccountId = newAccount.Id; 
                    opportunity.Name= newAccount.FirstName + newAccount.LastName;                                       
                } else if(accountType == 'Corporate'){
                    opportunity.AccountId = corporateAccount.Id; 
                    opportunity.Name= corporateAccount.Name;                     
                }
                insert opportunity;
                duplicateAccountWrapper.resultOpportunity =opportunity;
                //duplicateAccountWrapper.resultString ='Opportunity Inserted';
                
                
            }else{
                for (Database.Error error : saveResult.getErrors()) {                    
                    duplicateAccountWrapper.resultString =error.getMessage();
                    if (error instanceof Database.DuplicateError) {
                        Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();                    
                        
                        system.debug(duplicateResult.getErrorMessage());
                        
                        Datacloud.MatchResult[] matchResults = 
                            duplicateResult.getMatchResults();
                        
                        Datacloud.MatchResult matchResult = matchResults[0];
                        
                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                        
                        // Add matched record to the duplicate records variable
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            duplicateAccountWrapper.duplicateAccountList.add((Account)matchRecord.getRecord());
                        }
                        if(duplicateAccountWrapper.duplicateAccountList.size() > 0){
                            //duplicateAccountWrapper.resultString ='Duplicate Records Identified';
                        }
                    }
                }
                
            }
            
        }catch(exception e){            
            return null;
        }
        
        
        
        return duplicateAccountWrapper;
    }
    
    @AuraEnabled
    public static  Map<String,String> getFieldLabel(String objectName){        
        return SchemaUtility.getObjectLabelMap(objectName);      
    }
    
    public class SearchResultWrapper {
        @AuraEnabled
        public List<Account> resultAccountList = new List<Account>();
        @AuraEnabled
        public List<Contact> resultContactList = new List<Contact>();
        @AuraEnabled
        public List<Opportunity> resultOpportunityList = new List<Opportunity>();
        @AuraEnabled
        public List<Asset> resultAssetList =new List<Asset>();
    }
    public class newAccountWrapper {
        @AuraEnabled
        public List<Account> duplicateAccountList = new List<Account>();
        @AuraEnabled
        public String resultString = '';
        @AuraEnabled
        public Opportunity resultOpportunity = new Opportunity();
    }
}