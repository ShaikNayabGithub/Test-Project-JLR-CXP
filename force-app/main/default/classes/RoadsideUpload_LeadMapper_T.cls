@isTest
public class RoadsideUpload_LeadMapper_T {
	static testMethod void AddToCollection_DoesNothing_GivenNoData()
	{
		RoadsideUpload_LeadMapper leadMapper = new RoadsideUpload_LeadMapper();

		List<Lead> leads = new List<Lead>();
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		leadMapper.AddToCollection(leads, recordCollection);


		System.assert(true);
	}

	static testMethod void AddToCollection_AddsLeadToLeadsByPhoneByPhone1_GivenLeadWithPhone1()
	{
		RoadsideUpload_LeadMapper leadMapper = new RoadsideUpload_LeadMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Lead lead1 = new Lead(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email_Address_2__c = email2);
		List<Lead> leads = new List<Lead> { lead1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		leadMapper.AddToCollection(leads, recordCollection);


		System.assertEquals(lead1.Name, recordCollection.LeadsByPhoneNumber.get(phone1).Name);
	}

	static testMethod void AddToCollection_AddsLeadToLeadByPhoneByPhone2_GivenLeadWithPhone2()
	{
		RoadsideUpload_LeadMapper leadMapper = new RoadsideUpload_LeadMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Lead lead1 = new Lead(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email_Address_2__c = email2);
		List<Lead> leads = new List<Lead> { lead1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		leadMapper.AddToCollection(leads, recordCollection);


		System.assertEquals(lead1.Name, recordCollection.LeadsByPhoneNumber.get(phone2).Name);
	}

	static testMethod void AddToCollection_AddsLeadToLeadByEmailByEmail1_GivenLeadWithEmail1()
	{
		RoadsideUpload_LeadMapper leadMapper = new RoadsideUpload_LeadMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Lead lead1 = new Lead(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email_Address_2__c = email2);
		List<Lead> leads = new List<Lead> { lead1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		leadMapper.AddToCollection(leads, recordCollection);


		System.assertEquals(lead1.Name, recordCollection.LeadsByEmail.get(email1).Name);
	}

	static testMethod void AddToCollection_AddsLeadToLeadByEmailByEmail2_GivenLeadWithEmail2()
	{
		RoadsideUpload_LeadMapper leadMapper = new RoadsideUpload_LeadMapper();

		String phone1 = '1';
		String phone2 = '2';
		String email1 = 'e1';
		String email2 = 'e2';

		Lead lead1 = new Lead(FirstName = 'fn1', Phone = phone1, Email = email1, MobilePhone = phone2,
				Email_Address_2__c = email2);
		List<Lead> leads = new List<Lead> { lead1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		leadMapper.AddToCollection(leads, recordCollection);


		System.assertEquals(lead1.Name, recordCollection.LeadsByEmail.get(email2).Name);
	}


	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.LeadsByPhoneNumber = new Map<String, Lead>();
		recordCollection.LeadsByEmail = new Map<String, Lead>();

		return recordCollection;
	}
}