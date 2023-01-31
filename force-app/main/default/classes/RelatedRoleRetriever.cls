public class RelatedRoleRetriever {
    //if we create a new asset role for an asset (Current Driver), we need to pull back all, existing, Current Driver roles for the
    //specified asset so we can update them to Previous Driver

    private List<Role__c> buildDynamicQuery(List<Role__c> roles, Set<String> assetIds, Set<String> contactIds, Set<String> accountIds, Set<String> roleStatuses)
    {
        List<Role__c> rolesToUpdate = new List<Role__c>();
        List<Role__c> existingRolesInDB = [SELECT Role__c, Vehicle__c, Contact__c, Account__c FROM Role__c WHERE Vehicle__c IN :assetIds]; 
        
        Set<String> newRoleKeys = new Set<String>();
        for(Role__c role : roles){
            newRoleKeys.add(role.Vehicle__c + ':' + role.Role__c);
        }
               
        //need to determine which roles correspond to the roles we wish to update (Role__c and Vehicle__c)
        for(Role__c dbrole : existingRolesInDB){
            if(roleStatuses.contains(dbrole.Role__c)){ //if it's a role with a 'previous' value
                String dbRecordKey = dbrole.Vehicle__c + ':' + dbrole.Role__c;
                if(newRoleKeys.contains(dbRecordKey)){ 
                    rolesToUpdate.add(dbrole);
                }
            }
        }

        return rolesToUpdate;
    }

    public List<Role__c> RetrieveRelated(List<Role__c> roles, Set<String> roleStatuses)
    {
        //return all Roles that are related to the Asset(s)
        //Contacts/Accounts not really important unless we want to change all instances where this Contact is the Current Driver of
        //any vehicle where the Current Driver of one vehicle has been updated?
        Set<String> assetIds = SObjectUtilities.GetFieldValues(roles, Role__c.Vehicle__c.getDescribe().getName());
        Set<String> contactIds = SObjectUtilities.GetFieldValues(roles, Role__c.Contact__c.getDescribe().getName());
        Set<String> accountIds = SObjectUtilities.GetFieldValues(roles, Role__c.Account__c.getDescribe().getName());
        
        if(!assetIds.isEmpty()){ //only update Asset Roles for the specific Asset we are interested in
            //String SOQL;
            try { 
                //SOQL = buildDynamicQuery(roleStatuses, assetIds, contactIds, accountIds); 
                List<Role__c> retrievedRoles = buildDynamicQuery(roles, assetIds, contactIds, accountIds, roleStatuses); 
                //List<Role__c> retrievedRoles = Database.query(SOQL); 
                return retrievedRoles;
            } catch (Exception ex) {
                String SOQL = 'SELECT Role__c, Vehicle__c, Contact__c, Account__c FROM Role__c WHERE Vehicle__c IN (';
                List<String> tmp = new List<String>();
                tmp.addAll(assetIds);
                SOQL += String.join(tmp, ',') + ')';
                EmailUtility.SendEmail(new List<String>{ System.label.Debug_EmailAddress_JLR }, 'RelatedRoleRetriever Exception', 'RelatedRoleRetriever.cls Exception - ' + system.now() + ' - ' + UserInfo.getUserName(),'<pre>'+ex.getMessage()+'</pre><hr/><pre>'+json.serializePretty(String.ValueOf(ex))+'</pre><hr/><pre>SOQL: '+SOQL+'</pre>');
                return new List<Role__c>();
            }
        
        }
        
        return new List<Role__c>();

    }

}