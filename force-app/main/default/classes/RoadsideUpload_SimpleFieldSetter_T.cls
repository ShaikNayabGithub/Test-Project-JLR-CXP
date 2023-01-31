@isTest
public class RoadsideUpload_SimpleFieldSetter_T {
	static testMethod void SetSimpleFields_DoesNothing_GivenEmptyCollection()
	{
		RoadsideUpload_SimpleFieldSetter fieldSetter = new RoadsideUpload_SimpleFieldSetter();

		Event eventRecord = new Event();
		List<String> rowData = new List<String>();
		CSVDataCollection dataCollection = CreateEmptyCollection();


		fieldSetter.SetSimpleFields(eventRecord, rowData, dataCollection);


		System.assert(true);
	}

	static testMethod void SetSimpleFields_SetsSubject_GivenSubject()
	{
		RoadsideUpload_SimpleFieldSetter fieldSetter = new RoadsideUpload_SimpleFieldSetter();

		Integer rowIndex1 = 1;
		Integer column1Index = 0;
		String column1Header = 'c1';
		String salesforceField1Name = Event.Subject.getDescribe().getName();
		String column1Value = 'v1';

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Salesforce_Field_Name__c = salesforceField1Name);
		insert fieldCustomSetting1;

		Event eventRecord = new Event();
		List<String> rowData = new List<String> { column1Value };
		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


		fieldSetter.SetSimpleFields(eventRecord, rowData, dataCollection);


		System.assertEquals(column1Value, eventRecord.Subject);
	}

	static testMethod void SetSimpleFields_SetsArrivedDate_GivenArrivedDate()
	{
		RoadsideUpload_SimpleFieldSetter fieldSetter = new RoadsideUpload_SimpleFieldSetter();

		Integer rowIndex1 = 1;
		Integer column1Index = 0;
		String column1Header = 'c1';
		String salesforceField1Name = Event.Resource_Arrived_Date_Time__c.getDescribe().getName();
		String column1Value = String.valueOf(Datetime.now());

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Salesforce_Field_Name__c = salesforceField1Name);
		insert fieldCustomSetting1;

		Event eventRecord = new Event();
		List<String> rowData = new List<String> { column1Value };
		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


		fieldSetter.SetSimpleFields(eventRecord, rowData, dataCollection);


		System.assertEquals(Datetime.valueOf(column1Value), eventRecord.Resource_Arrived_Date_Time__c);
	}


	static CSVDataCollection CreateEmptyCollection()
	{
		CSVDataCollection dataCollection = new CSVDataCollection();
		dataCollection.ColumnIndexesByFieldName = new Map<String, Integer>();

		return dataCollection;
	}
}