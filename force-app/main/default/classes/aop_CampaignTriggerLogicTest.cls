@isTest
public class aop_CampaignTriggerLogicTest {
    static TestMethod void TestCampaignMemberStatusAfterInsert()
    {
        Test.StartTest();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        Campaign newCamp = new Campaign(Name = 'TestCamp', RecordTypeId = rt.Id, ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCamp;
        
        List<CampaignMemberStatus> cmsList = [SELECT  Id, Label, HasResponded, IsDefault FROM CampaignMemberStatus WHERE CampaignId =: newCamp.Id];
        System.assertEquals('CF', cmsList[0].Label);    
        
        delete newCamp;
        Test.StopTest();
    }
    
    static TestMethod void TestCampaignMemberStatusAfterInsertWrongType()
    {
        Test.StartTest();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name != 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        Campaign newCampTest = new Campaign(Name = 'TestCamp', RecordTypeId = rt.Id, ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampTest;
        System.debug('New Id '+ newCampTest.Id);
        
        List<CampaignMemberStatus> cmsList = [SELECT  Id, Label, HasResponded, IsDefault FROM CampaignMemberStatus WHERE CampaignId =: newCampTest.Id];
      if(cmsList.size() != 0)
        {
          System.assertNotEquals('CF', cmsList[0].Label);
        }
        
        delete newCampTest;
        Test.StopTest();
        
    
    }
    
    static TestMethod void TestCampaignMemberStatusDeletesOldCampaignMemberStatus()
    {
        Test.StartTest();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        Campaign newCampTest = new Campaign(Name = 'TestCamp', RecordTypeId = rt.Id, ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampTest;
        System.debug('New Id '+ newCampTest.Id);
        
        List<CampaignMemberStatus> cmsList = [SELECT  Id, Label, HasResponded, IsDefault FROM CampaignMemberStatus WHERE CampaignId =: newCampTest.Id];
      if(cmsList.size() != 0)
        {
          try
            {
                delete(cmsList[0]);
                
            }
            catch(exception e){
                //LB The salesforce error message has been changed slightly, resulting in a previous version of this test to fail
                //Due to this I've added a less exact/verbose error message check to prevent this happening again
                
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains('DELETE_FAILED') && errorMessage.contains('default'));                       
            }
        }
        
        delete newCampTest;
        Test.StopTest();
    
    }
    
    static TestMethod void TestAddCustomSettingCreatesNewCustomSetting()
    {
        Test.StartTest();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
      Campaign newCampTest = new Campaign(Name = 'TestCamp', RecordTypeId = rt.Id, ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampTest;
        aop_CampaignTriggerLogic logic = new aop_CampaignTriggerLogic();
        logic.AddCustomSetting(newCampTest);
        
        aop_CampaignTracker__c tracker = aop_CampaignTracker__c.getInstance(newCampTest.ID);
        System.assertNotEquals(null, tracker);
        Test.StopTest();
        
    }
    
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

            System.runAs (thisUser)
            {
            insert globalDefaults;
            }
        
            Account retailer = new Account(Name = 'TestRetailer', RecordTypeId = retailerRecordType.id, Dealer_CI_Code__c = 'x', Primary_Dealer_Code__c = 'x', Secondary_Dealer_Code__c = 'x');
            
          System.runAs (thisUser)
            {
            insert retailer;
            }
 

            
    
            aop_Area_Configuration__c areaConfigFrance = new aop_Area_Configuration__c
                (aop_AWS_Path__c = 'x', 
                 aop_Checkfront_AOP_Id__c = 'x', aop_Checkfront_Instance__c = 'abc.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = newPermissionSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
          System.runAs (thisUser)
            {
            insert areaConfigFrance;
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
            
            System.runAs (thisUser)
            {
      insert areaEmailConfig1;
            insert areaEmailConfig2;            
            }
            
            Request__c requestGlobalTest = new Request__c(Last_Name__c = 'GlobalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'Germany', Language__c = 'German', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);
        
          Request__c requestLocalTest = new Request__c(Last_Name__c = 'LocalTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', Language__c = 'French', 
                                                     RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);
        
          Request__c requestMatchTest = new Request__c(Last_Name__c = 'MatchTest', First_Name__c = 'TestData', Email__c = 'test@test.com', aop_Country__c = 'France', 
                                                         Language__c = 'German', RecordTypeId = preRegistrationRequestRecordType.id, aop_Source__c = 'Retailer', 
                                                         aop_Status__c = 'Submitted', aop_Event_Type__c = 'AOP Request', Preferred_Retailer__c = retailer.id);

      
        
          Account account = new Account(Name = 'TestAccount');
        
          System.runAs(thisUser)
            {
                 insert account;
            }
        
          Contact contactGlobalTest = new Contact(LastName = 'GlobalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'Germany', Language__c = 'German');
            Contact contactLocalTest = new Contact(LastName = 'LocalTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'France', Language__c = 'French');
          Contact contactMatchTest = new Contact(LastName = 'MatchTest', Email = 'test@test.com', AccountId = account.id, aop_Country__c = 'France', Language__c = 'German');
        
        List<RecordType> campaignRecordTypes = [SELECT ID
                                               FROM RecordType
                                               WHERE Name =: 'Game Event' AND sObjectType = 'Campaign'
                                              ]; 
      Campaign newCampTest = new Campaign(Name = 'TestCamp', RecordTypeId = campaignRecordTypes[0].id, ExpectedResponse = 0.20, aop_Checkfront_Instance__c = 'def.com', Status = 'Visible', Market_ID__c = 'IN');
            
            System.runAs(thisUser)
            {
                insert newCampTest;
            }
          
          
        
          System.runAs(thisUser)
            {

                
                insert contactGlobalTest;
                insert contactLocalTest;
                //insert contactMatchTest;
                
                

            }
                            
          CampaignMember campaignMember1 = new CampaignMember(ContactId = contactGlobalTest.id, aop_CF_Status__C = 'Pending', CampaignId = newCampTest.id);
        
          System.runAs(thisUser)
            {
                insert campaignMember1;

            }
            
      Profile prof = [SELECT Name FROM Profile WHERE Name =: 'Customer Community Login User' LIMIT 1];
          User newUser = new User(aop_Has_AoP_Community_Access__c = true, ContactId = contactGlobalTest.id, Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');

        

      insert newUser;
          
            
        
  }
    
    static TestMethod void TestSendEmailOnCreateOfCampaignSendsEmails()
    {
        
        setTestData();
        Test.StartTest();
        aop_CampaignTriggerLogic campaignTriggerLogic = new aop_CampaignTriggerLogic();
        
        Campaign campaign = [SELECT ID, aop_Checkfront_Instance__c
                            FROM Campaign
                            WHERE Name =: 'TestCamp'
                            LIMIT 1
                            ];
        
        List<aop_Area_Configuration__c> areaConfigs =   [SELECT ID, aop_Checkfront_Instance__c 
                                                        FROM aop_Area_Configuration__c
                                                        ];
        
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                                               aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c, aop_Language__c
                                               FROM aop_Area_Email_Configuration__c];
        
        List<EmailTemplate> emailTemplates = [SELECT id, name, developername 
                                              FROM EmailTemplate 
                                             ];
                            
        List<String> countries = new List<String>();
        countries.add('French');
        countries.add('German');
        Map<string, List<sObject>> dataMap = aop_CampaignTriggerLogic.GetContactsCampaignMembersUsers(countries);
        campaignTriggerLogic.SendEmailOnCreateOfCampaign(campaign, dataMap.get('contacts'), dataMap.get('campaignMembers'), dataMap.get('users'), areaConfigs, areaEmailConfigs, emailTemplates);
        Test.StopTest();
    }
    
    static TestMethod void TestSetLastQualifiedEventCompleteOfCampaign()
    {
         setTestData();
         Test.StartTest();
         aop_CampaignTriggerLogic campaignTriggerLogic = new aop_CampaignTriggerLogic();
         Campaign campaign = [
                    SELECT ID, Status
                            FROM Campaign
                            WHERE Name =: 'TestCamp'
                    LIMIT 1
                            ];
        
        campaignTriggerLogic.SetLastQualifiedEventCompleteOfCampaign(campaign);
        Test.StopTest();
    }
    
    static testMethod void TestDeleteCustomSettingDeletesIfFound()
    {
        Campaign newCam = new Campaign(Name = 'abc campaign', Status = 'Visible', ExpectedResponse = 12, Market_ID__c = 'IN');
        insert newCam;
        aop_CampaignTracker__c newTracker = new aop_CampaignTracker__c(Name = newCam.Id);
        insert newTracker;
        aop_CampaignTracker__c tracker = aop_CampaignTracker__c.getInstance(newCam.ID);
        //if(tracker != null)
        //{
            aop_CampaignTriggerLogic testLogic = new aop_CampaignTriggerLogic();
            testLogic.DeleteCustomSetting(newCam);
        //}
        aop_CampaignTracker__c result = aop_CampaignTracker__c.getInstance(newCam.Id);
        system.assertEquals(null, result);
    }
    
    static testMethod void TestGetCountriesFromCampaignsReturnsNonEmptyList()
    {
        aop_NationalityToISOCode__C isoKey1 = new aop_NationalityToISOCode__c(Name = 'France', aop_ISO_Code__c = 'FR', aop_Checkfront_Instance__c = 'checkfront.com');
        insert isoKey1;
        Campaign newCam = new Campaign(aop_Checkfront_Instance__c = 'checkfront.com');
        List<Campaign> campList = new List<Campaign>();
        campList.add(newCam);
        
        aop_CampaignTriggerLogic testLogic = new aop_CampaignTriggerLogic();
        List<string> result = testLogic.getCountriesFromCampaigns(campList);
        
        system.assertEquals(false, result.isEmpty());
        system.assertEquals('France', result[0]);
    }
    
    static testMethod void TestGetCountriesFromCampaignTrackersReturnsNonEmptyList()
    {
        aop_NationalityToISOCode__C isoKey1 = new aop_NationalityToISOCode__c(Name = 'France', aop_ISO_Code__c = 'FR', aop_Checkfront_Instance__c = 'checkfront.com');
        insert isoKey1;
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        Campaign newCamp = new Campaign(aop_Checkfront_Instance__c = 'checkfront.com', Name = 'TestCamp', RecordTypeId = rt.Id, ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCamp;
        aop_CampaignTracker__c tracker  = new aop_CampaignTracker__c(Name = newCamp.Id);
        List<aop_CampaignTracker__c> trackerList = new List<aop_CampaignTracker__c>();
        trackerList.add(tracker);
        
        aop_CampaignTriggerLogic testLogic = new aop_CampaignTriggerLogic();
        List<string> result = testLogic.getCountriesFromCampaignTracker(trackerList);
        system.assertEquals(false, result.isEmpty());
        system.assertEquals('France', result[0]);
    }
    
    static testMethod void TestReturnsEmailTemplates()
    {        
        setTestData();
        aop_CampaignTriggerLogic campaignTriggerLogic = new aop_CampaignTriggerLogic();

        List<aop_Area_Email_Configuration__c> areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                                               aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c, aop_Language__c
                                               FROM aop_Area_Email_Configuration__c];
        
        List<EmailTemplate> result = campaignTriggerLogic.getEmailTemplates(areaEmailConfigs);
        
        


        
    }
    
}