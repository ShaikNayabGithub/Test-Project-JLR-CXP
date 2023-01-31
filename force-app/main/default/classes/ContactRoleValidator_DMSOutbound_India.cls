public class ContactRoleValidator_DMSOutbound_India implements I_OpportunityValidator{
    public void Validate(Opportunity opportunity)
    {
    	if(opportunity.OpportunityContactRoles.Size() < 1)
    	{ 
    		throw new DMSOutbound_InvalidDataException(System.Label.DMSException_OpportunityMissingContact); 
		}

		DMS_FieldPopulatedValidator.CheckField(opportunity.OpportunityContactRoles[0].Contact, Schema.sObjectType.Contact.fields.LastName);
		DMS_FieldPopulatedValidator.CheckField(opportunity.OpportunityContactRoles[0].Contact, Schema.sObjectType.Contact.fields.FirstName);
		DMS_FieldPopulatedValidator.CheckField(opportunity.OpportunityContactRoles[0].Contact, Schema.sObjectType.Contact.fields.MobilePhone);
    }
}