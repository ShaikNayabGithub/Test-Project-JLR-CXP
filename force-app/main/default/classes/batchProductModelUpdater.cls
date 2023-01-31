global class batchProductModelUpdater implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Id rtId= Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId(); 
        String query = 'select id,model_alternative__c ,name,model__c,model__r.model_alternative__c from product2 where model_alternative__c =null and recordtypeid=:rtId';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Product2> prodList) {
     
        for(Product2 prod : prodList)
        {        
                    
                            prod.model_alternative__c=prod.model__r.model_alternative__c;
                    
        }
        try {
       
            update prodList;
        
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}