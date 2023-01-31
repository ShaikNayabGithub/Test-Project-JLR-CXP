@isTest
public class TestClass_ApexJob {
	public static Apex_Job__c Build()
	{
		return new Apex_Job__c(
				Name = 'TestClass_ApexJob'
			);
	}

	public static Apex_Job__c Create()
	{
		Apex_Job__c apexJob = Build();
		insert apexJob;

		return apexJob;
	}
}