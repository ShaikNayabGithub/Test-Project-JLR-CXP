public class RoadsideUpload_RecordCollection_FF {
    public RoadsideUpload_RecordCollection_F Create()
    {
        CSVIteratedReader csvReader = new CSVIteratedReader();
         
        RoadsideUpload_ChildApexJobBuilder apexJobBuilder = new RoadsideUpload_ChildApexJobBuilder();
        RoadsideUpload_ApexJobRetriever apexJobRetriever = new RoadsideUpload_ApexJobRetriever();
        RoadsideUpload_HeaderParser headerParser = new RoadsideUpload_HeaderParser(csvReader);

        return new RoadsideUpload_RecordCollection_F(csvReader, apexJobBuilder, apexJobRetriever, 
                headerParser);
    }
}