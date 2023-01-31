@isTest(SeeAllData = false)
public class ReservationConfirmThankYouTest {
    private static User currentUser { get; set; }
    private static String assetId { get; set; }
    private static Account acc { get; set; }
    private static Lead lead { get; set; }
    Static Vehicle_Specification__c vehiclespec= new Vehicle_Specification__c();
    private static String retailerRT { get; set; }
    @testSetup static void createTestData()
    {
        retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        List<Account> retailers = TestDataFactory.generateAccounts(1, retailerRT, '埼玉県', 'さいたま市;');
        Account retailer = retailers[0];

        system.assertEquals(1, retailers.size());
        String brand = TestDataFactory.generateVehicleSpecification('Land Rover');
        // Create Asset
        assetId = TestDataFactory.generateAsset(brand, retailer.Id);

        // Create user
        CreateTestData ctd = new CreateTestData();
        Account acc = ctd.createPersonalAccount();
        insert acc;
        Lead lead  = ctd.createLead(acc);
        insert lead;
        currentUser = ctd.createCustomerCommunityUser(acc);
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert currentUser;
        }
        ctd.loadJUDAANMarketSettingsData();
        ctd.createVehicleSpecForCompare();
        currentUser = [select Id, AccountId from User where Id = :currentUser.Id];

        Opportunity opp = TestDataFactory.generateOpportunity(assetId, currentUser.AccountId);
        opp = [select Id, Asset__c, AccountId from Opportunity where Id = :opp.Id];
        vehiclespec=[select id,Make__c,product_code__c ,Name,Is_Currently_Sold__c from Vehicle_Specification__c limit 1];
        system.assertEquals(true, opp.AccountId != null);
        system.assertEquals(true, opp.Asset__c != null);
    }
    @isTest static void testThankYouPage()
    {
        // Get Asset
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Account acc = [select Id from Account where Id = :l.Account__c];
        // Insert saved vehicles
        TestDataFactory.generateSavedVehicleForLead(3, l.Id, asset.Id);
        Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        User u = [select Id from User where ContactId = :pcon.Id];
        system.assertEquals(3, [select Id from Saved_Vehicle_for_Lead__c].size());
        
        
        test.startTest();
        PageReference thankYouPage = Page.ReservationConfirmThankYou;
        thankYouPage.getParameters().put('vid', asset.Id); 
        thankYouPage.getParameters().put('market', 'jp');
        thankYouPage.getParameters().put('brand','jaguar');
        thankYouPage.getParameters().put('lang','en');
        test.setCurrentPage(thankYouPage);
        ReservationConfirmThankYouController reservationObj = new ReservationConfirmThankYouController();
        reservationObj.IsAPO = true;
        reservationObj.language = 'en';
        reservationObj.brand = 'jaguar';
        system.assertEquals(true,reservationObj.IsAPO);
        system.assertEquals('en',reservationObj.language);
        system.assertEquals('jaguar',reservationObj.brand);
        reservationObj.init();
        System.assert(reservationObj.wrapper != null);
        reservationObj.getCustomerAccount();
        System.assert(reservationObj.getCustomerAccount().getURL().contains('/customeraccountpage'));
        reservationObj.getSearchPage();
        System.assert(reservationObj.getSearchPage().getURL().contains('/apovehiclesearch'));
		
        
        test.stopTest();
    }
}