public class RoleStatusSetter {
    private final RelatedRoleRetriever relatedRoleRetriever;
    private final RelatedRoleMatcher relatedRoleMatcher;
    
    
    public RoleStatusSetter(RelatedRoleRetriever relatedRoleRetriever, RelatedRoleMatcher relatedRoleMatcher)
    {
        this.relatedRoleRetriever = relatedRoleRetriever;
        this.relatedRoleMatcher = relatedRoleMatcher;
    }
    
    
    public void UpdateStatuses(List<Role__c> roles, Set<String> matchingStatusValues)
    {
        List<Role__c> retrievedRoles = this.relatedRoleRetriever.RetrieveRelated(roles, matchingStatusValues);
        List<Role__c> rolesForUpdate = new List<Role__c>();
            
        for(Role__c retrievedRole : retrievedRoles){
            List<Role__c> newRoles = relatedRoleMatcher.GetMatchingRoles(retrievedRole, roles);
            
            if(newRoles.size() > 0){
                newRoles[0].Previous_Role__c = retrievedRole.Id;
                CurrentToPreviousRoleMap__c rolePair = RoleStatusMaintainer.RoleStatusMap.get(retrievedRole.Role__c);
                retrievedRole.Role__c = rolePair.Previous_Role__c;
                rolesForUpdate.add(retrievedRole); 
            }
        }
        
        update rolesForUpdate;
    }
    
    public void RollbackRelatedRoles(List<Role__c> rolesForRemoval)
    {
        List<Role__c> rolesForUpdate = new List<Role__c>();
        
        for(Role__c roleForRemoval : rolesForRemoval){
            if(String.isNotEmpty(roleForRemoval.Previous_Role__c)){
                Role__c previousRole = new Role__c();
                
                previousRole.Id = roleForRemoval.Previous_Role__c;
                previousRole.Role__c = roleForRemoval.Role__c;
                
                rolesForUpdate.add(previousRole);
            }
        }
        
        update rolesForUpdate;
    }
}