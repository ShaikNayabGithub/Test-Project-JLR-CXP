@isTest
public class AccountPseudoOwnerController_Test {
    //THIS CLASS CAN BE DELETED - REMOVAL OF PSEUDO_ACCOUNT_OWNER
    
    static testMethod void isUserPartner_ReturnsTrue_IfGivenIdInList()
    {
        List<UserRole> allRoles = [SELECT Id FROM UserRole];
        Set<UserRole> userRoles = new Set<UserRole>(allRoles);
        Id currentUserRoleId = userInfo.getUserRoleId();
        
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        boolean result = ownerController.isUserPartner(userRoles, currentUserRoleID);
        
        system.assertEquals(true, result);
    }
    
    static testMethod void isUserPartner_ReturnsFalse_IfGivenIdNotInList()
    {
        List<UserRole> allRoles = [SELECT Id FROM UserRole];
        Set<UserRole> userRoles = new Set<UserRole>(allRoles);
        Id currentUserRoleId = userInfo.getUserId();
        
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        boolean result = ownerController.isUserPartner(userRoles, currentUserRoleID);
        
        system.assertEquals(false, result);
    }
    
    static testMethod void getUserList_Returns1User_IfOneAccountPassedIn()
    {
        Account newAccount = new Account(Name = 'newAcc');
        insert newAccount;
        
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        List<User> result = ownerController.getUserList(new List<Account>{newAccount});
        
        system.assertEquals(1, result.size());
    }
    
    static testMethod void getUserList_Returns2Users_IfTwoAccountsDifferentOwnersPassedIn()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newUser = new User(Username = 'xyzabc@bcd.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US');
    insert newUser;
        Account newAccount = new Account(Name = 'newAcc');
        Account newAccount2 = new Account(Name = 'newAcc2', OwnerId = newUser.ID);
        insert new List<Account>{newAccount, newAccount2};
        
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        List<User> result = ownerController.getUserList(new List<Account>{newAccount, newAccount2});
        
        system.assertEquals(2, result.size());
    }
    
    static testMethod void canCurrentUserUpdate_ReturnsTrue_IfCurrentUserOwnsRecord()
    {
        Set<Id> currentUserRoles = new Set<Id>();
        Set<UserRole> allRoles = new Set<UserRole>();
        User oldNewUser = [SELECT Market__c FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        Boolean canUpdate = ownerController.canCurrentUserUpdate(userInfo.getUserId(), userInfo.getUserId(), currentUserRoles, allRoles, oldNewUser, oldNewUser, false);
        
        system.assertEquals(true, canUpdate);
    }
    
    static testMethod void canCurrentUserUpdate_ReturnsTrue_IfCurrentMarketEqualsOldMarketAndNotPartner()
    {
        Set<Id> currentUserRoles = new Set<Id>();
        Set<UserRole> allRoles = new Set<UserRole>();
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newUser = new User(Username = 'xyzabc@bcd.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US', Market__c = 'IN');
    insert newUser;
        User oldNewUser = [SELECT Market__c FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        oldNewUser.Market__c = 'IN';
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        Boolean canUpdate = ownerController.canCurrentUserUpdate(newUser.Id, userInfo.getUserId(), currentUserRoles, allRoles, newUser, oldNewUser, false);
        
        system.assertEquals(true, canUpdate);
    }
    
    static testMethod void canCurrentUserUpdate_ReturnsFalse_IfPartnerUserBelowCurrentUserInRole()
    {
        Set<Id> currentUserRoles = new Set<Id>();
        Set<UserRole> allRoles = new Set<UserRole>();
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newUser = new User(Username = 'xyzabc@bcd.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US', Market__c = 'IN');
    insert newUser;
        User oldNewUser = [SELECT Market__c FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        oldNewUser.Market__c = 'IN';
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        Boolean canUpdate = ownerController.canCurrentUserUpdate(newUser.Id, userInfo.getUserId(), currentUserRoles, allRoles, newUser, oldNewUser, true);
        
        system.assertEquals(false, canUpdate);
    }
    
    static testMethod void CheckIfCanEditPseudoOwner_ThrowsError_IfMarketsDifferent()
    {
        User oldNewUser = [SELECT Market__c FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        oldNewUser.Market__c = 'UK';
        update oldNewUser;
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newUser = new User(Username = 'xyzabc@bcd.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US', Market__c = 'IN');
        insert newUser;
        Account newAccount = new Account(Name = 'newAcc',  OwnerId = newUser.ID);
        insert newAccount;
        Account newAccount2 = new Account(Name = 'newAcc2', Id = newAccount.Id, OwnerId = userInfo.getUserId());
        
        AccountPseudoOwnerController ownerController = new AccountPseudoOwnerController();
        //ownerController.CheckIfCanEditPseudoOwner(new List<Account>{newAccount}, new List<Account>{newAccount2});
        try
        {
            //update newAccount2;
            ownerController.CheckIfCanEditPseudoOwner(new List<Account>{newAccount}, new List<Account>{newAccount2});
        }
        catch(Exception e)
        {
            system.debug('exception is ' + e.getMessage());
            system.assertEquals(true, e.getMessage().contains('Insufficient'));
        }
    }
    
    static testMethod void isgetUserFromList_ReturningCorrectUser()
    {
    User testUser = new User(UserName = 'Test1');
        //insert testUser;
        Id testUserID = '00524000003KMfy';
        testUser.Id = testUserID;
        
        List<User> testuserlist = new List<User>();
        testuserlist.add(testUser);
        
        AccountPseudoOwnerController controller = new AccountPseudoOwnerController();
        
        User result = controller.getUserFromList(testuserlist, testUserID);
        
        system.assertEquals(testUser, result);
    }
        
        
  static testMethod void getAllChildRoleIds_ReturnsChildRoles()
    {
        Set<ID> roleIds = new Set<ID>();
        Set<UserRole> allRoles = new Set<UserRole>();
        
         UserRole userRole1 = new UserRole(Name = 'Test1');
        UserRole userRole2 = new UserRole(Name = 'Test2');
        UserRole userRole3 = new UserRole(Name = 'Test3');
        
        insert userRole1;
        insert userRole2;
        insert userRole3;
        
        userRole1.ParentRoleID = userRole2.Id;
        userRole2.ParentRoleID = userRole3.Id;
        
        allRoles.add(userRole1);
        allRoles.add(userRole2);
        allRoles.add(userRole3);
        
        roleIds.add(userRole3.id);
        
        Set<ID> expectedResult = new Set<ID>();
        
        expectedResult.add(userRole1.id);
    expectedResult.add(userRole2.id);
            
        AccountPseudoOwnerController controller = new AccountPseudoOwnerController();
        Set<ID> result = controller.getAllChildRoleIds(roleIds, allRoles);
            
        system.assertEquals(expectedResult, result);
    }
    
    
      


}