@isTest
public class FinanceUpload_AccountRetriever_T {
    static testMethod void RemoveContactDetailsFromSets_DoesNothing_GivenEmptyCollections()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        Set<String> emails = new Set<String>();
        Set<String> phoneNumbers = new Set<String>();
        List<Account> accounts = new List<Account>();


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(true);
    }

    static testMethod void RemoveContactDetailsFromSets_DoesNothing_GivenAccountWithEmail1AsPersonEmail()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>();
        Set<String> phoneNumbers = new Set<String>();
        List<Account> accounts = new List<Account>{ new Account(PersonEmail = email1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(true);
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesEmail1FromEmails_GivenAccountWithEmail1AsPersonEmail()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>{ email1 };
        Set<String> phoneNumbers = new Set<String>();
        List<Account> accounts = new List<Account>{ new Account(PersonEmail = email1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!emails.Contains(email1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesEmail1FromEmails_GivenAccountWithEmail1AsEmail2()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>{ email1 };
        Set<String> phoneNumbers = new Set<String>();
        List<Account> accounts = new List<Account>{ new Account(Email2__pc = email1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!emails.Contains(email1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesEmail1FromEmails_GivenAccountWithEmail1AsEmail3()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String email1 = 'e1';

        Set<String> emails = new Set<String>{ email1 };
        Set<String> phoneNumbers = new Set<String>();
        List<Account> accounts = new List<Account>{ new Account(Email3__pc = email1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!emails.Contains(email1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenAccountWithPhone1AsHomePhone()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Account> accounts = new List<Account>{ new Account(PersonHomePhone = phone1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenAccountWithPhone1AsMobilePhone()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Account> accounts = new List<Account>{ new Account(PersonMobilePhone = phone1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenAccountWithPhone1AsOtherPhone()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Account> accounts = new List<Account>{ new Account(PersonOtherPhone = phone1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }

    static testMethod void RemoveContactDetailsFromSets_RemovesPhone1FromPhoneNumbers_GivenAccountWithPhone1AsPhone()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String phone1 = '1';

        Set<String> emails = new Set<String>{ };
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Account> accounts = new List<Account>{ new Account(Phone = phone1) };


        accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);


        System.Assert(!phoneNumbers.Contains(phone1));
    }
    
     static testMethod void Retrieve()
    {
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();

        String phone1 = '1';
        String lastName = 'Test1';

        Set<String> legalentityIds= new Set<String>{ };
        Set<String> emails = new Set<String>{ };
        Set<String> lastnameSet = new Set<String>{lastName};
        Set<String> phoneNumbers = new Set<String> { phone1 };
        List<Account> accounts = accountRetriever.retrieve(lastnameSet,emails, phoneNumbers,legalentityIds);
        
        System.assertNotEquals(accounts,null);
       
    }
}