({
	extractCSV: function(component, event, helper) {
        var a = document.createElement("a");
        var dt = "data:text/csv,";
        a.href = "data:text/csv,";
        var opportunityId = component.get("v.recordId");
        var opp = component.get("v.simpleOpp");
		dt += 'Opportunity Id,Opportunity Name,Salutation,Last Name,First Name,Phone,Other Phone,Mobile Phone,Email,Email2,Language,Gender,Account Name,Mailing Street,Mailing City,Mailing State,Mailing Postal Code,Mailing Country,Purchase Type,Jaguar Status,Land Rover Status,Lead Source,Retailer Name,Retailer Primary Code,Retailer Secondary Code,Owner Name,Amount,Budget,Product Model Code,Product Brand,Product Derivative,Quantity\r\n';
        var action = component.get("c.getLineItems");
        action.setParams({oppId : opportunityId});
	   	action.setCallback(this, function(response) {
	    	var state = response.getState();
	        if(state === 'SUCCESS'){
                var oppItems = response.getReturnValue();
                if(oppItems != null){
                    for(var i=0; i<oppItems.length; i++){
                        dt += opp.Id + ',' + opp.Name + ',' + opp.Account.PersonContact.Salutation + ',' + opp.Account.PersonContact.LastName + ',' + opp.Account.PersonContact.FirstName + ',' + opp.Account.Phone + ',' + opp.Account.PersonContact.OtherPhone + ',' + opp.Account.PersonContact.MobilePhone + ',' + opp.Account.PersonContact.Email + ',' + opp.Account.PersonContact.Email2__c + ',' + opp.Account.PersonContact.Language__c + ',' + opp.Account.PersonContact.Gender__c + ',' + opp.Account.Name + ',' + opp.Account.PersonContact.MailingStreet + ',' + opp.Account.PersonContact.MailingCity + ',' + opp.Account.PersonContact.MailingState + ',' + opp.Account.PersonContact.MailingPostalCode +',' + opp.Account.PersonContact.MailingCountry + ',' + opp.Purchase_Type__c + ',' + opp.Account.ntt_Jaguar_Status__c + ',' + opp.Account.ntt_Land_Rover_Status__c + ',' + opp.LeadSource + ',' + opp.Retailer_Name__c + ',' + opp.Retailer_Primary_Code__c + ',' + opp.Retailer_Secondary_Code__c + ',' + opp.Owner.Name + ',' + opp.Amount + ',' + opp.Budget__c;
                        dt += oppItems[i].Product_Model_Code_Hidden__c + ',' + oppItems[i].Product_Brand_Hidden__c + ',' + oppItems[i].Product_Derivative_Hidden__c + ',' + oppItems[i].Quantity;
                        dt += '\r\n';
                    }
                }
                else{
                    dt += opp.Id + ',' + opp.Name + ',' + opp.Account.PersonContact.Salutation + ',' + opp.Account.PersonContact.LastName + ',' + opp.Account.PersonContact.FirstName + ',' + opp.Account.Phone + ',' + opp.Account.PersonContact.OtherPhone + ',' + opp.Account.PersonContact.MobilePhone + ',' + opp.Account.PersonContact.Email + ',' + opp.Account.PersonContact.Email2__c + ',' + opp.Account.PersonContact.Language__c + ',' + opp.Account.PersonContact.Gender__c + ',' + opp.Account.Name + ',' + opp.Account.PersonContact.MailingStreet + ',' + opp.Account.PersonContact.MailingCity + ',' + opp.Account.PersonContact.MailingState + ',' + opp.Account.PersonContact.MailingPostalCode +',' + opp.Account.PersonContact.MailingCountry + ',' + opp.Purchase_Type__c + ',' + opp.Account.ntt_Jaguar_Status__c + ',' + opp.Account.ntt_Land_Rover_Status__c + ',' + opp.LeadSource + ',' + opp.Retailer_Name__c + ',' + opp.Retailer_Primary_Code__c + ',' + opp.Retailer_Secondary_Code__c + ',' + opp.Owner.Name + ',' + opp.Amount + ',' + opp.Budget__c;
                }
                a.href = dt;
	            a.download = opp.Name + '.csv';
    	    	a.click();
	        }
		});
	    $A.enqueueAction(action);
    }
})