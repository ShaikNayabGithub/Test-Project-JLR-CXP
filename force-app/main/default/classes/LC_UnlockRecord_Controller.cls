public class LC_UnlockRecord_Controller {

    @AuraEnabled
    public static boolean isLocked(String recordId) {
        return Approval.isLocked(Id.valueOf(recordId));
    }
    
    @AuraEnabled
    public static boolean UnlockRecord(String recordId) {
        List<String> unlockRecord = new List<String>();
        unlockRecord.add(recordId);
        try{
            Approval.UnlockResult[] unlockedResult = Approval.unlock(unlockRecord);
            return true;
        }
        catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean UserCanUnlockRecord(String sobjectName) {
        List<ObjectPermissions> userPermissions = [SELECT Id, Parent.Name, PermissionsModifyAllRecords FROM ObjectPermissions WHERE SObjectType=:sobjectName AND PermissionsModifyAllRecords=true AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId())];
		return userPermissions.size() > 0;
    }
    
}