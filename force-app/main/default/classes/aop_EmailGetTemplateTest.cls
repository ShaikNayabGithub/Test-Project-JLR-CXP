@isTest
Public Class aop_EmailGetTemplateTest
{

    static void setTestData()
    {

       

        	

            aop_NationalityToISOCode__C isoKey1 = new aop_NationalityToISOCode__c(Name = 'France', aop_ISO_Code__c = 'FR', aop_Checkfront_Instance__c = 'abc.com');
            aop_NationalityToISOCode__C isoKey2 = new aop_NationalityToISOCode__c(Name = 'Germany', aop_ISO_Code__c = 'DE', aop_Checkfront_Instance__c = 'def.com');


        	insert isoKey1;
        	insert isoKey2;
        	aop_Locale_Mapping__c localeMapFranceFrance = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'fr_fr', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_FR', aop_Salesforce_Language__c = 'fr', aop_country__c = 'France', aop_language__c = 'French',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');
            aop_Locale_Mapping__c localeMapGermanyGerman = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'fr_fr', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'de_DE', aop_Salesforce_Language__c = 'de', aop_country__c = 'Germany', aop_language__c = 'German',
                                                                                    aop_Checkfront_Language_Code__c = 'xxx');
        	aop_Locale_Mapping__c localeMapFranceGerman = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'fr_fr', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_BE', aop_Salesforce_Language__c = 'de', aop_country__c = 'France', aop_language__c = 'German',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');
        	insert localeMapFranceFrance;
        	insert localeMapGermanyGerman;
        	insert localeMapFranceGerman;


        	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        	Id runningId = userinfo.getUserId();


			PermissionSet newPermissionSet = new PermissionSet(Name = 'name', Label = 'label');

            EmailTemplate emailTemplateGlobalTest; 
        	EmailTemplate emailTemplateLocalTest;        
       		EmailTemplate emailTemplateMatchTest;        


        	System.runAs (thisUser)
            {

        	//email template

            emailTemplateGlobalTest = new EmailTemplate(developerName = 'GlobalTest', TemplateType = 'Text', Name ='GlobalTest', FolderID = UserInfo.getUserId());
            emailTemplateLocalTest = new EmailTemplate(developerName = 'LocalTest', TemplateType = 'Text', Name ='LocalTest', FolderID = UserInfo.getUserId());
            emailTemplateMatchTest = new EmailTemplate(developerName = 'MatchTest', TemplateType = 'Text', Name ='MatchTest', FolderID = UserInfo.getUserId());

        	insert emailTemplateGlobalTest;
            insert emailTemplateLocalTest;
        	insert emailTemplateMatchTest;

            insert newPermissionSet;


        	}

        	//global defaults
        	aop_emailGlobalDefault__c globalDefaults = new aop_emailGlobalDefault__c(Name = 'emailGlobalDefault', aop_Already_Known_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Asset_Reminder_Template_ID__c = emailTemplateGlobalTest.id,
                                                                                     aop_Disqualified_Template_ID__c = emailTemplateGlobalTest.id, aop_New_Event_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Post_Event_Template_ID__c = emailTemplateGlobalTest.id, aop_Qualified_Template_ID__c = emailTemplateGlobalTest.id, 
                                                                                     aop_Walk_in_Template_ID__c = emailTemplateGlobalTest.id);


            insert globalDefaults;


            





            aop_Area_Configuration__c areaConfigFrance = new aop_Area_Configuration__c
                (aop_AWS_Path__c = 'x', 
                 aop_Checkfront_AOP_Id__c = 'x', aop_Checkfront_Instance__c = 'abc.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = newPermissionSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
            insert areaConfigFrance;

            aop_Area_Configuration__c areaConfigGermany = new aop_Area_Configuration__c
                    (aop_AWS_Path__c = 'x', 
                     aop_Checkfront_AOP_Id__c = 'x', aop_Checkfront_Instance__c = 'def.com', aop_Checkfront_Token__c = 'x',
                     aop_Community_Permission_Set__c = newPermissionSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                     aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                     aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
                insert areaConfigGermany;

            aop_Area_Email_Configuration__c areaEmailConfig1 = new aop_Area_Email_Configuration__c(aop_Area_Configuration__c = areaConfigFrance.id, aop_Language__c = 'English', 
                                                                                                   aop_Is_Area_Default__c = true, aop_Qualified_Template_Name__c = emailTemplateLocalTest.Name,
                                                                                                   aop_Walk_in_Template_Name__c = emailTemplateLocalTest.Name,
                                                                                                   aop_Disqualified_Template_Name__c = emailTemplateLocalTest.Name,
                                                                                                   aop_Already_Known_Template_Name__c = emailTemplateLocalTest.Name,
                                                                                                   Post_Event_Template_Name__c = emailTemplateLocalTest.Name,
                                                                                                   aop_Asset_Reminder_Template_Name__c = emailTemplateLocalTest.Name,
                                                                                                   aop_New_Event_Template_Name__c = emailTemplateLocalTest.Name);
            aop_Area_Email_Configuration__c areaEmailConfig2 = new aop_Area_Email_Configuration__c(aop_Area_Configuration__c = areaConfigFrance.id, aop_Language__c = 'German', 
                                                                                                   aop_Is_Area_Default__c = false, aop_Qualified_Template_Name__c = emailTemplateMatchTest.Name,
                                                                                                   aop_Walk_in_Template_Name__c = emailTemplateMatchTest.Name,
                                                                                                   aop_Disqualified_Template_Name__c = emailTemplateMatchTest.Name,
                                                                                                   aop_Already_Known_Template_Name__c = emailTemplateMatchTest.Name,
                                                                                                   Post_Event_Template_Name__c = emailTemplateMatchTest.Name,
                                                                                                   aop_Asset_Reminder_Template_Name__c = emailTemplateMatchTest.Name,
                                                                                                   aop_New_Event_Template_Name__c = emailTemplateMatchTest.Name);
            insert areaEmailConfig1;
            insert areaEmailConfig2;

         
      
        


        	









	}
	
	static void globalRequestSetup()
	{
		
		 List<RecordType> retailerRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =: 'Retailer' AND sObjectType = 'Account'
                                              ]; 
		Account account = new Account(Name = 'TestAccount');
        	insert account;

        RecordType retailerRecordType = retailerRecordTypes[0];
		
		Account retailer = new Account(Name = 'TestRetailer', RecordTypeId = retailerRecordType.id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');

        insert retailer;
		
		List<RecordType> preRegistrationRequestRecordTypes = [SELECT ID
                                                   			 FROM RecordType
                                                   			 WHERE Name =: 'Pre-Registration Request' AND sObjectType = 'Request__c'
                                                  			 ]; 
                                                  			
		 RecordType preRegistrationRequestRecordType = preRegistrationRequestRecordTypes[0];
		 
		 Request__c requestGlobalTest = new Request__c(Last_Name__c = 'GlobalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'Germany', Language__c = 'German', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);
		 
		 Contact contactGlobalTest = new Contact(LastName = 'GlobalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'Germany', Language__c = 'German');
		
		 insert requestGlobalTest;
		 insert contactGlobalTest;
		 
		
	}
	
	static void localRequestSetup()
	{
		
				 List<RecordType> retailerRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =: 'Retailer' AND sObjectType = 'Account'
                                              ]; 
		Account account = new Account(Name = 'TestAccount');
        	insert account;

        RecordType retailerRecordType = retailerRecordTypes[0];
		
		Account retailer = new Account(Name = 'TestRetailer', RecordTypeId = retailerRecordType.id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');

        insert retailer;
		
		List<RecordType> preRegistrationRequestRecordTypes = [SELECT ID
                                                   			 FROM RecordType
                                                   			 WHERE Name =: 'Pre-Registration Request' AND sObjectType = 'Request__c'
                                                  			 ]; 
                                                  			
		 RecordType preRegistrationRequestRecordType = preRegistrationRequestRecordTypes[0];
		 
		 Request__c requestLocalTest = new Request__c(Last_Name__c = 'LocalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', Language__c = 'French', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);

         Contact contactLocalTest = new Contact(LastName = 'LocalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'France', Language__c = 'French');
		
		 insert requestLocalTest;
		 insert contactLocalTest;
		
	}
	
	static void matchRequestSetup()
	{
		
				 List<RecordType> retailerRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =: 'Retailer' AND sObjectType = 'Account'
                                              ]; 
		Account account = new Account(Name = 'TestAccount');
        	insert account;

        RecordType retailerRecordType = retailerRecordTypes[0];
		
		Account retailer = new Account(Name = 'TestRetailer', RecordTypeId = retailerRecordType.id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');

        insert retailer;
		
		List<RecordType> preRegistrationRequestRecordTypes = [SELECT ID
                                                   			 FROM RecordType
                                                   			 WHERE Name =: 'Pre-Registration Request' AND sObjectType = 'Request__c'
                                                  			 ]; 
                                                  			
		 RecordType preRegistrationRequestRecordType = preRegistrationRequestRecordTypes[0];
		 
		 Request__c requestMatchTest = new Request__c(Last_Name__c = 'MatchTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', 
                                                         Language__c = 'German', RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', 
                                                         aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);

         Contact contactMatchTest = new Contact(LastName = 'MatchTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'France', Language__c = 'German');
		
		 insert requestMatchTest;
		 insert contactMatchTest;
		
	}
	

    static TestMethod void TestGetQualifyTemplateReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       matchRequestSetup();
       Test.StartTest();
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'MatchTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetQualifyTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }
    static TestMethod void TestGetQualifyTemplateReturnsDefaultTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        localRequestSetup();
        Test.StartTest();
        
               
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'LocalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetQualifyTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }
    static TestMethod void TestGetQualifyTemplateReturnsGlobalTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        globalRequestSetup();
        Test.StartTest();
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'GlobalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetQualifyTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }

	static TestMethod void TestGetWalkInTemplateReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
        matchRequestSetup();
       Test.StartTest();
      
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'MatchTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetWalkInTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }
    static TestMethod void TestGetWalkInTemplateReturnsDefaultTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        
        localRequestSetup();
        Test.StartTest();
        
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'LocalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetWalkInTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
    }
    static TestMethod void TestGetWalkInTemplateReturnsGlobalTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        globalRequestSetup();
        Test.StartTest();
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'GlobalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetWalkInTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }

    static TestMethod void TestGetDisqualifiedTemplateReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       matchRequestSetup();
       Test.StartTest();
       
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'MatchTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetDisqualifiedTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }
    static TestMethod void TestGetDisqualifiedTemplateReturnsDefaultTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        localRequestSetup();
        Test.StartTest();
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'LocalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetDisqualifiedTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }
    static TestMethod void TestGetDisqualifiedTemplateReturnsGlobalTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        globalRequestSetup();
        Test.StartTest();
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'GlobalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetDisqualifiedTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }

    static TestMethod void TestGetAlreadyKnownTemplateReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       matchRequestSetup();
       Test.StartTest();
       
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'MatchTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetAlreadyKnownTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }
    static TestMethod void TestGetAlreadyKnownTemplateReturnsDefaultTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        localRequestSetup();
        Test.StartTest();
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'LocalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetAlreadyKnownTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }
    static TestMethod void TestGetAlreadyKnownTemplateReturnsGlobalTemplate()
    {
        aop_EmailGetTemplateTest.setTestData();
        globalRequestSetup();
        Test.StartTest();
        
        List<Request__c> Requests = [SELECT ID, aop_country__c, language__c
                                     FROM Request__c
                                     WHERE Last_Name__c =: 'GlobalTest'
                                    ];

        ID templateID;
        if(Requests != null || !Requests.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.GetAlreadyKnownTemplate(Requests[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();
    }

    static TestMethod void TestCampaignCompleteReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       matchRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'MatchTest'
                                    ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignComplete(Contacts[0]);
        }

        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
	   Test.StopTest();
    }

    static TestMethod void TestCampaignCompleteReturnsDefaultTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       localRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'LocalTest'
                                    ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignComplete(Contacts[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }

    static TestMethod void TestCampaignCompleteReturnsGlobalTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       globalRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'GlobalTest'
                                    ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignComplete(Contacts[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }

        static TestMethod void TestCampaignCompleteSixtyDaysReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       matchRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'MatchTest'
                                    ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignCompleteSixtyDays(Contacts[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }

    static TestMethod void TestCampaignCompleteSixtyDaysReturnsDefaultTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       localRequestSetup();
       Test.StartTest();
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'LocalTest'
                                    ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignCompleteSixtyDays(Contacts[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }

    static TestMethod void TestCampaignCompleteSixtyDaysReturnsGlobalTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       globalRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'GlobalTest'
                                    ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignCompleteSixtyDays(Contacts[0]);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
       Test.StopTest();

    }

         static TestMethod void TestCampaignCreatedReturnsMatchingTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       matchRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'MatchTest'
                                    ];
        
                List<aop_Area_Configuration__c> areaConfigs =   [SELECT ID, aop_Checkfront_Instance__c 
                                                        FROM aop_Area_Configuration__c
                                                        ];
        
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                                               aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c,
                                               aop_Language__c, aop_Is_Area_Default__c
                                               FROM aop_Area_Email_Configuration__c];
        
        List<EmailTemplate> emailTemplates = [SELECT id, name, developername 
                                              FROM EmailTemplate 
                                             ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignCreated(Contacts[0], areaConfigs, areaEmailConfigs, emailTemplates);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'MatchTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
		Test.StopTest();		
    }

    static TestMethod void TestCampaignCreatedReturnsDefaultTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       localRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'LocalTest'
                                    ];
        
                List<aop_Area_Configuration__c> areaConfigs =   [SELECT ID, aop_Checkfront_Instance__c 
                                                        FROM aop_Area_Configuration__c
                                                        ];
        
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                                               aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c,
                                               aop_Language__c, aop_Is_Area_Default__c
                                               FROM aop_Area_Email_Configuration__c];
        
        List<EmailTemplate> emailTemplates = [SELECT id, name, developername 
                                              FROM EmailTemplate 
                                             ];
        
        System.debug('areaConfigs: ' + areaConfigs);
        System.debug('areaEmailConfigs: ' + areaEmailConfigs);
        System.debug('emailTemplates: ' + emailTemplates);


        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignCreated(Contacts[0], areaConfigs, areaEmailConfigs, emailTemplates);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'LocalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
		Test.StopTest();
    }

    static TestMethod void TestCampaignCreatedReturnsGlobalTemplate()
    {

       aop_EmailGetTemplateTest.setTestData();
       globalRequestSetup();
       Test.StartTest();
       
        List<Contact> Contacts = [SELECT ID, aop_country__c, language__c
                                     FROM Contact
                                     WHERE LastName =: 'GlobalTest'
                                    ];
        List<aop_Area_Configuration__c> areaConfigs =   [SELECT ID, aop_Checkfront_Instance__c 
                                                        FROM aop_Area_Configuration__c
                                                        ];
        
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                                               aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c,
                                               aop_Language__c, aop_Is_Area_Default__c
                                               FROM aop_Area_Email_Configuration__c];
        
        List<EmailTemplate> emailTemplates = [SELECT id, name, developername 
                                              FROM EmailTemplate 
                                             ];

        ID templateID;
        if(Contacts != null || !Contacts.isEmpty())
        {
            aop_EmailGetTemplate emailTemplateGetter = new aop_EmailGetTemplate();
            templateID = emailTemplateGetter.CampaignCreated(Contacts[0], areaConfigs, areaEmailConfigs, emailTemplates);
        }


        List<EmailTemplate> et = [SELECT ID
                            	  FROM EmailTemplate
                                  WHERE DeveloperName =: 'GlobalTest'
                                 ];

       System.assertEquals(et[0].id, templateID);
		Test.StopTest();
    }



}