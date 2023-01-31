@isTest
public class ProcessSuhoEventStageHandler_Test {
    static Id testDriveRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
    static Id appRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
    static Id quoRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Quotation').getRecordTypeId();
    static Id orderRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
    static Id regRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Registration').getRecordTypeId();
    static Id welComeRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Welcome_Questionnaire').getRecordTypeId();
    
    @isTest public static void testAppraisalTask(){
        
        Opportunity oppIns = createOpportunity();
        oppIns.Appraisal__c = 'Not Started';
        update oppIns;
        Test.startTest();
        oppIns.Appraisal__c = 'In Progress';
        OpportunityHandler.shuhoRecurrsionCheck = true;
        update oppIns;
        Test.stopTest();
        List<Task> taskList = [select id from Task where whatid =: oppIns.Id and recordTypeId =: appRecTypeId];
        system.assertEquals(taskList.size(),1);
    }
    
    @isTest public static void testOrderTask(){
        Opportunity oppIns = createOpportunity();
        oppIns.Order__c = 'Not Required (by customer)';
        update oppIns;
        Test.startTest();
        OpportunityHandler.shuhoRecurrsionCheck = true;
        oppIns.Order__c = 'In Progress';
        update oppIns;
        Test.stopTest();
        List<Task> taskList = [select id from Task where whatid =: oppIns.Id and recordTypeId =: orderRecTypeId];
        system.assertEquals(taskList.size(),1);
        
    }
    
    @isTest public static void testQuotationTask(){
        Opportunity oppIns = createOpportunity();
        oppIns.Quotation__c = 'Not Required (by customer)';
        update oppIns;
        Test.startTest();
        OpportunityHandler.shuhoRecurrsionCheck = true;
        oppIns.Quotation__c = 'In Progress';
        update oppIns;
        Test.stopTest();
        List<Task> taskList = [select id from Task where whatid =: oppIns.Id and recordTypeId =: quoRecTypeId];
        system.assertEquals(taskList.size(),1);
    }
    
    @isTest public static void testWelQueTask(){
        Opportunity oppIns = createOpportunity();
        oppIns.Welcome_Questionnaire__c = 'Not Required (by customer)';
        update oppIns;
        Test.startTest();
        OpportunityHandler.shuhoRecurrsionCheck = true;
        oppIns.Welcome_Questionnaire__c = 'In Progress';
        update oppIns;
        Test.stopTest();
        List<Task> taskList = [select id from Task where whatid =: oppIns.Id and recordTypeId =: welComeRecTypeId];
        system.assertEquals(taskList.size(),1);
    }
    
    @isTest public static void testRegEveTask(){
        Opportunity oppIns = createOpportunity();
        oppIns.Registration_Date__c = system.today()+1;
        update oppIns;
        Test.startTest();
        OpportunityHandler.shuhoRecurrsionCheck = true;
        oppIns.Registration_Date__c = system.today()+5;
        update oppIns;
        Test.stopTest();
        List<Task> taskList = [select id from Task where whatid =: oppIns.Id and recordTypeId =: regRecTypeId];
        system.assertEquals(taskList.size(),1);
    }
    
    @isTest public static void testDrivEveTask(){
        Opportunity oppIns = createOpportunity();
        oppIns.Test_Drive_Complete__c = 'No Show';
        update oppIns;
        Test.startTest();
        OpportunityHandler.shuhoRecurrsionCheck = true;
        oppIns.Test_Drive_Complete__c = 'Not Required';
        update oppIns;
        Test.stopTest();
        List<Event> taskList = [select id from Event where whatid =: oppIns.Id and recordTypeId =: testDriveRecTypeId];
        system.assertEquals(taskList.size(),1);
    }
    
    @isTest public static void testAppraisalTaskCreation(){
        Id appRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
        Opportunity oppIns = createOpportunity();
        Task taskIns = new Task();
        taskIns.whatid = appRecTypeId;
        taskIns.whatId = oppIns.Id;
        taskIns.Subject='Donni';
        taskIns.Status='Not Started';
        taskIns.Priority='Normal';
        Test.startTest();
        insert taskIns;
        Test.stopTest();
    }
    
    @isTest public static void testAppraisalEventTask(){
        Id appRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
        Opportunity oppIns = createOpportunity();
        Task taskIns = new Task();
        taskIns.whatid = appRecTypeId;
        taskIns.whatId = oppIns.Id;
        taskIns.Subject='Donni';
        taskIns.Status='Not Started';
        taskIns.Priority='Normal';
        Test.startTest();
        insert taskIns;
        Test.stopTest();
    }
    
    public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        // testAccount.Customer_Journey_Stage__c = 'Take Ownership';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }
}