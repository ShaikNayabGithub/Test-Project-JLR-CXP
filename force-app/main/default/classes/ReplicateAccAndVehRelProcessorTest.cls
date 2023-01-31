@isTest(seealldata=true)
private class ReplicateAccAndVehRelProcessorTest {
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    private static final String retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    
    static testMethod void testNoAssetFound() {
        
        ReplicateAccAndVehRelProcessor processor= new ReplicateAccAndVehRelProcessor();    
        ReplicateAccAndVehRel.AccountVehicle accVeh=new ReplicateAccAndVehRel.AccountVehicle();
        accVeh.Vhcl= new ReplicateAccAndVehRel.Vhcl();
        
        //create test asset
        asset asset=new asset();
        asset.vin__c='xxx';
        asset.name='xxx';
        
        
        account acc=new account();
        acc.recordtypeid=individualRecordTypeId;
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        acc.phone='0074343430';
        insert acc;
        
        
        Account retailer= new account();
        retailer.phone='3433400877';
        retailer.name='fdsafsdretailer';
        retailer.recordtypeid=retailerRecordTypeId;
        insert retailer;
        
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        if(VehicleSpecificationUtilities.brands.get('land rover')!=null)
            asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        
        asset.accountid=retailer.id;
        insert asset;
        
        accVeh.Vhcl.VIN='SALJAX23423';
        accVeh.Vhcl.Brand='Jaguar';
        
        
        
        accVeh.Vhcl.VhclAcctRltns= new ReplicateAccAndVehRel.VhclAcctRltns();
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn.Acct=new ReplicateAccAndVehRel.Acct();
        rltn.Acct.LstNm='test surname';
        rltn.Acct.OrgNm1='company name';
        
        
        rltn.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        
        ReplicateAccAndVehRel.AcctAddr acctAdrr= new ReplicateAccAndVehRel.AcctAddr();
        ReplicateAccAndVehRel.Addr address= new ReplicateAccAndVehRel.Addr();
        address.Cntry='Algeria';
        
        acctAdrr.Addr=address;
        rltn.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        rltn.Acct.Prmssns=new ReplicateAccAndVehRel.Prmssns();
        rltn.Acct.Prmssns.Prmssn=new List<ReplicateAccAndVehRel.Prmssn>();
        ReplicateAccAndVehRel.Prmssn permission= new ReplicateAccAndVehRel.Prmssn();
        permission.Cnsnt='Jaguar';
        
        ReplicateAccAndVehRel.Prmssn permission2= new ReplicateAccAndVehRel.Prmssn();
        permission2.Cnsnt='YES';
        
        
        ReplicateAccAndVehRel.Prmssn permission3= new ReplicateAccAndVehRel.Prmssn();
        permission3.Cnsnt='Land Rover';
        
        
        rltn.Acct.Prmssns.Prmssn.add(permission);
        rltn.Acct.Prmssns.Prmssn.add(permission2);
        rltn.Acct.Prmssns.Prmssn.add(permission3);
        
        //emails
        ReplicateAccAndVehRel.Emails emails=new ReplicateAccAndVehRel.Emails();
        rltn.Acct.Emails=emails;
        
        ReplicateAccAndVehRel.Email email= new ReplicateAccAndVehRel.Email();
        email.EmailAddr='invidivudal@fafds.com';
        
        rltn.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn.Acct.Emails.Email.add(email);
        
        //phones
        
        ReplicateAccAndVehRel.Tels phones=new ReplicateAccAndVehRel.Tels();
        rltn.Acct.Tels=phones;
        
        ReplicateAccAndVehRel.Tel tel= new ReplicateAccAndVehRel.Tel();
        tel.PhNum='0074343430';
        
        rltn.Acct.Tels.Tel= new List<ReplicateAccAndVehRel.Tel>();
        rltn.Acct.Tels.Tel.add(tel);
        
        
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn= new  List<ReplicateAccAndVehRel.VhclAcctRltn>();
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn);
        
