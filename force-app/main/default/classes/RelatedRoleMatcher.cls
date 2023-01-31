public class RelatedRoleMatcher {
    public List<Role__c> GetMatchingRoles(Role__c inputRole, List<Role__c> roles)
    {
        List<Role__c> matchingRoles = new List<Role__c>();  
        for(Role__c role : roles){
            if( role.Role__c == inputRole.Role__c &&
                (role.Vehicle__c == inputRole.Vehicle__c && String.isNotBlank(role.Vehicle__c) &&
                    ((String.isNotBlank(role.Account__c) && role.Account__c != inputRole.Account__c ) || (String.isNotBlank(role.Contact__c) && role.Contact__c != inputRole.Contact__c))) ) 
            {     
                matchingRoles.add(role);
            }
            else if( role.Role__c == 'Current Owner' && role.Role__c == inputRole.Role__c &&
                (role.Vehicle__c == inputRole.Vehicle__c && String.isNotBlank(role.Vehicle__c) &&
                    ((String.isNotBlank(role.Account__c) && role.Account__c == inputRole.Account__c ) || (String.isNotBlank(role.Contact__c) && role.Contact__c == inputRole.Contact__c))) ) 
            {
             matchingRoles.add(role);           
            }
        }    
        return matchingRoles;
    }
}