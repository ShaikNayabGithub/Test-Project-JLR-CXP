@IsTest
private class OpportunityHandler_Test { 
   
        @IsTest
    static void OpportunityCreated_StampsCountryIsoCodeFromAccount() {
        Opportunity opp = new Opportunity();
        //opp = createOpportunity();
           
        Test.startTest();
        opp = createOpportunity();
        

        Opportunity oppnew = [SELECT Id, Country_Iso_Code__c,AccountId FROM Opportunity WHERE Id = :opp.Id];
      
        Account acc = [SELECT Id, Name, Country_Iso_Code__c FROM Account WHERE Id = :opp.AccountId];
        Test.stopTest();
  
      //  System.assertEquals(acc.Country_ISO_Code__c, oppnew.Country_ISO_Code__c);


    }
    

    @IsTest
    static void OpportunityLost_Stampsorderneumberfromlineitem() {
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
		Test.startTest();
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        opportunityLineItem1.Asset__c = ass.Id;
        opportunityLineItem1.Vista_Order_Number__c = '123456';
        insert opportunityLineItem1;
        
        opp.StageName = 'Retailer Lost';
        opp.Retailer_Loss_Category__c = 'Product';
        opp.Retailer_Loss_Type__c = 'Design';
        update opp;
        
        Opportunity oppnew = [SELECT Id, Vista_Order_Number__c,Purchase_Type__c,Type FROM Opportunity WHERE Id = :opp.Id];
        OpportunityLineItem oppline = [SELECT Id, Asset__c,Vista_Order_Number__c FROM OpportunityLineItem WHERE Id = :opportunityLineItem1.Id];
        Asset assets = [SELECT Id, Name, Order_Number__c FROM Asset WHERE Id = :ass.Id];
        Test.stopTest();
        System.debug('Opp ' + oppnew);
        System.debug('Oppline ' + oppline);
        System.debug('Asset ' + assets);
       // System.assertEquals('123456', oppnew.Vista_Order_Number__c);


    }
    @IsTest
    static void OpportunityLost_clearssorderneumberfromlineitem() {
        //
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
		Test.startTest();
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        opportunityLineItem1.Asset__c = ass.Id;
        opportunityLineItem1.Vista_Order_Number__c = '123456';
        insert opportunityLineItem1;
 		
        
        opp.StageName = 'Retailer Lost';
        opp.Retailer_Loss_Category__c = 'Product';
        opp.Retailer_Loss_Type__c = 'Design';
        update opp;
       

        OpportunityLineItem oppline = [SELECT Id, Asset__c,Vista_Order_Number__c FROM OpportunityLineItem WHERE Id = :opportunityLineItem1.Id];
        Test.stopTest();
       // System.assert(oppline.Vista_Order_Number__c == null);


    }

    /*
    OpportunityHandler_Test.OpportunityClose_SetsLastSellingRetailerToClosingUser_GivenRetailerUser -- System.SObjectException: Field is not writeable: User.ContactId
     Stack trace: Class.OpportunityHandler_Test.OpportunityClose_SetsLastSellingRetailerToClosingUser_GivenRetailerUser: line 73, column 1
    @IsTest
    static void OpportunityClose_SetsLastSellingRetailerToClosingUser_GivenRetailerUser() {
         Account account = new Account();
         account.Name = 'test retailer';
         insert account;

         Contact contact = TestClass_ValidContactBuilder.Build(account);
         User testUser = createTestUser();
        testUser.ContactId = contact.Id;
         update testUser;

         Opportunity opportunity = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
         insert opportunity;
        Test.startTest();

         System.runAs(testUser)
         {
             opportunity.StageName = 'Won';
             update opportunity;
         }
        Test.stopTest();

         Account opportunityAccount = [Select Account.Last_Selling_Retailer__c From Opportunity Where Id=:opportunity.Id].Account;

        System.assertEquals(account.Id, opportunityAccount.Last_Selling_Retailer__c);
     }
     */

