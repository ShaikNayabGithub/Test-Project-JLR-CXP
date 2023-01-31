@isTest
public class RepeatEventHandlerTest {
    @IsTest
    static void RepeatCaseUpserterTest()
    {
        Asset testAsset =  TestClass_AssetBuilder.BuildVehicle(true);
        insert testAsset;
         System.debug('testAsset'+testAsset);
        Id roadsideId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').GetRecordTypeId();        
        Id repairId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Repair').GetRecordTypeId();
        Account assetAccount = [select id,recordtype.developername,Region_or_Market__c from Account where Id =: testAsset.AccountId];
        assetAccount.Region_or_Market__c = 'MENA';
        update assetAccount;
        System.debug(assetAccount);
        Event roadsideEvent = new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now(), WhatId=testAsset.Id,RecordTypeId=roadsideId,Repeat_Event__c=true);       
        insert roadsideEvent;
        Test.startTest();
        Event repairEvent = new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now(), WhatId=testAsset.Id,RecordTypeId=repairId,Repeat_Event__c=true);
        insert repairEvent;
        List<Case> proactiveCaseList =[SELECT Id FROM Case Where AssetId =:testAsset.Id];
        System.assertEquals(1, proactiveCaseList.size());
        Test.stopTest();    
    }
    
}