@isTest(SeeAllData=true)
private class RequestTriggerHandler_Test { //uncomment after AOP fix
    /*static testMethod void PreCreate_AllowsInsertion_GivenValidRequest() {
        TestClass_AvokaSettingCreator.InsertBrandMapping('jag', 'Jaguar');
        TestClass_AvokaSettingCreator.InsertRecordTypeMapping('tdsf', 'Test_Drive_Request');
        TestClass_AvokaSettingCreator.InsertLocalMapping('in', 'INR', 'IN', 'India NSC Queue');
        
        Request__c request = TestClass_RequestCreator.Build();
        Database.SaveResult result = Database.insert(request);
        
        System.assert(result.isSuccess());
    }
    
    static testMethod void PreCreate_PreventsInsertion_GivenInvalidRequest() {
        TestClass_AvokaSettingCreator.InsertBrandMapping('jag', 'Jaguar');
        TestClass_AvokaSettingCreator.InsertRecordTypeMapping('tdsf', 'Test_Drive_Request');
        TestClass_AvokaSettingCreator.InsertLocalMapping('in', 'INR', 'IN', 'India NSC Queue');
        
        Request__c request = TestClass_RequestCreator.Build();
        request.Request_Source__c = 'invalid';
        Database.SaveResult result = Database.insert(request, false);
        
        System.assert(!result.isSuccess());
    }*/
}