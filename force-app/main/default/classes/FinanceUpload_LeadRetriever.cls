public class FinanceUpload_LeadRetriever {
    public List<Lead> Retrieve(Set<String> emails, Set<String> phoneNumbers)
    {
        if(emails.Size() == 0 && phoneNumbers.Size() == 0) return new List<Lead>();
        
        return [SELECT Account__r.Id, Email, Email_Address_2__c, Email_Address_3__c, MobilePhone, Other_Phone__c, 
                Phone FROM Lead 
                WHERE Email IN: emails OR Email_Address_2__c IN: emails OR Email_Address_3__c IN: emails
                OR MobilePhone IN: phoneNumbers OR Other_Phone__c IN: phoneNumbers OR Phone IN: phoneNumbers];
    }
}