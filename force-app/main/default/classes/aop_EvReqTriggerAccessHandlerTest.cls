@isTest
public class aop_EvReqTriggerAccessHandlerTest {
    static Contact GetTestContact()
    {
        Contact con = new Contact(LastName = 'Percy', FirstName = 'Test', Email = 'atestuser@b.com', Language__c = 'French', aop_Country__c = 'France');
        insert con;
        return con;
        
    }
    
    static testMethod void TestCreateNewPersonAccountCreatesAccount()
    {
        aop_Area_Configuration__C eventConfig = new aop_Area_Configuration__c(Name = 'Test config');
        RecordType rt = [select Name, DeveloperName, sObjectType, Id from RecordType where Name = 'Individual' and SobjectType = 'Account' limit 1];
        List<RecordType>  recTypes = new List<RecordType>();
        recTypes.add(rt);
        Request__c evReq = new Request__c(aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'First Name', Last_Name__c = 'Last Name', Language__c = 'French', Email__c = 'a@b.com',  aop_Date_Of_Birth__c = Date.today());
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        Account acc = accessHandler.CreateNewPersonAccount(evReq, eventConfig, recTypes);
        
        System.assertEquals('City', acc.PersonMailingCity);
    }
    
    static testMethod void TestIsContactCommunityUserReturnsFalseIfNoUser()
    {
        Contact con = GetTestContact();
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        User result = accessHandler.IsContactCommunityUser(con.Id);
        
        System.assertEquals(null, result);
    }
    
    static testMethod void TestGetUserNameReturnsContactEmailIfNoUsers()
    {
        Request__c evReq = new Request__c(aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'First Name', Last_Name__c = 'Last Name', Language__c = 'French', Email__c = 'idoubtthisisanyonesemail@no.com',  aop_Date_Of_Birth__c = Date.today());
        
        Contact con = GetTestContact();
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        string result = accessHandler.GetUserName(evReq);
        
        System.assertEquals('idoubtthisisanyonesemail@no.com', result);
    }
    
    static testMethod void TestGetCommunityNicknameReturnsConcatNameNoUsers()
    {
        Request__c evReq = new Request__c(aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'Percy', Last_Name__c = 'Test', Language__c = 'French', Email__c = 'a@b.com',  aop_Date_Of_Birth__c = Date.today());
        Contact con = GetTestContact();
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        string result = accessHandler.GetCommunityNickName(evReq);
        
        System.assertEquals('TestPercy', result);
    }
    
    static testMethod void TestCreateCampaignMemberCreatesCampaignMember()
    {
        Contact con = GetTestContact();
        Campaign camp = new Campaign(Name = 'newCampaign', ExpectedResponse = 10, Market_ID__c = 'IN');
        insert camp;
        Request__c evReq = new Request__c(aop_Customer__c = con.Id, Campaign__c = Camp.Id);
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        accessHandler.CreateCampaignMember(con, evReq);
        CampaignMember campMem = [SELECT Id FROM CampaignMember WHERE CampaignId =: camp.Id AND ContactId =: con.Id LIMIT 1];
        
        System.assertNotEquals(null, campMem);
    }
    
    static testMethod void TestGetLocaleMappingReturnsNullNoMappings()
    {
        Request__c evReq = new Request__c(aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'First Name', Last_Name__c = 'Last Name', Language__c = 'French', Email__c = 'a@b.com',  aop_Date_Of_Birth__c = Date.today());
        Contact con = GetTestContact();
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        aop_Locale_Mapping__C localeMap = accessHandler.GetLocaleMapping(evReq);
        System.assertEquals(null, localeMap);
    }
    
    static testMethod void TestGetLocaleMappingReturnsMappingIfAvailable()
    {
        Request__c evReq = new Request__c(aop_Country__C = 'France', aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'First Name', Last_Name__c = 'Last Name', Language__c = 'French', Email__c = 'a@b.com',  aop_Date_Of_Birth__c = Date.today());
        
        Contact con = GetTestContact();
        aop_Locale_Mapping__C locales = new aop_Locale_Mapping__c(aop_Locale_Code__C = 'fr_FR', aop_Checkfront_Language_Code__C = 'abc', aop_Time_Zone__c = 'GMT', aop_Encoding__c = 'UTF-8', Name = 'France', aop_Country__c = 'France', aop_Language__c = 'French', aop_Salesforce_Language__C = 'French');
        insert locales;
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        aop_Locale_Mapping__C localeMap = accessHandler.GetLocaleMapping(evReq);
        System.assertEquals(locales.Id, localeMap.Id);
    }
    
    static testMethod void TestGetProfileIDReturnsProfileWithName()
    {
        Profile prof = [SELECT Name FROM Profile LIMIT 1];
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        Id profID = accessHandler.GetProfileID(prof.Name);
        System.assertEquals(prof.Id, profID);
    }
    
