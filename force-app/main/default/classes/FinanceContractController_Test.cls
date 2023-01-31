@isTest
public class FinanceContractController_Test {
    
    @isTest static void getcurrentRecordDataTestWithMatchingStage(){
        Account accIns = TestUtility.createIndividualAccount();
        insert accIns;
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Product2 prodIns = Testutility.createProduct();
        Asset assetId = Testutility.createAsset(accIns.Id,prodIns.Id);
        Testutility.createLineItem(oppIns.Id,prodIns.Id,assetId.Id);
        
        Test.startTest();
        FinanceContractController.getcurrentRecordData(oppIns.Id);
        Test.stopTest();
    }
    
    @isTest static void getcurrentRecordDataTestWithNonMathcingStage(){
        Account accIns = TestUtility.createIndividualAccount();
        insert accIns;
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        
        Test.startTest();
        FinanceContractController.getcurrentRecordData(oppIns.Id);
        Test.stopTest();
    }
    @isTest static void getcurrentRecordDataTestWithExistingContract(){
        Account accIns = TestUtility.createIndividualAccount();
        insert accIns;
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Contract conIns = TestUtility.createContract(accIns.Id,oppIns.Id,'Initial Contract');
        insert conIns;
        
        Test.startTest();
        FinanceContractController.getcurrentRecordData(oppIns.Id);
        Test.stopTest();
    }
    @isTest static void getcurrentRecordDataTestWithCorporateAccount(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Product2 prodIns = Testutility.createProduct();
        Asset assetId = Testutility.createAsset(accIns.Id,prodIns.Id);
        Testutility.createLineItem(oppIns.Id,prodIns.Id,assetId.Id);
        
        Test.startTest();
        FinanceContractController.getcurrentRecordData(oppIns.Id);
        Test.stopTest();
    }
    
    @isTest static void getcurrentRecordDataTestWithCorporateAccountWithMultipleContact(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,2);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Product2 prodIns = Testutility.createProduct();
        Asset assetId = Testutility.createAsset(accIns.Id,prodIns.Id);
        Testutility.createLineItem(oppIns.Id,prodIns.Id,assetId.Id);
        
