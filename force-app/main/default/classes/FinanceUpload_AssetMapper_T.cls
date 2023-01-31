@isTest
public class FinanceUpload_AssetMapper_T {
    static testMethod void AddToCollection_DoesNothing_GivenEmptyCollections()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        List<Asset> assets = new List<Asset>();


        assetMapper.AddToCollection(assets, recordCollection);


        System.Assert(true);
    }

    static testMethod void AddToCollection_DoesNothing_GivenEmptyAsset()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        Asset asset1 = new Asset();
        List<Asset> assets = new List<Asset>{ asset1 };


        assetMapper.AddToCollection(assets, recordCollection);


        System.Assert(true);
    }

    static testMethod void AddToCollection_DoesNothing_GivenAssetWithUnknownVin()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String vin1 = 'v1';

        Asset asset1 = new Asset(Vin__c = vin1);
        List<Asset> assets = new List<Asset>{ asset1 };


        assetMapper.AddToCollection(assets, recordCollection);


        System.Assert(true);
    }

    static testMethod void AddToCollection_DoesNothing_GivenAssetWithUnknownRegistration()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String registration1 = 'r1';

        Asset asset1 = new Asset(Registration_Number__c = registration1);
        List<Asset> assets = new List<Asset>{ asset1 };


        assetMapper.AddToCollection(assets, recordCollection);


        System.Assert(true);
    }

    static testMethod void AddToCollection_AssetToCollection_AndCSVCollectionWithVin1()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String vin1 = 'v1';
        Integer rowIndex1 = 1;

        Asset asset1 = new Asset(Vin__c = vin1);
        List<Asset> assets = new List<Asset>{ asset1 };

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { vin1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.VIN_COLUMN_HEADER, 
                0);


        assetMapper.AddToCollection(assets, recordCollection);


        System.AssertEquals(vin1, recordCollection.AssetsByRowId.get(rowIndex1).Vin__c);
    }

    static testMethod void AddToCollection_AssetToCollection_GivenAssetAndCSVCollectionWithRegistration1()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String registration1 = 'r1';
        Integer rowIndex1 = 1;

        Asset asset1 = new Asset(Registration_Number__c = registration1);
        List<Asset> assets = new List<Asset>{ asset1 };

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { registration1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.REGISTRATION_COLUMN_HEADER, 
                0);


        assetMapper.AddToCollection(assets, recordCollection);


        System.AssertEquals(registration1, recordCollection.AssetsByRowId.get(rowIndex1).Registration_Number__c);
    }

    static testMethod void AddToCollection_DoesNotAddAccountToCollection_GivenAssetAndCSVCollectionWithVin1AndPersonAccountWithNoId()
    {
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();

        FinanceUpload_RecordCollection recordCollection = CreateEmptyCollection();

        String vin1 = 'v1';
        Integer rowIndex1 = 1;

        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        account1.Id = null;
        Asset asset1 = new Asset(Vin__c = vin1, Account = account1);
        List<Asset> assets = new List<Asset>{ asset1 };

        recordCollection.CSVDataCollection.LinesByRowIndex.put(rowIndex1, new List<String> { vin1 });
        recordCollection.CSVDataCollection.ColumnIndexesByFieldName.put(FinanceUpload_Constants.VIN_COLUMN_HEADER, 
                0);


        assetMapper.AddToCollection(assets, recordCollection);


        System.AssertEquals(null, recordCollection.AccountsByRowId.get(rowIndex1));
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