public class RoadsideUpload_ChildApexJobBuilder {
	public Apex_Job__c Build(Id parentId, String childJobName)
	{
		return new Apex_Job__c(
				Name = childJobName,
				Parent_Job__c = parentId,
				Status__c = ApexJobUtilities.PROCESSING_STATUS,
				Records_Inserted__c = 0,
				Records_Updated__c = 0,
				Failure_Count__c = 0
			);
	}
}