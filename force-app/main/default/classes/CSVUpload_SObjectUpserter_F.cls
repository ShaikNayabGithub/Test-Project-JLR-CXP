public class CSVUpload_SObjectUpserter_F {
    public CSVUpload_SObjectUpserter Create()
    {
        CSVUpload_PairedListPopulator pairedListPopulator = new CSVUpload_PairedListPopulator();
        CSVUpload_ErrorProcessor errorProcessor = new CSVUpload_ErrorProcessor();

        return new CSVUpload_SObjectUpserter(pairedListPopulator, errorProcessor);
    }
}