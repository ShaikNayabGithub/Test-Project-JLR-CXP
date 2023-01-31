@isTest
public class CSVDataCollectionUtilities_T {
    static testMethod void GetUniqueValues_ReturnsEmptySet_GivenNotFoundField()
	{
        String fieldName = 'test';

        CSVDataCollection csvData = BuildEmptyCollection();


        Set<String> result = CSVDataCollectionUtilities.GetUniqueValues(fieldName, csvData);


        System.assertEquals(0, result.Size());
    }

    static testMethod void GetUniqueValues_ReturnsEmptySet_GivenEmptyCollection()
	{
        String field1Name = 'test';
        Integer field1Index = 0;

        CSVDataCollection csvData = BuildEmptyCollection();
        csvData.ColumnIndexesByFieldName.put(field1Name, field1Index);


        Set<String> result = CSVDataCollectionUtilities.GetUniqueValues(field1Name, csvData);


        System.assertEquals(0, result.Size());
    }

    static testMethod void GetUniqueValues_ReturnsValue1_GivenV1InField1AndField1()
	{
        String field1Name = 'f1';
        String value1 = 'v1';
        Integer field1Index = 0;

        List<String> row1Data = new List<String> { value1 };

        CSVDataCollection csvData = BuildEmptyCollection();
        csvData.ColumnIndexesByFieldName.put(field1Name, field1Index);
        csvData.LinesByRowIndex.put(0, row1Data);


        Set<String> result = CSVDataCollectionUtilities.GetUniqueValues(field1Name, csvData);


        System.assert(result.Contains(value1));
    }

    static testMethod void GetUniqueValues_ReturnsValue2_GivenV1AndV2InField1AndField1()
	{
        String field1Name = 'f1';
        String value1 = 'v1';
        String value2 = 'v2';
        Integer field1Index = 0;

        List<String> row1Data = new List<String> { value1 };
        List<String> row2Data = new List<String> { value2 };

        CSVDataCollection csvData = BuildEmptyCollection();
        csvData.ColumnIndexesByFieldName.put(field1Name, field1Index);
        csvData.LinesByRowIndex.put(0, row1Data);
        csvData.LinesByRowIndex.put(1, row2Data);


        Set<String> result = CSVDataCollectionUtilities.GetUniqueValues(field1Name, csvData);


        System.assert(result.Contains(value2));
    }


    static testMethod void GetColumnValue_ReturnsNull_GivenColumnNotFound()
	{
        CSVDataCollection dataCollection = BuildEmptyCollection();
		String column1Header = 'c1';
        List<String> rowData = new List<String>();


        String result = CSVDataCollectionUtilities.GetColumnValue(dataCollection, column1Header, rowData);


        System.assertEquals(null, result);
    }

    static testMethod void GetColumnValue_ReturnsEmptyString_GivenColumnNotPopulated()
	{
		String column1Header = 'c1';
        Integer field1Index = 0;
        List<String> rowData = new List<String>{ '' };

        CSVDataCollection dataCollection = BuildEmptyCollection();
        dataCollection.ColumnIndexesByFieldName.put(column1Header, field1Index);


        String result = CSVDataCollectionUtilities.GetColumnValue(dataCollection, column1Header, rowData);


        System.assertEquals('', result);
    }

    static testMethod void GetColumnValue_ReturnsV1_GivenV1InColumn1()
	{
		String column1Header = 'c1';
        Integer field1Index = 0;
        String column1Value = 'v1';
        List<String> rowData = new List<String>{ column1Value };

        CSVDataCollection dataCollection = BuildEmptyCollection();
        dataCollection.ColumnIndexesByFieldName.put(column1Header, field1Index);


        String result = CSVDataCollectionUtilities.GetColumnValue(dataCollection, column1Header, rowData);


        System.assertEquals(column1Value, result);
    }


    static CSVDataCollection BuildEmptyCollection()
    {
        CSVDataCollection dataCollection = new CSVDataCollection();
        dataCollection.ColumnIndexesByFieldName = new Map<String, Integer>();
        dataCollection.LinesByRowIndex = new Map<Integer, List<String>>();

        return dataCollection;
    }
}