@isTest
public class RetailerContactRequestRetriever_Test {
    
    @TestSetup
    static void CreateData(){

        Account newAccount = TestClass_AccountCreator.BuildRetailer(); 
        newAccount.Dealer_CI_Code__c = '12345';
        newAccount.Dealer_CI_Code_2__c = '12345';
        newAccount.Primary_Dealer_Code__c = '54321';
        newAccount.Secondary_Dealer_Code__c = '54321';
        newAccount.Retailer_Type__c = 'Main Dealer';
        newAccount.Record_Sub_Type__c = 'Dual Brand';
        insert newAccount;
    }
    
    @isTest
    private static void Retrieve_TestGetQueueId_JaguarBrand(){
        test.startTest();
        Id acctQueue = [Select queue_id__c from Account where name = 'test retailer'].queue_id__c;
        
        List<RecordType> recordTypes = [Select Id From RecordType where DeveloperName ='Avoka_Request' and SobjectType ='Request__c'  limit 1]; 
        Request__c request = new Request__c();
        if(recordTypes.size() > 0){
            request.RecordTypeId = recordTypes[0].Id;
        }
        request.Request_Source__c = 'jag-tdsf-in-en';
        request.Last_Name__c = UniqueString.CreateNew();
        request.Purchase_Type__c = 'New Vehicle';
        request.Email__c = 't.t@t.com';
        request.Brand__c = 'Jaguar';
        request.Retailer_Contact__c = true;
        request.Preferred_Retailer_Code__c = '12345';
        test.stopTest();
        Id queueId1 = RetailerContactRequestRetriever.GetQueueId(request);
        
        system.assertEquals(acctQueue, queueId1);
    }
    
    
    @isTest
    private static void Retrieve_TestGetQueueId_LandRoverBrand(){
        
        test.startTest();
        Id acctQueue = [Select queue_id__c from Account where name = 'test retailer'].queue_id__c;
        
        List<RecordType> recordTypes = [Select Id From RecordType where DeveloperName ='Avoka_Request' and SobjectType ='Request__c'  limit 1]; 
        Request__c request = new Request__c();
        if(recordTypes.size() > 0){
            request.RecordTypeId = recordTypes[0].Id;
        }
        request.Request_Source__c = 'jag-tdsf-in-en';
        request.Last_Name__c = UniqueString.CreateNew();
        request.Purchase_Type__c = 'New Vehicle';
        request.Email__c = 't.t@t.com';
        request.Brand__c = 'Land Rover';
        request.Retailer_Contact__c = true;
        request.Preferred_Retailer_Code__c = '12345';
        test.stopTest();
        Id queueId1 = RetailerContactRequestRetriever.GetQueueId(request);
        
        system.assertEquals(acctQueue, queueId1);
    }
    
    @isTest
    private static void Retrieve_TestGetQueueId_NullValue(){
        
        Request__c requestRecord = TestClass_RequestCreator.Build();
        requestRecord.Brand__c = 'Land Rover';
        requestRecord.Retailer_Contact__c = false;
        requestRecord.Preferred_Retailer_Code__c = null;
        
        Id queueId1 = RetailerContactRequestRetriever.GetQueueId(requestRecord);
        
        system.assertEquals(null, queueId1);
    }
    
}