        Test.startTest();
        processor.process(accVeh);
        Test.stopTest();
        
    }
    
    
    static testMethod void ReplicateAccAndVehRelProcessorTest() {
        Test.startTest();
        ReplicateAccAndVehRelProcessor processor= new ReplicateAccAndVehRelProcessor();    
        ReplicateAccAndVehRel.AccountVehicle accVeh=new ReplicateAccAndVehRel.AccountVehicle();
        accVeh.Vhcl= new ReplicateAccAndVehRel.Vhcl();
        
        //create test asset
        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        
        
        account acc=new account();
        acc.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        insert acc;
        
        
        Account retailer= new account();
        retailer.phone='0074343430';
        retailer.name='fdsafsdretailer';
        retailer.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id;
        insert retailer;
        
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        if(VehicleSpecificationUtilities.brands.get('land rover')!=null)
            asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        
        asset.accountid=retailer.id;
        insert asset;
        
        accVeh.Vhcl.VIN='SALJAX23423';
        accVeh.Vhcl.Brand='Jaguar';
        
        
        
        accVeh.Vhcl.VhclAcctRltns= new ReplicateAccAndVehRel.VhclAcctRltns();
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn.Acct=new ReplicateAccAndVehRel.Acct();
        rltn.Acct.LstNm='test surname';
        rltn.Acct.OrgNm1='company name';
        
        
        rltn.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        
        ReplicateAccAndVehRel.AcctAddr acctAdrr= new ReplicateAccAndVehRel.AcctAddr();
        ReplicateAccAndVehRel.Addr address= new ReplicateAccAndVehRel.Addr();
        address.Cntry='Algeria';
        
        acctAdrr.Addr=address;
        rltn.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        rltn.Acct.Prmssns=new ReplicateAccAndVehRel.Prmssns();
        rltn.Acct.Prmssns.Prmssn=new List<ReplicateAccAndVehRel.Prmssn>();
        ReplicateAccAndVehRel.Prmssn permission= new ReplicateAccAndVehRel.Prmssn();
        permission.Cnsnt='NO';
        
        ReplicateAccAndVehRel.Prmssn permission2= new ReplicateAccAndVehRel.Prmssn();
        permission2.Cnsnt='YES';
        
        
        ReplicateAccAndVehRel.Prmssn permission3= new ReplicateAccAndVehRel.Prmssn();
        permission3.Cnsnt='Land Rover';
        
        
        rltn.Acct.Prmssns.Prmssn.add(permission);
        rltn.Acct.Prmssns.Prmssn.add(permission2);
        rltn.Acct.Prmssns.Prmssn.add(permission3);
        
        //emails
        ReplicateAccAndVehRel.Emails emails=new ReplicateAccAndVehRel.Emails();
        rltn.Acct.Emails=emails;
        
        ReplicateAccAndVehRel.Email email= new ReplicateAccAndVehRel.Email();
        email.EmailAddr='invidivudal@fafds.com';
        
        rltn.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn.Acct.Emails.Email.add(email);
        
        //phones
        
        ReplicateAccAndVehRel.Tels phones=new ReplicateAccAndVehRel.Tels();
        rltn.Acct.Tels=phones;
        
        ReplicateAccAndVehRel.Tel tel= new ReplicateAccAndVehRel.Tel();
        tel.PhNum='0074343430';
        
        rltn.Acct.Tels.Tel= new List<ReplicateAccAndVehRel.Tel>();
        rltn.Acct.Tels.Tel.add(tel);
        
        
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn= new  List<ReplicateAccAndVehRel.VhclAcctRltn>();
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn);
        
        
        processor.process(accVeh);
        
        
        
        
        Test.stopTest();
        
    }
    
    static testMethod void ReplicateAccAndVehRelProcessorTestIdMatchNonZero() {
        
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = salesExecutiveProfile.Id;
        commUser.UserName = 'test@test.test.retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.Country = 'India';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';      
        commUser.DefaultCurrencyIsoCode ='INR';        
        
        commUser.Market__c = 'IN';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert commUser;
        }
        
        
        
        
        
        
        // AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        // insert ash;
        
        ReplicateAccAndVehRelProcessor processor= new ReplicateAccAndVehRelProcessor();    
        ReplicateAccAndVehRel.AccountVehicle accVeh=new ReplicateAccAndVehRel.AccountVehicle();
        accVeh.Vhcl= new ReplicateAccAndVehRel.Vhcl();
        
        //create test asset
        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        
        System.RunAs(commUser){
            list<Account> accsss =  new List<Account>();
            account acc=new account();
            acc.recordtypeid=individualRecordTypeId;
            acc.firstname='individual';
            acc.lastname='dfsdf';
            acc.personemail='invidivudal@fafds.com';
            acc.mena_reference2__c='0123456';
            acc.OwnerId = commUser.id;
            acc.country_iso_code__c ='IN';
            // insert acc;
            accsss.add(acc);
            account acc2=new account();
            acc2.recordtypeid=individualRecordTypeId;
            acc2.firstname='individual';
            acc2.lastname='dfsdf';
            acc2.personemail='invidivudal@fafds.com';
            acc2.country_iso_code__c ='IN';
            acc2.OwnerId = commUser.id;
            accsss.add(acc2);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(accsss, dml);
            
        }
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        if(VehicleSpecificationUtilities.brands.get('land rover')!=null)
            asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        
        asset.accountid=retailerAccount.id;
        insert asset;
        
        accVeh.Vhcl.VIN='SALJAX23423';
        accVeh.Vhcl.Brand='Jaguar';
        
        
        
        accVeh.Vhcl.VhclAcctRltns= new ReplicateAccAndVehRel.VhclAcctRltns();
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn.Acct=new ReplicateAccAndVehRel.Acct();
        rltn.Acct.LstNm='test surname';
        rltn.Acct.OrgNm1='company name';
        rltn.Acct.AcctId = '0123456';
        
        rltn.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        
        ReplicateAccAndVehRel.AcctAddr acctAdrr= new ReplicateAccAndVehRel.AcctAddr();
        ReplicateAccAndVehRel.Addr address= new ReplicateAccAndVehRel.Addr();
        address.Cntry='India';
        
        acctAdrr.Addr=address;
        rltn.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        rltn.Acct.Prmssns=new ReplicateAccAndVehRel.Prmssns();
        rltn.Acct.Prmssns.Prmssn=new List<ReplicateAccAndVehRel.Prmssn>();
        ReplicateAccAndVehRel.Prmssn permission= new ReplicateAccAndVehRel.Prmssn();
        permission.Cnsnt='NO';
        
        ReplicateAccAndVehRel.Prmssn permission2= new ReplicateAccAndVehRel.Prmssn();
        permission2.Cnsnt='YES';
        
        
        ReplicateAccAndVehRel.Prmssn permission3= new ReplicateAccAndVehRel.Prmssn();
        permission3.Cnsnt='Land Rover';
        
        
        rltn.Acct.Prmssns.Prmssn.add(permission);
        rltn.Acct.Prmssns.Prmssn.add(permission2);
        rltn.Acct.Prmssns.Prmssn.add(permission3);
        
        //emails
        ReplicateAccAndVehRel.Emails emails=new ReplicateAccAndVehRel.Emails();
        rltn.Acct.Emails=emails;
        
        ReplicateAccAndVehRel.Email email= new ReplicateAccAndVehRel.Email();
        email.EmailAddr='invidivudal@fafds.com';
        
        rltn.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn.Acct.Emails.Email.add(email);
        
        //phones
        
        ReplicateAccAndVehRel.Tels phones=new ReplicateAccAndVehRel.Tels();
        rltn.Acct.Tels=phones;
        
        ReplicateAccAndVehRel.Tel tel= new ReplicateAccAndVehRel.Tel();
        tel.PhNum='0074343430';
        
        rltn.Acct.Tels.Tel= new List<ReplicateAccAndVehRel.Tel>();
        rltn.Acct.Tels.Tel.add(tel);
        
        
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn= new  List<ReplicateAccAndVehRel.VhclAcctRltn>();
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn);
        Test.startTest();
        
        processor.process(accVeh);
        
        
        
        
        Test.stopTest();
        
    }      
    
    static testMethod void ReplicateAccAndVehRelProcessorTestIdMatchZero() {
        
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = retailerRecordTypeId;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = salesExecutiveProfile.Id;
        commUser.UserName = 'test@test.test.retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.Country = 'India';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';      
        commUser.DefaultCurrencyIsoCode ='INR';        
        
        commUser.Market__c = 'IN';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert commUser;
        }
        
        
        
        
        
        
        // AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        // insert ash;
        
        ReplicateAccAndVehRelProcessor processor= new ReplicateAccAndVehRelProcessor();    
        ReplicateAccAndVehRel.AccountVehicle accVeh=new ReplicateAccAndVehRel.AccountVehicle();
        accVeh.Vhcl= new ReplicateAccAndVehRel.Vhcl();
        
        //create test asset
        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        
        System.RunAs(commUser){
            List<Account> accs = new list<Account>();
            account acc=new account();
            acc.recordtypeid=individualRecordTypeId;
            acc.firstname='individual';
            acc.lastname='dfsdf';
            acc.personemail='invidivudal@fafds.com';
            acc.mena_reference2__c='0123456';
            acc.OwnerId = commUser.id;
            acc.country_iso_code__c ='IN';
            accs.add( acc);
            
            account acc2=new account();
            acc2.recordtypeid=individualRecordTypeId;
            acc2.firstname='individual';
            acc2.lastname='dfsdf';
            acc2.personemail='invidivudal@fafds.com';
            acc2.country_iso_code__c ='IN';
            acc2.OwnerId = commUser.id;
            acc2.mena_reference2__c='123456';
            accs.add( acc2);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(accs, dml);
            
        }
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        if(VehicleSpecificationUtilities.brands.get('land rover')!=null)
            asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        
        asset.accountid=retailerAccount.id;
        insert asset;
        
        accVeh.Vhcl.VIN='SALJAX23423';
        accVeh.Vhcl.Brand='Jaguar';
        
        
        
        accVeh.Vhcl.VhclAcctRltns= new ReplicateAccAndVehRel.VhclAcctRltns();
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn.Acct=new ReplicateAccAndVehRel.Acct();
        rltn.Acct.LstNm='test surname';
        rltn.Acct.OrgNm1='company name';
        rltn.Acct.AcctId = '123456';
        
        rltn.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        
        ReplicateAccAndVehRel.AcctAddr acctAdrr= new ReplicateAccAndVehRel.AcctAddr();
        ReplicateAccAndVehRel.Addr address= new ReplicateAccAndVehRel.Addr();
        address.Cntry='India';
        
        acctAdrr.Addr=address;
        rltn.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        rltn.Acct.Prmssns=new ReplicateAccAndVehRel.Prmssns();
        rltn.Acct.Prmssns.Prmssn=new List<ReplicateAccAndVehRel.Prmssn>();
        ReplicateAccAndVehRel.Prmssn permission= new ReplicateAccAndVehRel.Prmssn();
        permission.Cnsnt='NO';
        
        ReplicateAccAndVehRel.Prmssn permission2= new ReplicateAccAndVehRel.Prmssn();
        permission2.Cnsnt='YES';
        
        
        ReplicateAccAndVehRel.Prmssn permission3= new ReplicateAccAndVehRel.Prmssn();
        permission3.Cnsnt='Land Rover';
        
        
        rltn.Acct.Prmssns.Prmssn.add(permission);
        rltn.Acct.Prmssns.Prmssn.add(permission2);
        rltn.Acct.Prmssns.Prmssn.add(permission3);
        
        //emails
        ReplicateAccAndVehRel.Emails emails=new ReplicateAccAndVehRel.Emails();
        rltn.Acct.Emails=emails;
        
        ReplicateAccAndVehRel.Email email= new ReplicateAccAndVehRel.Email();
        email.EmailAddr='invidivudal@fafds.com';
        
        rltn.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn.Acct.Emails.Email.add(email);
        
        //phones
        
        ReplicateAccAndVehRel.Tels phones=new ReplicateAccAndVehRel.Tels();
        rltn.Acct.Tels=phones;
        
        ReplicateAccAndVehRel.Tel tel= new ReplicateAccAndVehRel.Tel();
        tel.PhNum='0074343430';
        
        rltn.Acct.Tels.Tel= new List<ReplicateAccAndVehRel.Tel>();
        rltn.Acct.Tels.Tel.add(tel);
        
        
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn= new  List<ReplicateAccAndVehRel.VhclAcctRltn>();
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn);
        
        Test.startTest(); 
        processor.process(accVeh);
        
        
        
        
        Test.stopTest();
        
    }   
    
    static testMethod void testKuwaitAssets() {
        ReplicateAccAndVehRelProcessor processor= new ReplicateAccAndVehRelProcessor();    
        ReplicateAccAndVehRel.AccountVehicle accVeh=new ReplicateAccAndVehRel.AccountVehicle();
        accVeh.Vhcl= new ReplicateAccAndVehRel.Vhcl();
        
        //create test asset
        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        
        account acc=new account();
        acc.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        insert acc;
        
        
        Account retailer= new account();
        retailer.phone='3433400877';
        retailer.name='Migrated';
        retailer.record_sub_type__c='Dual Brand';
        retailer.retailer_type__c='Importer';
        retailer.country_iso_code__c='KW';
        retailer.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id;
        insert retailer;
        
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        
        
        
        if(VehicleSpecificationUtilities.brands.get('land rover')!=null)
            asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        
        asset.accountid=retailer.id;
        insert asset;
        
        accVeh.Vhcl.VIN='SALJAX23423';
        accVeh.Vhcl.Brand='Jaguar';
        
        
        
        accVeh.Vhcl.VhclAcctRltns= new ReplicateAccAndVehRel.VhclAcctRltns();
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn.Acct=new ReplicateAccAndVehRel.Acct();
        rltn.Acct.LstNm='test surname';
        rltn.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        
        ReplicateAccAndVehRel.AcctAddr acctAdrr= new ReplicateAccAndVehRel.AcctAddr();
        ReplicateAccAndVehRel.Addr address= new ReplicateAccAndVehRel.Addr();
        address.Cntry='Kuwait';
        
        acctAdrr.Addr=address;
        rltn.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        
        ReplicateAccAndVehRel.Emails emails=new ReplicateAccAndVehRel.Emails();
        rltn.Acct.Emails=emails;
        
        ReplicateAccAndVehRel.Email email= new ReplicateAccAndVehRel.Email();
        email.EmailAddr='invidivudal@fafds.com';
        
        rltn.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn.Acct.Emails.Email.add(email);
        
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn= new  List<ReplicateAccAndVehRel.VhclAcctRltn>();
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn);
        
        processor.process(accVeh);
        processor.isSameAccount('Organisation','company','last name',acc,'Compnay name');
        processor.isSameAccount('Individual','individual','dfsdf',acc,'Compnay name');
        ReplicateAccAndVehRel.upsertVehicleAndVehicleOwnership(accVeh);
        
        accVeh.Vhcl.VhclAcctRltns=null;
        Test.startTest();
        // ReplicateAccAndVehRel.upsertVehicleAndVehicleOwnership(accVeh);
        ReplicateAccAndVehRel.upsertVehicleAndVehicleOwnership(accVeh);
        Test.stopTest();
        String test1=ReplicateAccAndVehRelProcessor.JAGUAR;
        test1=ReplicateAccAndVehRelProcessor.YES;
        test1=ReplicateAccAndVehRelProcessor.LANDROVER;
        
        
        
        
    }
    static testMethod void testKuwaitAssets1() {
        ReplicateAccAndVehRelProcessor processor= new ReplicateAccAndVehRelProcessor();    
        ReplicateAccAndVehRel.AccountVehicle accVeh=new ReplicateAccAndVehRel.AccountVehicle();
        accVeh.Vhcl= new ReplicateAccAndVehRel.Vhcl();
        
        //create test asset
        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        
        account acc=new account();
        acc.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Corporate').Id;
        //acc.firstname='individual';
        acc.name='dfsdf';
        //acc.email='invidivudal@fafds.com';
        insert acc;
        
        
        Account retailer= new account();
        retailer.phone='3433400877';
        retailer.name='Migrated';
        retailer.record_sub_type__c='Dual Brand';
        retailer.retailer_type__c='Importer';
        retailer.country_iso_code__c='KW';
        retailer.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id;
        insert retailer;
        
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        
        
        
        if(VehicleSpecificationUtilities.brands.get('land rover')!=null)
            asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        
        asset.accountid=retailer.id;
        insert asset;
        
        accVeh.Vhcl.VIN='SALJAX23423';
        accVeh.Vhcl.Brand='Jaguar';
        
        
        
        accVeh.Vhcl.VhclAcctRltns= new ReplicateAccAndVehRel.VhclAcctRltns();
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn.Acct=new ReplicateAccAndVehRel.Acct();
        rltn.Acct.LstNm='test surname';
        rltn.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        rltn.Acct.AcctType = 'Organisation';
        rltn.Acct.OrgNm1 = 'JJLR CXP Org';
        
        ReplicateAccAndVehRel.VhclAcctRltn rltn1= new ReplicateAccAndVehRel.VhclAcctRltn();
        rltn1.Acct=new ReplicateAccAndVehRel.Acct();
        rltn1.Acct.LstNm='test surname';
        rltn1.Acct.AcctAddrs=new ReplicateAccAndVehRel.AcctAddrs();
        rltn1.Acct.AcctAddrs.AcctAddr=new List<ReplicateAccAndVehRel.AcctAddr>();
        rltn1.Acct.AcctType = 'Organisation';
        rltn1.Acct.OrgNm1 = 'JJLR CXP Org';
        
        ReplicateAccAndVehRel.AcctAddr acctAdrr= new ReplicateAccAndVehRel.AcctAddr();
        ReplicateAccAndVehRel.Addr address= new ReplicateAccAndVehRel.Addr();
        address.Cntry='Kuwait';
        
        acctAdrr.Addr=address;
        rltn.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        rltn1.Acct.AcctAddrs.AcctAddr.add(acctAdrr);
        
        ReplicateAccAndVehRel.Emails emails=new ReplicateAccAndVehRel.Emails();
        rltn.Acct.Emails=emails;
        rltn1.Acct.Emails=emails;
        
        ReplicateAccAndVehRel.Email email= new ReplicateAccAndVehRel.Email();
        email.EmailAddr='invidivudal@fafds.com';
        
        rltn.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn1.Acct.Emails.Email= new List<ReplicateAccAndVehRel.Email>();
        rltn.Acct.Emails.Email.add(email);
        rltn1.Acct.Emails.Email.add(email);
        
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn= new  List<ReplicateAccAndVehRel.VhclAcctRltn>();
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn);
        accVeh.Vhcl.VhclAcctRltns.VhclAcctRltn.add(rltn1);
        
        processor.process(accVeh);
        processor.isSameAccount('Organisation','company','last name',acc,'Compnay name');
        processor.isSameAccount('Individual','individual','dfsdf',acc,'Compnay name');
        ReplicateAccAndVehRel.upsertVehicleAndVehicleOwnership(accVeh);
        
        accVeh.Vhcl.VhclAcctRltns=null;
        Test.startTest();
        // ReplicateAccAndVehRel.upsertVehicleAndVehicleOwnership(accVeh);
        ReplicateAccAndVehRel.upsertVehicleAndVehicleOwnership(accVeh);
        Test.stopTest();
        String test1=ReplicateAccAndVehRelProcessor.JAGUAR;
        test1=ReplicateAccAndVehRelProcessor.YES;
        test1=ReplicateAccAndVehRelProcessor.LANDROVER;
        
        
        
        
    }
    static testMethod void testErrorMessage() {
        Test.startTest();
        
        
        
        ReplicateAccAndVehRelProcessor.SendErrorEmail('test',null);
        ReplicateAccAndVehRel.replicateVehicleAndVehicleOwnershipResponse resp=new ReplicateAccAndVehRel.replicateVehicleAndVehicleOwnershipResponse();
        Test.stopTest(); 
        
    }
    
    
    
}