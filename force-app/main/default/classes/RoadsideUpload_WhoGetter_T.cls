@isTest
public class RoadsideUpload_WhoGetter_T {
    static testMethod void GetWho_ReturnsNull_GivenEmptyCollections()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        List<String> rowData = new List<String>();
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(null, result);
    }

    static testMethod void GetWho_ReturnsContact1_GivenEmail1AndContact1()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        String email1 = 'e1';
        Integer emailColumnIndex = 0;
        Contact contact1 = new Contact(FirstName = 'c1');

        List<String> rowData = new List<String> { email1 };
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.ContactsByEmail.put(email1, contact1);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.EMAIL_COLUMN_HEADER, 
                emailColumnIndex);


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(contact1.FirstName, ((Contact)result).FirstName);
    }

    static testMethod void GetWho_ReturnsContact1_GivenPhone1AndContact1()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        String phone1 = 'p1';
        Integer phoneColumnIndex = 0;
        Contact contact1 = new Contact(FirstName = 'c1');

        List<String> rowData = new List<String> { phone1 };
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.ContactsByPhoneNumber.put(phone1, contact1);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.PHONE_COLUMN_HEADER, 
                phoneColumnIndex);


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(contact1.FirstName, ((Contact)result).FirstName);
    }

    static testMethod void GetWho_ReturnsLead1_GivenEmail1AndLead1()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        String email1 = 'e1';
        Integer emailColumnIndex = 0;
        Lead lead1 = new Lead(FirstName = 'l1');

        List<String> rowData = new List<String> { email1 };
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.LeadsByEmail.put(email1, lead1);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.EMAIL_COLUMN_HEADER, 
                emailColumnIndex);


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(lead1.FirstName, ((Lead)result).FirstName);
    }

    static testMethod void GetWho_ReturnsLead1_GivenPhone1AndLead1()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        String phone1 = 'p1';
        Integer phoneColumnIndex = 0;
        Lead lead1 = new Lead(FirstName = 'l1');

        List<String> rowData = new List<String> { phone1 };
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.LeadsByPhoneNumber.put(phone1, lead1);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.PHONE_COLUMN_HEADER, 
                phoneColumnIndex);


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(lead1.FirstName, ((Lead)result).FirstName);
    }

    static testMethod void GetWho_ReturnsContact1_GivenContact1AndLead1WithEmail1()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        String email1 = 'e1';
        Integer emailColumnIndex = 0;
        Contact contact1 = new Contact(FirstName = 'c1');
        Lead lead1 = new Lead(FirstName = 'l1');

        List<String> rowData = new List<String> { email1 };
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.ContactsByEmail.put(email1, contact1);
        recordCollection.LeadsByEmail.put(email1, lead1);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.EMAIL_COLUMN_HEADER, 
                emailColumnIndex);


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(contact1.FirstName, ((Contact)result).FirstName);
    }

    static testMethod void GetWho_ReturnsContact1_GivenContact1WithEmail1AndContact2WithPhone1()
	{
        RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();

        String email1 = 'e1';
        Integer emailColumnIndex = 0;
        String phone1 = 'p1';
        Integer phoneColumnIndex = 1;
        Contact contact1 = new Contact(FirstName = 'c1');
        Contact contact2 = new Contact(FirstName = 'c2');

        List<String> rowData = new List<String> { email1, phone1 };
        RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.ContactsByEmail.put(email1, contact1);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.EMAIL_COLUMN_HEADER, 
                emailColumnIndex);
        recordCollection.ContactsByPhoneNumber.put(phone1, contact2);
        recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.PHONE_COLUMN_HEADER, 
                phoneColumnIndex);


        SObject result = whoGetter.GetWho(rowData, recordCollection);


        System.assertEquals(contact1.FirstName, ((Contact)result).FirstName);
    }


    static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();

		recordCollection.ContactsByPhoneNumber = new Map<String, Contact>();
        recordCollection.ContactsByEmail = new Map<String, Contact>();
        recordCollection.LeadsByPhoneNumber = new Map<String, Lead>();
        recordCollection.LeadsByEmail = new Map<String, Lead>();

		recordCollection.CSVData = new CSVDataCollection();
        recordCollection.CSVData.ColumnIndexesByFieldName = new Map<String, Integer>();

		return recordCollection;
	}
}