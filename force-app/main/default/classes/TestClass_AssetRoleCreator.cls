@IsTest
public class TestClass_AssetRoleCreator {
    public static Role__c Create(String roleStatus)
    {
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        
        Role__c role = new Role__c();
        
        role.Account__c = TestClass_AccountCreator.createPersonAccount().Id;
        role.Vehicle__c = vehicle.Id;
        role.Role__c = roleStatus;
        
        insert role;
        return role;
    }

    public static Role__c Create(String roleStatus, String accountId, String vehicleId)
    {
        Role__c role = new Role__c();

        role.Account__c = accountId;
        role.Vehicle__c = vehicleId;
        role.Role__c = roleStatus;

        insert role;
        return role;
    }
    
    public static Role__c CreateNew(Role__c existingRole)
    {
        Role__c role = new Role__c();
        
        role.Account__c = TestClass_AccountCreator.createPersonAccount().Id;
        role.Vehicle__c = existingRole.Vehicle__c;
        role.Role__c = existingRole.Role__c;
        
        insert role;
        return role;
    }
}