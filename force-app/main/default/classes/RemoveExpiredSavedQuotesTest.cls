@isTest
public class RemoveExpiredSavedQuotesTest {

    static testMethod void testExecute() {
        CreateTestData tdata = new CreateTestData();
        
        RecordSharer.DisableRecordSharing = true; 
        OpportunityHandler.IgnoreMMIT = true; 
        AssetHandler.IgnoreMMIT = true; 
        
        JUDAAN_Date__c expiredDay = tdata.createExpireDay( 3 , 7 , 7 );
        List<Opportunity> opps = tdata.createOpportunities( Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c ) ) , RemoveExpiredSavedQuotesBatch.DELETE_STAGE_NAME );
        
        Opportunity tmp = [Select Deposit_paid_date__c , DaysAfterExpiry__c From Opportunity Where Id = :opps.get(0).Id];
        System.debug( '------------------- tmp = ' + tmp );
        
        Test.startTest();
        RemoveExpiredSavedQuotesBatch batch = new RemoveExpiredSavedQuotesBatch();
        Database.executeBatch( batch , 200 );
        Test.stopTest();
        
        Date edate = Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c));
        system.assertEquals(200, [select Id from Opportunity where StageName = 'Save a Quote' and Quote_Saved_Date__c <= :edate].size());  // TCRM-3766      
    }
}