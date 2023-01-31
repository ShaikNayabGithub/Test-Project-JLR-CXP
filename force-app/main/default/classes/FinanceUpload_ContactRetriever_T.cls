@isTest
public class FinanceUpload_ContactRetriever_T {
    static testMethod void RemoveContactDetailsFromSets_DoesNothing_GivenEmptyCollections()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        Set<String> emails = new Set<String>();
        Set<String> phoneNumbers = new Set<String>();
        List<Contact> contacts = new List<Contact>();


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(true);
    }

    static testMethod void RemoveContactDetailsFromSets_DoesNothing_GivenContactWithEmail1()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>();
        Set<String> phoneNumbers = new Set<String>();
        List<Contact> contacts = new List<Contact>{ new Contact(Email = email1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(true);
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesEmail1FromEmails_GivenContactWithEmail1AsEmail()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>{ email1 };
        Set<String> phoneNumbers = new Set<String>();
        List<Contact> contacts = new List<Contact>{ new Contact(Email = email1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!emails.Contains(email1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesEmail1FromEmails_GivenContactWithEmail1AsEmail2()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>{ email1 };
        Set<String> phoneNumbers = new Set<String>();
        List<Contact> contacts = new List<Contact>{ new Contact(Email2__c = email1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!emails.Contains(email1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesEmail1FromEmails_GivenContactWithEmail1AsEmail3()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>{ email1 };
        Set<String> phoneNumbers = new Set<String>();
        List<Contact> contacts = new List<Contact>{ new Contact(Email3__c = email1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!emails.Contains(email1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenContactWithPhone1AsHomePhone()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Contact> contacts = new List<Contact>{ new Contact(HomePhone = phone1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenContactWithPhone1AsMobilePhone()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Contact> contacts = new List<Contact>{ new Contact(MobilePhone = phone1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenContactWithPhone1AsOtherPhone()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Contact> contacts = new List<Contact>{ new Contact(OtherPhone = phone1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenContactWithPhone1AsPhone()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Contact> contacts = new List<Contact>{ new Contact(Phone = phone1) };


        contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }
    
     static testMethod void RetrieveContactDetailsFromSets_RetrieveFromPhoneNumbers_GivenContactWithPhone1AsPhone()
    {
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();

        Contact contact = new Contact();
        contact.phone='343434';
        contact.lastName='test';
        
        insert contact;
        
        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { contact.phone};
  

        List<Contact> listContacts=contactRetriever.retrieve(emails, phoneNumbers);
        
        System.AssertNotequals(listContacts,null);
        System.assertNotequals(listContacts.size(),0);
        
    }
}