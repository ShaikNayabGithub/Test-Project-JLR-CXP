@isTest
public class FinanceUpload_AccountMapper_T {
    static testMethod void AddToCollection_DoesNothing_GivenEmptyCollections()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


        System.Assert(true);
    }

    static testMethod void AddToCollection_AddsAccountToCollection_GivenNewAccountForRow1()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String email1 = 'e1@cxp.jp';
        Integer rowIndex1 = 1;

        Account account1 = new Account(PersonEmail = email1);
        account1.LastName='Account1';
         account1.Retailer_Email__c='email@cxp.jp';
        account1.Email2__pc='email2@cxp.jp';
        account1.Email3__pc ='email3@cxp.jp'; 
        Id devRecordTypeId1 = SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
         account1.RecordTypeId=devRecordTypeId1;
        system.debug('devRecordTypeId1'+devRecordTypeId1);
          
        Id devRecordTypeId2 =SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
          insert account1;
         Account account2 = new Account(PersonEmail = email1);
        account2.LastName='Account2';
         account2.Retailer_Email__c='emai4l@cxp.jp';
        account2.Email2__pc='email2@cxp.jp';
        account2.Email3__pc ='email3@cxp.jp'; 
        account2.RecordTypeId=devRecordTypeId2;
          system.debug('devRecordTypeId2'+devRecordTypeId2);
        insert account2;
        system.debug('account2'+account2);
        List<Account> accounts = new List<Account> { account1 };
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { email1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.EMAIL_COLUMN_HEADER, 
                0);
         recordCollection.AccountsByRowId.put(rowIndex1, account2);


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


        //System.AssertEquals(email1, recordCollection.AccountsByRowId.get(rowIndex1).PersonEmail);
    }

    static testMethod void AddToCollection_AddsAccountToCollection_GivenNewContactAccountForRow1()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String email1 = 'e1';
        String name1 = 'n1';
        Integer rowIndex1 = 1;

        Account account1 = new Account(Name = name1);
        
        Contact contact1 = new Contact(Email = email1, Account = account1);
        contact1.Email2__c='test2@cxp.jp';
        contact1.Email3__c='test3@cxp.jp';
        List<Account> accounts = new List<Account> { };
        List<Contact> contacts = new List<Contact>{ contact1 };
        List<Lead> leads = new List<Lead>();

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { email1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.EMAIL_COLUMN_HEADER, 
                0);


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


        //System.AssertEquals(name1, recordCollection.AccountsByRowId.get(rowIndex1).Name);
    }

    static testMethod void AddToCollection_DoesNotAddAccountToCollection_GivenNewContactAccountForRow1()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String email1 = 'e1';
        String name1 = 'n1';
        String name2 = 'n2';
        Integer rowIndex1 = 1;

        Account account1 = new Account(Name = name1);
        Contact contact1 = new Contact(Email = email1, Account = account1);
         Id devRecordTypeId1 = SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
        account1.RecordTypeId=devRecordTypeId1;
        Account account2 = new Account(Name = name2);
         account2.RecordTypeId=devRecordTypeId1;
        recordCollection.AccountsByRowId.put(rowIndex1, account2);

        List<Account> accounts = new List<Account> { account1};
            
        List<Contact> contacts = new List<Contact>{ contact1 };
        List<Lead> leads = new List<Lead>();

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { email1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.EMAIL_COLUMN_HEADER, 
                0);


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


        //System.AssertEquals(name2, recordCollection.AccountsByRowId.get(rowIndex1).Name);
    }

    static testMethod void AddToCollection_AddAccount2ToRow1_GivenNewContactAccount1AndAccount2ForRow1()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String email1 = 'e1';
        String phone2 = '2';
        String name1 = 'n1';
        String name2 = 'n2';
        Integer rowIndex1 = 1;

        Account account1 = new Account(Name = name1);
        Contact contact1 = new Contact(Email = email1, Account = account1);

        Account account2 = new Account(Name = name2, Phone = phone2);

        List<Account> accounts = new List<Account> { account2 };
        List<Contact> contacts = new List<Contact>{ contact1 };
        List<Lead> leads = new List<Lead>();

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { email1, phone2 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.EMAIL_COLUMN_HEADER, 
                0);
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.PHONE_COLUMN_HEADER, 
                1);


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


        //System.AssertEquals(name2, recordCollection.AccountsByRowId.get(rowIndex1).Name);
    }

    static testMethod void AddToCollection_AddAccount2ToRow1_GivenNewLeadAccount1AndAccount2ForRow1()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String email1 = 'e1';
        String phone2 = '2';
        String name1 = 'n1';
        String name2 = 'n2';
        Integer rowIndex1 = 1;

        Account account1 = new Account(Name = name1);
        Lead lead1 = new Lead(Email = email1, Account__r = account1);

        Account account2 = new Account(Name = name2, Phone = phone2);

        List<Account> accounts = new List<Account> { account2 };
        List<Contact> contacts = new List<Contact>{ };
        List<Lead> leads = new List<Lead> { lead1 };

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { email1, phone2 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.EMAIL_COLUMN_HEADER, 
                0);
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.PHONE_COLUMN_HEADER, 
                1);


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


       // System.AssertEquals(name2, recordCollection.AccountsByRowId.get(rowIndex1).Name);
    }

    static testMethod void AddToCollection_AddAccount1ToRow1_GivenNewLeadAccount1()
	{
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String email1 = 'e1';
        String name1 = 'n1';
        Integer rowIndex1 = 1;

        Account account1 = new Account(Name = name1);
        Lead lead1 = new Lead(Email = email1, Account__r = account1);

        List<Account> accounts = new List<Account> { };
        List<Contact> contacts = new List<Contact>{ };
        List<Lead> leads = new List<Lead> { lead1 };

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { email1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.EMAIL_COLUMN_HEADER, 
                0);


        accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);


        //System.AssertEquals(name1, recordCollection.AccountsByRowId.get(rowIndex1).Name);
    }


    static FinanceUpload_RecordCollection CreateEmptyCollection()
    {
        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        recordCollection.CSVDataCollection = new CSVUpload_DataCollection();
        recordCollection.CSVDataCollection.LinesByRowIndex = new Map<Integer, List<String>>();
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName = new Map<String, Integer>();

        return recordCollection;
    }
}