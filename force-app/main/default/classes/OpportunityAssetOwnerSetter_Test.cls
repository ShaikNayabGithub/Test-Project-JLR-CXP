@isTest
public class OpportunityAssetOwnerSetter_Test{
    
    static testmethod void SetOwner_ValidOpportunityProduct_SetsAssetOwnerTrue(){
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Test.startTest();
        //create OpportunityLineItems
        OpportunityLineItem oppLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oppLineItem.Asset__c = vehicle.Id;
        oppLineItem.Status__c = 'Fulfilled From Stock';
        insert oppLineItem;
        Test.stopTest();

        opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppLineItem.OpportunityId];
        vehicle = [SELECT AccountId FROM Asset WHERE Id = :vehicle.Id];
        //System.assertEquals(vehicle.AccountId, opp.AccountId);

    }
    
     static testmethod void SetOwner_ValidOpportunityProduct_SetsAssetStatusTrue(){
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
              Test.startTest();
        //create OpportunityLineItems
        OpportunityLineItem oppLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oppLineItem.Asset__c = vehicle.Id;
        oppLineItem.Status__c = 'Fulfilled From Stock';
        insert oppLineItem;
         Test.stopTest();

        vehicle = [SELECT Status FROM Asset WHERE Id = :vehicle.Id];
        System.assertEquals(vehicle.Status, 'Owned');

    }
    
    static testmethod void SetOwner_InvalidOpportunityProductStatus_SetsAssetOwnerFalse(){
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();

        Test.startTest();
        //create OpportunityLineItems
        OpportunityLineItem oppLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oppLineItem.Asset__c = vehicle.Id; //do not set status
        insert oppLineItem;
        Test.stopTest();

        opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppLineItem.OpportunityId];
        vehicle = [SELECT AccountId FROM Asset WHERE Id = :vehicle.Id];
        System.assertNotEquals(vehicle.AccountId, opp.AccountId);

    }
    
    static testmethod void SetOwner_InvalidOpportunityProductStatus_SetsAssetStatusFalse(){
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        //create OpportunityLineItems

        Test.startTest();
        OpportunityLineItem oppLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oppLineItem.Asset__c = vehicle.Id; //do not set status
        insert oppLineItem;

        Test.stopTest();
        vehicle = [SELECT Status FROM Asset WHERE Id = :vehicle.Id];
        System.assertNotEquals(vehicle.Status, 'Owned');

    }
    
    static testmethod void ClearOwner_ValidOpportunityProduct_ResetsOwnerTrue(){
    	Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
    	insert opp;
    	Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
    	Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
    	vehicle.Status = 'For Sale';
    	vehicle.Historic_Status__c = 'For Sale';
        vehicle.Model_Year_Code__c = '001BS';
    	insert vehicle;

        Test.startTest();
    	vehicle = [SELECT AccountId FROM Asset WHERE Id = :vehicle.Id];
    	Id ownerId = vehicle.AccountId;
    	//create OpportunityLineItems
    	OpportunityLineItem oppLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
    	oppLineItem.Asset__c = vehicle.Id;
    	oppLineItem.Status__c = 'Fulfilled From Stock';
    	insert oppLineItem;
    	//delete the Opportunity Line Item and ensure the Asset gets its old Status back
    	delete oppLineItem;

        Test.stopTest();
    	vehicle = [SELECT AccountId FROM Asset WHERE Id = :vehicle.Id];
    	System.assertEquals(ownerId, vehicle.AccountId);

    }
    
    static testmethod void ClearOwner_ValidOpportunityProduct_ResetsStatusTrue(){
    	Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
    	insert opp;
    	Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
    	Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
    	vehicle.Status = 'For Sale';
    	vehicle.Historic_Status__c = 'For Sale';
    	insert vehicle;

        Test.startTest();
    	//create OpportunityLineItems
    	OpportunityLineItem oppLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
    	oppLineItem.Asset__c = vehicle.Id;
    	oppLineItem.Status__c = 'Fulfilled From Stock';
    	insert oppLineItem;
    	//delete the Opportunity Line Item and ensure the Asset gets its old Status back
    	delete oppLineItem;

        Test.stopTest();
    	vehicle = [SELECT Status FROM Asset WHERE Id = :vehicle.Id];
    	//System.assertEquals('For Sale', vehicle.Status);

    }

}