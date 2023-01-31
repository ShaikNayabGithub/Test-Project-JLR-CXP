@isTest
private class CaseGoodwillApprovalHandlerTest {
    
    static testMethod void testGetAllUsersReturnsNonEmptyList()
    {
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	
    	Map<Id, User> userList = handler.GetAllUsers();
    	
    	system.assertEquals(false, userList.isEmpty());
    }
    
    static testMethod void testGetCasesToSubmitReturnsPassedInListIfNoProcesses()
    {
    	Case newCase = new  Case(Case_Contact_Email__c = 'example@example.com', Status = 'Open', Origin = 'Web');
    	insert newCase;
    	List<Case> caseList = new List<Case>();
    	caseList.add(newCase);
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	
    	List<Case> result = handler.GetCasesToSubmit(caseList);
    	
    	system.assertEquals(false, result.isEmpty());
    } 
    
    static testMethod void testGetCasesToSubmitReturnsEmptyListIfPassedCaseWithProcess()
    {
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	Id approverId = userInfo.getUserId();
    	string processName = Label.Goodwill_Approval_Name;
        List<Profile> userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'JLR System Administrator' OR Name = 'Delegated NSC Administrator'];
    	Id prof1=userProfile[0].Id;
    	User newUser = new User(Country_ISO_Code__c = 'GB',Market__c='Korea', Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof1, LanguageLocaleKey = 'en_US');
        insert newUser;
    	Case newCase = new  Case(Goodwill_Responsibility__C = Label.Goodwill_Approval_JLR, Case_Contact_Email__c = 'example@example.com', Status = 'Open', Origin = 'Web', Goodwill__c = 'Yes', Goodwill_Type__C =  'Experience', Goodwill_Value__c = 566, ownerid=newUser.Id);
    	system.debug(newCase);
        insert newCase;
    	
    	handler.SubmitForApproval(approverId, newCase.Id ,processName,null);
    	
    	List<Case> caseList = new List<Case>();
    	caseList.add(newCase);
    	
    	List<Case> result = handler.GetCasesToSubmit(caseList);
    	
