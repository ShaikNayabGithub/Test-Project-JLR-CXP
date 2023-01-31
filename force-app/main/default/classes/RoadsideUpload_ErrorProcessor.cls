public class RoadsideUpload_ErrorProcessor {
	public Integer ProcessErrors(Database.SaveResult[] insertResults, List<Integer> rowIndexes, 
			Map<Integer, CSVRowStatus> lineStatusesByRowIndex)
	{
		Integer recordsSaved = 0;

		for(Integer i = 0; i < insertResults.Size(); i++) {
			if(!insertResults[i].isSuccess()) {
				CSVRowStatus rowStatus = lineStatusesByRowIndex.get(rowIndexes[i]);
				if(rowStatus == null) {
					rowStatus = new CSVRowStatus();
					lineStatusesByRowIndex.put(rowIndexes[i], rowStatus);
				}

				Database.Error[] errors = insertResults[i].getErrors();
				
				for(Database.Error errorString : errors) {
					rowStatus.Message += errorString;
				}

				rowStatus.HasErrored = true;
			} else {
				recordsSaved++;
			}
		}

		return recordsSaved;
	}
}