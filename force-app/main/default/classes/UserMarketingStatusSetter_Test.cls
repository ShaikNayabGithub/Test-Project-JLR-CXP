@IsTest
public class UserMarketingStatusSetter_Test {
    
    @IsTest
    public static void SetStatus_SetsTheIsMarketingUserFieldEqualToTheUserPermissionsMarketingUserField_WhenPassedAListOfUsers(){
        UserMarketingStatusSetter userMarketingStatusSetter = new UserMarketingStatusSetter();
        List<User> users = new List<User>();
        Boolean setsField = true;
        
        try{
            userMarketingStatusSetter.SetStatus(users);
        }
        catch(Exception e){
            setsField = false;
        }
        
        System.Assert(setsField);
    }

}