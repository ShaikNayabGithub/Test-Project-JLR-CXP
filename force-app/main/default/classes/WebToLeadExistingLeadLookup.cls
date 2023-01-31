public class WebToLeadExistingLeadLookup {
	
	private static final String WEBSOURCE = System.Label.WebToLead_LeadSource;

	public void CheckAllWebLeads(List<Lead> allLeads){
		for(Lead l : allLeads){
			if(IsWebToLead(l)){
				CheckNewLead(l);
			}
		}
	}
	
	public Account getExistingAccount(Lead newLead){
		Account existingAccount = null;
		if(String.IsBlank(newLead.LastName)){
			return existingAccount;
		}
		if(String.IsBlank(newLead.Email) && String.IsBlank(newLead.MobilePhone)){
			return existingAccount;
		}
		List<Contact> contacts = [SELECT AccountId FROM Contact WHERE
		                          LastName = :newLead.LastName AND
		                          ((Email = :newLead.Email AND Email != null)  OR
		                          (MobilePhone = :newLead.MobilePhone AND MobilePhone != null)) AND
		                          RecordType.DeveloperName != 'Employee_Contact' LIMIT 1];
        if(contacts.size() > 0){
        	existingAccount = new Account(Id=contacts[0].AccountId);
        }
        return existingAccount;
	}
	
	public boolean LeadExists(Lead newLead){
        integer leadMatchingtime = integer.valueof(Label.Lead_Matching_Time);
        DateTime dt = System.Now().addHours(-leadMatchingtime);
        List<Lead> existingLeads = [SELECT Id FROM Lead WHERE 
                				    LastName = :newLead.LastName AND
                				    Email = :newLead.Email AND
                				    RecordTypeId = :newLead.RecordTypeId AND
                				    Brand__c = :newLead.Brand__c AND
                				    Primary_Model_Interest__c = :newLead.Primary_Model_Interest__c AND
                					Preferred_Retailer__c = :newLead.Preferred_Retailer__c
                                    AND createddate >=:dt];
        if(existingLeads.size() > 0){
        	return true;
        }
        return false;
	}

    public void CheckNewLead(Lead leadToCheck){
        if(LeadExists(leadToCheck)){
        	//leadToCheck.addError('Lead already exists');
        	leadToCheck.Status = 'Lost';
            leadToCheck.Lost_Reason__c = 'Duplicate Lead';
            leadToCheck.Lost_Reason_Others__c = 'Weblead Dupe';
            leadToCheck.Lead_Lost__c = true;
        }
        else{
        	Account existingAccount = getExistingAccount(leadToCheck);
	        if(existingAccount != null){
    	    	leadToCheck.Account__c = existingAccount.Id;
        	}
        }
    }
    
    public boolean IsWebToLead(Lead checkLead){
    	return String.IsNotBlank(checkLead.LeadSource) && checkLead.LeadSource.equalsIgnoreCase(WEBSOURCE) && String.IsNotBlank(checkLead.Mapping_Brand__c);
    }

}