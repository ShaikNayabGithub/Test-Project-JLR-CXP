@isTest
public class pdiRequestTriggerHandler_TEST {
    
    @testSetup
    static void setup() {
        Account newAccount = new Account();
        newAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        newAccount.Name = 'testAccount';
        newAccount.BillingStreet = 'Valid Street';
        newAccount.BillingPostalCode = 'Valid PostalCode';
        newAccount.BillingState = 'Valid State';
        newAccount.BillingCity = 'Valid City';
        newAccount.Retailer_Email__c = 'test@test.com';
        newAccount.Corporate_Code__c = '';
        newAccount.Trading_Partner_Type__c ='Dealer';
        newAccount.Retailer_Status__c='Trading';
        newAccount.Country_ISO_Code__c ='AU';
        newAccount.Dealer_CI_Code_2__c = '01182';
        newAccount.Primary_Dealer_Code__c ='JJ922011182';
        insert newAccount;
        System.debug('newAccount-->'+newAccount);
        Vehicle_Specification__c vs=new Vehicle_Specification__c();
        vs.name='Jaguar';
        insert vs;
        System.debug('vehicle-->'+vs);
        Asset newasset=new Asset();
        newasset.accountId=newAccount.id;
        newasset.registration_Number__c='test12dd3';
        newasset.name='SAJXXX13484734923';
        newasset.Brand__c = VehicleSpecificationUtilities.Brands.get('jaguar').Id;
        newasset.Customs_Clearance_Status__c = 'Clearance Completed';
        newasset.Arrival_Date__c = Date.today();
        insert newasset;
    }
    
    static testMethod void serviceEventUpdation()
    {
        Test.startTest();
        Asset newasset = [SELECT Id, Name FROM Asset LIMIT 1];
        Map<Id, PDI_Request__c> mapOfIdAndPdiReqs = new Map<Id, PDI_Request__c>();
        List<PDI_Request__c> pdiRequests = new List<PDI_Request__c>();
        PDI_Request__c pdiReq = new PDI_Request__c();
        pdiReq.Vehicle__c = newasset.Id;
        pdiReq.PDI_Status__c ='Requested';
        pdiReq.Requested_Completion_Date__c =date.today();
        pdiReq.Requested_Delivery_Date__c = date.today().addDays(5);
        Insert pdiReq;
        mapOfIdAndPdiReqs.put(pdiReq.Id,pdiReq);
        pdiRequests.add(pdiReq);
        pdiRequestTriggerHandler pdiRqTH = new pdiRequestTriggerHandler();
        pdiRqTH.PreInsert(pdiRequests);
        pdiRqTH.preUpdate(pdiRequests, mapOfIdAndPdiReqs);
        PDI_Request__c pdiReqLi = [SELECT id, Name,Requested_Delivery_Date__c,PDI_Status__c FROM PDI_Request__c LIMIT 1];
        pdiReqLi.Requested_Delivery_Date__c =date.today().addDays(10);
        update pdiReqLi;
        system.assertEquals('Requested', pdiReqLi.PDI_Status__c);
        Test.stopTest();
    }
}