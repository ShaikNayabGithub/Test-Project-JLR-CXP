public class AssetWithOpportunityTableController {
    
    @AuraEnabled(cacheable=true) 
    public static List<pickwrap> getPicklistValues(String objectName,String fieldName){
        List<pickwrap> pickwrapList = new List<pickwrap>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            pickwrap pickIns = new pickwrap();
            pickIns.label = pickListVal.getLabel();
            pickIns.value = pickListVal.getValue();
            pickwrapList.add(pickIns);
        }  
        return pickwrapList;
    }
    
    @AuraEnabled(cacheable=true)  
    public static AssetWrapper handleAssetSearch(Date createdFromDate
                                                 ,Date createdToDate
                                                 ,List<String> assetStatus
                                                 ,List<String> salesType
                                                 ,List<String> isoCodeList
                                                 ,String region
                                                 ,String retailerId){
                                                     AssetWrapper assetwrap = new AssetWrapper();
                                                     String soqlQuery;
                                                     try{
                                                         system.debug('createdFromDate --> '+createdFromDate);
                                                         system.debug('createdToDate --> '+createdToDate);
                                                         system.debug('assetStatus --> '+assetStatus);
                                                         system.debug('salesType --> '+salesType);
                                                         system.debug('region --> '+region);
                                                         system.debug('retailerId --> '+retailerId);
                                                         system.debug('isoCodeList --> '+isoCodeList);
                                                         
                                                         List<AssetWrapper> AssetWrapperList = new List<AssetWrapper>();
                                                         set<id> productIdsSet = new set<Id>();
                                                         map<Id,Asset> assetMap = new map<Id,Asset>();
                                                         
                                                         soqlQuery = 'SELECT id,name,Product2id,Product2.Name,Common_Sale_Type__c,ownerid,owner.name,Retailer_Name__c,Ordering_Market_Region__c,Retailer_Account_Name__c,Vista_Status__c,Product2.IsActive,Model_Text__c,accountid,account.name,Handover_Date__c,Vin__c,Order_Number__c,Country_ISO_Code__c,Dealer_Code__c,CreatedDate,LastModifiedDate FROM Asset ';
                                                         String whereCondition;
                                                         system.debug('createdFromDate --> '+createdFromDate);
                                                         system.debug('createdToDate --> '+createdToDate);
                                                         if(createdFromDate != null && createdToDate != null){
                                                             whereCondition = '(createddate >=: createdFromDate AND createddate <=: createdToDate)';
                                                         }                     
                                                         system.debug('assetStatus --> '+assetStatus);
                                                         if(whereCondition != null && assetStatus != null && !assetStatus.isEmpty()){
                                                             whereCondition += 'AND Vista_Status__c IN: assetStatus ';
                                                         }else if(assetStatus != null && !assetStatus.isEmpty()){
                                                             whereCondition = 'Vista_Status__c IN: assetStatus '; 
                                                         }
                                                         
                                                         system.debug('salesType --> '+salesType);
                                                         if(whereCondition != null && salesType != null && !salesType.isEmpty()){
                                                             whereCondition += 'AND Common_Sale_Type__c IN: salesType ';
                                                         }else if(salesType != null && !salesType.isEmpty()){
                                                             whereCondition = 'Common_Sale_Type__c IN: salesType '; 
                                                         }
                                                         
                                                         system.debug('region --> '+region);
                                                         if(whereCondition != null && region != null){
                                                             whereCondition += 'AND Ordering_Market_Region__c =: region ';
                                                         }else if(region != null){
                                                             whereCondition = 'Ordering_Market_Region__c =: region '; 
                                                         }
                                                         system.debug('isoCodeList --> '+isoCodeList);
                                                         if(whereCondition != null && isoCodeList != null && !isoCodeList.isEmpty()){
                                                             whereCondition += 'AND Country_ISO_Code__c IN: isoCodeList ';
                                                         }else if(isoCodeList != null && !isoCodeList.isEmpty()){
                                                             whereCondition = 'Country_ISO_Code__c IN: isoCodeList '; 
                                                         }
                                                         
                                                         system.debug('retailerId --> '+retailerId);
                                                         if(whereCondition != null && retailerId != null){
                                                             whereCondition += 'AND (owner.contactid != null AND owner.contact.accountid != null AND owner.contact.accountid =: retailerId) ';
                                                         }else if(retailerId != null){
                                                             whereCondition = '(owner.contactid != null AND owner.contact.accountid != null AND owner.contact.accountid =: retailerId) '; 
                                                         }
                                                         system.debug('whereCondition --> '+whereCondition);
                                                         if(whereCondition != null){
                                                             soqlQuery = soqlQuery+' WHERE '+whereCondition;
                                                         }
                                                         soqlQuery = soqlQuery+' order by LastModifiedDate desc,createddate desc limit 5000';
                                                         system.debug('soqlQuery --> '+soqlQuery);
                                                         system.debug('soqlQuery --> '+ database.query(soqlQuery));
                                                         List<Asset> assetList = database.query(soqlQuery);
                                                         
                                                         if(assetList != null && !assetList.isEmpty()){    
                                                             for(Asset assIns : assetList){
                                                                 if(assIns.Product2id != null){
                                                                     productIdsSet.add(assIns.Product2id);
                                                                 }
                                                                 assetMap.put(assIns.Id,assIns);
                                                             }
                                                             system.debug('assetMap --> '+assetMap);
                                                             system.debug('productIdsSet --> '+productIdsSet);
                                                             List<AssetDataWrapper> assetWithOppList = new List<AssetDataWrapper>();
                                                             List<AssetDataWrapper> assetWithoutOppList = new List<AssetDataWrapper>();
                                                             set<id> availableAssetIdsSet = new set<id>();
                                                             map<id,String> oppNameMap = new map<id,String>();
                                                             map<id,String> oppIdMap = new map<id,String>();
                                                             for(opportunitylineitem oli : [select id,Asset__c,Product2Id,opportunityid,opportunity.Name from opportunitylineitem where Product2Id in:productIdsSet AND Asset__c != null AND Asset__c In: assetMap.keyset() and opportunityid != null]){
                                                                 availableAssetIdsSet.add(oli.Asset__c);
                                                                 oppNameMap.put(oli.Asset__c,oli.opportunity.Name);
                                                                 oppIdMap.put(oli.Asset__c,oli.opportunityid);
                                                             }
                                                             for(id assetId : assetMap.keyset()){
                                                                 
                                                                 AssetDataWrapper assetWrapIns = new AssetDataWrapper();
                                                                 assetWrapIns.assetName = assetMap.get(assetId).Name;
                                                                 assetWrapIns.assetId = '/'+assetMap.get(assetId).Id;
                                                                 assetWrapIns.handoverDate = assetMap.get(assetId).Handover_Date__c;
                                                                 assetWrapIns.createdDate = assetMap.get(assetId).createdDate;
                                                                 assetWrapIns.lastModifieddate = assetMap.get(assetId).lastModifieddate;
                                                                 assetWrapIns.accountName = assetMap.get(assetId).account.Name;
                                                                 assetWrapIns.productName = assetMap.get(assetId).Product2.Name;
                                                                 assetWrapIns.accountId = '/'+assetMap.get(assetId).accountId;
                                                                 assetWrapIns.productId = '/'+assetMap.get(assetId).Product2Id;
                                                                 assetWrapIns.orderNumber = assetMap.get(assetId).Order_Number__c;
                                                                 assetWrapIns.countryIsoCode = assetMap.get(assetId).Country_ISO_Code__c;
                                                                 assetWrapIns.dealerCode = assetMap.get(assetId).Dealer_Code__c;
                                                                 assetWrapIns.vistaStatus = assetMap.get(assetId).Vista_Status__c;
                                                                 assetWrapIns.model = assetMap.get(assetId).Model_Text__c;
                                                                 assetWrapIns.active = assetMap.get(assetId).Product2.IsActive;
                                                                 assetWrapIns.commonSalesType = assetMap.get(assetId).Common_Sale_Type__c;
                                                                 assetWrapIns.region = assetMap.get(assetId).Ordering_Market_Region__c;
                                                                 assetWrapIns.retailerId = '/'+assetMap.get(assetId).ownerid;
                                                                 assetWrapIns.retailerName = assetMap.get(assetId).owner.name;
                                                                 
                                                                 
                                                                 if(availableAssetIdsSet.contains(assetId)){
                                                                     if(oppNameMap.containskey(assetId)){
                                                                         assetWrapIns.oppName = oppNameMap.get(assetId);
                                                                     }
                                                                     if(oppIdMap.containskey(assetId)){
                                                                         assetWrapIns.oppId = '/'+oppIdMap.get(assetId);
                                                                     }
                                                                     assetWithOppList.add(assetWrapIns);
                                                                 }else{
                                                                     assetWithoutOppList.add(assetWrapIns);   
                                                                 }
                                                             }
                                                             if((assetWithOppList != null && !assetWithOppList.isEmpty()) || (assetWithoutOppList != null && !assetWithoutOppList.isEmpty())){
                                                                 assetwrap.assetWithOppList = assetWithOppList;
                                                                 assetwrap.assetWithoutOppList = assetWithoutOppList;
                                                                 assetwrap.assetWithOppCount = assetWithOppList.size();
                                                                 assetwrap.assetWithoutOppCount = assetWithoutOppList.size();
                                                             } 
                                                         }
                                                         assetwrap.hasError = false;
                                                         assetwrap.message = 'Search Done';
                                                         assetwrap.soqlQuery = soqlQuery;
                                                     }catch(Exception ex){
                                                         assetwrap.hasError = true;
                                                         assetwrap.soqlQuery = soqlQuery;
                                                         assetwrap.message = ex.getMessage()+' - '+ex.getStackTraceString();
                                                     }
                                                     return assetwrap;
                                                 }
    
    public class AssetWrapper{
        public AssetWrapper(){}
        @AuraEnabled public List<AssetDataWrapper> assetWithOppList;
        @AuraEnabled public List<AssetDataWrapper> assetWithoutOppList;
        @AuraEnabled public integer assetWithOppCount;
        @AuraEnabled public integer assetWithoutOppCount;
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public String message;
        @AuraEnabled public String soqlQuery;
    }
    public class AssetDataWrapper{
        public AssetDataWrapper(){}
        @AuraEnabled public String assetName;
        @AuraEnabled public String assetId;
        @AuraEnabled public String oppName;
        @AuraEnabled public String oppId;
        @AuraEnabled public date handoverDate;
        @AuraEnabled public dateTime createdDate;
        @AuraEnabled public dateTime lastModifieddate;
        @AuraEnabled public String vistaStatus;
        @AuraEnabled public String accountName;
        @AuraEnabled public String accountId;
        @AuraEnabled public String productName;
        @AuraEnabled public String productId;
        @AuraEnabled public String model;
        @AuraEnabled public boolean active;
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String countryIsoCode;
        @AuraEnabled public String dealerCode;
        @AuraEnabled public String commonSalesType;
        @AuraEnabled public String region;
        @AuraEnabled public String retailerId;
        @AuraEnabled public String retailerName;
    }
    public class pickwrap{
        public pickwrap(){}
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
}