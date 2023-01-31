@isTest
private class aop_CampaignEmailBatchTest {

    static void setTestData()
    {
        List<RecordType> preRegistrationRequestRecordTypes = [SELECT ID
                                                         FROM RecordType
                                                         WHERE Name =: 'Pre-Registration Request' AND sObjectType = 'Request__c'
                                                        ]; 

        List<RecordType> retailerRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =: 'Retailer' AND sObjectType = 'Account'
                                              ]; 
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];


            RecordType retailerRecordType = retailerRecordTypes[0];

          RecordType preRegistrationRequestRecordType = preRegistrationRequestRecordTypes[0];

            aop_NationalityToISOCode__C isoKey1 = new aop_NationalityToISOCode__c(Name = 'France', aop_ISO_Code__c = 'FR', aop_Checkfront_Instance__c = 'abc.com');
            aop_NationalityToISOCode__C isoKey2 = new aop_NationalityToISOCode__c(Name = 'Germany', aop_ISO_Code__c = 'DE', aop_Checkfront_Instance__c = 'def.com');

          System.runAs (thisUser)
            {

          insert isoKey1;
          insert isoKey2;

            }

          aop_Locale_Mapping__c localeMapFranceFrance = new aop_Locale_Mapping__c(aop_Locale_Code__C = 'fr_FR', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_FR', aop_Salesforce_Language__c = 'fr', aop_country__c = 'France', aop_language__c = 'French',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');
            aop_Locale_Mapping__c localeMapGermanyGerman = new aop_Locale_Mapping__c(aop_Locale_Code__C = 'fr_FR', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'de_DE', aop_Salesforce_Language__c = 'de', aop_country__c = 'Germany', aop_language__c = 'German',
                                                                                    aop_Checkfront_Language_Code__c = 'xxx');
          aop_Locale_Mapping__c localeMapFranceGerman = new aop_Locale_Mapping__c(aop_Locale_Code__C = 'fr_FR',  aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_BE', aop_Salesforce_Language__c = 'de', aop_country__c = 'France', aop_language__c = 'German',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');



          System.runAs (thisUser)
            {

          insert localeMapFranceFrance;
          insert localeMapGermanyGerman;
          insert localeMapFranceGerman;

            }




          Id runningId = userinfo.getUserId();


      PermissionSet newPermissionSet = new PermissionSet(Name = 'name', Label = 'label');

            EmailTemplate emailTemplateGlobalTest; 
          EmailTemplate emailTemplateLocalTest;        
           EmailTemplate emailTemplateMatchTest;        


          System.runAs (thisUser)
            {

          //email template

            emailTemplateGlobalTest = new EmailTemplate(developerName = 'GlobalTest', TemplateType = 'Text', Name ='GlobalTest', FolderID = UserInfo.getUserId(), IsActive = true);

          insert emailTemplateGlobalTest;

            insert newPermissionSet;


          }

          //global defaults
          aop_emailGlobalDefault__c globalDefaults = new aop_emailGlobalDefault__c(Name = 'emailGlobalDefault', aop_Already_Known_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Asset_Reminder_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Disqualified_Template_ID__c = emailTemplateGlobalTest.id, aop_New_Event_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Post_Event_Template_ID__c = emailTemplateGlobalTest.id, aop_Qualified_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Walk_in_Template_ID__c = emailTemplateGlobalTest.id);

            System.runAs (thisUser)
            {
            insert globalDefaults;
            }

            Account retailer = new Account(Name = 'TestRetailer', RecordTypeId = retailerRecordType.id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');

          System.runAs (thisUser)
            {
            insert retailer;
            }






            aop_Area_Configuration__c areaConfigGermany = new aop_Area_Configuration__c
                    (aop_AWS_Path__c = 'x', 
                     aop_Checkfront_AOP_Id__c = 'x', aop_Checkfront_Instance__c = 'def.com', aop_Checkfront_Token__c = 'x',
                     aop_Community_Permission_Set__c = newPermissionSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                     aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                     aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
          System.runAs (thisUser)
            {
                insert areaConfigGermany;
            }



            Request__c requestGlobalTest = new Request__c(Last_Name__c = 'GlobalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'Germany', Language__c = 'German', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);

          Account account = new Account(Name = 'TestAccount');

          System.runAs(thisUser)
            {
                 insert account;
            }

          Contact contactGlobalTest = new Contact(LastName = 'GlobalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'Germany', Language__c = 'German');





          System.runAs(thisUser)
            {

                insert requestGlobalTest;
                insert contactGlobalTest;
            }


      Profile prof = [SELECT Name FROM Profile WHERE Name =: 'Customer Community Login User' LIMIT 1];
          User newUser = new User(aop_Has_AoP_Community_Access__c = true, ContactId = contactGlobalTest.id, Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');

      insert newUser;



  }

    static testMethod void TestBatchRunsAndDoesntDeletesTrackers() {
    	System.RunAs(new User(Id=UserInfo.getUserId())){
        	setTestData();
    	}
        Test.startTest();
        List<RecordType> campaignRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =: 'Game Event' AND sObjectType = 'Campaign'
                                              ]; 
                                              
        Campaign newCorrectCam = new Campaign(Name = 'abc campaign', ExpectedResponse = 12, aop_Checkfront_Instance__c = 'def.com',  RecordTypeId = campaignRecordTypes[0].id, Market_ID__c = 'IN');
        insert newCorrectCam;
        aop_CampaignTracker__c correctTracker = new aop_CampaignTracker__c(Name = newCorrectCam.Id);
        insert correctTracker;

        Campaign newErrorCam = new Campaign(Name = 'abcde campaign', ExpectedResponse = 12, aop_Checkfront_Instance__c = 'def.com', RecordTypeId = campaignRecordTypes[0].id, Market_ID__c = 'IN');
        insert newErrorCam;
        aop_CampaignTracker__c errorTracker = new aop_CampaignTracker__c(Name = newErrorCam.Id, aop_Error_Language__c = 'English (UK), French', aop_IsError__c = true);
        insert errorTracker;



        aop_CampaignEmailBatch emailBatch = new aop_CampaignEmailBatch();
        Database.executeBatch(emailBatch);
        Test.stopTest();


        Integer i = [SELECT Count() FROM aop_CampaignTracker__c];
        System.assertEquals(1, i);
    }
}