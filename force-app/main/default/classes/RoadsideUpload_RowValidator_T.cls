@isTest
public class RoadsideUpload_RowValidator_T {
	static testMethod void Validate_DoesNothing_GivenEmptyCollection()
	{
		RoadsideUpload_RowValidator vaidator = new RoadsideUpload_RowValidator();

		CSVDataCollection dataCollection = CreateEmptyCollection();


		vaidator.Validate(dataCollection);


		System.assert(true);
	}

	static testMethod void Validate_DoesNotSetRowStatusToHasFailed_GivenMandatoryFieldPresent()
	{
		RoadsideUpload_RowValidator vaidator = new RoadsideUpload_RowValidator();

		Integer column1Index = 0;
		String column1Header = 'c1';
		Integer rowIndex1 = 1;

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Is_Mandatory__c = true);
		insert fieldCustomSetting1;

		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { 'not empty' });
		dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


		vaidator.Validate(dataCollection);


		System.assertNotEquals(true, dataCollection.LineStatusesByRowIndex.get(rowIndex1).HasErrored);
	}

	static testMethod void Validate_SetsRowStatusToHasFailed_GivenMissingMandatoryField()
	{
		RoadsideUpload_RowValidator vaidator = new RoadsideUpload_RowValidator();

		Integer column1Index = 0;
		String column1Header = 'c1';
		Integer rowIndex1 = 1;

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Is_Mandatory__c = true);
		insert fieldCustomSetting1;

		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { '' });
		dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


		vaidator.Validate(dataCollection);


		System.assert(dataCollection.LineStatusesByRowIndex.get(rowIndex1).HasErrored);
	}

	static testMethod void Validate_SetsRowStatusMessage_GivenMissingMandatoryField()
	{
		RoadsideUpload_RowValidator vaidator = new RoadsideUpload_RowValidator();

		Integer column1Index = 0;
		String column1Header = 'c1';
		Integer rowIndex1 = 1;

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Is_Mandatory__c = true);
		insert fieldCustomSetting1;

		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { '' });
		dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


		vaidator.Validate(dataCollection);


		System.assertEquals(System.Label.Required_Field_Missing + column1Header, 
				dataCollection.LineStatusesByRowIndex.get(rowIndex1).Message);
	}

	static testMethod void Validate_SetsRowStatusToHasFailed_GivenMissingMandatoryColumn()
	{
		RoadsideUpload_RowValidator vaidator = new RoadsideUpload_RowValidator();

		Integer column1Index = 0;
		String column1Header = 'c1';
		Integer rowIndex1 = 1;

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Is_Mandatory__c = true);
		insert fieldCustomSetting1;

		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { });


		vaidator.Validate(dataCollection);


		System.assert(dataCollection.LineStatusesByRowIndex.get(rowIndex1).HasErrored);
	}

	static testMethod void Validate_SetsRowStatusMessage_GivenMissingMandatoryColumn()
	{
		RoadsideUpload_RowValidator vaidator = new RoadsideUpload_RowValidator();

		Integer column1Index = 0;
		String column1Header = 'c1';
		Integer rowIndex1 = 1;

		Roadside_Upload_Field__c fieldCustomSetting1 = new Roadside_Upload_Field__c(Name = column1Header,
				Is_Mandatory__c = true);
		insert fieldCustomSetting1;

		CSVDataCollection dataCollection = CreateEmptyCollection();
		dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { });


		vaidator.Validate(dataCollection);


		System.assertEquals(System.Label.Required_Field_Missing + column1Header, 
				dataCollection.LineStatusesByRowIndex.get(rowIndex1).Message);
	}


	static CSVDataCollection CreateEmptyCollection()
	{
		CSVDataCollection dataCollection = new CSVDataCollection();
		dataCollection.LinesByRowIndex = new Map<Integer, List<String>>();
		dataCollection.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();
		dataCollection.ColumnIndexesByFieldName = new Map<String, Integer>();

		return dataCollection;
	}
}