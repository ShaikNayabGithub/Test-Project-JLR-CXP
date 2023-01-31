@isTest
public class RoadsideUpload_ContactMapper_T {
	static testMethod void AddToCollection_DoesNothing_GivenNoData()
	{
		RoadsideUpload_ContactMapper contactMapper = new RoadsideUpload_ContactMapper();

		List<Contact> contacts = new List<Contact>();
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		contactMapper.AddToCollection(contacts, recordCollection);


		System.assert(true);
	}

	static testMethod void AddToCollection_AddsContactToContactByPhoneByPhone1_GivenContactWithPhone1()
	{
		RoadsideUpload_ContactMapper contactMapper = new RoadsideUpload_ContactMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Contact contact1 = new Contact(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email2__c = email2);
		List<Contact> contacts = new List<Contact> { contact1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		contactMapper.AddToCollection(contacts, recordCollection);


		System.assertEquals(contact1.Name, recordCollection.ContactsByPhoneNumber.get(phone1).Name);
	}

	static testMethod void AddToCollection_AddsContactToContactByPhoneByPhone2_GivenContactWithPhone2()
	{
		RoadsideUpload_ContactMapper contactMapper = new RoadsideUpload_ContactMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Contact contact1 = new Contact(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email2__c = email2);
		List<Contact> contacts = new List<Contact> { contact1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		contactMapper.AddToCollection(contacts, recordCollection);


		System.assertEquals(contact1.Name, recordCollection.ContactsByPhoneNumber.get(phone2).Name);
	}

	static testMethod void AddToCollection_AddsContactToContactByEmailByEmail1_GivenContactWithEmail1()
	{
		RoadsideUpload_ContactMapper contactMapper = new RoadsideUpload_ContactMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Contact contact1 = new Contact(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email2__c = email2);
		List<Contact> contacts = new List<Contact> { contact1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		contactMapper.AddToCollection(contacts, recordCollection);


		System.assertEquals(contact1.Name, recordCollection.ContactsByEmail.get(email1).Name);
	}

	static testMethod void AddToCollection_AddsContactToContactByEmailByEmail2_GivenContactWithEmail2()
	{
		RoadsideUpload_ContactMapper contactMapper = new RoadsideUpload_ContactMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Contact contact1 = new Contact(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email2__c = email2);
		List<Contact> contacts = new List<Contact> { contact1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		contactMapper.AddToCollection(contacts, recordCollection);


		System.assertEquals(contact1.Name, recordCollection.ContactsByEmail.get(email2).Name);
	}


	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.ContactsByPhoneNumber = new Map<String, Contact>();
		recordCollection.ContactsByEmail = new Map<String, Contact>();

		return recordCollection;
	}
}