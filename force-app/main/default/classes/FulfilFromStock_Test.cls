@isTest
public class FulfilFromStock_Test{
    
    static testmethod void Setup_InternalUser_RetailerWarningDisplayed(){
        User testUser = TestClass_UserCreator.CreateUser([SELECT Id FROM Profile WHERE Name = 'Delegated NSC Administrator' LIMIT 1][0]);
        System.runAs(testUser){
            Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
            insert opp;
            ApexPages.currentPage().getParameters().put('Id', opp.Id);
            FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
            fulfilFromStock.ShowNoRetailerWarning();
            System.assertEquals(System.Label.Stock_Search_No_Retailer_Assigned, ApexPages.getMessages()[0].getSummary());
        }
    }
    
    static testmethod void SelectVehicle_ValidAsset_PriceAssigned(){
        //create an Opportunity and an Asset and ensure the created Opportunity Product has the correct price 
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Status = 'For Sale';
        vehicle.Price = 1000;
        insert vehicle;
        ApexPages.currentPage().getParameters().put('Id', opp.Id);
        FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
        fulfilFromStock.asf.PerformSearch();
        fulfilFromStock.chosenAsset = '' + vehicle.Id;
        fulfilFromStock.SelectVehicle();
        System.assertEquals(1000, fulfilFromStock.opportunityProduct.UnitPrice);
    }
    
    static testmethod void Save_NoUnitPrice_ErrorMessageDisplayed(){
        //create an Opportunity and an Asset and ensure an error is displayed when trying to save the Opportunity Product with no Unit Price
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Status = 'For Sale';
        insert vehicle;
        ApexPages.currentPage().getParameters().put('Id', opp.Id);
        FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
        fulfilFromStock.asf.PerformSearch();
        fulfilFromStock.chosenAsset = '' + vehicle.Id;
        fulfilFromStock.SelectVehicle();
        fulfilFromStock.Save();
        System.assertEquals(System.Label.Stock_Search_Sales_Price_Mandatory, ApexPages.getMessages()[0].getSummary());
    }
    
    static testmethod void SelectVehicle_ExternalUser_PricebookEntryIsCorrect(){
        //setup external user
        Account account = TestClass_AccountCreator.CreateRetailer();
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        User currentUser = new User(Id=UserInfo.getUserId());
        User testUser;
        
        //create an India pricebook and a FROM STOCK product and create a valid pricebook entry for the two
        Pricebook2 indiaPb = TestClass_PricebookCreator.CreatePricebook('India'); //TestClass_PricebookCreator saves Pricebook record
        PriceBookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(indiaPb, 'FROM STOCK'); //TestClass_PriceBookEntryBuilder save PriceBookEntry record
        
        System.runAs(currentUser){
            testUser = TestClass_UserCreator.CreateRetailerUser(contact); //TestClass_UserCreator saves User record
            testUser.Market__c = 'IN'; //set the User's Market
            update testUser;
        }
        
        System.runAs(testUser){
            
            TestClass_NationalityToISOCodeCreator.Create('IN', 'India'); //need to create a aop_NationalityToISOCode__c entry so we know IN maps to India
            //create an Opportunity and an Asset and ensure an Opportunity Product is created when picking the Asset for the Opportunity
            Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
            opp.Pricebook2Id = indiaPb.Id;
            insert opp;
            Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
            //need to make the Account Region 'IN'
            Account retailer = [SELECT Id, Region_or_Market__c FROM Account WHERE Id = :vehicle.AccountId];
            retailer.Region_or_Market__c = 'IN';
            update retailer;
            vehicle.Status = 'For Sale';
            insert vehicle;
            ApexPages.currentPage().getParameters().put('Id', opp.Id);
            FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
            fulfilFromStock.asf.PerformSearch();
            fulfilFromStock.chosenAsset = '' + vehicle.Id;
            fulfilFromStock.SelectVehicle();
            System.assertEquals(pbe.Id, fulfilFromStock.opportunityProduct.PricebookEntryId);
        }
    } 
    
