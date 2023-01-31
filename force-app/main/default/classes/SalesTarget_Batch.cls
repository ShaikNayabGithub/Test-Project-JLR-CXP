global class SalesTarget_Batch implements Database.Batchable<sObject> {
    
    public String currentYear;
    public id recordtypeId;
    public String market;
    public String stageName;
    public String retailer;
    set<String> handOverStageSet = new set<String>{'Handover'};
        set<String> orderStageSet = new set<String>{'Order','Order Taken'};
            
            
            public SalesTarget_Batch(
                String currentYear,
                String market,
                String stageName,
                String retailer
            ){
                this.currentYear = currentYear;
                this.market = market;
                this.stageName = stageName;
                this.retailer = retailer;
                this.recordtypeId = Schema.SObjectType.Sales_Target__c.getRecordTypeInfosByName().get('Opportunity Sales Target').getRecordTypeId();
            }
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        
        if(stageName != null 
           && (handOverStageSet.contains(stageName) 
               || orderStageSet.contains(stageName))){                   
                   
                   String query = 'SELECT Id,January_Order__c,February_Order__c,March_Order__c,April_Order__c,May_Order__c,June_Order__c,July_Order__c,August_Order__c,September_Order__c,October_Order__c,November_Order__c,December_Order__c,Salesperson__c';
                   query += ' FROM Sales_Target__c where Salesperson__c != null AND Salesperson__r.isActive = true and Target_Year__c = :currentYear and recordtypeid = :recordtypeId';
                   if(market != null && market != 'All'){
                       query += ' AND Salesperson__r.Market__c = :market';
                   }
                   if(retailer != null && retailer != 'All'){
                       query += ' AND Salesperson__r.Contact.Account.Name = :retailer';
                   }
                   system.debug('query '+query);         
                   return Database.getQueryLocator( query );
               }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<Sales_Target__c> scope) {
        set<id>salesPersonIdsSet = new set<id>();
        for ( Sales_Target__c targetData : scope ){
            if(targetData.Salesperson__c != null){
                salesPersonIdsSet.add(targetData.Salesperson__c);
            }
        }
        
        if(salesPersonIdsSet != null 
           && !salesPersonIdsSet.isEmpty()){
               if(orderStageSet.contains(stageName)){
                   ProcessSalesTargetCounts.processCounts(currentYear,salesPersonIdsSet,orderStageSet,stageName);
               }else if(handOverStageSet.contains(stageName)){
                   ProcessSalesTargetCounts.processCounts(currentYear,salesPersonIdsSet,handOverStageSet,stageName);
               } 
           }
    }
    
    global void finish( Database.BatchableContext BC ) {
        
    } 
    
}