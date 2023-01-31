public class RoadsideUpload_RecordCollection_F {
	private final CSVIteratedReader csvReader;
	private final RoadsideUpload_ChildApexJobBuilder apexJobBuilder;
	private final RoadsideUpload_ApexJobRetriever apexJobRetriever;
	private final RoadsideUpload_HeaderParser headerParser;


	public RoadsideUpload_RecordCollection_F(CSVIteratedReader csvReader,
			RoadsideUpload_ChildApexJobBuilder apexJobBuilder,
			RoadsideUpload_ApexJobRetriever apexJobRetriever,
			RoadsideUpload_HeaderParser headerParser)
	{
		this.csvReader = csvReader;
		this.apexJobBuilder = apexJobBuilder;
		this.apexJobRetriever = apexJobRetriever;
		this.headerParser = headerParser;
	}


	public RoadsideUpload_RecordCollection Construct(Id parentJobId, String childJobName, List<String> csvRows)
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();

		recordCollection.ApexJob = this.apexJobBuilder.Build(parentJobId, childJobName);
		insert recordCollection.ApexJob;

		recordCollection.CSVData = new CSVDataCollection();
		recordCollection.CSVData.LinesByRowIndex = this.csvReader.Read(csvRows);
		recordCollection.CSVData.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();

		Apex_Job__c parentJob = this.apexJobRetriever.Retrieve(parentJobId);
		recordCollection.CSVData.ColumnIndexesByFieldName = this.headerParser.ParseHeader(parentJob);

		return recordCollection;
	}
}