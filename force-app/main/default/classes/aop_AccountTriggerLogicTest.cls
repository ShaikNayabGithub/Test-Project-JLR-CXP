@isTest
private class aop_AccountTriggerLogicTest {

    static testMethod void myUnitTest() {
    	
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile prof = [SELECT Name FROM Profile WHERE Name =: 'System Administrator' LIMIT 1];
        
        User portalAccountOwner1 = new User(UserRoleId = portalRole.Id, ProfileID = prof.id, Username = System.now().millisecond() + 'test3@test.com',
						   					Alias = 'batman',Email='bruce.wayne@wayneenterprises.com',EmailEncodingKey='UTF-8',	Firstname='Bruce',
						   					Lastname='Wayne',LanguageLocaleKey='en_US',	LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago'); 
					
		Account retrievedAccount;				   					
		System.RunAs(portalAccountOwner1)
        {
	        RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' LIMIT 1];
	        Account account = new Account(FirstName = 'Test2', LastName = 'Test2', PersonEmail = 'test@test.com2', RecordType = personAccountRecordType);
	        insert account;
	        retrievedAccount = [SELECT Id, PersonContactID, IsPersonAccount, FirstName, LastName, PersonEmail FROM Account WHERE ID =: account.id];
        }
		   					
		Profile prof2 = [SELECT Name FROM Profile WHERE Name =: 'Customer Community Login User' LIMIT 1];

		User user = new User(aop_Has_AoP_Community_Access__c = true, Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = prof2.Id, LanguageLocaleKey = 'en_US', contactid = retrievedAccount.personcontactid);
	    insert user; 
     
        Test.StartTest();
        aop_AccountTriggerLogic accountLogic = new aop_AccountTriggerLogic();
        List<Account> accounts = new List<Account>();
        accounts.add(retrievedAccount);
        accountLogic.SetUserToMatchPersonAccountIfHasAOPAccess(accounts);
        Test.StopTest();
    }
}