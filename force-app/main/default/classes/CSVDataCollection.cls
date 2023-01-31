public virtual class CSVDataCollection {
	public Map<Integer, List<String>> LinesByRowIndex;
	public Map<Integer, CSVRowStatus> LineStatusesByRowIndex;
	public Map<String, Integer> ColumnIndexesByFieldName;
}