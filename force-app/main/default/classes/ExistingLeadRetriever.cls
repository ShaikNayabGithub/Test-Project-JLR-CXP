public class ExistingLeadRetriever {
    public Boolean LeadExists(Request__c requestRecord, Account existingAccount, AvokaFormInformation avokaFormInformation)
    {
        if(requestRecord.Email__c == null){
            return false;
        }
        List<Lead> existingLeads = [SELECT Id, RecordTypeId, Brand__c, Preferred_Retailer__c, Primary_Model_Interest__r.Name,
                                    Primary_Model_Interest__r.Product_Code__c FROM Lead WHERE Email = :requestRecord.Email__c];
        if(existingLeads.Size() > 0) {
            for (Lead leads : existingLeads)
            {
                if(leads.RecordTypeId == avokaFormInformation.RecordType.Id 
                   && leads.Brand__c == avokaFormInformation.Brand.Id
                   && leads.Preferred_Retailer__c == requestRecord.Preferred_Retailer__c
                   && (requestRecord.Primary_Model_Of_Interest_Text__c != null 
                       && ((leads.Primary_Model_Interest__c != null && leads.Primary_Model_Interest__r.Name.contains(requestRecord.Primary_Model_Of_Interest_Text__c))
                       ||(leads.Primary_Model_Interest__c != null && leads.Primary_Model_Interest__r.Product_Code__c != null 
                          && leads.Primary_Model_Interest__r.Product_Code__c.contains(requestRecord.Primary_Model_Of_Interest_Text__c))
                      )
                  ))
                {
                    return true;
                } 
            }   
            
        }
        return false;
    }
}