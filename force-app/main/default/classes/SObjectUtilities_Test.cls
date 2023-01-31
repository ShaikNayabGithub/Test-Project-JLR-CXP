@isTest
public class SObjectUtilities_Test {
    static testmethod void GetFieldValues_ReturnsEmptySet_GivenEmptyList()
    {
    	List<SObject> records = new List<SObject>();
    	
    	Set<String> results = SObjectUtilities.GetFieldValues(records, 'OwnerId');
    	
    	System.assertEquals(0, results.size());
    }
    
    static testmethod void GetFieldValues_ReturnsEmptySet_GivenListWithNoOwners()
    {
    	List<SObject> records = new List<SObject>();
    	
    	Lead lead = new Lead();
    	records.add(lead);
    	
    	Set<String> results = SObjectUtilities.GetFieldValues(records, 'OwnerId');
    	
    	System.assertEquals(0, results.size());
    }
    
    static testmethod void GetFieldValues_ReturnedSetContainsOwnerOne_GivenListWithOneOwnerOwnerOne()
    {
    	String ownerOne = '00524000000hnkfAAA';
    	List<SObject> records = new List<SObject>();
    	
    	Lead lead = new Lead();
    	lead.OwnerId = ownerOne;
    	records.add(lead);
    	
    	Set<String> results = SObjectUtilities.GetFieldValues(records, 'OwnerId');
    	
    	System.assert(results.contains(ownerOne));
    }
    
    static testmethod void SetMultiple_SetsOwnerId_GivenOwnerId()
    {
    	String ownerOne = '00524000000hnkfAAA';
    	
    	List<String> fieldNames = new List<String>();
    	fieldNames.add('OwnerId');
    	
    	Lead lead = new Lead();
    	
    	SObjectUtilities.SetMultiple(lead, fieldNames, ownerOne);
    	
    	System.assertEquals(ownerOne, lead.OwnerId);
    }
    
    static testmethod void SetMultiple_SetsOwnerIdAndFirstName_GivenOwnerIdAndFirstName()
    {
    	String ownerOne = '00524000000hnkfAAA';
    	
    	List<String> fieldNames = new List<String>();
    	fieldNames.add('OwnerId');
    	fieldNames.add('FirstName');
    	
    	Lead lead = new Lead();
    	
    	SObjectUtilities.SetMultiple(lead, fieldNames, ownerOne);
    	
    	System.assert(lead.OwnerId == ownerOne && lead.FirstName == ownerOne);
    }
    
    static testmethod void GetOwnerMap_ReturnsThisUser_GivenNoRecords()
    {
    	List<SObject> records = new List<SObject>();
    	
    	Map<Id, User> result = SObjectUtilities.GetOwnerMap(records);
    	
    	System.assert(result.ContainsKey(UserInfo.getUserId()));
    }
    
    static testmethod void GetOwnerMap_ReturnsThisUser_GivenQueueId()
    {
    	List<SObject> records = new List<SObject>();
    	
    	Lead lead = new Lead();
    	lead.OwnerId = '00G8E000000qvb3';
    	records.add(lead);
    	
    	Map<Id, User> result = SObjectUtilities.GetOwnerMap(records);
    	
    	System.assert(result.ContainsKey(UserInfo.getUserId()));
    }
    
    static testMethod void QueryWithMultipleOrs_ReturnsTwoOfThreeInsertedAccount_GivenWhereClauseExcludingOne()
    {
       	Account account1 = new Account(Name = 'Account1');
        Account account2 = new Account(Name = 'Account2');
        Account account3 = new Account(Name = 'Account3');
        insert new List<Account>{account1, account2, account3};
        string queryFirstLine = 'SELECT Id FROM Account WHERE ';
        string whereClauseFormat = '(Name = \'\'{0}\'\')';
        List<string> fieldsToGet = new List<string>{'Name'}; 
        List<Account> objectsToIterate = new List<Account>{account1, account2};
        
        List<Account> result = SObjectUtilities.QueryWithMultipleOrs(queryFirstLine, whereClauseFormat, fieldsToGet, objectsToIterate);
        system.assertEquals(2, result.size());
    }
        
    static testmethod void GetChanged_ReturnsEmptyList_GivenTwoLeadsWithLastNameTestAndFieldLastName()
    {
    	Lead lead1 = new Lead(LastName='Test');
    	Lead lead2 = new Lead(LastName='Test');
    	
    	List<SObject> results = SObjectUtilities.GetChanged(new List<Lead>{lead1},new List<Lead>{lead2}, new Set<String>{'LastName'});
    	
    	System.AssertEquals(0, results.Size());
    }
    
