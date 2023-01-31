global class RemoveExpiredSaveVehicleForAccountBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
	    Integer DaysforExpiry;

        //Retrieving Custom setting field to calculate expiration date for query
        for(JUDAAN_Date__c Jdate : JUDAAN_Date__c.getAll().values()){
            DaysforExpiry = Integer.valueOf(Jdate.Reservation__c);
        }
        
        Date dueDate = Date.today().addDays( - Integer.valueOf( DaysforExpiry ) );
	
        System.debug( '--------------- dueDate = ' + dueDate );

        String query = 'select id from Saved_Vehicle_for_Account__c where DAY_ONLY( LastModifiedDate  ) <= :dueDate';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {	
    	system.debug('To be deleted Junction object Saved_Vehicle_for_Account__c ====>>'+ scope);
    	delete scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {    	
        system.debug('**** Finish');
    }
}