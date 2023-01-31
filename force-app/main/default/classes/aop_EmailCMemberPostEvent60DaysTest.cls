@isTest
public class aop_EmailCMemberPostEvent60DaysTest {

    
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
        
        	aop_Locale_Mapping__c localeMapFranceFrance = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'FR_fr', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'fr_FR', aop_Salesforce_Language__c = 'fr', aop_country__c = 'France', aop_language__c = 'French',
                                                                                   aop_Checkfront_Language_Code__c = 'xxx');
            aop_Locale_Mapping__c localeMapGermanyGerman = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'DE_de',aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
                                                                          Name = 'de_DE', aop_Salesforce_Language__c = 'de', aop_country__c = 'Germany', aop_language__c = 'German',
                                                                                    aop_Checkfront_Language_Code__c = 'xxx');
        	aop_Locale_Mapping__c localeMapFranceGerman = new aop_Locale_Mapping__c(aop_Locale_Code__c = 'FR_fr', aop_Encoding__c = 'utf-8', aop_Time_Zone__c = 'gmt', 
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
                //insert contactLocalTest;
                //insert contactMatchTest;
            }
        
        	CampaignMember campaignMember1 = new CampaignMember(campaignID = campaign.id, contactId = contactGlobalTest.id, status = 'CF');
            //CampaignMember campaignMember2 = new CampaignMember(campaignID = campaign.id, contactId = contactLocalTest.id, status = 'CF');
        	//CampaignMember campaignMember3 = new CampaignMember(campaignID = campaign.id, contactId = contactMatchTest.id, status = 'CF');

            insert campaignMember1;
            //insert campaignMember2;
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
        
        aop_EmailCampaignMemberPostEvent60Days.sendEmail(campaignMembers);
        Test.StopTest();
    }
}