@isTest
public class Vista_ErrorWriter_T {
	static testmethod void WriteErrors_SetsRequestStatusToError_GivenRequestAndKeyK1()
	{
		Vista_ErrorWriter errorWriter = new Vista_ErrorWriter();


		String key = 'k1';
		Database.Error[] errors = new Database.Error[]{};
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		Vista_Request__c request1 = new Vista_Request__c();
		Vista_RecordGroup recordGroup1 = new Vista_RecordGroup();
		recordGroup1.Request = request1;

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>{
			key => new List<Vista_RecordGroup>{ recordGroup1 } };


		errorWriter.WriteErrors(key, errors, requestCollection);

		System.assertEquals('Error', request1.Status__c);
	}

	static testmethod void WriteErrors_DoesNotSetRequestK2StatusToError_GivenRequestAndKeyK1()
	{
		Vista_ErrorWriter errorWriter = new Vista_ErrorWriter();


		String key1 = 'k1';
		String key2 = 'k2';
		Database.Error[] errors = new Database.Error[]{};
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		Vista_Request__c request1 = new Vista_Request__c();
		Vista_RecordGroup recordGroup1 = new Vista_RecordGroup();
		recordGroup1.Request = request1;

		Vista_Request__c request2 = new Vista_Request__c();
		request2.Status__c = 'test';
		Vista_RecordGroup recordGroup2 = new Vista_RecordGroup();
		recordGroup2.Request = request2;

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>{
			key1 => new List<Vista_RecordGroup>{ recordGroup1 },
			key2 => new List<Vista_RecordGroup>{ recordGroup2 } };


		errorWriter.WriteErrors(key1, errors, requestCollection);

		System.assertEquals('test', request2.Status__c);
	}

	static testmethod void WriteErrors_SetsRequestErrorLog_GivenRequestAndKeyK1()
	{
		Vista_ErrorWriter errorWriter = new Vista_ErrorWriter();


		String key = 'k1';
		Database.Error[] errors = Database.insert(new List<Contact>{ new Contact() }, false)[0].getErrors();
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Error_Log__c = '';
		Vista_RecordGroup recordGroup1 = new Vista_RecordGroup();
		recordGroup1.Request = request1;

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>{
			key => new List<Vista_RecordGroup>{ recordGroup1 } };


		errorWriter.WriteErrors(key, errors, requestCollection);

		System.assertNotEquals('', request1.Error_Log__c);
	}

	static testmethod void WriteErrors_DoesNotSetRequestK2ErrorLog_GivenRequestAndKeyK1()
	{
		Vista_ErrorWriter errorWriter = new Vista_ErrorWriter();


		String key1 = 'k1';
		String key2 = 'k2';
		Database.Error[] errors = Database.insert(new List<Contact>{ new Contact() }, false)[0].getErrors();
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		Vista_Request__c request1 = new Vista_Request__c();
		Vista_RecordGroup recordGroup1 = new Vista_RecordGroup();
		recordGroup1.Request = request1;

		Vista_Request__c request2 = new Vista_Request__c();
		request2.Error_Log__c = 'test';
		Vista_RecordGroup recordGroup2 = new Vista_RecordGroup();
		recordGroup2.Request = request2;

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>{
			key1 => new List<Vista_RecordGroup>{ recordGroup1 },
			key2 => new List<Vista_RecordGroup>{ recordGroup2 } };


		errorWriter.WriteErrors(key1, errors, requestCollection);

		System.assertEquals('test', request2.Error_Log__c);
	}
}