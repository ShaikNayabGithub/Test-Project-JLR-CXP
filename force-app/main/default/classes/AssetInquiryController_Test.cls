@isTest(SeeAllData=false)
public class AssetInquiryController_Test{ 

    @testSetup static void setup() { 
        List<Asset> assetsToInsert = new List<Asset>();
        //ASSET OWNED BY RETAILER 
        Asset assetRetailer = TestClass_AssetBuilder.BuildVehicle(false); 
        assetRetailer.name = 'assetRetailer';
        assetsToInsert.add(assetRetailer);
        //ASSET OWNED BY INDIVIDUAL
        Asset assetPerson = TestClass_AssetBuilder.BuildVehicle(true);
        assetPerson.name = 'assetPerson';
        assetsToInsert.add(assetPerson);
        //ASSET OWNED BY NSC
        Asset assetNSC = TestClass_AssetBuilder.BuildVehicle(false); 
        assetNSC.name = 'assetNSC';
        assetsToInsert.add(assetNSC);
        insert assetsToInsert;

        Account assetNSCparent = [select id, name, recordtypeid, Dealer_CI_Code__c, Primary_Dealer_Code__c, 
                                            Secondary_Dealer_Code__c, Alternative_Key__c
                                            from Account where id = : assetNSC.accountid]; 
        assetNSCparent.name = 'Random Migrated Vehicles';
        assetNSCparent.Dealer_CI_Code__c = null;
        assetNSCparent.Primary_Dealer_Code__c=null;
        assetNSCparent.Secondary_Dealer_Code__c=null;
        assetNSCparent.Alternative_Key__c=null;
        update assetNSCparent;
      
        //OTHER MIGRATED ACCOUNT
        Account accountBrazilMigrated = TestClass_AccountCreator.CreateRetailer();
        accountBrazilMigrated.name = 'Brazil Migrated Vehicles';
        update accountBrazilMigrated;
    }
    
    static user createPartnerUser() {
        Contact c = new Contact(LastName='bbb',Email='email_is@mandatory.com',AccountId=[select accountid from asset where name = 'assetRetailer'].accountid);
        insert c;
        User partnerUser = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', country='United States',IsActive =true,country_ISO_Code__c='BR',
                ContactId = c.Id, CommunityNickname='testUser123',
                timezonesidkey='America/Los_Angeles', username='kmoihte4edtcews34789hhgtfe@cxp.com');  
        partnerUser.profileid = [select id from profile where name='Partner Community User'].id; 
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert partnerUser;
        }
        return partnerUser;
    }
        
    static testMethod void searchVIN_noResults() { 
        Test.startTest();
        AssetInquiryController ac = new AssetInquiryController();
        ac.searchVIN = 'Non_Existant_VIN'; 
        PageReference searchResult = ac.searchVIN();
        system.assertEquals(0,ac.assets.size());
        Test.stopTest();
    }
    
    static testMethod void searchVIN_withResults() { 
        Test.startTest();
        AssetInquiryController ac = new AssetInquiryController();
        ac.searchVIN = 'assetRetailer'; 
        PageReference searchResult = ac.searchVIN();
        system.assertEquals(1,ac.assets.size());
        Test.stopTest();
    }
    
    static testMethod void searchVIN_withMigratedVehicleResults() { 
        Test.startTest();
        AssetInquiryController ac = new AssetInquiryController();
        ac.searchVIN = 'assetNSC'; 
        PageReference searchResult = ac.searchVIN();
        system.assertEquals(1,ac.assets.size());
        Test.stopTest();
    }
    
    static testMethod void takeOwnership_internalUser_rejected() {
        Test.startTest();
        User u = [select country_iso_code__c from user where id = : UserInfo.getUserId()];
        u.country_iso_code__c=null;
        update u;
        AssetInquiryController ac = new AssetInquiryController(); 
        ac.previousVINsearch = 'assetNSC';
        PageReference takeOwnershipPage = ac.takeOwnership();
        Asset assetNSC = [select account.name from asset where name = 'assetNSC'];
        system.assertEquals('Random Migrated Vehicles',assetNSC.account.name);
        Test.stopTest();
    }    
    
    static testMethod void takeOwnership_internalUser_accepted() { 
        Test.startTest();
        User u = [select country_iso_code__c from user where id = : UserInfo.getUserId()];
        u.country_iso_code__c='BR';
        update u;        
        AssetInquiryController ac = new AssetInquiryController(); 
        ac.previousVINsearch = 'assetNSC';
        PageReference takeOwnershipPage = ac.takeOwnership();
        Asset assetNSC = [select account.name from asset where name = 'assetNSC'];
        system.assertEquals('Brazil Migrated Vehicles',assetNSC.account.name);
        Test.stopTest();
    }        
    
    static testMethod void takeOwnership_externalUser_accepted() {         
        User partnerUser = createPartnerUser();
        Test.startTest();
        System.runAs(partnerUser) {
            AssetInquiryController ac = new AssetInquiryController(); 
            ac.previousVINsearch = 'assetNSC';
            PageReference takeOwnershipPage = ac.takeOwnership();
        }
        Asset assetNSC = [select account.name from asset where name = 'assetNSC'];
        system.assertEquals('test retailer',assetNSC.account.name);
        Test.stopTest();
    }  
    
    static testMethod void requestSharing_externalUser_noResults() {
        User partnerUser = createPartnerUser();
        Test.startTest();
        Asset assetPerson = [select accountid from asset where name = 'assetPerson'];
        //system.assertEquals(0,[select id from accountshare where accountid = : assetPerson.accountid and userorgroupid = : partnerUser.Id].size());
        system.runAs(partnerUser) {
            AssetInquiryController ac = new AssetInquiryController(); 
            ac.previousVINsearch = 'Non_Existant_VIN';
            PageReference requestSharingPage = ac.requestSharing(); 
        }
        system.assertEquals(0,[select id from accountshare where accountid = : assetPerson.accountid and userorgroupid = : partnerUser.Id].size());
        Test.stopTest();
    }
    
    static testMethod void requestSharing_externalUser_wtihResults() { 
        User partnerUser = createPartnerUser();
        Test.startTest();
        Asset assetPerson = [select accountid from asset where name = 'assetPerson'];
        //system.assertEquals(0,[select id from accountshare where accountid = : assetPerson.accountid and userorgroupid = : partnerUser.Id].size());
        system.runAs(partnerUser) {
            AssetInquiryController ac = new AssetInquiryController(); 
            ac.previousVINsearch = 'assetPerson';
            PageReference requestSharingPage = ac.requestSharing(); 
        }
        //system.assertEquals(1,[select id from accountshare where accountid = : assetPerson.accountid and userorgroupid = : partnerUser.Id].size());
        system.assertEquals(1,[select id from accountshare where accountid = : assetPerson.accountid and userorgroupid = : partnerUser.Id].size());
        Test.stopTest();
    }
    
}