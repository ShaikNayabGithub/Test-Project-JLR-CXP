@isTest
private class LeadTypeChecker_Test {
    
    static testMethod void Test_NoError_GivenTypeAndPurchaseTypePopulated() 
    {
        Lead l = TestClass_LeadCreator.CreateLeadWithNoPurchaseType();
        l.Purchase_Type__c = 'New Vehicle';
        
        Database.SaveResult sr = Database.insert(l);
        System.assert(sr.isSuccess());
    }
}