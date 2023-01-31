@isTest
public class SalesTarget_Batch_Test {
    
    @isTest static void testHandoverSalesData(){
        
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        system.runAs(userIns){
            Account accIns = createAccount();
            Contact conIns = createContact(accIns.Id);
            date myDate = date.newInstance(2020, 05, 05);
            createOpportunityWithStageAndName(accIns.Id,'Handover & RDA',2020,10);
            
        }
        Test.startTest();
        SalesTarget_Batch salesIns = new SalesTarget_Batch('2020','MENA','Handover',null);
        Database.executeBatch(salesIns);
        Test.stopTest();
        Sales_Target__c saleTarget = [SELECT 
                                      Id, Salesperson__c, Target_Year__c, April_Handover__c, August_Handover__c,  December_Handover__c, February_Handover__c, January_Handover__c, July_Handover__c, June_Handover__c, March_Handover__c, May_Handover__c, November_Handover__c, October_Handover__c, Salesperson_Manager__c, September_Handover__c, Region_or_Market__c, Retailer__c, April_Order__c, August_Order__c, December_Order__c, February_Order__c, January_Order__c, July_Order__c, June_Order__c, March_Order__c, May_Order__c, November_Order__c, October_Order__c, September_Order__c, Current_Month_Order__c
                                      FROM 
                                      Sales_Target__c 
                                      where 
                                      Salesperson__c =:userIns.Id 
                                      limit 
                                      1];
        system.debug('saleTarget --> '+json.serialize(saleTarget));
        system.assertEquals(saleTarget.January_Handover__c,1);
        system.assertEquals(saleTarget.February_Handover__c,1);
        system.assertEquals(saleTarget.March_Handover__c,1);
        system.assertEquals(saleTarget.April_Handover__c,1);
        system.assertEquals(saleTarget.May_Handover__c,1);
        system.assertEquals(saleTarget.June_Handover__c,1);
        system.assertEquals(saleTarget.July_Handover__c,1);
        system.assertEquals(saleTarget.August_Handover__c,1);
        system.assertEquals(saleTarget.September_Handover__c,1);
        system.assertEquals(saleTarget.October_Handover__c,1);
        system.assertEquals(saleTarget.November_Handover__c,1);
        system.assertEquals(saleTarget.December_Handover__c,1); 
    }
    
