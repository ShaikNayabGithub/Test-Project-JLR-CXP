@isTest
public with sharing class VehicleOptionsController_Tests {
    
    @TestSetup
    static void makeData(){

        Account priamryIndividual = TestClass_AccountCreator.createPrimaryAccount();
        Account secondaryIndvidiual = TestClass_AccountCreator.createPersonAccount();
        Boolean buildForPersonAccount = false;
        Asset myAsset = TestClass_AssetBuilder.BuildAndInsertVehicle(buildForPersonAccount);
        

        Test.startTest();
        String productName = 'Test Accessory';
        Product2 accessory = TestClass_Product2.createAccessoryProduct(productName);
        String accessoryId = accessory.Id;
        TestClass_OppLineItemCreator.CreatePricebookEntryForCurrency(accessoryId, 'JPY');
        
        String accessory2Name = 'Another Option';
        Product2 accessory2 = TestClass_Product2.createAccessoryProduct(accessory2Name);
        String accessory2Id = accessory2.Id;
        TestClass_OppLineItemCreator.CreatePricebookEntryForCurrency(accessory2Id, 'JPY');

        Product2 derivative = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Derivative' limit 1];
        String derivativeId = derivative.Id;
        TestClass_Product2.createProductOptionMapping(derivativeId, accessoryId, true);
        TestClass_Product2.createProductOptionMapping(derivativeId, accessory2Id, false);
        Opportunity myOpp = TestClass_OpportunityCreator.generateOpportunity(myAsset.Id, secondaryIndvidiual.Id);
        
        OpportunityLineItem oli = TestClass_OppLineItemCreator.CreateOppLineItemForCurrency(myOpp.Id, derivativeId, 'JPY');
        
        


        insert oli;
        System.debug('created oli');
        System.debug(oli);
        Test.stopTest();
    }

    @isTest 
    public static void Test_getOpportunityProductDerivatives() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        Test.startTest();
        List<OpportunityLineItem> oppLines = VehicleOptionsController.getOpportunityProductDerivatives(oppId);
        Test.stopTest();

        Assert.isNotNull(oppLines);

    }

    @isTest 
    public static void Test_getProductAddons() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        Product2 derivative = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Derivative' limit 1];
        String derivativeIdsJson = '["' + derivative.Id + '"]';

        Test.startTest();
        String output = VehicleOptionsController.getProductAddons(oppId, derivativeIdsJson);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_changeProductOptions_addNew() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        Product2 derivative = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Derivative' limit 1];
        Product2 option = [SELECT Id FROM Product2 WHERE Name = 'Another Option'];
        
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        String derivativeIdsJson = '["' + derivative.Id + '"]';

        String changeData = '{"allChangedOptionIds": ["' + option.Id + '"], ';
        changeData += '"toAdd": [{"optionId": "' + option.Id + '", "optionName": "Another Option", "productId": "' + derivative.Id + '", ';
        changeData += '"selected": true, "marketMandatory": false, "quantity": 1, "unitPrice": 100 , "opportunityProductId": "' + oli.Id + '" }';
        changeData += ' ]}';

        List<PriceBookEntry> pbes = [SELECT Id, Product2Id FROM PriceBookEntry WHERE PriceBook2Id = :Test.getStandardPricebookId()];


        System.debug('changeData');
        System.debug(changeData);

        System.debug('pbes');
        System.debug(pbes);

        Test.startTest();
        String output = VehicleOptionsController.changeProductOptions(oppId, changeData);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_changeProductOptions_removeExisting() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        Product2 derivative = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Derivative' limit 1];
        Product2 option = [SELECT Id FROM Product2 WHERE Name = 'Another Option'];
        
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        String derivativeIdsJson = '["' + derivative.Id + '"]';

        String changeData = '{"allChangedOptionIds": ["' + option.Id + '"], ';
        changeData += '"toAdd": [{"optionId": "' + option.Id + '", "optionName": "Another Option", "productId": "' + derivative.Id + '", ';
        changeData += '"selected": true, "marketMandatory": false, "quantity": 1, "unitPrice": 100 , "opportunityProductId": "' + oli.Id + '" }';
        changeData += ' ]}';

        
        VehicleOptionsController.changeProductOptions(oppId, changeData);

        String changeDataRemove = '{"allChangedOptionIds": ["' + option.Id + '"], ';
        changeDataRemove += '"toRemove": [{"optionId": "' + option.Id + '", "optionName": "Another Option", "productId": "' + derivative.Id + '", ';
        changeDataRemove += '"selected": true, "marketMandatory": false, "quantity": 1, "unitPrice": 100 , "opportunityProductId": "' + oli.Id + '" }';
        changeDataRemove += ' ]}';
        

        Test.startTest();
        String output = VehicleOptionsController.changeProductOptions(oppId, changeDataRemove);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_changeProductOptions_updateExisting() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String oppId = opp.Id;
        Product2 derivative = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Derivative' limit 1];
        Product2 option = [SELECT Id FROM Product2 WHERE Name = 'Another Option'];
        
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        String derivativeIdsJson = '["' + derivative.Id + '"]';

        String changeData = '{"allChangedOptionIds": ["' + option.Id + '"], ';
        changeData += '"toAdd": [{"optionId": "' + option.Id + '", "optionName": "Another Option", "productId": "' + derivative.Id + '", ';
        changeData += '"selected": true, "marketMandatory": false, "quantity": 1, "unitPrice": 100 , "opportunityProductId": "' + oli.Id + '" }';
        changeData += ' ]}';

        
        VehicleOptionsController.changeProductOptions(oppId, changeData);

        
        String changeDataUpdate = '{"allChangedOptionIds": ["' + option.Id + '"], ';
        changeDataUpdate += '"toUpdate": [{"optionId": "' + option.Id + '", "optionName": "Another Option", "productId": "' + derivative.Id + '", ';
        changeDataUpdate += '"selected": true, "marketMandatory": false, "quantity": 1, "unitPrice": 100 , "opportunityProductId": "' + oli.Id + '" }';
        changeDataUpdate += ' ]}';
        

        Test.startTest();
        String output = VehicleOptionsController.changeProductOptions(oppId, changeDataUpdate);
        Test.stopTest();

        Assert.isNotNull(output);
    }
}