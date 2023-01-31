public class CSVUpload_DataCollection_F {
	private final CSVIteratedReader csvReader;
	private final CSVUpload_ChildApexJobBuilder apexJobBuilder;
	private final CSVUpload_ApexJobRetriever apexJobRetriever;
	private final CSVUpload_HeaderParser headerParser;


	public CSVUpload_DataCollection_F(CSVIteratedReader csvReader, 
			CSVUpload_ChildApexJobBuilder apexJobBuilder, CSVUpload_ApexJobRetriever apexJobRetriever,
			CSVUpload_HeaderParser headerParser)
	{
		this.csvReader = csvReader;
		this.apexJobBuilder = apexJobBuilder;
		this.apexJobRetriever = apexJobRetriever;
		this.headerParser = headerParser;
	}


    public CSVUpload_DataCollection Construct(Id parentJobId, String childJobName, List<String> csvRows)
	{
        CSVUpload_DataCollection recordCollection = new CSVUpload_DataCollection();

		recordCollection.ApexJob = this.apexJobBuilder.Build(parentJobId, childJobName);
		insert recordCollection.ApexJob;

		recordCollection.LinesByRowIndex = this.csvReader.Read(csvRows);
		recordCollection.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();

		Apex_Job__c parentJob = this.apexJobRetriever.Retrieve(parentJobId);
		recordCollection.ColumnIndexesByFieldName = this.headerParser.ParseHeader(parentJob);

		return recordCollection;
	}
}