public class OpportunityContactRoleCreator {
    //private final OpportunityContactRoleBuilder opportunityContactRoleBuilder;
    
    /*
public OpportunityContactRoleCreator(OpportunityContactRoleBuilder opportunityContactRoleBuilder)
{
this.opportunityContactRoleBuilder = opportunityContactRoleBuilder;
} */
     
    @future
    public static void Create(String jsonStr)
    {
        List<Opportunity> opportunities = (List<Opportunity>)json.deserialize(jsonStr, List<Opportunity>.class);
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(opportunities);
       // List<Opportunity> opportunityRoleInformation = [Select Account.PersonContactId From Opportunity Where Id In:opportunityMap.keySet()];
        
        List<OpportunityContactRole> contactRoleList = [select id from OpportunityContactRole where Opportunityid in:opportunityMap.keySet()];
        system.debug('--> '+json.serialize(contactRoleList));
        if(contactRoleList != null && !contactRoleList.isEmpty()){
            OpportunityContactRole contactRole = contactRoleList.get(0);
            contactRole.Role = 'Primary Contact';
            update contactRole;
        }
        
    }
}