/**
 * Created by Ethan Sargent on 22/10/19.
 */

@IsTest
private class CaseBusinessHoursDate_Test
{
    @IsTest
    static void createdAfterHours()
    {
        // Arrange
        Datetime createdDt = Datetime.newInstance(2019,11,7, 21, 0, 0 );
        Case newCase = TestClass_CaseCreator.Create(createdDt);
        List<Case> invocableTestCase = new List<Case>();
        invocableTestCase.add(newCase);
        // Act
        Test.startTest();
        CaseBusinessHoursDate.setCalculationStart(invocableTestCase);
        Test.stopTest();
        // Assert

        Datetime correctDatetime = Datetime.newInstance(2019, 11, 8, 9, 0, 0);
        Case finalCase = [SELECT BusinessHours_Calculation_Date__c, CreatedDate FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assert(finalCase.BusinessHours_Calculation_Date__c == correctDatetime);
    }

    @IsTest
    static void createdOnWeekend()
    {
        // Arrange
        Datetime createdDt = Datetime.newInstance(2019,11,10, 21, 0, 0 );
        Case newCase = TestClass_CaseCreator.Create(createdDt);
        List<Case> invocableTestCase = new List<Case>();
        invocableTestCase.add(newCase);
        // Act
        Test.startTest();
        CaseBusinessHoursDate.setCalculationStart(invocableTestCase);
        Test.stopTest();
        // Assert
        Datetime correctDatetime = Datetime.newInstance(2019,11,11,9,0,0);
        Case finalCase = [SELECT BusinessHours_Calculation_Date__c, CreatedDate FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assert(finalCase.BusinessHours_Calculation_Date__c == correctDatetime);
    }

    @IsTest
    static void createdBeforeMorningStart()
    {
        // Arrange
        Datetime createdDt = Datetime.newInstance(2019,11,11, 2, 0, 0 );
        Case newCase = TestClass_CaseCreator.Create(createdDt);
        List<Case> invocableTestCase = new List<Case>();
        invocableTestCase.add(newCase);
        // Act
        Test.startTest();
        CaseBusinessHoursDate.setCalculationStart(invocableTestCase);
        test.stopTest();
        // Assert
        Datetime correctDatetime = Datetime.newInstance(2019,11,11,9,0,0);
        Case finalCase = [SELECT BusinessHours_Calculation_Date__c, CreatedDate FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assert(finalCase.BusinessHours_Calculation_Date__c == correctDatetime);

    }

    @IsTest
    static void createdDuringBusinessHours()
    {
        // Arrange
        Datetime createdDt = Datetime.newInstance(2019,11,11, 10, 0, 0 );
        Case newCase = TestClass_CaseCreator.Create(createdDt);
        List<Case> invocableTestCase = new List<Case>();
        invocableTestCase.add(newCase);
        // Act
        Test.startTest();
        CaseBusinessHoursDate.setCalculationStart(invocableTestCase);
        test.stopTest();
        // Assert
        Datetime correctDatetime = Datetime.newInstance(2019,11,11,10,0,0);
        Case finalCase = [SELECT BusinessHours_Calculation_Date__c, CreatedDate FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assert(finalCase.BusinessHours_Calculation_Date__c == correctDatetime);
    }
}