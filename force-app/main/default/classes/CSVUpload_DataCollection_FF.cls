public class CSVUpload_DataCollection_FF {
    public CSVUpload_DataCollection_F Create()
    {
        CSVIteratedReader csvReader = new CSVIteratedReader();
        
        CSVUpload_ChildApexJobBuilder apexJobBuilder = new CSVUpload_ChildApexJobBuilder();
        CSVUpload_ApexJobRetriever apexJobRetriever = new CSVUpload_ApexJobRetriever();
        CSVUpload_HeaderParser headerParser = new CSVUpload_HeaderParser(csvReader);

        return new CSVUpload_DataCollection_F(csvReader, apexJobBuilder, apexJobRetriever, 
                headerParser);
    }
}