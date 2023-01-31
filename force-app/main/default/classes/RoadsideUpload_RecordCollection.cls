public class RoadsideUpload_RecordCollection {
	public CSVDataCollection CSVData;
	public Apex_Job__c ApexJob;

	public Map<String, Contact> ContactsByPhoneNumber;
	public Map<String, Contact> ContactsByEmail;

	public Map<String, Lead> LeadsByPhoneNumber;
	public Map<String, Lead> LeadsByEmail;

	public Map<String, Asset> AssetsByVIN;
	public Map<String, Asset> AssetsByRegistration;

	public Map<Integer, Event> EventByCSVRowNumber;
	public Map<Integer, Asset> AssetsToUpdate;
}