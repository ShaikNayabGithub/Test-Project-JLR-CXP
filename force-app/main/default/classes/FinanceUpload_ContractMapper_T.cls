@isTest
public class FinanceUpload_ContractMapper_T {
    static testMethod void AddToCollection_DoesNothing_GivenEmptyCollections()
	{
        FinanceUpload_ContractMapper contractMapper = new FinanceUpload_ContractMapper();

        List<Contract> contracts = new List<Contract>();
        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        contractMapper.AddToCollection(contracts, recordCollection);

        System.AssertEquals(0, recordCollection.ContractsByRowId.Size());
    }

    static testMethod void AddToCollection_AddsContract1ToList_GivenContract1WithFinanceReferenceFR1()
	{
        FinanceUpload_ContractMapper contractMapper = new FinanceUpload_ContractMapper();

        String financeReference1 = 'FR1';
        Integer rowIndex1 = 1;

        Contract contract1 = new Contract(Name = 'c1', Finance_Reference__c = financeReference1);
        List<Contract> contracts = new List<Contract> { contract1 };
        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.FINANCE_REFERENCE_COLUMN_HEADER,
                0);
        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { financeReference1 });

        contractMapper.AddToCollection(contracts, recordCollection);

        System.AssertEquals(contract1.Name, recordCollection.ContractsByRowId.get(rowIndex1).Name);
    }


    private static FinanceUpload_RecordCollection CreateEmptyCollection()
    {
        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        recordCollection.CSVDataCollection = new CSVUpload_DataCollection();
        recordCollection.CSVDataCollection.LinesByRowIndex = new Map<Integer, List<String>>();
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName = new Map<String, Integer>();

        return recordCollection;
    }
}