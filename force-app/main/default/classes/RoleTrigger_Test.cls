@isTest
public class RoleTrigger_Test {
    static testmethod void InsertOfRole_SetsPreviousRoleStatusToPrevious_GivenCurrentRoleForAssetAlreadyExists()
    {
        CurrentToPreviousRoleMap__c currentToPreviousRoleMap = TestClass_CurrentToPreviousRoleMapCreato.Create('Owner');
        Role__c role1 = TestClass_AssetRoleCreator.Create(currentToPreviousRoleMap.Name);
        
        Test.StartTest();
        Role__c role2 = TestClass_AssetRoleCreator.CreateNew(role1);
        
        role1 = [Select Role__c From Role__c Where Id=: role1.Id];
        
        System.assertEquals(currentToPreviousRoleMap.Previous_Role__c, role1.Role__c);
        Test.StopTest();
    }
    
    static testmethod void InsertOfRole_SetsRolePreviousRoleToPreviousRole_GivenCurrentRoleForAssetAlreadyExists()
    {
        CurrentToPreviousRoleMap__c currentToPreviousRoleMap = TestClass_CurrentToPreviousRoleMapCreato.Create('Owner');
        Role__c role1 = TestClass_AssetRoleCreator.Create(currentToPreviousRoleMap.Name);
        
        Test.StartTest();
        Role__c role2 = TestClass_AssetRoleCreator.CreateNew(role1);
        
        role2 = [Select Previous_Role__c From Role__c Where Id=: role2.Id];
        
        System.assertEquals(role1.Id, role2.Previous_Role__c);
        Test.StopTest();
    }
}