public class RoadsideUpload_HeaderParser {
	private final CSVIteratedReader csvReader;


	public RoadsideUpload_HeaderParser(CSVIteratedReader csvReader)
	{
		this.csvReader = csvReader;
	}


	public Map<String, Integer> ParseHeader(Apex_Job__c apexJob)
	{
		Map<String, Integer> columnIndexesByFieldName = new Map<String, Integer>();
		if(String.isBlank(apexJob.File_Header__c)) return columnIndexesByFieldName;

		Map<Integer, List<String>> csvLinesByIndex = this.csvReader.Read(new List<String> { 
				apexJob.File_Header__c });

		List<String> columnHeaders = csvLinesByIndex.get(CSVParser.ROW_START_INDEX);

		for(Integer i = 0; i < columnHeaders.Size(); i++) {
			columnIndexesByFieldName.put(columnHeaders[i], i);
		}

		return columnIndexesByFieldName;
	}
}