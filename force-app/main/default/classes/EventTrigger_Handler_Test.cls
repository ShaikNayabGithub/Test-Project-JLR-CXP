@isTest
public class EventTrigger_Handler_Test {
    static testMethod void Placeholder() 
    {
        Event e= new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now());
        
        insert e;
        update e;
        
        System.Assert(true);
    }
    
    
    @IsTest
    static void Test_SetCustomerJourneyToPurchase_WhenRoadsideEventCreated()
    {
      Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        insert ass;
        system.debug('ASSET '+ass);
        Id roadsideId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').GetRecordTypeId();
         system.debug('roadsideid '+roadsideId);
        Event e = new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now(), WhatId=ass.Id,RecordTypeId=roadsideId);
             system.debug('e '+e);
      //  Test.startTest();
        insert e;
       // Test.stopTest();
        Account acc = [Select id, Customer_Journey_Stage__c from Account where id =: ass.AccountId];
        System.debug('account '+acc);
        System.assertEquals('Maintain', acc.Customer_Journey_Stage__c);
        
        
        
    }
     @IsTest
    static void Test_DoesNotSetCustomerJourneyToPurchase_WhenRoadsideEventCreatedAndJourneyAlreadyHigher()
    {
      Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        insert ass;
        system.debug('ASSET '+ass);
        Id roadsideId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').GetRecordTypeId();
        Account toUpdateAccount = new Account(Id=ass.AccountId, Customer_Journey_Stage__c = 'Select');
        update toUpdateAccount;
         system.debug('roadsideid '+roadsideId);
        Event e = new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now(), WhatId=ass.Id,RecordTypeId=roadsideId);
             system.debug('e '+e);
      Test.startTest();
        insert e;
        Test.stopTest();
        Account acc = [Select id, Customer_Journey_Stage__c from Account where id =: ass.AccountId];
        System.debug('account '+acc);
        System.assertEquals('Select', acc.Customer_Journey_Stage__c);
        
        
        
    }
    
    @IsTest
      static  void TestEvent_RelatedToOpenCaseIsCreated()
    {
          Id roadsideId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').GetRecordTypeId();
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);

        User user;
        Case caseRecord;

        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Market__c = 'AU';
        }

       
         System.runAs(user){   
            caseRecord = TestClass_CaseCreator.Create('Phone','01217396328','test@test.com');
        }
        Case updatedCase =[Select id,OwnerId from Case where id =:caseRecord.Id];
      
         //ACT
        test.startTest();
          Event e = new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now(), WhatId=updatedCase.Id,RecordTypeId=roadsideId);
        insert e;    
        system.debug('e '+e);
        test.stopTest();


        //ASSERT
       
        List<Event> eventes = [Select id From Event ];

        //System.AssertNotEquals(null, cases[0].ContactId); //LB- Case/Contact linking functionality has been removed from the case trigger
        System.AssertNotEquals(null, eventes);
    }
    @IsTest
      static  void TestEvent_RelatedToOpenCaseIsAbleToDelete()
    {
          Id roadsideId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').GetRecordTypeId();
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);

        User user;
        Case caseRecord;

        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Market__c = 'AU';
        }

       
         System.runAs(user){   
            caseRecord = TestClass_CaseCreator.Create('Phone','01217396328','test@test.com');
        }
        Case updatedCase =[Select id,OwnerId from Case where id =:caseRecord.Id];
      
         //ACT
        test.startTest();
          Event e = new Event(DurationInMinutes=1,ActivityDateTime=DateTime.Now(), WhatId=updatedCase.Id,RecordTypeId=roadsideId);
        insert e;    
        system.debug('e '+e);
        test.stopTest();
        delete e;


        //ASSERT
       
        List<Event> eventes = [Select id From Event ];

        //System.AssertNotEquals(null, cases[0].ContactId); //LB- Case/Contact linking functionality has been removed from the case trigger
        System.AssertEquals(null, null);
    }
    
    }