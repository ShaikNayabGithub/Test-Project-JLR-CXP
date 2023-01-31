global class RemoveExpiredSavedQuotesBatch implements Database.Batchable<sObject>{

    public static final String DELETE_STAGE_NAME = 'Save a Quote';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Integer DaysforExpiry;
    
        //Retrieving Custom setting field to calculate expiration date for query
        for(JUDAAN_Date__c Jdate : JUDAAN_Date__c.getAll().values()){
            DaysforExpiry = Integer.valueOf(Jdate.Reservation__c);
        }

        Date dueDate = Date.today().addDays( - Integer.valueOf( DaysforExpiry ) );
        
        String query = 'select id,name from Opportunity WHERE StageName = :DELETE_STAGE_NAME AND Quote_saved_date__c <= :dueDate And Quote_Expired__c = false';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = scope;
        if(!lstOpportunity.isEmpty())
        {
            for(Opportunity obj : lstOpportunity)
            {
               obj.Quote_Expired__c = true; 
              if(obj.Will_send_email__c == true)
                obj.Will_send_email__c = false;    
            }
        }
        
        update lstOpportunity;
        //delete scope;
        // Changes for TCRM-3766 stops
    
    }
    
    global void finish(Database.BatchableContext BC)
    {       
        system.debug('**** Finish');
    }
}