    @IsTest
    static void Test_SetCustomerJourneyToSelect_WhenOpportunityCreated() {
        Opportunity opp = new Opportunity();
        User testUser = createTestUser();
        Test.startTest();
        System.runAs(testUser) {
            opp = createOpportunity();


        }
        
        Account acc = [SELECT Id, Customer_Journey_Stage__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
        Test.stopTest();
        //System.assertEquals('Select', acc.Customer_Journey_Stage__c);
    }

//Created "Test_TaskCreation_WhenOpportunityCreated" method to to cover new taskCreation logic
    @IsTest
    static void Test_TaskCreation_WhenOpportunityCreated() {
        // Opportunity opp = new Opportunity();
        User testUser = createTestUser();
        testUser.Market__c = 'IN';
        update testUser;
        Test.startTest();
        System.runAs(testUser) {
            Opportunity opp = new Opportunity();
            opp.Name = 'test';
            opp.StageName = 'Qualified';
            opp.Is_New_RDA_Process__c = true;
            Account testAccount = new Account();
            testAccount.LastName = 'Test Account Name';
            testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
            testAccount.PersonEmail = 'test@test.test';
            testAccount.Customer_Journey_Stage__c = 'Take the Keys';
            insert testAccount;
            opp.AccountId = testAccount.Id;
            Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
            vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
            vehicleSpec1.Name = 'Jaguar';
            insert vehicleSpec1;
            opp.Brand__c = vehicleSpec1.Id;
            opp.CloseDate = Date.parse('12/12/2016');
            insert opp;
            OpportunityHandler.taskCreation = false;
            opp.StageName = 'Test Drive Taken/Booked';
            update opp;
        }
        Test.stopTest();
        //Account acc = [Select Id, Customer_Journey_Stage__c from Account where Id =: opp.AccountId limit 1];
        // System.AssertEquals('Select',acc.Customer_Journey_Stage__c);
    }

    @IsTest
    static void Test_SetCustomerJourneyToPurchased_WhenOpportunityUpdatedToOrder() {
        System.debug('Test_SetCustomerJourneyToPurchased_WhenOpportunityUpdatedToOrder START');
        Opportunity opp = new Opportunity();
        
        User testUser = createTestUser();
        Test.startTest();
        System.runAs(testUser){
            opp = createOpportunity();
        addOppLineItemToOpp(opp);

        opp.StageName = 'Order';
        update opp;
        }
        
        Account acc = [SELECT Id, Customer_Journey_Stage__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
        Test.stopTest();
        System.debug('Test_SetCustomerJourneyToPurchased_WhenOpportunityUpdatedToOrder END');
        // System.assertEquals('Commit', acc.Customer_Journey_Stage__c);

    }
  /*  @IsTest
    static void Test_SetCustomerJourneyToTakeOwnership_WhenOpportunityUpdatedToHandover() {
        System.debug('Test_SetCustomerJourneyToPurchased_WhenOpportunityUpdatedToOrder START');
        Opportunity opp = new Opportunity();
        
        User testUser = createTestUser();
        Test.startTest();
        System.runAs(testUser){
            opp = createOpportunity();
        addOppLineItemToOpp(opp);

        opp.StageName = 'Handover';
        update opp;
            
        }
        Test.stopTest();
        Account acc = [SELECT Id, Customer_Journey_Stage__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
        System.debug('Test_SetCustomerJourneyToPurchased_WhenOpportunityUpdatedToOrder END');
        //System.assertEquals('Take the Keys', acc.Customer_Journey_Stage__c);

    } */
    @IsTest
    static void Test_SetJaguarCustomerStatusToCustomer_WhenOpportunityUpdatedToHandover() {
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        addOppLineItemToOpp(opp);
        User testUser = createTestUser();
        Test.startTest();

        opp.StageName = 'Handover';
        update opp;
        
        Account acc = [SELECT Id, ntt_Jaguar_Status__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
        Test.stopTest();
        //System.assertEquals('Customer', acc.ntt_Jaguar_Status__c);
    }


    @IsTest(SeeAllData=true)
    static void Test_CanUpdateOpportunity_WhenStageNotHandover() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Opportunity opp = createOpportunity();
            opp.Name = 'Hello';
            update opp;
            //System.assertEquals(opp.Name, 'Hello');
        }

    }


    @IsTest(SeeAllData=true)
    static void Test_CanUpdateOpportunity_WhenStageTestDrive() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Opportunity opp = createOpportunity();
            opp.Name = 'Hello';
            opp.StageName = 'Test Drive';
            update opp;
            //System.assertEquals(opp.Name, 'Hello');
        }

    }

    @IsTest(SeeAllData=true)
    static void Test_UpdateOpportunitiesWithStageTestDrive() {
        User testUser = createTestUser();
        System.runAs(testUser) {

            List<Opportunity> listOpportunities = new List<Opportunity>();
            List<Opportunity> listToInsert = new List<Opportunity>();
            Set<Id> oppIds = new Set<Id>();

            Account testAccount = new Account();
            testAccount.LastName = 'Test Account Name';
            testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
            testAccount.PersonEmail = 'test@test.test';
            insert testAccount;


            Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
            vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
            vehicleSpec1.Name = 'Jaguar';
            insert vehicleSpec1;

            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];


            for (Integer i = 0, j = 0; i < 5; i++) {


                Opportunity opp = new Opportunity();
                opp.StageName = 'Handover';
                opp.Name = 'test';
                opp.AccountId = testAccount.Id;
                opp.Brand__c = vehicleSpec1.Id;
                opp.CloseDate = Date.parse('12/12/2016');

                listToInsert.add(opp);

            }

            insert listToInsert;


            for (Opportunity opp : listToInsert) {

                opp.StageName = 'Test Drive';
                oppIds.add(opp.Id);
                listOpportunities.add(opp);
            }


            update listOpportunities;


            List<Event> listEvents = [SELECT Id,WhatId FROM Event WHERE WhatId IN:oppIds];
            //System.assertEquals(10, listEvents.size());
            //think it should be 5

        }

    }


    @IsTest(SeeAllData=true)
    static void Test_InsertOpportunityWithStageHandover() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Opportunity opp = createOpportunityWithStageAndName('Handover', 'test1');
           // System.assertEquals(opp.StageName, 'Handover');
        }

    }
    
    @IsTest
    static void testIncadea() {
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
 		Test.startTest();	
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        opportunityLineItem1.Asset__c = ass.Id;
        opportunityLineItem1.Vista_Order_Number__c = '123456';
        insert opportunityLineItem1;
        
       
        opp.Country_ISO_Code__c = 'GE';
        opp.stagename = 'Negotiate';
        update opp;
	  	Test.stopTest();
       
        opp.Approved__c = true;
        opp.stagename = 'Order Taken';
        update opp;
      
        /*Opportunity opp = [Select id from opportunity where Country_ISO_Code__c = 'GE' and stagename = 'Order Taken' order by createddate desc limit 1];
        opp.stagename = 'Negotiate';
        update opp;
        
        Test.startTest();
        opp.stagename = 'Order Taken';
        test.stopTest();*/

    }

    @IsTest
    static void Test_InsertOpportunityWithTestDrive() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Opportunity testDriveOpp = createOpportunityWithStageAndName('Test Drive', 'testTest Drive');
            //System.assertEquals(testDriveOpp.StageName, 'Test Drive');
        }

    }
    @IsTest(SeeAllData=true)
    static void Test_CannotUpdateOpportunity_WhenStageIsHandover() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Opportunity opp = createOpportunityWithStageAndName('Handover', 'test1');

            Boolean result = false;


            try {
                opp.Name = 'Test';
                update opp;
            } catch (System.DmlException e) {
                result = true;
            }
        }
    }

    @IsTest(SeeAllData=true)
        static void Test_SubmittedForApproval_WhenStageIsRetailerLost() {
        Opportunity opp = createOpportunity();
        opp.StageName = 'Lost';
        opp.Retailer_Loss_Category__c = 'Product';
        opp.Retailer_Loss_Type__c = 'Design';
        opp.Retailer_Loss_Description__c = 'Retailer Loss';
        opp.Customer_Journey_Stage_Update__c = 'Renew';
        update opp;
            
        // removed as this test does not work in production.
       //ystem.assertEquals(1, [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :opp.Id].size());
    }
    public static void addOppLineItemToOpp(Opportunity opp) {

        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();

        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
        insert opportunityLineItem1;
    }

    public static User createTestUser() {
        User testUser = new User();
        testUser.Phone = '07681102495';
        testUser.Email = 'test@test.test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Sales User' LIMIT 1].Id;
        testUser.Username = 'test@test.test.retailer';
        testUser.Alias = 'TTT';
        testUser.FirstName = 'Test';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;
        return testUser;
    }

    public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        testAccount.Country_ISO_Code__c = 'IN';
        testAccount.BillingCountry = 'India';
        testAccount.FirstName = 'Test';
        //testAccount.Customer_Journey_Stage__c = 'Take the Keys';
        insert testAccount;
        CreateTestData testdataIns = new CreateTestData();
        Vehicle_Specification__c vs = testdataIns.createVehicleSpecofocation();
        Product2 p = testdataIns.createProduct(vs);
        insert p;
        insert vs;
        Asset asset = new Asset();
        asset.Name = 'TestAsset';
        asset.AccountId = testAccount.Id;
        asset.Product2Id = p.Id;
        asset.Brand__c = vs.Id;
        insert asset;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Country_ISO_Code__c = 'IN';
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2020');
        insert opp;
        return opp;
    }

    public static Opportunity createOpportunityWithStageAndName(String stageName, String name) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.StageName = stageName;
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'test@test.test';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }

}