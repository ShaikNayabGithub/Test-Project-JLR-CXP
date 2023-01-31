public class UserMarketingStatusSetter {
    public void SetStatus(List<User> users){
        for (User user : users){
            user.Is_Marketing_User__c = user.UserPermissionsMarketingUser;
        }
    }
}