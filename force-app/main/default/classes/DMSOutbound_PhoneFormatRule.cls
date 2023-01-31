public class DMSOutbound_PhoneFormatRule implements I_OpportunityValidator{
	private static final integer minimumNumberLength = 10;

	public void Validate(Opportunity opportunity)
    {
    	string offendingField = '';
    	if(opportunity.Account != null && opportunity.Account.Phone != null && opportunity.Account.Phone.length() < minimumNumberLength){ 
    		offendingField = ' Account.Phone '; }
    	else if(opportunity.OpportunityContactRoles.size() > 0)
    	{
    		if(opportunity.OpportunityContactRoles[0].Contact.MobilePhone != null && opportunity.OpportunityContactRoles[0].Contact.MobilePhone.length() < minimumNumberLength){ 
    			offendingField = ' Contact.MobilePhone '; }
    		else if(opportunity.OpportunityContactRoles[0].Contact.OtherPhone != null && opportunity.OpportunityContactRoles[0].Contact.OtherPhone.length() < minimumNumberLength){ 
    			offendingField = ' Contact.OtherPhone '; }
    	}

    	if(!String.isEmpty(offendingField))
    	{
	    	string exceptionMessage = String.format(System.Label.DMSException_InvalidPhoneLength, new List<String> {offendingField, String.valueOf(minimumNumberLength)});
	    	throw new DMSOutbound_InvalidDataException(exceptionMessage);
	    }
    }
}