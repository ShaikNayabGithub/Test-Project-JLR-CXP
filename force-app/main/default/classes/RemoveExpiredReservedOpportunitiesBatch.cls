global class RemoveExpiredReservedOpportunitiesBatch implements Database.Batchable<sObject>{

    public static final String DELETE_STAGE_NAME = 'Pay Deposit';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Integer DaysforExpiry;
        
        //Retrieving Custom setting field to calculate expiration date for query
        for(JUDAAN_Date__c Jdate : JUDAAN_Date__c.getAll().values()){
            DaysforExpiry = Integer.valueOf(Jdate.Reservation__c);
        }
        
        Date dueDate = Date.today().addDays( - Integer.valueOf( DaysforExpiry ) );
        
        //Creating a savepoint before executing the query
        String query = 'select id,name, StageName from Opportunity WHERE StageName = :DELETE_STAGE_NAME And Reservation_Cancelled__c = false And Deposit_paid_date__c <= :dueDate';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('To be deleted Opportunities ====>>'+ scope);

        List<Opportunity> targets = new List<Opportunity>();
        for( sObject so : scope ) {
            Opportunity tmp = (Opportunity) so; 
            if(tmp.StageName == DELETE_STAGE_NAME)
            {
                tmp.StageName = 'Reservation Canceled';
            }
            tmp.Will_send_email__c = true;
            tmp.Reservation_Cancelled__c = true;
            targets.add( tmp );
        }
        
        update targets;
        
//      delete scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}