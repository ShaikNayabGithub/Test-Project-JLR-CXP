public class CSVIteratedReader {
    private static final String CHARS_TO_TREAT_AS_EMPTY = ',';


	public Map<Integer, List<String>> Read(List<String> csvRows)
	{
		Map<Integer, List<String>> csvLinesByIndex = new Map<Integer, List<String>>();

		String csvFile = '';
		List<Integer> rowIndexes = new List<Integer>();

        for(String row : csvRows) {
            if(String.isBlank(row)) continue;
        	String[] splitRow = row.split(CSVParser.ROW_NUMBER_TAG);
            if(splitRow.Size() < 2) continue;

        	Integer rowIndex = Integer.valueOf(splitRow[0]);
        	String rowData = splitRow[1];
            if(rowData.containsOnly(CHARS_TO_TREAT_AS_EMPTY)) continue;

            csvFile += rowData + CSVParser.CRLF;
            rowIndexes.add(rowIndex);
        }

        List<List<String>> csvLines = CSVReader.readIETFRFC4180CSVFile(csvFile);

        for(Integer i = 0; i < csvLines.size(); i++) {
            if(csvLines[i].Size() == 0 || (csvLines[i].Size() == 1 && String.isBlank(csvLines[i][0]))) continue;
        	csvLinesByIndex.put(rowIndexes[i], csvLines[i]);
        }

        return csvLinesByIndex;
	}
}