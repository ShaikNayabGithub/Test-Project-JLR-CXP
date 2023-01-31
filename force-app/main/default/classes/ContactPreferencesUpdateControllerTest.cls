@isTest
public class ContactPreferencesUpdateControllerTest {
    
    public static testmethod void getContact() {
        Account secondaryIndvidiual = TestClass_AccountCreator.GenerateCorporateAccount();
        Contact contact = new Contact(LastName = 'test', Email = 'test@test.com', AccountId = secondaryIndvidiual.Id);
        insert contact;
        
        ContactPreferencesUpdateController.getContact(contact.ID);
        ContactPreferencesUpdateController.getContactAccess(contact.ID);
        ContactPreferencesUpdateController.getContactLabelMap('Contact');
        ContactPreferencesUpdateController.saveContact(contact);
        
        contact.Jaguar_SMS_Opt_Out__c = false;
        ContactPreferencesUpdateController.saveContact(contact);
        
    }
}