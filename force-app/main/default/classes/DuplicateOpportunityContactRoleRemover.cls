public class DuplicateOpportunityContactRoleRemover {
    public void DeleteDuplicateContactRoles(List<Lead> leads)
    {
        Set<String> opportunityIds = SObjectUtilities.GetFieldValues(leads, Lead.ConvertedOpportunityId.getDescribe().getName());
        List<Opportunity> opportunities = [Select (Select Id From OpportunityContactRoles) From Opportunity Where Id In:opportunityIds];
        
        List<OpportunityContactRole> rolesForDeletion = new List<OpportunityContactRole>();
        
        for(Opportunity opportunity : opportunities)
        {
            for(integer i = 1; i < opportunity.OpportunityContactRoles.size(); i++){
                rolesForDeletion.add(opportunity.OpportunityContactRoles[i]);
            }
        }
        
        delete rolesForDeletion;
        if(rolesForDeletion.Size() > 0) {
            Database.emptyRecycleBin(rolesForDeletion);
        }
    }
}