    @isTest static void testHandoverSalesDataWithNoOpp(){
        
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        system.runAs(userIns){
            Account accIns = createAccount();
            Contact conIns = createContact(accIns.Id);
            date myDate = date.newInstance(2020, 05, 05);
            //createOpportunityWithStageAndName(accIns.Id,'Handover & RDA',myDate,10);
            
        }
        Test.startTest();
        SalesTarget_Batch salesIns = new SalesTarget_Batch('2020','MENA','Handover',null);
        Database.executeBatch(salesIns);
        Test.stopTest();
        Sales_Target__c saleTarget = [SELECT 
                                      Id, Salesperson__c, Target_Year__c, April_Handover__c, August_Handover__c,  December_Handover__c, February_Handover__c, January_Handover__c, July_Handover__c, June_Handover__c, March_Handover__c, May_Handover__c, November_Handover__c, October_Handover__c, Salesperson_Manager__c, September_Handover__c, Region_or_Market__c, Retailer__c, April_Order__c, August_Order__c, December_Order__c, February_Order__c, January_Order__c, July_Order__c, June_Order__c, March_Order__c, May_Order__c, November_Order__c, October_Order__c, September_Order__c, Current_Month_Order__c
                                      FROM 
                                      Sales_Target__c 
                                      where 
                                      Salesperson__c =:userIns.Id 
                                      limit 
                                      1];
        system.debug('saleTarget --> '+json.serialize(saleTarget));
        system.assertEquals(saleTarget.January_Handover__c,0);
        system.assertEquals(saleTarget.February_Handover__c,0);
        system.assertEquals(saleTarget.March_Handover__c,0);
        system.assertEquals(saleTarget.April_Handover__c,0);
        system.assertEquals(saleTarget.May_Handover__c,0);
        system.assertEquals(saleTarget.June_Handover__c,0);
        system.assertEquals(saleTarget.July_Handover__c,0);
        system.assertEquals(saleTarget.August_Handover__c,0);
        system.assertEquals(saleTarget.September_Handover__c,0);
        system.assertEquals(saleTarget.October_Handover__c,0);
        system.assertEquals(saleTarget.November_Handover__c,0);
        system.assertEquals(saleTarget.December_Handover__c,0); 
    }
    
    
    @isTest static void testOrderSalesData(){
        
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        system.runAs(userIns){
            Account accIns = createAccount();
            Contact conIns = createContact(accIns.Id);
            date myDate = date.newInstance(2020, 05, 05);
            List<Opportunity> oppList = createOpportunityWithStageAndName(accIns.Id,'Order',2020,12);
            updateOpp(oppList,2020);
            
        }
        Test.startTest();
        List<Opportunity> oppList = [select id,Date_To_Order_Stage__c from Opportunity];
        system.debug('oppList --> '+json.serialize(oppList));
        SalesTarget_Batch salesIns = new SalesTarget_Batch('2020','MENA','Order',null);
        Database.executeBatch(salesIns);
        Test.stopTest();
        Sales_Target__c saleTarget = [SELECT 
                                      Id, Salesperson__c, Target_Year__c, April_Handover__c, August_Handover__c,  December_Handover__c, February_Handover__c, January_Handover__c, July_Handover__c, June_Handover__c, March_Handover__c, May_Handover__c, November_Handover__c, October_Handover__c, Salesperson_Manager__c, September_Handover__c, Region_or_Market__c, Retailer__c, April_Order__c, August_Order__c, December_Order__c, February_Order__c, January_Order__c, July_Order__c, June_Order__c, March_Order__c, May_Order__c, November_Order__c, October_Order__c, September_Order__c, Current_Month_Order__c
                                      FROM 
                                      Sales_Target__c 
                                      where 
                                      Salesperson__c =:userIns.Id 
                                      limit 
                                      1];
        system.debug('saleTarget --> '+json.serialize(saleTarget));
        system.assertEquals(saleTarget.January_Order__c,1);
        system.assertEquals(saleTarget.February_Order__c,1);
        system.assertEquals(saleTarget.March_Order__c,1);
        system.assertEquals(saleTarget.April_Order__c,1);
        system.assertEquals(saleTarget.May_Order__c,1);
        system.assertEquals(saleTarget.June_Order__c,1);
        system.assertEquals(saleTarget.July_Order__c,1);
        system.assertEquals(saleTarget.August_Order__c,1);
        system.assertEquals(saleTarget.September_Order__c,1);
        system.assertEquals(saleTarget.October_Order__c,1);
        system.assertEquals(saleTarget.November_Order__c,1);
        system.assertEquals(saleTarget.December_Order__c,1); 
    }
    
    
    @isTest static void testOrderSalesDataWithNoOpp(){
        
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        system.runAs(userIns){
            Account accIns = createAccount();
            Contact conIns = createContact(accIns.Id);
            date myDate = date.newInstance(2020, 05, 05);
            //createOpportunityWithStageAndName(accIns.Id,'Handover & RDA',myDate,10);
            
        }
        Test.startTest();
        SalesTarget_Batch salesIns = new SalesTarget_Batch('2020','MENA','Order',null);
        Database.executeBatch(salesIns);
        Test.stopTest();
        Sales_Target__c saleTarget = [SELECT 
                                      Id, Salesperson__c, Target_Year__c, April_Handover__c, August_Handover__c,  December_Handover__c, February_Handover__c, January_Handover__c, July_Handover__c, June_Handover__c, March_Handover__c, May_Handover__c, November_Handover__c, October_Handover__c, Salesperson_Manager__c, September_Handover__c, Region_or_Market__c, Retailer__c, April_Order__c, August_Order__c, December_Order__c, February_Order__c, January_Order__c, July_Order__c, June_Order__c, March_Order__c, May_Order__c, November_Order__c, October_Order__c, September_Order__c, Current_Month_Order__c
                                      FROM 
                                      Sales_Target__c 
                                      where 
                                      Salesperson__c =:userIns.Id 
                                      limit 
                                      1];
        system.debug('saleTarget --> '+json.serialize(saleTarget));
        system.assertEquals(saleTarget.January_Order__c,0);
        system.assertEquals(saleTarget.February_Order__c,0);
        system.assertEquals(saleTarget.March_Order__c,0);
        system.assertEquals(saleTarget.April_Order__c,0);
        system.assertEquals(saleTarget.May_Order__c,0);
        system.assertEquals(saleTarget.June_Order__c,0);
        system.assertEquals(saleTarget.July_Handover__c,0);
        system.assertEquals(saleTarget.August_Order__c,0);
        system.assertEquals(saleTarget.September_Order__c,0);
        system.assertEquals(saleTarget.October_Order__c,0);
        system.assertEquals(saleTarget.November_Order__c,0);
        system.assertEquals(saleTarget.December_Order__c,0); 
    }
    
    
    @isTest static void testOrderSalesDataWithNoOpp1(){
        
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        system.runAs(userIns){
            Account accIns = createAccount();
            Contact conIns = createContact(accIns.Id);
            date myDate = date.newInstance(2020, 05, 05);
            createOpportunityWithStageAndName(accIns.Id,'Order',2018,10);
            
        }
        Test.startTest();
        SalesTarget_Batch salesIns = new SalesTarget_Batch('2020','MENA','Order',null);
        Database.executeBatch(salesIns);
        Test.stopTest();
        Sales_Target__c saleTarget = [SELECT 
                                      Id, Salesperson__c, Target_Year__c, April_Handover__c, August_Handover__c,  December_Handover__c, February_Handover__c, January_Handover__c, July_Handover__c, June_Handover__c, March_Handover__c, May_Handover__c, November_Handover__c, October_Handover__c, Salesperson_Manager__c, September_Handover__c, Region_or_Market__c, Retailer__c, April_Order__c, August_Order__c, December_Order__c, February_Order__c, January_Order__c, July_Order__c, June_Order__c, March_Order__c, May_Order__c, November_Order__c, October_Order__c, September_Order__c, Current_Month_Order__c
                                      FROM 
                                      Sales_Target__c 
                                      where 
                                      Salesperson__c =:userIns.Id 
                                      limit 
                                      1];
        system.debug('saleTarget --> '+json.serialize(saleTarget));
        system.assertEquals(saleTarget.January_Order__c,0);
        system.assertEquals(saleTarget.February_Order__c,0);
        system.assertEquals(saleTarget.March_Order__c,0);
        system.assertEquals(saleTarget.April_Order__c,0);
        system.assertEquals(saleTarget.May_Order__c,0);
        system.assertEquals(saleTarget.June_Order__c,0);
        system.assertEquals(saleTarget.July_Handover__c,0);
        system.assertEquals(saleTarget.August_Order__c,0);
        system.assertEquals(saleTarget.September_Order__c,0);
        system.assertEquals(saleTarget.October_Order__c,0);
        system.assertEquals(saleTarget.November_Order__c,0);
        system.assertEquals(saleTarget.December_Order__c,0); 
    }
    
