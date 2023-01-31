@isTest
public class SandboxEmailChangeTest {
    @testSetup static void setupInvalidUsers(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Group g = [SELECT Id FROM Group WHERE DeveloperName = 'SandboxEmail'];
        User u = new User();
        u.Phone = '07681102495';
        u.Email = 'sandboxemailchange@test.test.invalid';
        u.UserName = UserInfo.getOrganizationId() + '@test.test';
        u.Country_ISO_Code__c = 'IN';
        u.Alias = 'TTT';
        u.FirstName = 'Test';
        u.LastName = 'Test';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Chicago';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = p.Id;
        User currentUser = new User(Id=UserInfo.getUserId());
        System.runAs(currentUser){
            insert u;
        }
        
        GroupMember gm = new GroupMember();
        gm.GroupId = g.Id;
        gm.UserOrGroupId = u.Id;
        insert gm;        
    }
    
    @isTest
    static void testEmailChange() {

        Test.startTest();
        
        Test.testSandboxPostCopyScript(
            new SandboxEmailChange(), UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
        String testUsrName = UserInfo.getOrganizationId() + '@test.test';
        User u = [SELECT Id, Email FROM User WHERE UserName = :testUsrName];
        System.assertEquals('sandboxemailchange@test.test', u.Email);

    }
}