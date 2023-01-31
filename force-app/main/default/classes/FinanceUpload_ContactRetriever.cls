public class FinanceUpload_ContactRetriever {
    public List<Contact> Retrieve(Set<String> emails, Set<String> phoneNumbers)
    {
        if(emails.Size() == 0 && phoneNumbers.Size() == 0) return new List<Contact>();
        
        if(emails.size()>0)
            return findDuplicates([SELECT Account.Id, Email, Email2__c, Email3__c, HomePhone, MobilePhone,
                OtherPhone, Phone,AssistantPhone FROM Contact 
                WHERE (Email IN: emails OR Email2__c IN: emails OR Email3__c IN: emails)               
                AND RecordTypeId !=: SObjectUtilities.RecordTypes.get('Contact').get('Employee_Contact').Id]);
        else
        return findDuplicates([SELECT Account.Id, Email, Email2__c, Email3__c, HomePhone, MobilePhone,
                OtherPhone, Phone,AssistantPhone FROM Contact 
                WHERE (HomePhone IN: phoneNumbers OR MobilePhone IN: phoneNumbers 
                OR OtherPhone IN: phoneNumbers OR Phone IN: phoneNumbers or AssistantPhone IN: phoneNumbers)
                AND RecordTypeId !=: SObjectUtilities.RecordTypes.get('Contact').get('Employee_Contact').Id]);            
    }
    
     public list<Contact> findDuplicates(List<Contact> listContacts){
  
     contact a;
     Map<ID,contact>duplicatesRemoved=new Map<ID,contact>(listContacts);
     Set<id> removedIds=new Set<Id>();
     
        System.debug('before removing duplicates: '+listContacts);
        for(integer i=0;i<listContacts.size();i++){

            a=listContacts[i];
            
            for(contact a2:listContacts){
            
                if(!String.isBlank(a2.Email)    && a2.email==a.email|| !String.isBlank(a2.AssistantPhone) && a2.assistantPhone==a.AssistantPhone ||
                !String.isBlank(a2.homePhone)  && a2.otherphone ==a.homePhone||
                !String.isBlank(a2.mobilephone) && a2.otherphone==a2.mobilephone ||
                !String.isBlank(a2.OtherPhone)  && a2.otherphone ==a.OtherPhone ||
                !String.isBlank(a2.homephone)   && a2.homePhone ==a.homephone ||
                !String.isBlank(a2.mobilephone) && a2.mobilePhone==a.mobilephone ||
                !String.isBlank(a2.email2__c) && a2.Email2__c==a.Email2__c||
                !String.isBlank(a2.Email3__c) && a2.email3__c==a.Email3__c )
                    if(a2.accountid!=a.accountid)
                        duplicatesRemoved.remove(a.id);              
            }
        }
   
       System.debug('after removing duplicates: '+ duplicatesRemoved.values());  
     return duplicatesRemoved.values();   
    }

    public void RemoveContactDetailsFromSets(Set<String> emails, Set<String> phoneNumbers, List<Contact> contacts)
    {
        for(Contact contact : contacts) {
            if(String.IsNotEmpty(contact.Email)) {
                emails.Remove(contact.Email);
            }
            if(String.IsNotEmpty(contact.Email2__c)) {
                emails.Remove(contact.Email2__c);
            }
            if(String.IsNotEmpty(contact.Email3__c)) {
                emails.Remove(contact.Email3__c);
            }
            if(String.IsNotEmpty(contact.HomePhone)) {
                phoneNumbers.Remove(contact.HomePhone);
            }
            if(String.IsNotEmpty(contact.MobilePhone)) {
                phoneNumbers.Remove(contact.MobilePhone);
            }
            if(String.IsNotEmpty(contact.OtherPhone)) {
                phoneNumbers.Remove(contact.OtherPhone);
            }
            if(String.IsNotEmpty(contact.Phone)) {
                phoneNumbers.Remove(contact.Phone);
            }
        }
    }
}