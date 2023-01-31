public class SetRetailerForRetailerContact {
    private static final RecordType retailerContactRecordType = [Select Id From RecordType Where DeveloperName='Retailer_Contact' And SObjectType = 'Contact'];

    public void SetRetailer(List<Contact> contacts)
    {
        
        // Get required variables
        //List<Contact> contactsQuery = [SELECT Id, Owner.Contact.AccountId, Owner.Id, Owner.UserType, Retailer__c, RecordTypeId FROM Contact WHERE Id IN :contacts limit 1];
        List<Contact> contactsQuery = [SELECT Id, Account.owner.Contact.AccountId, Account.ownerId, Account.owner.UserType, Retailer__c, RecordTypeId FROM Contact WHERE Id IN :contacts limit 1];
        
        // check the owner is a retailer PC user and contact is a Retailer Contact, otherwise exit
        if(contactsQuery.size() != 1  || contactsQuery[0].Account.ownerId== NULL || contactsQuery[0].Account.owner.UserType!='PowerPartner' || contactsQuery[0].RecordTypeId != retailerContactRecordType.Id) {
            return;
        }
        
        Contact contactToUpdate = new Contact(Id = contactsQuery[0].Id);
        contactToUpdate.Retailer__c = contactsQuery[0].Account.owner.Contact.AccountId;
        
        update contactToUpdate;
        
    }
    
}