    static testmethod void Save_ValidAsset_FulfilledFromStock(){
        //setup external user
        Account account = TestClass_AccountCreator.BuildRetailer();
        insert account;
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        User currentUser = new User(Id=UserInfo.getUserId());
        User testUser;
        
        //create an India pricebook and a FROM STOCK product and create a valid pricebook entry for the two
        Pricebook2 indiaPb = TestClass_PricebookCreator.CreatePricebook('India'); //TestClass_PricebookCreator saves Pricebook record
        PriceBookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(indiaPb, 'FROM STOCK'); //TestClass_PriceBookEntryBuilder save PriceBookEntry record
        
        System.runAs(currentUser){
            testUser = TestClass_UserCreator.CreateRetailerUser(contact); //TestClass_UserCreator saves User record
            testUser.Market__c = 'IN'; //set the User's Market
            update testUser;
        }
        Opportunity opp;
        
        System.runAs(testUser){
            
            TestClass_NationalityToISOCodeCreator.Create('IN', 'India'); //need to create a aop_NationalityToISOCode__c entry so we know IN maps to India
            //create an Opportunity and an Asset and ensure an Opportunity Product is created when picking the Asset for the Opportunity
            opp = TestClass_ValidOpportunityBuilder.Build();
            opp.Pricebook2Id = indiaPb.Id;
            opp.CurrencyIsoCode = 'INR';
            insert opp;
            Asset vehicle = TestClass_AssetBuilder.BuildVehicle();  
            //need to make the Account Region 'IN'
            Account retailer = [SELECT Id, Region_or_Market__c FROM Account WHERE Id = :vehicle.AccountId];
            retailer.Region_or_Market__c = 'IN';
            update retailer;     
            vehicle.Status = 'For Sale';
            insert vehicle;
            Test.StartTest();
            ApexPages.currentPage().getParameters().put('Id', opp.Id);
            FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
            fulfilFromStock.asf.PerformSearch();
            fulfilFromStock.chosenAsset = '' + vehicle.Id;
            fulfilFromStock.SelectVehicle();
            fulfilFromStock.opportunityProduct.UnitPrice = 1000; //enter a unit price
            fulfilFromStock.Save();Test.StopTest();
        }
        OpportunityLineItem oli = [SELECT Status__c FROM OpportunityLineItem WHERE OpportunityId = :opp.Id LIMIT 1];
        System.assertEquals('Fulfilled From Stock', oli.Status__c);
    }
    
    static testmethod void Save_NoPricebookEntry_ErrorMessageDisplayed(){
        //create an Opportunity and an Asset but no PricebookEntry and ensure the error message is displayed
        //setup external user
        Account account = TestClass_AccountCreator.CreateRetailer();
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        User currentUser = new User(Id=UserInfo.getUserId());
        User testUser;
        
        //create an India pricebook and a FROM STOCK product and create a valid pricebook entry for the two
        Pricebook2 indiaPb = TestClass_PricebookCreator.CreatePricebook('India'); //TestClass_PricebookCreator saves Pricebook record
        TestClass_NationalityToISOCodeCreator.Create('IN', 'India'); //need to create a aop_NationalityToISOCode__c entry so we know IN maps to India
        
        System.runAs(currentUser){
            testUser = TestClass_UserCreator.CreateRetailerUser(contact); //TestClass_UserCreator saves User record
            testUser.Market__c = 'IN'; //set the User's Market
            update testUser;
        }
        Opportunity opp;
        
        System.runAs(testUser){
            
            //create an Opportunity and an Asset and ensure an Opportunity Product is created when picking the Asset for the Opportunity
            opp = TestClass_ValidOpportunityBuilder.Build();
            opp.Pricebook2Id = indiaPb.Id;
            insert opp;
            Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
            //need to make the Account Region 'IN'
            Account retailer = [SELECT Id, Region_or_Market__c FROM Account WHERE Id = :vehicle.AccountId];
            retailer.Region_or_Market__c = 'IN';
            update retailer;
            vehicle.Status = 'For Sale';
            insert vehicle;
            ApexPages.currentPage().getParameters().put('Id', opp.Id);
            FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
            fulfilFromStock.asf.PerformSearch();
            fulfilFromStock.chosenAsset = '' + vehicle.Id;
            fulfilFromStock.SelectVehicle();
            fulfilFromStock.opportunityProduct.UnitPrice = 1000; //enter a unit price
            fulfilFromStock.Save();
        }
        String expectedError = String.format(System.Label.Stock_Search_No_Pricebook_Entry, new List<String>{'India'});
        System.assertEquals(expectedError, ApexPages.getMessages()[0].getSummary());
    }
    
    static testmethod void Save_NoAsset_ErrorMessageDisplayed(){
        //create an Opportunity and ensure an error message is displayed when we try to create an Opportunity Product without selecting an Asset
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        ApexPages.currentPage().getParameters().put('Id', opp.Id);
        FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
        fulfilFromStock.asf.PerformSearch();
        System.assertEquals(System.Label.Stock_Search_No_Results, ApexPages.getMessages()[0].getSummary());
    }
    
    static testmethod void Cancel_PageReferenceReturned(){
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        ApexPages.currentPage().getParameters().put('Id', opp.Id);
        FulfilFromStock_Controller fulfilFromStock = new FulfilFromStock_Controller();
        System.assertEquals('/' + opp.Id, fulfilFromStock.Cancel().getUrl());
    }
    
}