    static testmethod void GetChanged_ReturnsEmptyList_GivenTwoLeadsWithFirstAndLastNameTestAndFieldsLastNameAndFirstName()
    {
    	Lead lead1 = new Lead(LastName='Test',FirstName='Test');
    	Lead lead2 = new Lead(LastName='Test',FirstName='Test');
    	
    	List<SObject> results = SObjectUtilities.GetChanged(new List<Lead>{lead1},new List<Lead>{lead2}, new Set<String>{'LastName','FirstName'});
    	
    	System.AssertEquals(0, results.Size());
    }
    
    static testmethod void GetChanged_ReturnsLead1_GivenTwoLeadsWithSameLastNameAndDifferentFirstNameAndFieldsLastNameAndFirstName()
    {
    	Lead lead1 = new Lead(LastName='Test',FirstName='TestDifferent');
    	Lead lead2 = new Lead(LastName='Test',FirstName='Test');
    	
    	List<SObject> results = SObjectUtilities.GetChanged(new List<Lead>{lead1},new List<Lead>{lead2}, new Set<String>{'LastName','FirstName'});
    	
    	System.AssertEquals(lead1, results[0]);
    }

    static testmethod void SetIfNotBlank_ReturnsDoesNotSetName_GivenFieldNameAndBlankString()
    {
        String input = '';
        String expected = 'e1';
        Contact contact = new Contact(FirstName=expected);
        Schema.DescribeFieldResult field = Schema.Contact.FirstName.getDescribe();

        SObjectUtilities.SetIfNotBlank(contact, field, input);

        system.assertEquals(expected, contact.FirstName);
    }

    static testmethod void SetIfNotBlank_ReturnsSetsNameToE1_GivenFieldNameAndStringE1()
    {
        String input = 'e1';
        Contact contact = new Contact(FirstName='test');
        Schema.DescribeFieldResult field = Schema.Contact.FirstName.getDescribe();

        SObjectUtilities.SetIfNotBlank(contact, field, input);

        system.assertEquals(input, contact.FirstName);
    }

    static testmethod void MapByIdField_MapsAccount1ById1_GivenAccounts1And2AndIdField()
    {
        Schema.DescribeFieldResult field = Schema.Account.Id.getDescribe();

        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Account account2 = TestClass_AccountCreator.CreatePersonAccount();

        List<SObject> records = new List<SObject>{ account1, account2 };


        Map<Id, List<SObject>> recordMap = SObjectUtilities.MapByIdField(records, field);

        system.assertEquals(account1.Id, recordMap.get(account1.Id)[0].Id);
    }

    static testmethod void MapByIdField_MapsAccount2ById2_GivenAccounts1And2AndIdField()
    {
        Schema.DescribeFieldResult field = Schema.Account.Id.getDescribe();

        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Account account2 = TestClass_AccountCreator.CreatePersonAccount();

        List<SObject> records = new List<SObject>{ account1, account2 };


        Map<Id, List<SObject>> recordMap = SObjectUtilities.MapByIdField(records, field);

        system.assertEquals(account2.Id, recordMap.get(account2.Id)[0].Id);
    }

    static testmethod void MapByIdField_MapsAccount2ByParentId_GivenAccounts2And3AndParentIdField()
    {
        Schema.DescribeFieldResult field = Schema.Account.ParentId.getDescribe();

        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Account account2 = TestClass_AccountCreator.CreatePersonAccount();
        account2.ParentId = account1.Id;
        Account account3 = TestClass_AccountCreator.CreatePersonAccount();
        account3.ParentId = account2.Id;

        List<SObject> records = new List<SObject>{ account2, account3 };


        Map<Id, List<SObject>> recordMap = SObjectUtilities.MapByIdField(records, field);

        system.assertEquals(account2.Id, recordMap.get(account2.ParentId)[0].Id);
    }

    static testmethod void MapByIdField_MapsAccount3ByParentId_GivenAccounts2And3And4AndParentIdField()
    {
        Schema.DescribeFieldResult field = Schema.Account.ParentId.getDescribe();

        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Account account2 = TestClass_AccountCreator.CreatePersonAccount();
        account2.ParentId = account1.Id;
        Account account3 = TestClass_AccountCreator.CreatePersonAccount();
        account3.ParentId = account2.Id;
        Account account4 = TestClass_AccountCreator.CreatePersonAccount();
        account4.ParentId = account2.Id;

        List<SObject> records = new List<SObject>{ account2, account3, account4 };


        Map<Id, List<SObject>> recordMap = SObjectUtilities.MapByIdField(records, field);

        system.assertEquals(account3.Id, recordMap.get(account2.Id)[0].Id);
    }

    static testmethod void MapByIdField_MapsAccount4ByParentId2_GivenAccounts2And3And4AndParentIdField()
    {
        Schema.DescribeFieldResult field = Schema.Account.ParentId.getDescribe();

        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Account account2 = TestClass_AccountCreator.CreatePersonAccount();
        account2.ParentId = account1.Id;
        Account account3 = TestClass_AccountCreator.CreatePersonAccount();
        account3.ParentId = account2.Id;
        Account account4 = TestClass_AccountCreator.CreatePersonAccount();
        account4.ParentId = account2.Id;

        List<SObject> records = new List<SObject>{ account2, account3, account4 };


        Map<Id, List<SObject>> recordMap = SObjectUtilities.MapByIdField(records, field);

        system.assertEquals(account4.Id, recordMap.get(account2.Id)[1].Id);
    }