    @isTest static void testHandoverSalesDataWithNoOpp1(){
        
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        system.runAs(userIns){
            Account accIns = createAccount();
            Contact conIns = createContact(accIns.Id);
            date myDate = date.newInstance(2020, 05, 05);
            createOpportunityWithStageAndName(accIns.Id,'Handover & RDA',2018,10);
            
        }
        Test.startTest();
        SalesTarget_Batch salesIns = new SalesTarget_Batch('2020','MENA','Handover',null);
        Database.executeBatch(salesIns);
        Test.stopTest();
        Sales_Target__c saleTarget = [SELECT 
                                      Id, Salesperson__c, Target_Year__c, April_Handover__c, August_Handover__c,  December_Handover__c, February_Handover__c, January_Handover__c, July_Handover__c, June_Handover__c, March_Handover__c, May_Handover__c, November_Handover__c, October_Handover__c, Salesperson_Manager__c, September_Handover__c, Region_or_Market__c, Retailer__c, April_Order__c, August_Order__c, December_Order__c, February_Order__c, January_Order__c, July_Order__c, June_Order__c, March_Order__c, May_Order__c, November_Order__c, October_Order__c, September_Order__c, Current_Month_Order__c
                                      FROM 
                                      Sales_Target__c 
                                      where 
                                      Salesperson__c =:userIns.Id 
                                      limit 
                                      1];
        system.debug('saleTarget --> '+json.serialize(saleTarget));
        system.assertEquals(saleTarget.January_Handover__c,0);
        system.assertEquals(saleTarget.February_Handover__c,0);
        system.assertEquals(saleTarget.March_Handover__c,0);
        system.assertEquals(saleTarget.April_Handover__c,0);
        system.assertEquals(saleTarget.May_Handover__c,0);
        system.assertEquals(saleTarget.June_Handover__c,0);
        system.assertEquals(saleTarget.July_Handover__c,0);
        system.assertEquals(saleTarget.August_Handover__c,0);
        system.assertEquals(saleTarget.September_Handover__c,0);
        system.assertEquals(saleTarget.October_Handover__c,0);
        system.assertEquals(saleTarget.November_Handover__c,0);
        system.assertEquals(saleTarget.December_Handover__c,0); 
    }
    
