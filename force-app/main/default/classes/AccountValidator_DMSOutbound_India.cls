public class AccountValidator_DMSOutbound_India implements I_OpportunityValidator{
    public void Validate(Opportunity opportunity)
    {
        Schema.DescribeFieldResult childRelationship = Schema.sObjectType.Opportunity.fields.AccountId;

        if(opportunity.Account == null)
        { 
            throw new DMSOutbound_InvalidDataException(System.Label.DMSException_OpportunityMissingAccount); 
        }
        if(opportunity.Account.RecordType.DeveloperName != 'Corporate'){ return; }
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account, Schema.sObjectType.Account.fields.Name);
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account, Schema.sObjectType.Account.fields.Phone);
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account, Schema.sObjectType.Account.fields.Site__c);
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account, Schema.sObjectType.Account.fields.RecordTypeId);
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account, new List<Schema.DescribeFieldResult>{Schema.sObjectType.Account.fields.ntt_Jaguar_Status__c, 
            Schema.sObjectType.Account.fields.ntt_Land_Rover_Status__c});
    }
}