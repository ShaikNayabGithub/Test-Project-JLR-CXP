@isTest
public with sharing class MB_UnitTestBase {
    
    @isTest
    public static void Test_CreateDeal() {
        //Account retailer  = TestClass_AccountCreator.CreateRetailer();
        Account priamryIndividual = TestClass_AccountCreator.createPrimaryAccount();
        Account secondaryIndvidiual = TestClass_AccountCreator.createPersonAccount();

        //Opportunity myOpp = TestClass_OpportunityCreator.
        Boolean buildForPersonAccount = false;
        Asset asset = TestClass_AssetBuilder.BuildAndInsertVehicle(buildForPersonAccount);

    }
}