    @isTest static void RetailerHandoverTestOpp(){
        User userIns = createCommunityUser('MENA');
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert userIns;
        }
        createSalesTarget(userIns.Id,'2020');
        Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
        Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true);
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle',Warranty_Length__c = 24);
        insert p2;
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Product__c  = p2.Id,Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = servicePlan.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Negotiation');
        
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        oppIns.Brand__c = modelVehicle.Make__c;
        oppIns.Handover_Date__c = system.today();
        insert oppIns;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppIns.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;
        
        Contract contIns = TestUtility.createContract(accIns.Id, oppIns.Id,'Initial Contract');
        contIns.recordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
        insert contIns;
        
        Test.startTest();
        oppIns.stageName = 'Handover';
        oppIns.Agency_Loss_Category__c = 'Product';
        OppIns.Agency_Loss_Type__c = 'Brand Image';
        oppIns.Agency_Loss_Description__c  = 'Test';
        oppIns.ownerid = userIns.Id;
        update oppIns;
        Test.stopTest();         
    }
    
     @isTest static void RetailerOrderTestOpp(){
        Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
        Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true);
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle',Warranty_Length__c = 24);
        insert p2;
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Product__c  = p2.Id,Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = servicePlan.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        oppIns.Brand__c = modelVehicle.Make__c;
        oppIns.Handover_Date__c = system.today();
        insert oppIns;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppIns.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;
        
        Contract contIns = TestUtility.createContract(accIns.Id, oppIns.Id,'Initial Contract');
        contIns.recordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
        insert contIns;
        
        Test.startTest();
        oppIns.stageName = 'Order';
        oppIns.Country_ISO_Code__c = 'IN';
        oppIns.Agency_Loss_Category__c = 'Product';
        OppIns.Agency_Loss_Type__c = 'Brand Image';
        oppIns.Agency_Loss_Description__c  = 'Test';
        update oppIns;
        Test.stopTest();  
        Contract cont = [select id,Contract_Status__c  from contract where id =: contIns.Id];
        system.assertEquals(cont.Contract_Status__c,'Initial Contract');
    }
    
    public static void createSalesTarget(id salesPersonId,String year){
        Sales_Target__c salesUp = new Sales_Target__c();
        salesUp.Salesperson__c = salesPersonId;
        salesUp.Target_Year__c = year;
        salesUp.January_Order__c = 0;
        salesUp.February_Order__c = 0;
        salesUp.March_Order__c = 0;
        salesUp.April_Order__c = 0;
        salesUp.May_Order__c = 0;
        salesUp.June_Order__c = 0;
        salesUp.July_Order__c = 0;
        salesUp.August_Order__c = 0;
        salesUp.September_Order__c = 0;
        salesUp.October_Order__c = 0;
        salesUp.November_Order__c = 0;
        salesUp.December_Order__c = 0;
        salesUp.January_Handover__c = 0;
        salesUp.February_Handover__c = 0;
        salesUp.March_Handover__c = 0;
        salesUp.April_Handover__c = 0;
        salesUp.May_Handover__c = 0;
        salesUp.June_Handover__c = 0;
        salesUp.July_Handover__c = 0;
        salesUp.August_Handover__c = 0;
        salesUp.September_Handover__c = 0;
        salesUp.October_Handover__c = 0;
        salesUp.November_Handover__c = 0;
        salesUp.December_Handover__c = 0;
        insert salesUp;
    }
    public static Account createAccount(){
        Account testAccount = new Account();
        testAccount.Name = 'Test Acc Name123';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        insert testAccount;
        return testAccount;
    }
    
    public static Contact createContact(id accountId){
        Contact testContact = new Contact();
        testContact.FirstName = 'JLR Contact';
        testContact.LastName = 'Test L Name';
        testContact.email = 'test3jlr@testjlr123.cxpdevjlr123';
        testContact.accountid = accountId;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('JLR Contact').getRecordTypeId();
        insert testContact;
        return testContact;
    }
    public static void updateOpp(List<Opportunity> oppList,integer year) {
        for(Integer i=0;i<=8;i++){
            integer j = i+4;
            Opportunity opp = oppList.get(i);
            opp.Date_to_Order_Stage_Time__c = date.newInstance(year, j, j);
            oppList[i] = opp;
        }
        integer j=1;
        year = year+1;
        for(Integer i=9;i<=11;i++){
            Opportunity opp = oppList.get(i);
            opp.Date_to_Order_Stage_Time__c = date.newInstance(year, j, j);
            oppList[i] = opp;
            j++;
        }
        
        update oppList;
    }
    
    public static List<Opportunity> createOpportunityWithStageAndName(id accountId,String stageName,integer year,Integer count) {
        
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=4;i<=12;i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp '+i;
            opp.AccountId = accountId;
            opp.StageName = stageName;
            opp.Brand__c = vehicleSpec1.Id;
            opp.CloseDate = date.newInstance(year, i, i);
            opp.Date_to_Order_Stage_Time__c = date.newInstance(year, i, i);
            opp.Purchase_Type__c = 'New Vehicle';
            opp.Handover_Date__c = date.newInstance(year, i, i);
            oppList.add(opp);
        }
        year = year + 1;
        for(Integer i=1;i<=3;i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp '+i;
            opp.AccountId = accountId;
            opp.StageName = stageName;
            opp.Brand__c = vehicleSpec1.Id;
            opp.CloseDate = date.newInstance(year, i, i);
            opp.Date_to_Order_Stage_Time__c = date.newInstance(year, i, i);
            opp.Purchase_Type__c = 'New Vehicle';
            opp.Handover_Date__c = date.newInstance(year, i, i);
            oppList.add(opp);
        }
        insert oppList;
        return oppList;
    }
    
    
    
    public static User createCommunityUser(String market) {
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Acc Name';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Test F Name';
        testContact.LastName = 'Test L Name';
        testContact.email = 'test123@test123.cxpdev123';
        testContact.accountid = testAccount.Id;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee Contact').getRecordTypeId();
        insert testContact;
        
        User testUser = new User();
        testUser.Phone = '07681102495';
        testUser.Email = 'test@test.test';
        testUser.ContactId = testContact.Id;
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager/Receptionist MENA' LIMIT 1].Id;
        testUser.Username = 'test@test.test.retailer';
        testUser.Alias = 'TTT';
        testUser.FirstName = 'Test';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.Market__c = market;
        testUser.IsActive = true;
        return testUser;
    }
    
    
}