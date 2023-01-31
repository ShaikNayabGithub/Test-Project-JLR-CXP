@IsTest
public class HandovervalidatorController_Test {
    
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id dealerOwnedRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    
    static testmethod void RDAValidatorWithLinkedOpportunity() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Private Individual';
        vehicle.Sale_Type_Code__c = 'RET';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'New';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover('');
        
        
        
    }
    static testmethod void RDAValidatorWithLinkedOpportunityNoLineItem() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'WHS';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'New';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        // insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithLinkedOpportunityNoSaleTypeOnAsset() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = null;
        vehicle.Common_Sale_Type__c = null;
        vehicle.Sale_Type_Code__c = null;
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'New';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithLinkedOpportunityIncorrectSaleTypeOnAsset() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'Rbbish';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'New';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
       handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithLinkedOpportunityOnSell() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'Rbbish';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'Used Vehicle';
        opp.Sale_Type__c = 'Demonstrator';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithLinkedOpportunitTradeIn() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'Rbbish';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'Approved_Pre_Owned';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithLinkedOpportunitNoSaleType() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'Rbbish';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = null;
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithIncorrectId() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'Rbbish';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = null;
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithOpportunityatcorrectstage() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Private Individual';
        vehicle.Sale_Type_Code__c = 'RET';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = null;
        opp.StageName = 'Handover & RDA';
        opp.Handover_Date__c = system.Date.Today();
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
    static testmethod void RDAValidatorWithOpportunityatTradeIn() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Private Individual';
        vehicle.Sale_Type_Code__c = 'RET';
        vehicle.Traded_In__c = true;
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'Pre_Owned';
        
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
        
        
    }
        static testmethod void RDAValidatorWithOpportunityatTradeInFlagNotSet() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Private Individual';
        vehicle.Sale_Type_Code__c = 'RET';
        vehicle.Traded_In__c = false;
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'Pre_Owned';
        
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        
    }
    static testmethod void RDAValidatorWithAssetRelatedToTwoOpportunities() {
                
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'Rbbish';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        opp.Sale_Type__c = 'Pre_Owned';
        Test.startTest();
        insert opp;
        
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        
        Opportunity opp1 = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp1.Purchase_Type__c = 'New Vehicle';
        opp1.Sale_Type__c = 'Pre_Owned';
        
        insert opp1;        
        OpportunityLineItem oli1 = TestClass_OpportunityProductBuilder.BuildLineItem(opp1, pb);
        oli1.Asset__c = vehicle.Id;
        insert oli1;
        
        handoverValidatorWrapper wraps = HandovervalidatorController.validateHandover( opp.id);
        Test.stopTest();        
    }   

}