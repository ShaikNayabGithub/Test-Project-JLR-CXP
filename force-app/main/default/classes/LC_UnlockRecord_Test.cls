@isTest
public class LC_UnlockRecord_Test {

    @isTest
    static void IsLocked_ReturnsFalse_WhenOpportunityIsUnlocked() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        String oppId = opp.Id;
        System.assert(LC_UnlockRecord_Controller.isLocked(oppId) == false);
    }

    @isTest
    static void IsLocked_ReturnsTrue_WhenOpportunityIsLocked() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        String oppId = opp.Id;
        Approval.lock(opp, false);
        System.assert(LC_UnlockRecord_Controller.isLocked(oppId) == true);
    }
    
    @isTest
    static void IsLocked_ReturnsFalse_WhenOpportunityIsLockedAndControllerUnlocksRecord() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        String oppId = opp.Id;
        Approval.lock(opp, false);
        LC_UnlockRecord_Controller.UnlockRecord(oppId);
        System.assert(LC_UnlockRecord_Controller.isLocked(oppId) == false);
    }
    
    @isTest
    static void UserCanUnlockRecord_ReturnsFalse_WhenUserHasNoModifyAllDataPermissions() {
        boolean canUnlock = true;
        List<User> noPermissionUser = [SELECT Id FROM User WHERE Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment) AND IsActive = true LIMIT 1];
        if(noPermissionUser.size() > 0){
            System.runAs(noPermissionUser[0]){
                canUnlock = LC_UnlockRecord_Controller.UserCanUnlockRecord('Opportunity');
            }
            System.assert(canUnlock == false);
        }
    }
    
    @isTest
    static void UserCanUnlockRecord_ReturnsTrue_WhenUserHasModifyAllDataPermission() {
        boolean canUnlock = false;
        List<Id> modifyAllDataPermissions = new List<Id>();
        for(PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType='Opportunity' AND PermissionsModifyAllRecords = true)]){
            modifyAllDataPermissions.add(psa.AssigneeId);
        }
        List<User> permittedUser = [SELECT Id FROM User WHERE Id IN :modifyAllDataPermissions AND IsActive = true LIMIT 1];
        if(permittedUser.size() > 0){
            System.runAs(permittedUser[0]){
                canUnlock = LC_UnlockRecord_Controller.UserCanUnlockRecord('Opportunity');
            }
            System.assert(canUnlock == true);
        }
    }
    
}