    static testMethod void TestAssignPermissionSetAssigns()
    {
        /*
        Profile prof = [SELECT Name FROM Profile LIMIT 1];
        User newUser = new User(Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');
        insert newUser;
        newUser.aop_Has_AoP_Community_Access__c = true; 
        PermissionSet permish = new PermissionSet(Name = 'permset', Label = 'permset');
        insert permish;
        
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        accessHandler.AssignPermissionSet(newUser, permish.Id);
        
        PermissionSetAssignment permAssign = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: newUser.Id LIMIT 1];
        
        System.assertNotEquals(null, permAssign);
*/
    }
    
    static testMethod void TestCreateCommunityUserReturnsUserWithCorrectCredentials()
    {
        Id runningId = userinfo.getUserId();
        User u = [SELECT Id FROM User WHERE Id =: runningId LIMIT 1];
        UserRole uRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        u.UserRoleId = uRole.Id;
       
        System.runAs(u)
        {
            update u;
        }
        Account acc = new Account(Name = 'newAcc');
        insert acc;
        Contact con = new Contact(LastName = 'Cox', FirstName = 'Amelia', Email = 'a@c.com', AccountId = acc.Id);
        insert con;
        
        
        aop_Locale_Mapping__c localeMap = new aop_Locale_Mapping__c(aop_Locale_Code__C = 'en_US', aop_Checkfront_Language_Code__C = 'abc', Name = 'en_US', aop_Salesforce_Language__c = 'en_US', aop_Time_Zone__c = 'Europe/London', aop_Country__c = 'France', aop_Encoding__c = 'UTF-8', aop_Language__c = 'French');
        insert localeMap;
        Request__c evReq = new Request__c(aop_Customer__c = con.Id, aop_Country__c = 'France', aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'First Name', Last_Name__c = 'Last Name', Language__c = 'French', Email__c = 'a@b.com',  aop_Date_Of_Birth__c = Date.today());
        
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        User noUser;
        System.RunAs(new User(Id=UserInfo.getUserId())){
        	noUser = accessHandler.CreateCommunityUser(evReq, null);
        }
        
        System.assertEquals(evReq.First_Name__c, noUser.FirstName);
        System.assertEquals(true, noUser.IsActive);
        System.assertEquals('FLast Na', noUser.Alias);
        
        
    }  
    
    static testMethod void TestCreateCommunityUserDoesntCreateUserWithNoLocale()
    {
        Id runningId = userinfo.getUserId();
        User u = [SELECT Id FROM User WHERE Id =: runningId LIMIT 1];
        UserRole uRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        u.UserRoleId = uRole.Id;
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_New_Record_Owner__c = u.Id);
       
        System.runAs(u)
        {
            update u;
        }
        Account acc = new Account(Name = 'newAcc');
        insert acc;
        Contact con = new Contact(LastName = 'Cox', FirstName = 'Amelia', Email = 'a@c.com', AccountId = acc.Id);
        insert con;

        Request__c evReq = new Request__c(aop_Customer__c = con.Id, aop_Country__c = 'France', aop_Street__c = 'Test', City__c = 'City', aop_State_Province__c = 'State', aop_Postcode_Zip_Code__c = 'Postcode', Salutation__C = 'Salutation', First_Name__c = 'First Name', Last_Name__c = 'Last Name', Language__c = 'French', Email__c = 'a@b.com',  aop_Date_Of_Birth__c = Date.today());
        
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        User noUser = accessHandler.CreateCommunityUser(evReq, areaConfig);
        
        System.assertEquals(null, noUser);
        
        
    }  
    
    static TestMethod void TestGetCampaignNameFromRequestReturnsCampaignName()
    {
        Campaign newCamp = new Campaign(Name = 'newCamp', ExpectedResponse = 20, Market_ID__c = 'IN');
        insert newCamp;
        Request__c evReq = new Request__c(Campaign__c = newCamp.Id);
        
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        string name = accessHandler.GetCampaignNameFromRequest(evReq);
        
        System.assertEquals('newCamp', name);
    }
    
    static TestMethod void TestUpdateExistingUserUpdatesCommunityPathAndAccess()
    {
        User u = new User();
        Campaign newCamp = new Campaign(Name = 'newCamp', ExpectedResponse = 20, Market_ID__c = 'IN');
        insert newCamp;
        Request__c evReq = new Request__c(Campaign__c = newCamp.Id);
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_Community_URL__c = 'compath');
        
        aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
        User newU  = accessHandler.UpdateExistingUser(u, evReq, areaConfig);
        
        System.assertEquals('compath', newU.aop_AOP_Community_Path__c);
        System.assertEquals(true, newU.aop_Has_AoP_Community_Access__c);
    }
    
    

    
}