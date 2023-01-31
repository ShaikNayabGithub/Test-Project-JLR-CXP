@isTest
private class NextActivitySetter_Test {

    static testMethod void ControllerSetsTaskDateAsAccountNextActivityDate_WhenFirstTaskCreated() {
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Date testDate = Date.today().addDays(2);
        Task t = new Task(Subject='First Test', WhatId=acc.Id, ActivityDate=testDate);
        insert t;
        acc = [SELECT Next_Activity_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(testDate, acc.Next_Activity_Date__c);
    }
    
    static testMethod void ControllerSetsSecondTaskDateAsAccountNextActivityDate_WhenSecondTaskEarlierThanFirstTaskCreated() {
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Date testDate1 = Date.today().addDays(3);
        Date testDate2 = Date.today().addDays(2);
        Task t1 = new Task(Subject='First Test', WhatId=acc.Id, ActivityDate=testDate1);
        insert t1;
        Task t2 = new Task(Subject='Second Test', WhatId=acc.Id, ActivityDate=testDate2);
        insert t2;
        acc = [SELECT Next_Activity_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(testDate2, acc.Next_Activity_Date__c);
    }

    static testMethod void ControllerSetsFirstTaskDateAsAccountNextActivityDate_WhenSecondTaskEarlierThanFirstTaskCreatedAndThenClosed() {
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Date testDate1 = Date.today().addDays(3);
        Date testDate2 = Date.today().addDays(2);
        Task t1 = new Task(Subject='First Test', WhatId=acc.Id, ActivityDate=testDate1);
        insert t1;
        Task t2 = new Task(Subject='Second Test', WhatId=acc.Id, ActivityDate=testDate2);
        insert t2;
        t2.Status = 'Completed';
        update t2;
        acc = [SELECT Next_Activity_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(testDate1, acc.Next_Activity_Date__c);
    }
    
    static testMethod void ControllerSetsTaskEditedDateAsAccountNextActivityDate_WhenTaskCreatedAndEdited() {
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Date testDate1 = Date.today().addDays(3);
        Date testDate2 = Date.today().addDays(2);
        Task t = new Task(Subject='First Test', WhatId=acc.Id, ActivityDate=testDate1);
        insert t;
        t.ActivityDate = testDate2;
        update t;
        acc = [SELECT Next_Activity_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(testDate2, acc.Next_Activity_Date__c);
    }
	
    static testMethod void ControllerSetsEventDateAsAccountNextActivityDate_WhenFirstEventCreated() {
        Account acc = TestClass_AccountCreator.CreateRetailer();
        DateTime testDateTime = DateTime.now().addDays(2);
        Date testDate = Date.today().addDays(2);
        Event evt = new Event(Subject='First Test', WhatId=acc.Id, ActivityDateTime=testDateTime, DurationInMinutes=30);
        insert evt;
        acc = [SELECT Next_Activity_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(testDate, acc.Next_Activity_Date__c);
    }
    
}