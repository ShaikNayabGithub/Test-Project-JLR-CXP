public class RoleStatusMaintainer {
    public static final Map<String, CurrentToPreviousRoleMap__c> RoleStatusMap = CurrentToPreviousRoleMap__c.getAll();
    private final RoleStatusSetter roleStatusSetter;
    
    
    public RoleStatusMaintainer(RoleStatusSetter roleStatusSetter)
    {
        this.roleStatusSetter = roleStatusSetter;
    }
    
    
    public void MaintainRoleStatuses(List<Role__c> roles)
    {
        List<Role__c> rolesForUpdate = this.GetCurrentRoles(roles);
        if(!rolesForUpdate.isEmpty()){
            roleStatusSetter.UpdateStatuses(rolesForUpdate, RoleStatusMaintainer.RoleStatusMap.KeySet());
        }
    }
    
    public void MaintainRoleStatuses(List<Role__c> currentRoles, List<Role__c> oldRoles)
    {
        List<Role__c> rolesForUpdate = this.GetCurrentRoles(currentRoles, oldRoles);
        if(!rolesForUpdate.isEmpty()){
            roleStatusSetter.UpdateStatuses(rolesForUpdate, RoleStatusMaintainer.RoleStatusMap.KeySet());
        }
    }
    
    public void RollbackRoleStatuses(List<Role__c> deletedRoles)
    {
        roleStatusSetter.RollbackRelatedRoles(deletedRoles);
    }
    
    
    private List<Role__c> GetCurrentRoles(List<Role__c> roles)
    {
        List<Role__c> currentRoles = new List<Role__c>();
        
        for(Role__c role : roles){
            if(RoleStatusMap.containsKey(role.Role__c)){
                currentRoles.add(role);
            }
        }
        
        return currentRoles;
    }
    
    private List<Role__c> GetCurrentRoles(List<Role__c> currentRoles, List<Role__c> oldRoles)
    {
        List<Role__c> rolesForUpdate = new List<Role__c>();
        
        for(integer i = 0; i < currentRoles.Size(); i++){
            if(RoleStatusMap.containsKey(currentRoles[i].Role__c) && currentRoles[i].Role__c != oldRoles[i].Role__c){
                rolesForUpdate.add(currentRoles[i]);
            }
        }
        
        return rolesForUpdate;
    }
}