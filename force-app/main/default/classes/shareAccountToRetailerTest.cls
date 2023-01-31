@isTest(SeeAlldata=false)
public class shareAccountToRetailerTest {
    private static User currentUser { get; set; }
    private static User currentPartnerUser { get; set; }
    private static User currentParentPartnerUser { get; set; }
    private static String assetId { get; set; }
    private static Account acc { get; set; }
    private static Lead lead { get; set; }
    Static Vehicle_Specification__c vehiclespec= new Vehicle_Specification__c();
    private static String retailerRT { get; set; }
    @testSetup static void createData()
    { 
        CreateTestData tdata= new CreateTestData();
        //retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        retailerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        List<Account> retailers = TestDataFactory.generateAccounts(1, retailerRT, '埼玉県', 'さいたま市;');
        Account retailer = retailers[0];
        currentPartnerUser=tdata.createPartnerCommunityUser(retailer);
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert currentPartnerUser;
        }
        system.assertEquals(1, retailers.size());
        String brand = TestDataFactory.generateVehicleSpecification('Land Rover');
        // Create Asset
        assetId = TestDataFactory.generateAsset(brand, retailer.Id);

        // Create user
        CreateTestData ctd = new CreateTestData();
        Account acc = ctd.createPersonalAccount();
        insert acc;
        Lead lead  = ctd.createLead(acc);
        lead.Enquiry_Type__c = 'Generic';
        insert lead;
        currentUser = ctd.createCustomerCommunityUser(acc);
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert currentUser;
        }
        ctd.loadJUDAANMarketSettingsData();
        ctd.createVehicleSpecForCompare();
        if(currentUser.Id != null){
            currentUser = [select Id, AccountId from User where Id = :currentUser.Id];
        }
        Opportunity opp = TestDataFactory.generateOpportunity(assetId, currentUser.AccountId);
        if(opp.Id != null){
            opp = [select Id, Asset__c, AccountId from Opportunity where Id = :opp.Id];
        }
        //vehiclespec=[select id,Make__c,product_code__c ,Name,Is_Currently_Sold__c from Vehicle_Specification__c limit 1]; //why is this being queried?
        system.assertEquals(true, opp.AccountId != null);
        system.assertEquals(true, opp.Asset__c != null);
    }
    
    static testMethod void testExecute() { //failing due to too many soql queries
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        //String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        String retailerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1 ];
        //Account Parentretailer = [select Id from Account where RecordTypeId = :retailerRT  limit 1 ]; //why is this being queried?
        Test.StartTest();
            Lead l = [select Id, Account__c from Lead limit 1];
            Contact pcon;
            if(l.Account__c != null){
                pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
            }
            //User u = [select Id from User where ContactId = :pcon.Id];
            User u = null;
            List<User> usrlist = new List<User>();
            if(pcon.Id != null || retailer.Id != null){
                usrlist = [SELECT Id, Accountid, ContactId FROM User WHERE ContactId = :pcon.Id OR Accountid = :retailer.Id];
                for(User usr : usrlist){
                    if(usr.ContactId == pcon.Id){
                        u = usr;
                        break;
                    }
                }
            }
            FinanceRates__c finance = TestDataFactory.generateRates();
            //User Partnerusr=[select id, Accountid from User where Accountid =:retailer.id limit 1];
            User Partnerusr;
            for(User usr : usrlist){
                if(usr.Accountid == retailer.id){
                    Partnerusr = usr;
                    break;
                }
            }
        
            Test.setCurrentPage(checkout);
            checkout.getParameters().put('market', 'jp');
            checkout.getParameters().put('vid', asset.Id); 
            Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
       
            CheckoutController con = new CheckoutController();
            con.setInit();
        
            //con.calculateRegular();
    
            con.dto.IsFirst = true;
            con.dto.userId = u.Id;
        
            system.runAs(u)
            {
                con.saveQuote();
           
            }
            if(l.Account__c != null && asset.Id != null){
                Opportunity savedQuote = [select  id, AccountId,Retailer__c,Asset__r.AccountId,Country_ISO_Code__c,StageName,LeadSource from Opportunity where AccountId = :l.Account__c and Asset__c = :asset.Id and StageName = 'Save a Quote' limit 1];
                savedQuote.Retailer__c=retailer.id;
                savedQuote.Country_ISO_Code__c='SG';
                savedQuote.LeadSource='UDAAN';
                update savedQuote;
                //Account acc= [select id from Account where id =:savedQuote.AccountId]; //why is this queried
                system.debug('----ac'+savedQuote);
                shareAccountToRetailer batch = new shareAccountToRetailer();
                Database.executeBatch( batch , 200 );
            }
        Test.stopTest();
        
        //system.assertEquals(200, [select Id from Opportunity where StageName = 'Save a Quote' AND createddate= Today ].size());
    }
    
    static testMethod void testExecuteCase() {
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        //String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        String retailerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Contact pcon;
        if(l.Account__c != null){
            pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        }
        Test.StartTest();
            //User u = [select Id from User where ContactId = :pcon.Id]; //why is this being queried?
            FinanceRates__c finance = TestDataFactory.generateRates();
            //User Partnerusr=[select id, Accountid from User where Accountid =:retailer.id limit 1]; //why is this being queried?
            if(l.Account__c != null){
                ID accId=  [Select id from Account Where Id = :l.Account__c Limit 1].id;
                asset.Accountid=retailer.id;
                update Asset;
                Case caseRecord = new Case();
                caseRecord.Status = 'Open';
                caseRecord.Origin = 'OSA Query';
                caseRecord.Case_Contact_Email__c = 'test123@test.com';
                caseRecord.SuppliedEmail = 'test123@test.com';      
                caseRecord.AccountID=  accid;    
                caseRecord.AssetId=asset.id;
                insert caseRecord;
                //List<Case> cases = [Select ContactId, id, Accountid,Retailer__c,Asset.Accountid From Case Where Id=:caseRecord.Id Limit 1]; //why is this being queried?
                shareAccountToRetailer batch = new shareAccountToRetailer();
                Database.executeBatch( batch , 200 );
            }
        Test.stopTest();
    }
    
    static testMethod void testExecuteParent() {
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        //String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        String retailerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Test.StartTest();
            List<Account> retailers = TestDataFactory.generateAccounts(1, retailerRT, '埼玉県', 'さいたま市;');
            Account retailer = retailers[0];
            Lead l = [select Id, Account__c from Lead limit 1];
            //Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1]; //why is this being queried?
            //User u = [select Id from User where ContactId = :pcon.Id];
            FinanceRates__c finance = TestDataFactory.generateRates();
            //User Partnerusr=[select id, Accountid from User where Accountid =:retailer.id limit 1];
        
            if(l.Account__c != null){
                ID accId=  [Select id from Account Where Id = :l.Account__c Limit 1].id;
                asset.Accountid=retailer.id;
                update Asset;
                Case caseRecord = new Case();
                caseRecord.Status = 'Open';
                caseRecord.Origin = 'OSA Query';
                caseRecord.Case_Contact_Email__c = 'test123@test.com';
                caseRecord.SuppliedEmail = 'test123@test.com';      
                caseRecord.AccountID=  accid;    
                caseRecord.AssetId=asset.id;
                insert caseRecord;
                //List<Case> cases = [Select ContactId, id, Accountid,Retailer__c,Asset.Accountid From Case Where Id=:caseRecord.Id Limit 1]; //why is this being queried?
                shareAccountToRetailer batch = new shareAccountToRetailer();
                Database.executeBatch( batch , 200 );
            }
        Test.stopTest();
    }
        
}