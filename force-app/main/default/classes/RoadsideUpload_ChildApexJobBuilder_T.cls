@isTest
public class RoadsideUpload_ChildApexJobBuilder_T {
	static testMethod void Build_ReturnsJobWithNameN1_GivenParentIdAndNameN1()
	{
		RoadsideUpload_ChildApexJobBuilder childApexJobBuilder = new RoadsideUpload_ChildApexJobBuilder();

		String childJobName = 'n1';
		Apex_Job__c parentJob = TestClass_ApexJob.Create();


		Apex_Job__c result = childApexJobBuilder.Build(parentJob.Id, childJobName);


		System.assertEquals(childJobName, result.Name);
	}

	static testMethod void Build_ReturnsJobWithParentIdP1_GivenParentIdAndNameN1()
	{
		RoadsideUpload_ChildApexJobBuilder childApexJobBuilder = new RoadsideUpload_ChildApexJobBuilder();

		String childJobName = 'n1';
		Apex_Job__c parentJob = TestClass_ApexJob.Create();


		Apex_Job__c result = childApexJobBuilder.Build(parentJob.Id, childJobName);


		System.assertEquals(parentJob.Id, result.Parent_Job__c);
	}

	static testMethod void Build_ReturnsJobWithStatusProcessing_GivenParentIdAndNameN1()
	{
		RoadsideUpload_ChildApexJobBuilder childApexJobBuilder = new RoadsideUpload_ChildApexJobBuilder();

		String childJobName = 'n1';
		Apex_Job__c parentJob = TestClass_ApexJob.Create();


		Apex_Job__c result = childApexJobBuilder.Build(parentJob.Id, childJobName);


		System.assertEquals(ApexJobUtilities.PROCESSING_STATUS, result.Status__c);
	}

	static testMethod void Build_ReturnsJobWithRecordsInserted0_GivenParentIdAndNameN1()
	{
		RoadsideUpload_ChildApexJobBuilder childApexJobBuilder = new RoadsideUpload_ChildApexJobBuilder();

		String childJobName = 'n1';
		Apex_Job__c parentJob = TestClass_ApexJob.Create();


		Apex_Job__c result = childApexJobBuilder.Build(parentJob.Id, childJobName);


		System.assertEquals(0, result.Records_Inserted__c);
	}

	static testMethod void Build_ReturnsJobWithRecordsUpdated0_GivenParentIdAndNameN1()
	{
		RoadsideUpload_ChildApexJobBuilder childApexJobBuilder = new RoadsideUpload_ChildApexJobBuilder();

		String childJobName = 'n1';
		Apex_Job__c parentJob = TestClass_ApexJob.Create();


		Apex_Job__c result = childApexJobBuilder.Build(parentJob.Id, childJobName);


		System.assertEquals(0, result.Records_Updated__c);
	}
}