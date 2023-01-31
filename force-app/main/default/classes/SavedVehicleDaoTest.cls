/* *************************************************************************************************************    
Class Name    : SavedVehicleDaoTest
Description   : This class is used for testing functionality of SavedVehicleDaoTest 
CreatedDate   : 05 Jan 2022         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                

***************************************************************************************************************** */
@isTest
private class SavedVehicleDaoTest {
    
	/* **************************************************
    Method Name: loadData
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to create test data
    //DJB - this doesn't need to be a testMethod - should be a testSetup method - and doesn't need any System.asserts
    ****************************************************** */  
    @testSetup static void loadData() {
        
        CreateTestData tdata = new CreateTestData();
        // Call load method for JUAAAN market Custom Settings
        tdata.loadJUDAANMarketSettingsData();
        
        Account acc = tdata.createPersonalAccount();
        insert acc;
        
        Lead leadRec = tdata.createLead(acc);
        insert leadRec;
        
        User usr = tdata.createCustomerCommunityUser(acc);
        System.RunAs(new User(Id=userinfo.getUserId())){ 
            insert usr;
        }
        
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(); //why are we calling createAssets when we only want one Asset anyway?
        
        //Query inserted Assets
        List<Asset> assetList = [select Id, Product2.Make__c, 
                     Product2.Make__r.Name,
                     AccountId,
                     Account.Country_ISO_Code__c,
                     APO__c,
                     Product2.Model_Alternative__c,
                     highlighted_base__c from Asset ];
        
        assetList[0].APO__c = true;
        assetList[0].highlighted_base__c = '"A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera"';
        assetList[0].Product2.Make__r.Name = 'jaguar';
        assetList[0].Product2.Model_Alternative__c = 'RANGE ROVER';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        AssetHandler.IgnoreMMIT = true;
        update assetList[0];
        
        Saved_Vehicle_for_Account__c savedVehAcc = tdata.createSavedVehicleForAccount( acc, assetList[0]);
        Saved_Vehicle_for_Lead__c savedVehLead = tdata.createSavedVehicleForLead( leadRec, assetList[0]);  
        
        Id rtIDforModel = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        
        Id rtIDforDerivative = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        
        insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
        
    }
    
    static testMethod void testSavedVehicleDAO() {
        Account accountObj = [SELECT Id FROM Account limit 1];
        List<Saved_Vehicle_for_Account__c>  saved4Acc = SavedVehicleDAO.getSavedVehicleForAccountByAccountId(accountObj.Id, 'Land Rover');
        List<Saved_Vehicle_for_Lead__c> saved4Lead = SavedVehicleDAO.getSavedVehicleForLeadByAccountId(accountObj.Id, 'Land Rover');
        
        system.assertEquals(1, saved4Acc.size());
        system.assertEquals(1, saved4Lead.size());
    }
}