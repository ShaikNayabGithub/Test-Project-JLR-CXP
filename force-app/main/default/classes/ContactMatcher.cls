public class ContactMatcher {
    public Contact GetMatchingContact(String lastname, String email, String mobile)
    {
        Contact contact = new Contact();
        if(String.isEmpty(lastname)){ return contact; }

        contact = RetrieveByEmail(lastname, email);        
        if(contact.Id != null){ return contact; }
        
        return RetrieveByMobile(lastname, mobile);
    }
    
    
    private Contact RetrieveByEmail(String lastname, String email)
    {
        if(String.isEmpty(email)){ return new Contact(); }

        List<Contact> contacts = [Select  Id, AccountId, FirstName, LastName, Email, aop_Country__c, Language__c from Contact where Email = :email And LastName = :lastname And RecordType.DeveloperName!='Employee_Contact' LIMIT 1];
        if(contacts.Size() == 0) { return new Contact(); }

        return contacts[0];
    }
    
    
    private Contact RetrieveByMobile(String lastname, String mobile)
    {
        if(String.isEmpty(mobile)){ return new Contact(); }

        List<Contact> contacts = [Select  Id, AccountId, FirstName, LastName, Email, aop_Country__c, Language__c from Contact where MobilePhone = :mobile And LastName = :lastname And RecordType.DeveloperName!='Employee_Contact' LIMIT 1];
        if(contacts.Size() == 0) { return new Contact(); }

        return contacts[0];
    }
}