    static testmethod void CastFieldData_ReturnsTrue_GivenTrueAndEventIsReminderSet()
    {
        String input = 'true';
        Schema.DescribeFieldResult fieldDescription = Event.IsReminderSet.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals(true, result);
    }

    static testmethod void CastFieldData_ReturnsN1_GivenN1AndContactLastName()
    {
        String input = 'n1';
        Schema.DescribeFieldResult fieldDescription = Contact.LastName.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals('n1', result);
    }

    static testmethod void CastFieldData_ReturnsA1_GivenA1AndCaseDescription()
    {
        String input = 'a1';
        Schema.DescribeFieldResult fieldDescription = Case.Description.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals('a1', result);
    }

    static testmethod void CastFieldData_ReturnsP1_GivenP1AndLeadPhone()
    {
        String input = 'p1';
        Schema.DescribeFieldResult fieldDescription = Lead.Phone.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals('p1', result);
    }

    static testmethod void CastFieldData_ReturnsS1_GivenS1AndOpportunityStageName()
    {
        String input = 's1';
        Schema.DescribeFieldResult fieldDescription = Opportunity.StageName.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals('s1', result);
    }

    static testmethod void CastFieldData_ReturnsId1_GivenId1AndApexJobParentId()
    {
        Apex_Job__c apexJob = TestClass_ApexJob.Create();
        Schema.DescribeFieldResult fieldDescription = Apex_Job__c.Parent_Job__c.getDescribe();


        object result = SObjectUtilities.CastFieldData(apexJob.Id, fieldDescription);


        System.assertEquals(apexJob.Id, result);
    }

    static testmethod void CastFieldData_ReturnsE1_GivenE1AndAccountPersonEmail()
    {
        String input = 'e1';
        Schema.DescribeFieldResult fieldDescription = Account.PersonEmail.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals('e1', result);
    }

    static testmethod void CastFieldData_ReturnsDate1_GivenDate1AndEventVehicleRecoveryDate()
    {
        String input = '2017-12-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();


        object result = SObjectUtilities.CastFieldData(input, fieldDescription);


        System.assertEquals(Date.valueOf(input), result);
    }
    
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateJanAndEventVehicleRecoveryDate()
    {
        String input = '17-JAN-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateFebAndEventVehicleRecoveryDate()
    {
        String input = '17-FEB-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateMarAndEventVehicleRecoveryDate()
    {
        String input = '17-MAR-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateAprAndEventVehicleRecoveryDate()
    {
        String input = '17-APR-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateMayAndEventVehicleRecoveryDate()
    {
        String input = '17-MAY-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateJunAndEventVehicleRecoveryDate()
    {
        String input = '17-JUN-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateJulAndEventVehicleRecoveryDate()
    {
        String input = '17-JUL-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateAugAndEventVehicleRecoveryDate()
    {
        String input = '17-AUG-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateSepAndEventVehicleRecoveryDate()
    {
        String input = '17-SEP-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateOctAndEventVehicleRecoveryDate()
    {
        String input = '17-OCT-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateNovAndEventVehicleRecoveryDate()
    {
        String input = '17-NOV-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrongDateDecAndEventVehicleRecoveryDate()
    {
        String input = '17-DEC-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);		
    }
    static testmethod void CastFieldData_ReturnsDate1_GivenWrong1Date1AndEventVehicleRecoveryDate()
    {
        String input = '2017-1-31';
        Schema.DescribeFieldResult fieldDescription = Event.Vehicle_Recovery_Date__c.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);
		System.assertEquals(Date.valueOf(input), result);
    }
    
    static testmethod void CastFieldData_Returns1p5_Given1p5AndPricebookEntryUnitPrice()
    {
        String input = '1.5';
        Schema.DescribeFieldResult fieldDescription = PricebookEntry.UnitPrice.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);

        System.assertEquals(1.5, result);
    }

    static testmethod void CastFieldData_ReturnsDateTime1_GivenDateTime1AndEventEndDateTime()
    {
        String input = '2017-12-31 13:59:58';
        Schema.DescribeFieldResult fieldDescription = Event.EndDateTime.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);

        System.assertEquals(DateTime.valueOf(input), result);
    }

    static testmethod void CastFieldData_Returns10_Given10AndEventDurationInMinutes()
    {
        String input = '10';
        Schema.DescribeFieldResult fieldDescription = Event.DurationInMinutes.getDescribe();

        object result = SObjectUtilities.CastFieldData(input, fieldDescription);

        System.assertEquals(10, result);
    }
}