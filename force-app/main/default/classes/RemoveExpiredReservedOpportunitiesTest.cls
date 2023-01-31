@isTest
private class RemoveExpiredReservedOpportunitiesTest {

    static testMethod void testExecute() {
        CreateTestData tdata = new CreateTestData();
        
        JUDAAN_Date__c expiredDay = tdata.createExpireDay( 3 , 7 , 7 );
        List<Opportunity> opps = tdata.createOpportunities( Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c ) ) , RemoveExpiredReservedOpportunitiesBatch.DELETE_STAGE_NAME );
        
        //List<Opportunity> others = tdata.createOpportunities( Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c ) ) , 'Contacted' );
        Opportunity tmp = [Select Deposit_paid_date__c , DaysAfterExpiry__c From Opportunity Where Id = :opps.get(0).Id];
        System.debug( '------------------- tmp = ' + tmp );
        
        Test.startTest();
        RemoveExpiredReservedOpportunitiesBatch batch = new RemoveExpiredReservedOpportunitiesBatch();
        Database.executeBatch( batch , 200 );
        Test.stopTest();
        
        system.assertEquals(200, [select Id from Opportunity where StageName = 'Reservation Canceled' and Reservation_Cancelled__c = true].size());
    }
    
    static testMethod void testCancelled()
    {
         CreateTestData tdata = new CreateTestData();
        
        JUDAAN_Date__c expiredDay = tdata.createExpireDay( 3 , 7 , 7 );
        
        List<Opportunity> others = tdata.createOpportunities( Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c ) ) , RemoveExpiredReservedOpportunitiesBatch.DELETE_STAGE_NAME );
        Opportunity tmp = [Select Deposit_paid_date__c , DaysAfterExpiry__c From Opportunity Where Id = :others.get(0).Id];
        System.debug( '------------------- tmp = ' + tmp );
        
        Test.startTest();
        RemoveExpiredReservedOpportunitiesBatch batch = new RemoveExpiredReservedOpportunitiesBatch();
        Database.executeBatch( batch , 200 );
        Test.stopTest();
        system.assertEquals(200, [select Id from Opportunity where Reservation_Cancelled__c = true].size());
    }
    
}