        Test.startTest();
        accIns.Key_Contact__c = contList.get(0).Id;
        update accIns;
        FinanceContractController.getcurrentRecordData(oppIns.Id);
        Test.stopTest();
    }
    
    @isTest static void getPicklistValuesTest(){
        Test.startTest();
        FinanceContractController.getPicklistValuesData('Contract','Contract_Status__c');
        Test.stopTest();
    }
    
    @isTest static void handleIndividualAccountChangeTest(){
        Account accIns = TestUtility.createIndividualAccount();
        insert accIns;
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Test.startTest();
        FinanceContractController.handleAccountChange(oppIns.Id,accIns.Id);
        Test.stopTest();
    }
    
    @isTest static void handleCorporateAccountChangeTest(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,2);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Test.startTest();
        FinanceContractController.handleAccountChange(oppIns.Id,accIns.Id);
        Test.stopTest();
    }
    
    @isTest static void saveContractTest(){
        Account accIns = TestUtility.createIndividualAccount();
        insert accIns;
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Purchase_Type__c = 'Used Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Product2 prodIns = Testutility.createProduct();
        Asset assetId = Testutility.createAsset(accIns.Id,prodIns.Id);
        Testutility.createLineItem(oppIns.Id,prodIns.Id,assetId.Id);
        
        FinanceContractWrapper financeInstance =  FinanceContractController.getcurrentRecordData(oppIns.Id);
        String jsonStr = JSON.serialize(financeInstance);
        
        Test.startTest();
        FinanceContractWrapper.dmlwrap dmlIns = FinanceContractController.saveContract(oppIns.Id,jsonStr);
        system.debug('dmlwrap --> '+JSON.serialize(dmlIns));
        Test.stopTest();
    }
    
    @isTest static void saveContractCorporateTest(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Product2 prodIns = Testutility.createProduct();
        Asset assetId = Testutility.createAsset(accIns.Id,prodIns.Id);
        OpportunityLineItem oli = Testutility.createLineItem(oppIns.Id,prodIns.Id,assetId.Id);
        
        Test.startTest();
        FinanceContractWrapper financeInstance =  FinanceContractController.getcurrentRecordData(oppIns.Id);
        financeInstance.fchContactId = contList.get(0).Id;
        financeInstance.isFCHChanged = true;
        financeInstance.isFchPerson = false;
        String jsonStr = JSON.serialize(financeInstance);
        
        
        oli.Model__c = prodIns.Id;
        update oli;
        FinanceContractWrapper.dmlwrap dmlIns = FinanceContractController.saveContract(oppIns.Id,jsonStr);
        system.debug('dmlwrap --> '+JSON.serialize(dmlIns));
        Test.stopTest();
    }
    
    @isTest static void saveContractCorporateTestNew(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Product2 prodIns = Testutility.createProduct();
        Asset assetId = Testutility.createAsset(accIns.Id,prodIns.Id);
        Testutility.createLineItem(oppIns.Id,prodIns.Id,assetId.Id);
        
        Test.startTest();
        FinanceContractWrapper financeInstance =  FinanceContractController.getcurrentRecordData(oppIns.Id);
        financeInstance.isFCHChanged = true;
        financeInstance.isFchPerson = false;
        String jsonStr = JSON.serialize(financeInstance);
        
        
        FinanceContractWrapper.dmlwrap dmlIns = FinanceContractController.saveContract(oppIns.Id,jsonStr);
        system.debug('dmlwrap --> '+JSON.serialize(dmlIns));
        Test.stopTest();
    }
    @isTest static void saveContractWithNull(){
        Test.startTest();
        FinanceContractWrapper.dmlwrap dmlIns = FinanceContractController.saveContract(null,null);
        system.debug('dmlwrap --> '+JSON.serialize(dmlIns));
        Test.stopTest();
    }
    @isTest static void getcurrentRecordDataTestWithNullValue(){
        FinanceContractWrapper financeInstance =  FinanceContractController.getcurrentRecordData(null);
    }
    
    @isTest static void saveContractCorporateTestWithoutAcc(){
        Opportunity oppIns = TestUtility.createOpportunity(null,'Order Taken');
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        Test.startTest();
        FinanceContractWrapper financeInstance =  FinanceContractController.getcurrentRecordData(oppIns.Id);
        Test.stopTest();
    }
    
    @isTest static void getContractPicklistValuesTest(){
        FinanceContractController.getContractPicklistValues('MENA','Finance Type');
    }
    
    //Opportunity Hanlder Test Classes
    @isTest static void RetailerTestOpp(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        
        Contract contIns = TestUtility.createContract(accIns.Id, oppIns.Id,'Initial Contract');
        contIns.recordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
        insert contIns;
        
        Test.startTest();
        oppIns.stageName = 'Retailer Lost';
        oppIns.Retailer_Loss_Category__c = 'Product';
        OppIns.Retailer_Loss_Type__c = 'Brand Image';
        oppIns.Agency_Loss_Description__c  = 'Test';
        
        update oppIns;
        Test.stopTest(); 
    }
    
    @isTest static void RetailerNSCTestOpp(){
        Account accIns = TestUtility.createCorporateAccount();
        insert accIns;
        List<Contact> contList = TestUtility.createContact(accIns.Id,1);
        Opportunity oppIns = TestUtility.createOpportunity(accIns.Id,'Order Taken');
        
        oppIns.Purchase_Type__c = 'New Vehicle';
        oppIns.Country_ISO_Code__c = 'DU';
        insert oppIns;
        
        Contract contIns = TestUtility.createContract(accIns.Id, oppIns.Id,'Initial Contract');
        contIns.recordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Finance').getRecordTypeId();
        insert contIns;
        
        Test.startTest();
        oppIns.stageName = 'NSC Lost';
        oppIns.Agency_Loss_Category__c = 'Product';
        OppIns.Agency_Loss_Type__c = 'Brand Image';
        oppIns.Agency_Loss_Description__c  = 'Test';
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
    
     @isTest static void RetailerHandoverTestOpp(){
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
        oppIns.stageName = 'Handover';
        oppIns.Agency_Loss_Category__c = 'Product';
        OppIns.Agency_Loss_Type__c = 'Brand Image';
        oppIns.Agency_Loss_Description__c  = 'Test';
        update oppIns;
        Test.stopTest();  
        Contract cont = [select id,Contract_Status__c  from contract where id =: contIns.Id];
        system.assertEquals(cont.Contract_Status__c,'Live Contract');
    }
    //Opportunity Hanlder Test Classes
}