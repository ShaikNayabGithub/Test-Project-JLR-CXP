public class RoadsideUpload_Upserter {
    private final RoadsideUpload_PairedListPopulator pairedListPopulator;
    private final RoadsideUpload_ErrorProcessor errorProcessor;


    public RoadsideUpload_Upserter(RoadsideUpload_PairedListPopulator pairedListPopulator,
            RoadsideUpload_ErrorProcessor errorProcessor)
    {
        this.pairedListPopulator = pairedListPopulator;
        this.errorProcessor = errorProcessor;
    }


    public void InsertEvents(RoadsideUpload_RecordCollection recordCollection)
    {
        List<Integer> rowIndexes = new List<Integer>();
        List<Event> events = new List<Event>();

        this.pairedListPopulator.PopulateLists(rowIndexes, events, recordCollection.EventByCSVRowNumber, 
                recordCollection.CSVData.LineStatusesByRowIndex);

        Database.SaveResult[] insertResults = Database.Insert(events, false);
        recordCollection.ApexJob.accounts_inserted__c=0;
        recordCollection.ApexJob.contracts_inserted__c=0;
        recordCollection.ApexJob.assets_inserted__c=0;
        
        recordCollection.ApexJob.Records_Inserted__c += this.errorProcessor.ProcessErrors(insertResults, 
            rowIndexes, recordCollection.CSVData.LineStatusesByRowIndex);
        recordCollection.ApexJob.events_inserted__c=recordCollection.ApexJob.Records_Inserted__c;
    }

    public void UpdateAssets(RoadsideUpload_RecordCollection recordCollection)
    {
        List<Integer> rowIndexes = new List<Integer>();
        List<Asset> assets = new List<Asset>();

        this.pairedListPopulator.PopulateLists(rowIndexes, assets, recordCollection.AssetsToUpdate, 
                recordCollection.CSVData.LineStatusesByRowIndex);

        Database.SaveResult[] insertResults = Database.Update(assets, false);
        recordCollection.ApexJob.Records_Updated__c += this.errorProcessor.ProcessErrors(insertResults, 
            rowIndexes, recordCollection.CSVData.LineStatusesByRowIndex);
    }
}