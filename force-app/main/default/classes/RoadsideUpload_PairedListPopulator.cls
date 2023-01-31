public class RoadsideUpload_PairedListPopulator {
	public void PopulateLists(List<Integer> rowIndexes, List<SObject> records, 
			Map<Integer, SObject> recordMap, Map<Integer, CSVRowStatus> lineStatusesByRowIndex)
	{
		for(Integer rowIndex : recordMap.keySet()) {
			CSVRowStatus rowStatus = lineStatusesByRowIndex.get(rowIndex);
			if(rowStatus != null && rowStatus.HasErrored == true) continue;

			rowIndexes.add(rowIndex);
			records.add(recordMap.get(rowIndex));
		}
	}
}