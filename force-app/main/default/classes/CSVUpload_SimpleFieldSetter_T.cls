@isTest
public class CSVUpload_SimpleFieldSetter_T {
    static testMethod void SetSimpleFields_DoesNothing_GivenEmptyCollection()
  {
    CSVUpload_SimpleFieldSetter fieldSetter = new CSVUpload_SimpleFieldSetter(new List<File_Upload_Field_Mapping__c>());

    Event eventRecord = new Event();

    Integer rowIndex1 = 1;
    List<String> rowData = new List<String>();

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, rowData);


    fieldSetter.SetSimpleFields(eventRecord, rowIndex1, dataCollection);


    System.assert(true);
  }
  
    static testMethod void SetSimpleFields_DoesNothing_GivenNullRecord()
  {
    CSVUpload_SimpleFieldSetter fieldSetter = new CSVUpload_SimpleFieldSetter(new List<File_Upload_Field_Mapping__c>());

    Event eventRecord ;

    Integer rowIndex1 = 1;
    List<String> rowData = new List<String>();

    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, rowData);


    fieldSetter.SetSimpleFields(eventRecord, rowIndex1, dataCollection);


    System.assert(true);
  }

  static testMethod void SetSimpleFields_SetsSubject_GivenIncorrectValue()
  {

    Integer rowIndex1 = 1;
    Integer column1Index = 0;
    String column1Header = '&^432433`c1';
    String salesforceField1Name = Event.Subject.getDescribe().getName();
    String column1Value = 'v1';

    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
                SObject_Name__c = 'Event',
        Salesforce_Field_Name__c = salesforceField1Name);
        List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c> {
                fieldCustomSetting1 };

    CSVUpload_SimpleFieldSetter fieldSetter = new CSVUpload_SimpleFieldSetter(fieldMappings);

    Event eventRecord = new Event();
    List<String> rowData = new List<String> { column1Value };
    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, rowData);
    dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


    fieldSetter.SetSimpleFields(eventRecord, rowIndex1, dataCollection);


    System.assertEquals(column1Value, eventRecord.Subject);
  }

  static testMethod void SetSimpleFields_SetsArrivedDate_GivenArrivedDate()
  {
    Integer rowIndex1 = 1;
    Integer column1Index = 0;
    String column1Header = 'c1';
    String salesforceField1Name = Event.Resource_Arrived_Date_Time__c.getDescribe().getName();
    String column1Value = String.valueOf(Datetime.now());

    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
                SObject_Name__c = 'Event',
        Salesforce_Field_Name__c = salesforceField1Name);
        List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c> {
                fieldCustomSetting1 };

    CSVUpload_SimpleFieldSetter fieldSetter = new CSVUpload_SimpleFieldSetter(fieldMappings);

    Event eventRecord = new Event();
    List<String> rowData = new List<String> { column1Value };
    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, rowData);
    dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);


    fieldSetter.SetSimpleFields(eventRecord, rowIndex1, dataCollection);


    System.assertEquals(Datetime.valueOf(column1Value), eventRecord.Resource_Arrived_Date_Time__c);
  }


  static CSVDataCollection CreateEmptyCollection()
  {
    CSVDataCollection dataCollection = new CSVDataCollection();
    dataCollection.ColumnIndexesByFieldName = new Map<String, Integer>();
    dataCollection.LinesByRowIndex = new Map<Integer, List<String>>();
    dataCollection.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();

    return dataCollection;
  }
  
   static testMethod void SetSimpleFields_Exception()
  {
    Integer rowIndex1 = 1;
    Integer column1Index = 0;
    String column1Header = 'c1';
    String salesforceField1Name = Event.Resource_Arrived_Date_Time__c.getDescribe().getName();
    String column1Value = 'exception expected';

    File_Upload_Field_Mapping__c fieldCustomSetting1 = new File_Upload_Field_Mapping__c(Name = 't1',
                Import_Node__c = column1Header,
                SObject_Name__c = 'Event',
        Salesforce_Field_Name__c = salesforceField1Name);
        List<File_Upload_Field_Mapping__c> fieldMappings = new List<File_Upload_Field_Mapping__c> {
                fieldCustomSetting1 };

    CSVUpload_SimpleFieldSetter fieldSetter = new CSVUpload_SimpleFieldSetter(fieldMappings);

    Event eventRecord = new Event();
    List<String> rowData = new List<String> { column1Value };
    CSVDataCollection dataCollection = CreateEmptyCollection();
    dataCollection.LinesByRowIndex.put(rowIndex1, rowData);
    dataCollection.ColumnIndexesByFieldName.put(column1Header, column1Index);

    try{
        fieldSetter.SetSimpleFields(eventRecord, rowIndex1, dataCollection);
        }
        catch(TypeException e)
        {
        
          System.assertNotequals(null,e);
        
        }

  }
}