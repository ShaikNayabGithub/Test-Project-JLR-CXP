public class OpportunityContactRoleBuilder {
   /* public List<OpportunityContactRole> Build(List<Opportunity> opportunityRoleInformation)
    {
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        
        for(Opportunity opportunity : opportunityRoleInformation){
            OpportunityContactRole opportunityContactRole = this.BuildRole(opportunity);
            if(opportunityContactRole.IsPrimary == true){
                opportunityContactRoles.add(opportunityContactRole);
            }
        }
        
        return opportunityContactRoles;
    }
    
    public OpportunityContactRole BuildRole(Opportunity opportunity)
    {
        OpportunityContactRole contactRole = new OpportunityContactRole();
        
        if(opportunity.Account == null || opportunity.Account.PersonContactId == null) { 
            return contactRole; 
        }

        contactRole.OpportunityId = opportunity.Id;
        contactRole.ContactId = opportunity.Account.PersonContactId;
        contactRole.IsPrimary = true;
        contactRole.Role = 'Primary Contact';

        return contactRole;
    } */
}