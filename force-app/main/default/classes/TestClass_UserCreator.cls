@isTest
public class TestClass_UserCreator {
    private static String baseUserName = 'TestClass_UserCreator@test.test';
    
    private static string UserName { get {
        if(String.isEmpty(UserName)) { UserName = baseUserName;}
        UserName += 't'; 
        return UserName;
    } set; }
    
    public static User CreateUser(Profile profile)
    {
        User user = BuildUser();
        user.ProfileId = profile.Id;
        TestClass_LockableRecordInserter.AttemptInsert(user, 5);
        return user;
    }
    
    public static User CreateRetailerUser(Contact contact)
    {
        User user = BuildUser();
        user.ProfileId = ProfileUtilities.Profiles.get('Dealer Principle').Id;
        user.PortalRole = 'Manager';
        user.Dealer_CI_Code__c = 'test';
        user.ContactId = contact.Id;
        user.CommunityNickname = user.UserName.split('\\.')[1];
        TestClass_LockableRecordInserter.AttemptInsert(user, 5);
        return user;
    }
    
    private static User BuildUser()
    {
        User user = new User();
        user.Phone = '07681102495';
        user.Email = 'test@test.test';
        user.UserName = UserName;
        user.Country_ISO_Code__c = 'IN';
        user.Alias = 'TTT';
        user.FirstName = 'Test';
        user.LastName = 'Test';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Chicago';
        user.EmailEncodingKey = 'UTF-8';
        user.Dealer_CI_Code__c = 'test';
        user.Dealer_CI_Code_2__c = 'test';
        return user;
    }
}