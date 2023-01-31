@isTest
public class aop_EmailCMemberPostEventTest {
    
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
        
        
            RecordType retailerRecordType = retailerRecordTypes[0];
        
        	RecordType preRegistrationRequestRecordType = preRegistrationRequestRecordTypes[0];

            aop_NationalityToISOCode__C isoKey1 = new aop_NationalityToISOCode__c(Name = 'France', aop_ISO_Code__c = 'FR', aop_Checkfront_Instance__c = 'abc.com');
            aop_NationalityToISOCode__C isoKey2 = new aop_NationalityToISOCode__c(Name = 'Germany', aop_ISO_Code__c = 'DE', aop_Checkfront_Instance__c = 'def.com');

        
        	insert isoKey1;
        	insert isoKey2;
        
        	aop_Locale_Mapping__c localeMapFranceFrance = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'fr_FR', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_FR', aop_Salesforce_Language__c = 'fr', aop_country__c = 'France', aop_language__c = 'French',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');
            aop_Locale_Mapping__c localeMapGermanyGerman = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'de_DE', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'de_DE', aop_Salesforce_Language__c = 'de', aop_country__c = 'Germany', aop_language__c = 'German',
                                                                                    aop_Checkfront_Language_Code__c = 'xxx');
        	aop_Locale_Mapping__c localeMapFranceGerman = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'fr_FR', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
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

        
            Account retailer = new Account(Name = 'TestRetailer', RecordTypeId = retailerRecordType.id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');
            
            insert retailer;
            
 

            
    
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
            
            Request__c requestGlobalTest = new Request__c(Last_Name__c = 'GlobalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'Germany', Language__c = 'German', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);
        
        	Request__c requestLocalTest = new Request__c(Last_Name__c = 'LocalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', Language__c = 'French', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);
        
        	Request__c requestMatchTest = new Request__c(Last_Name__c = 'MatchTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', 
                                                         Language__c = 'German', RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', 
                                                         aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);

			
        
        	Account account = new Account(Name = 'TestAccount');
        	insert account;
        	Contact contactGlobalTest = new Contact(LastName = 'GlobalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'Germany', Language__c = 'German');
            Contact contactLocalTest = new Contact(LastName = 'LocalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'France', Language__c = 'French');
        	Contact contactMatchTest = new Contact(LastName = 'MatchTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'France', Language__c = 'German');
        
        	Campaign campaign = new campaign(Name = 'x', Market_ID__c = 'IN');
        
        	insert campaign;

        	
        	
        
        	System.runAs(thisUser)
            {

                
                insert contactGlobalTest;
                insert contactLocalTest;
                //insert contactMatchTest;
                
                

            }
        
        	CampaignMember campaignMember1 = new CampaignMember(campaignID = campaign.id, contactId = contactGlobalTest.id, status = 'CF');
            CampaignMember campaignMember2 = new CampaignMember(campaignID = campaign.id, contactId = contactLocalTest.id, status = 'CF');
        	//CampaignMember campaignMember3 = new CampaignMember(campaignID = campaign.id, contactId = contactMatchTest.id, status = 'CF');
                            


            insert campaignMember1;
            insert campaignMember2;
            //insert campaignMember3;
        
	}
    static TestMethod void TestsendEmailRuns()
    {
        setTestData();
        Test.StartTest();
        List<CampaignMember> campaignMembers = [SELECT ID, ContactId, CampaignId
                                               FROM CampaignMember
                                               ];
        
        System.debug('This is campaignMembers brought back for test ' + campaignMembers);
        
        aop_EmailCampaignMemberPostEvent.sendEmail(campaignMembers);
        Test.StopTest();
    }
    
    static testMethod void TestGetAreaConfigReturnsAreaConfigWithMatchingCheckfrontString()
    {
        PermissionSet newPermissionSet = [SELECT Id FROM PermissionSet LIMIT 1];
        test.startTest();
    	aop_Area_Configuration__c areaConfigFrance = new aop_Area_Configuration__c
                (aop_AWS_Path__c = 'x', 
                 aop_Checkfront_AOP_Id__c = 'x', aop_Checkfront_Instance__c = 'abc.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = newPermissionSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
            insert areaConfigFrance;
            
        aop_Area_Configuration__c result = aop_EmailCampaignMemberPostEvent.GetAreaConfig('abc.com');
        test.stopTest();
        System.assertEquals(result.Id, areaConfigFrance.Id);
        
    }

}