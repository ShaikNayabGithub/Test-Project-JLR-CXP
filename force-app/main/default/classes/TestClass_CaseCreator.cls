@isTest
public class TestClass_CaseCreator {
    public static Case Create(String origin)
    {
    	Case caseRecord = new Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
    	caseRecord.Priority='Low';
    	caseRecord.Status = 'Open';
    	caseRecord.Origin = origin;
    	caseRecord.Case_Contact_Email__c = 'test123@test.com';
    	caseRecord.SuppliedEmail = 'test123@test.com';   
        caseRecord.Subject = 'Subject 1';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
    	insert caseRecord;    	
    	
    	return caseRecord;
    }

	public static Case Create(String origin, String phone, String email)
    {
        Case caseRecord = new Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
        caseRecord.Priority='Low';
    	caseRecord.Status = 'Open';
    	caseRecord.Origin = origin;
    	caseRecord.Case_Contact_Email__c = email;
    	caseRecord.SuppliedEmail = email;
        caseRecord.Subject = 'Subject 1';
		caseRecord.Case_Contact_Phone__c = phone;
		caseRecord.Brand2__c = 'Jaguar';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
    	insert caseRecord;
    	
    	return caseRecord;
    }

	public static Case Create(Datetime createdDatetime)
	{
		Case caseRecord = new Case();
		caseRecord.Next_Follow_up_Date__c = System.today();
		caseRecord.Priority='Low';
		caseRecord.Status = 'Open';
		caseRecord.Origin = 'Email';
		caseRecord.Case_Contact_Email__c = 'test123@test.com';
		caseRecord.SuppliedEmail = 'test123@test.com';
		caseRecord.Subject = 'Subject 1';
		caseRecord.CreatedDate = createdDatetime;
		//Set RecordType to Retailer
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
		insert caseRecord;

		return caseRecord;
	}
    
    public static Case CreateCRC(Account accountassociated)
    {
		Case caseRecord = new Case();
		caseRecord.Next_Follow_up_Date__c = System.today();
		caseRecord.Priority='Low';
		caseRecord.Status = 'Open';
		caseRecord.Origin = 'Email';
        caseRecord.AccountId = accountassociated.id;
		caseRecord.Case_Contact_Email__c = 'test123@test.com';
		caseRecord.SuppliedEmail = 'test123@test.com';
		caseRecord.Subject = 'Subject 1';
		//Set RecordType to Retailer
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
		insert caseRecord;
        
        return caseRecord;
    }
    
    public static Case CreateWithAcc(Account accountassociated)
    {
		Case caseRecord = new Case();
		caseRecord.Next_Follow_up_Date__c = System.today();
		caseRecord.Priority='Low';
		caseRecord.Status = 'Open';
		caseRecord.Origin = 'Email';
        caseRecord.AccountId = accountassociated.id;
		caseRecord.Case_Contact_Email__c = 'test123@test.com';
		caseRecord.SuppliedEmail = 'test123@test.com';
		caseRecord.Subject = 'Subject 1';
		caseRecord.Brand2__c = 'Jaguar';
		//Set RecordType to Retailer
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
		insert caseRecord;
        
        return caseRecord;
    }
}