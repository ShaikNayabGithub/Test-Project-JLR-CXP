global class BatchIMSDeltaProcessor implements Database.batchable<sObject>, Database.Stateful {
    
    Static final List<String> NOTIFICATION_EMAILS = Label.IMS_BATCH_NOTIFICATION_EMAILS.split(','); 
    Static final Integer BATCH_SIZE = Integer.ValueOf(Label.IMS_BATCH_REQUEST_SIZE);
    string Query,errMsg = '';
    List<string> IsoCountryCodeLst= New List<string>();
    String IsoCountryCode = '';
    List<IMS_Request__c> queuedRecords = new List<IMS_Request__c>(); 
    Set<string> queuedVins = new set<string>(); 
    Integer counter = 0;
    
    global BatchIMSDeltaProcessor(string countryCode) {  
        
        IsoCountryCode = countryCode;
        
        if(string.isNotEmpty(countryCode) && string.isNotBlank(countryCode))
            IsoCountryCodeLst=countryCode.split(';');
        
        if (queuedRecords.isEmpty()) {
            queuedRecords = [select createddate, vin__c, Processed_Status__c  
                             from IMS_Request__c where Processed_Status__c = 'Queued' 
                             and Country_code__c IN: IsoCountryCodeLst]; 
        }
        if (!queuedRecords.isEmpty()) 
            for (IMS_Request__c ims : queuedRecords) queuedVins.add(ims.vin__c);
 
        Query = 'select createddate, name,apo_stock_status__c from asset where apo__c = true and apo_stock_status__c != \'Sold\' ';
        Query += 'and account.country_iso_code__c IN:IsoCountryCodeLst';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        return Database.getQueryLocator(query);
    }  
    
    global void execute(Database.BatchableContext BC, List<Asset> ForSaleAssets)
    {   
        if (!queuedVins.isEmpty() && !ForSaleAssets.isEmpty()) {  
            for (Asset a : ForSaleAssets) {
                if (!queuedVins.contains(a.name)) a.apo_stock_status__c = 'Sold'; 
            }
            try {
                update ForSaleAssets;
            } catch (Exception e) { 
                errMsg +=  e.getMessage() + '----' + e.getStackTraceString() + '\n'; 
            } 
        } 
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if (string.isNotEmpty(errMsg)) {
            EmailUtility.SendEmail(NOTIFICATION_EMAILS, 'BatchIMSDeltaProcessor', 'BatchIMSDeltaProcessor Status Report - ' + system.now(),'<pre>'+errMsg+'</pre>'); 
        } else if (!queuedVins.isEmpty() ) {
            Database.executebatch(new BatchIMSRequestProcessor(IsoCountryCode), BATCH_SIZE); 
        }
    }
    
}