    	system.assertEquals(true, result.isEmpty());
    } 
    
    static testMethod void testGetApprovalMappingReturnsMappingIfExists()
    {
    	GoodwillApprovalMapping__c approvalMap = new GoodwillApprovalMapping__c(Name = 'abc', Type__c = 'NSC', Minimum_Value__c = 0, Maximum_Value__c = 10, Country__c = 'GB', Profile_ID__c = 'xyz');
    	insert approvalMap;
    	
    	Case toApprove = new Case(Goodwill_Value__c = 5);
    	
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	List<GoodwillApprovalMapping__c> result = handler.GetApprovalMapping(toApprove, 'GB', false);
    	
    	system.assertEquals(10, result[0].Maximum_Value__c);
    	
    	
    }
    
    static testMethod void testGetUsersOfProfileReturnsListOf1When1UserWithProfilePassedIn()
    {
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	
    	Map<Id, User> userList = handler.GetAllUsers();
    	
    	User runningUser = userList.get(userInfo.getUserId());
    	runningUser.Country_ISO_Code__c = 'GB';
    	Id profileId = runningUser.ProfileId;
    	List<User> oneUserList = new List<User>();
    	oneUserList.add(runningUser);
    	
    	GoodwillApprovalMapping__c approvalMap = new GoodwillApprovalMapping__c(Name = profileId, Country__c = 'GB', Profile_Id__c = profileId);
    	
    	List<User> result = handler.GetUsersOfProfile(approvalMap, oneUserList);
    	
    	system.assertEquals(1, result.size());
    	
    }
    
    static testMethod void testGetRetailerUserReturnsNullIfNoUserInThatRetailerWithProfile()
    {
    	Account testAcc = new Account(Name = 'Test Retailer');
    	
    	insert testAcc;
    	Contact caseOwnerCon = new Contact(LastName = 'Retailer1', Email = 'example@example.com', AccountId = testAcc.Id);
    	insert caseOwnerCon;
    	
    	User caseOwner = new User(ContactId = caseOwnerCon.Id);
    	
    	User userWithProfile = new User();
    	List<User> profileList = new List<User>();
    	profileList.add(userWithProfile);
    	
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	User result = handler.GetRetailerUser(caseOwner, profileList, new List<Contact>());
    	
    	system.assertEquals(null, result);
    	
    }
    
    static testMethod void testGetRetailerUserReturnsUserIfUserExistsInThatRetailerWithProfile()
    {
    	Account testAcc = new Account(Name = 'Test Retailer');
    	
    	insert testAcc;
    	Contact caseOwnerCon = new Contact(LastName = 'Retailer1', Email = 'example@example.com', AccountId = testAcc.Id);
    	insert caseOwnerCon;
    	List<contact> conList = new List<Contact>();
    	conList.add(caseOwnerCon);
    	
    	User caseOwner = new User(ContactId = caseOwnerCon.Id);
    	
    	User userWithProfile = new User(ContactId = caseOwnerCon.Id);
    	List<User> profileList = new List<User>();
    	profileList.add(userWithProfile);
    	
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	User result = handler.GetRetailerUser(caseOwner, profileList, conList);
    	
    	system.assertNotEquals(null, result);
    	
    }
    
    static testMethod void testSubmitForApprovalMakesNewProcessInstanceForTargetObjectCasePassedIn()
    {
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();
    	Id approverId = userInfo.getUserId();
    	string processName = Label.Goodwill_Approval_Name;
        List<Profile> userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'JLR System Administrator' OR Name = 'Delegated NSC Administrator'];
    	Id prof1=userProfile[0].Id;
    	User newUser = new User(Country_ISO_Code__c = 'GB',Market__c='Korea', Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof1, LanguageLocaleKey = 'en_US');
        insert newUser;
    	Case newCase = new  Case(Goodwill_Responsibility__C = Label.Goodwill_Approval_JLR, Case_Contact_Email__c = 'example@example.com', Status = 'Open', Origin = 'Web', Goodwill__c = 'Yes', Goodwill_Type__C =  'Experience', Goodwill_Value__c = 566, ownerid=newUser.Id);
    	insert newCase;
    	
    	handler.SubmitForApproval(approverId, newCase.Id ,processName,null);
    	
    	List<ProcessInstance> pi = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectID =: newCase.Id];
    	
    	system.assertEquals(false, pi.isEmpty());
    }
    
    static testMethod void testHandleGoodwillApprovalSubmitsForApprovalWithAllData()
    {
    	List<Profile> userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'JLR System Administrator' OR Name = 'Delegated NSC Administrator'];
    	Id prof1;
    	Id prof2;
    	for(Profile prof : userProfile)
    	{
    		if(prof.Name == 'JLR System Administrator')
    		{
    			prof1 = prof.ID;
    		}
    		else if(prof.Name == 'Delegated NSC Administrator')
    		{
    			prof2 = prof.Id;
    		}
    	}
    	
    	List<sObject> toInsert = new List<sObject>();

    	User newUser = new User(Country_ISO_Code__c = 'GB',Market__c='Korea', Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof1, LanguageLocaleKey = 'en_US');
    	User newUser2 = new User(Country_ISO_Code__c = 'GB',Market__c='Korea', Username = 'xyzwabc@b.com', LastName = 'wabc', Email = 'wa@b.com', Alias = 'bwarry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bwazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof2, LanguageLocaleKey = 'en_US');
    	toInsert.add(newUser);
    	toInsert.add(newUser2);
    	GoodwillApprovalMapping__c unapprovedMap = new GoodwillApprovalMapping__C(Profile_ID__c = prof1, Name = 'unapprove', Type__C = 'NSC', Minimum_Value__C = 0, Maximum_Value__c = 4, Country__c = 'GB');
    	GoodwillApprovalMapping__c approvalMap = new GoodwillApprovalMapping__c(Profile_ID__c = prof2, Name = prof2, Type__c = 'NSC', Minimum_Value__c = 0, Maximum_Value__c = 10, Country__c = 'GB');
    	toInsert.add(unapprovedMap);
    	toInsert.add(approvalMap);
    	insert toInsert;
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();

    	Case newCase = new  Case(Goodwill_Responsibility__C = Label.Goodwill_Approval_JLR, Case_Contact_Email__c = 'example@example.com', Status = 'Open', Origin = 'Web', Goodwill__c = 'Yes', Goodwill_Type__C =  'Experience', Goodwill_Value__c = 5, OwnerId = newUser.Id);
    	insert newCase;
    	List<Case> caseList = new List<Case>();
    	caseList.add(newCase);
    	handler.HandleGoodwillApproval(caseList,null);
    	
    	List<ProcessInstance> pi = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectID =: newCase.Id];
    	
    	system.assertEquals(false, pi.isEmpty());
    }
     static testMethod void HandleGoodwillApprovalKorea()
    {
    	List<Profile> userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'JLR System Administrator' OR Name = 'Delegated NSC Administrator'];
    	Id prof1;
    	Id prof2;
    	for(Profile prof : userProfile)
    	{
    		if(prof.Name == 'JLR System Administrator')
    		{
    			prof1 = prof.ID;
    		}
    		else if(prof.Name == 'Delegated NSC Administrator')
    		{
    			prof2 = prof.Id;
    		}
    	}
    	
    	List<sObject> toInsert = new List<sObject>();

    	User newUser = new User(Country_ISO_Code__c = 'GB',Market__c='Korea', Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof1, LanguageLocaleKey = 'en_US');
    	User newUser2 = new User(Country_ISO_Code__c = 'GB',Market__c='Korea', Username = 'xyzwabc@b.com', LastName = 'wabc', Email = 'wa@b.com', Alias = 'bwarry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bwazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof2, LanguageLocaleKey = 'en_US');
    	toInsert.add(newUser);
    	toInsert.add(newUser2);
    	GoodwillApprovalMapping__c unapprovedMap = new GoodwillApprovalMapping__C(Profile_ID__c = prof1, Name = 'unapprove', Type__C = 'NSC', Minimum_Value__C = 0, Maximum_Value__c = 4, Country__c = 'GB');
    	GoodwillApprovalMapping__c approvalMap = new GoodwillApprovalMapping__c(Profile_ID__c = prof2, Name = prof2, Type__c = 'NSC', Minimum_Value__c = 0, Maximum_Value__c = 10, Country__c = 'GB');
    	toInsert.add(unapprovedMap);
    	toInsert.add(approvalMap);
    	insert toInsert;
    	CaseGoodwillApprovalHandler handler = new CaseGoodwillApprovalHandler();

    	Case newCase = new  Case(Goodwill_Responsibility__C = Label.Goodwill_Approval_JLR, Case_Contact_Email__c = 'example@example.com', Status = 'Open', Origin = 'Web', Goodwill__c = 'Yes', Goodwill_Type__C =  'Experience', Goodwill_Value__c = 5, OwnerId = newUser.Id);
    	insert newCase;
    	
    	CaseGoodwillApprovalHandler.HandleGoodwillApprovalKorea(newCase.id);
    	CaseGoodwillApprovalHandler.GoodwillButtonStatusKorea(newCase.id);
    	List<ProcessInstance> pi = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectID =: newCase.Id];
    	
    	system.assertEquals(false, pi.isEmpty());
    }
   
    
    
    
}