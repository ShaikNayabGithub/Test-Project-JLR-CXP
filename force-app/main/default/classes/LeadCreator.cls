public class LeadCreator {
    private final LeadBuilder leadBuilder;

    public LeadCreator(LeadBuilder leadBuilder)
    {
        this.leadBuilder = leadBuilder;
    }

    public void Create(Request__c requestRecord, Account existingAccount, AvokaFormInformation avokaFormInformation)  
    {
        Lead newLead = leadBuilder.Build(requestRecord, existingAccount, avokaFormInformation);
        
        try
        {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            Database.SaveResult sr = Database.insert(newLead, dml);
            if(requestRecord.Campaign__c != null){ 
                insert new CampaignMember (campaignid=requestRecord.Campaign__c, leadid=newLead.id);
            }
        }
        catch(DmlException e)
        {
            requestRecord.addError(System.Label.Invalid_Request + ': ' + e.getMessage());
        }
    } 
}