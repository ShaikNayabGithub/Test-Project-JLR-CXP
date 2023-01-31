public class BRS_RequestCollection {
	public Map<Id, BRS_Request__c> Requests;
	public Map<String, List<BRS_Request__c>> RequestsByProductCode = new Map<String, List<BRS_Request__c>>();
	public Map<String, Product2> ProductByProductCode = new Map<String, Product2>();
}