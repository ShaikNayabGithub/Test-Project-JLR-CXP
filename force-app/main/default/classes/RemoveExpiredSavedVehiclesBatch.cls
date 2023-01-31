global class RemoveExpiredSavedVehiclesBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	Integer DaysforExpiry;
        
        //Retrieving Custom setting field to calculate expiration date for query
        for(JUDAAN_Date__c Jdate : JUDAAN_Date__c.getAll().values()){
				DaysforExpiry = Integer.valueOf(Jdate.Saved_Vehicle__c);
        }

        Date dueDate = Date.today().addDays( - Integer.valueOf( DaysforExpiry ) );
        
        String query = 'select id from Saved_Vehicle_for_Lead__c where DaysFromSaveVehicleExpiry__c >=: DaysforExpiry';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {	
    	system.debug('To be deleted Junction object Saved_Vehicle_for_Lead__c ====>>'+ scope);
    	delete scope;
    }
     
    global void finish(Database.BatchableContext BC)
    {	
        system.debug('**** Finish');
    }
}