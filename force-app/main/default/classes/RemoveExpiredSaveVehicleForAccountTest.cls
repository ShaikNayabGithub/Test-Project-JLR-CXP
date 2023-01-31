@isTest
private class RemoveExpiredSaveVehicleForAccountTest {

    static testMethod void testExecute() {
        CreateTestData tdata = new CreateTestData();
        
        JUDAAN_Date__c expiredDay = tdata.createExpireDay( -1 , 0 , 0 );
        List<Saved_Vehicle_for_Account__c> records = tdata.createSavedVehicle();
        
        Saved_Vehicle_for_Account__c tmp = [Select LastModifiedDate From Saved_Vehicle_for_Account__c Where Id = :records.get(0).Id];
        System.debug( '----------------- records.get(0) = ' + tmp.LastModifiedDate );
        
        Test.startTest();
        RemoveExpiredSaveVehicleForAccountBatch batch = new RemoveExpiredSaveVehicleForAccountBatch();
        Database.executeBatch( batch , 200 );
        Test.stopTest();        
        
        Date dueDate = Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c) );
        system.assertEquals(0, [select Id from Saved_Vehicle_for_Account__c  where DAY_ONLY( LastModifiedDate  ) <= :dueDate].size());
        system.assertEquals(0, [select Id from Saved_Vehicle_for_Account__c].size());
    }
}