@isTest
public class CSVUpload_RowValidator_T {
    static testMethod void Validate_DoesNothing_GivenEmptyCollection()
  {
    CSVUpload_RowValidator validator = new CSVUpload_RowValidator(new List<File_Upload_Field_Mapping__c>());

    CSVDataCollection dataCollection = CreateEmptyCollection();


    validator.Validate(dataCollection);


    System.assert(true);
  }

  static testMethod void Validate_DoesNotSetRowStatusToHasFailed_GivenMandatoryFieldPresent()
  {
    Integer column1Index = 0;
    String column1Header = 'c1';
    Integer rowIndex1 = 1;

        List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c>();
    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
        Is_Mandatory__c = true);
    fieldMappings.add(fieldCustomSetting1);

    CSVUpload_RowValidator validator = new CSVUpload_RowValidator(fieldMappings);

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { 'not empty' });
    dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


    validator.Validate(dataCollection);


    System.assertNotEquals(true, dataCollection.LineStatusesByRowIndex.get(rowIndex1).HasErrored);
  }

  static testMethod void Validate_SetsRowStatusToHasFailed_GivenMissingMandatoryField()
  {
    Integer column1Index = 0;
    String column1Header = 'c1';
    Integer rowIndex1 = 1;

    List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c>();
    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
        Is_Mandatory__c = true);
    fieldMappings.add(fieldCustomSetting1);

    CSVUpload_RowValidator validator = new CSVUpload_RowValidator(fieldMappings);

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { '' });
    dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


    validator.Validate(dataCollection);


    System.assert(dataCollection.LineStatusesByRowIndex.get(rowIndex1).HasErrored);
  }

  static testMethod void Validate_SetsRowStatusMessage_GivenMissingMandatoryField()
  {
    Integer column1Index = 0;
    String column1Header = 'c1';
    Integer rowIndex1 = 1;

    List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c>();
    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
        Is_Mandatory__c = true);
    fieldMappings.add(fieldCustomSetting1);

    CSVUpload_RowValidator validator = new CSVUpload_RowValidator(fieldMappings);

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { '' });
    dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


    validator.Validate(dataCollection);


    System.assertEquals(System.Label.Required_Field_Missing + column1Header, 
        dataCollection.LineStatusesByRowIndex.get(rowIndex1).Message);
  }

  static testMethod void Validate_SetsRowStatusToHasFailed_GivenMissingMandatoryColumn()
  {
    Integer column1Index = 0;
    String column1Header = 'c1';
    Integer rowIndex1 = 1;

    List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c>();
    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
        Is_Mandatory__c = true);
    fieldMappings.add(fieldCustomSetting1);

    CSVUpload_RowValidator validator = new CSVUpload_RowValidator(fieldMappings);

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { });


    validator.Validate(dataCollection);


    System.assert(dataCollection.LineStatusesByRowIndex.get(rowIndex1).HasErrored);
  }

  static testMethod void Validate_SetsRowStatusMessage_GivenMissingMandatoryColumn()
  {
    Integer column1Index = 0;
    String column1Header = 'c1';
    Integer rowIndex1 = 1;

    List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c>();
    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
        Is_Mandatory__c = true);
    fieldMappings.add(fieldCustomSetting1);

    CSVUpload_RowValidator validator = new CSVUpload_RowValidator(fieldMappings);

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { });


    validator.Validate(dataCollection);


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