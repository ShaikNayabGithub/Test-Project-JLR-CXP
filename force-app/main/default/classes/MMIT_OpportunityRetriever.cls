public class MMIT_OpportunityRetriever {
    public List<Opportunity> Retrieve(Set<String> opportunityIds)
    {
        List<Opportunity> oppList = new List<Opportunity>();
        if(opportunityIds != null && opportunityIds.size()>0){
            oppList = [SELECT Id, StageName FROM Opportunity WHERE Id IN: opportunityIds and ((IsWon=TRUE and IsClosed=TRUE) OR IsClosed=FALSE)];
            return oppList;
        }else{
            return oppList;
        }
    }
}