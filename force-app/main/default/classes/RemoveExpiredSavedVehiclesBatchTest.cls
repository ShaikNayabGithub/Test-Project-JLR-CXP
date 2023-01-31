@isTest
public class RemoveExpiredSavedVehiclesBatchTest {
    static testMethod void testExecute() {
        CreateTestData tdata = new CreateTestData();
        
        JUDAAN_Date__c expiredDay = tdata.createExpireDay( -1 , 0 , 0 );
        List<Saved_Vehicle_for_Lead__c> records = tdata.createSavedVehicleForLead();
        
        Saved_Vehicle_for_Lead__c tmp = [Select LastModifiedDate From Saved_Vehicle_for_Lead__c Where Id = :records.get(0).Id];
        System.debug( '----------------- records.get(0) = ' + tmp.LastModifiedDate );
        
        Test.startTest();
        RemoveExpiredSavedVehiclesBatch batch = new RemoveExpiredSavedVehiclesBatch();
        Database.executeBatch( batch , 200 );
        Test.stopTest();  
        system.assertEquals(0, [select Id from Saved_Vehicle_for_Lead__c  where DaysFromSaveVehicleExpiry__c >= :expiredDay.Saved_Vehicle__c].size());
        system.assertEquals(0, [select Id from Saved_Vehicle_for_Lead__c].size());
    }
}