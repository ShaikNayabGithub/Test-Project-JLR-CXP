@isTest
public class ConsentHandler_Test {
    static testMethod void getConsents_Test1() {
        CreateTestData tdata = new CreateTestData();
        tdata.loadConsents();
        Account acc = tdata.createPersonalAccount();
        acc.et4ae5__HasOptedOutOfMobile__pc = true;
        acc.PersonDoNotCall = true;
        acc.PersonHasOptedOutOfEmail = true;
        acc.Direct_Mail_Opt_Out__pc = true;
        insert acc;
        Lead ld = tdata.createLead(acc);
        ld.Account__c = null;
        ld.LeadSource = 'OEM Web & Digital';
        insert ld;

        acc = [Select Id, PersonIndividualId, Country_ISO_Code__c, et4ae5__HasOptedOutOfMobile__pc, PersonDoNotCall, PersonHasOptedOutOfEmail, Direct_Mail_Opt_Out__pc, aop_Country__pc, LiveAgent_OptOut__c, LA_Opt_In__pc, Retailer_Id__c From Account Where Id = :acc.Id];

        test.startTest();

        ConsentHandler.updateConsents(new List<Account>{acc});

        test.stopTest();

    }

    static testMethod void getConsents_Test2() {
        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP', Translatable_Value__c = 'Events and Experiences'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP', Translatable_Value__c = 'Events and Experiences'));
        insert dupList;

        CreateTestData tdata = new CreateTestData();
        List<Account> accList = new List<Account>();
        Account acc = tdata.createPersonalAccount();
        acc.aop_Country__pc = 'Japan';
        accList.add(acc);
        acc = tdata.createPersonalAccount();
        acc.LiveAgent_OptOut__c = 'J';
        accList.add(acc);
        acc = tdata.createPersonalAccount();
        acc.LiveAgent_OptOut__c = 'LR';
        accList.add(acc);
        acc = tdata.createPersonalAccount();
        acc.LA_Opt_In__pc = 'LY';
        accList.add(acc);
        acc = tdata.createPersonalAccount();
        acc.LA_Opt_In__pc = 'LN';
        accList.add(acc);
        acc = tdata.createPersonalAccount();
        acc.LA_Opt_In__pc = 'JY';
        accList.add(acc);
        acc = tdata.createPersonalAccount();
        acc.LA_Opt_In__pc = 'JN';
        accList.add(acc);


        test.startTest();

        insert accList;

        test.stopTest();

    }

    static testMethod void getConsents_Test3() {
        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP', Translatable_Value__c = 'Events and Experiences'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP', Translatable_Value__c = 'Events and Experiences'));
        insert dupList;

        CreateTestData tdata = new CreateTestData();
        List<Contact> conList = new List<Contact>();
        Account acc = tdata.createDealer();
        insert acc;
        
        Contact con = tdata.createContact(acc);
        con.aop_Country__c = 'Japan';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'LY';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'LN';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'JY';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'JN';
        conList.add(con);


        test.startTest();

        insert conList;

        test.stopTest();

    }

    static testMethod void getConsents_Test4() {
        CreateTestData tdata = new CreateTestData();
        tdata.loadConsents();
        Account acc = tdata.createPersonalAccount();
        acc.et4ae5__HasOptedOutOfMobile__pc = true;
        acc.PersonDoNotCall = true;
        acc.PersonHasOptedOutOfEmail = true;
        acc.Direct_Mail_Opt_Out__pc = true;
        insert acc;
        Lead ld = tdata.createLead(acc);
        ld.Account__c = null;
        ld.LeadSource = 'OEM Web & Digital';
        insert ld;

        Id usr = [select Id from Profile where Name='JLR System Administrator'].Id;
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='MCC Testing', LanguageLocaleKey='en_US', ProfileId = usr,
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueUserName, IsActive =true, LocaleSidKey='en_US');
        insert u;
        

        acc = [Select Id, PersonIndividualId, Country_ISO_Code__c, et4ae5__HasOptedOutOfMobile__pc, PersonDoNotCall, PersonHasOptedOutOfEmail, Direct_Mail_Opt_Out__pc, aop_Country__pc, LiveAgent_OptOut__c, LA_Opt_In__pc, Retailer_Id__c From Account Where Id = :acc.Id];

        test.startTest();

        System.runAs(u) {
            ConsentHandler.updateConsents(new List<Account>{acc});
        }

        test.stopTest();

    }

    static testMethod void getConsents_Test5() {
        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP', Translatable_Value__c = 'Events and Experiences'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP', Translatable_Value__c = 'Events and Experiences'));
        insert dupList;

        CreateTestData tdata = new CreateTestData();
        List<Contact> conList = new List<Contact>();
        Account acc = tdata.createDealer();
        insert acc;
        
        Contact con = tdata.createContact(acc);
        con.aop_Country__c = 'Japan';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'LY';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'LN';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'JY';
        conList.add(con);
        con = tdata.createContact(acc);
        con.LA_Opt_In__c = 'JN';
        conList.add(con);

        insert conList;

        Id usr = [select Id from Profile where Name='JLR System Administrator'].Id;
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='MCC Testing', LanguageLocaleKey='en_US', ProfileId = usr,
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueUserName, IsActive =true, LocaleSidKey='en_US');
        insert u;

        test.startTest();

        System.runAs(u) {
            ConsentHandler.updateConsents(conList);
        }
        

        test.stopTest();

    }
}