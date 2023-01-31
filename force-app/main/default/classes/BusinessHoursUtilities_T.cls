@isTest
public class BusinessHoursUtilities_T {
	static testmethod void AddMinutes_Returns0540_Given0510AndEmptyListAnd30()
    {
    	Datetime startDate = Datetime.newInstance(0, 0, 0, 5, 10, 0);
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{};
    	Integer minutesToAdd = 30;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(0, 0, 0, 5, 40, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_Returns0605_Given0510AndEmptyListAnd55()
    {
    	Datetime startDate = Datetime.newInstance(0, 0, 0, 5, 10, 0);
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{};
    	Integer minutesToAdd = 55;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(0, 0, 0, 6, 5, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_Returns0740_Given0510AndEmptyListAnd150()
    {
    	Datetime startDate = Datetime.newInstance(0, 0, 0, 5, 10, 0);
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{};
    	Integer minutesToAdd = 150;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(0, 0, 0, 7, 40, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_ReturnsMonday0540_GivenMonday0510AndMonday5Until6And30()
    {
    	Datetime startDate = Datetime.newInstance(2017, 6, 19, 5, 10, 0);
    	Business_Hours__c businessHours1 = new Business_Hours__c(Days__c = 'Monday',
    			UTC_Start_Time__c = '05:00',
    			UTC_End_Time__c = '06:00');
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 };
    	Integer minutesToAdd = 30;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(2017, 6, 19, 5, 40, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_ReturnsTuesday0530_GivenMonday0510AndTuesday5Until6And30()
    {
    	Datetime startDate = Datetime.newInstance(2017, 6, 19, 5, 10, 0);
    	Business_Hours__c businessHours1 = new Business_Hours__c(Days__c = 'Tuesday',
    			UTC_Start_Time__c = '05:00',
    			UTC_End_Time__c = '06:00');
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 };
    	Integer minutesToAdd = 30;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(2017, 6, 20, 5, 30, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_Returns2ndTuesday0530_GivenMonday0510AndTuesday5Until6And90()
    {
    	Datetime startDate = Datetime.newInstance(2017, 6, 19, 5, 10, 0);
    	Business_Hours__c businessHours1 = new Business_Hours__c(Days__c = 'Tuesday',
    			UTC_Start_Time__c = '05:00',
    			UTC_End_Time__c = '06:00');
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 };
    	Integer minutesToAdd = 90;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(2017, 6, 27, 5, 30, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_ReturnsTuesday1040_GivenMonday0510AndMonday5Until6AndTuesday9Until12And150()
    {
    	Datetime startDate = Datetime.newInstance(2017, 6, 19, 5, 10, 0);
    	Business_Hours__c mondayHours = new Business_Hours__c(Days__c = 'Monday',
    			UTC_Start_Time__c = '05:00',
    			UTC_End_Time__c = '06:00');
    	Business_Hours__c tuesdayHours = new Business_Hours__c(Days__c = 'Tuesday',
    			UTC_Start_Time__c = '09:00',
    			UTC_End_Time__c = '12:00');
    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ mondayHours, tuesdayHours };
    	Integer minutesToAdd = 150;

    	Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

    	Datetime expectedResult = Datetime.newInstance(2017, 6, 20, 10, 40, 0);

    	System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_ReturnsMonday1340_GivenMonday0510AndMonday5Until6AndMonday12Until15And150()
    {
        Datetime startDate = Datetime.newInstance(2017, 6, 19, 5, 10, 0);
        Business_Hours__c mondayMorningHours = new Business_Hours__c(Days__c = 'Monday',
                UTC_Start_Time__c = '05:00',
                UTC_End_Time__c = '06:00');
        Business_Hours__c mondayAfternoonHours = new Business_Hours__c(Days__c = 'Monday',
                UTC_Start_Time__c = '12:00',
                UTC_End_Time__c = '15:00');
        List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ mondayMorningHours, 
                mondayAfternoonHours };
        Integer minutesToAdd = 150;

        Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

        Datetime expectedResult = Datetime.newInstance(2017, 6, 19, 13, 40, 0);

        System.assertEquals(expectedResult, result);
    }

    static testmethod void AddMinutes_ReturnsMonday1340_GivenMonday0510AndMonday12Until15AndMonday5Until6And150()
    {
        Datetime startDate = Datetime.newInstance(2017, 6, 19, 5, 10, 0);
        Business_Hours__c mondayMorningHours = new Business_Hours__c(Days__c = 'Monday',
                UTC_Start_Time__c = '05:00',
                UTC_End_Time__c = '06:00');
        Business_Hours__c mondayAfternoonHours = new Business_Hours__c(Days__c = 'Monday',
                UTC_Start_Time__c = '12:00',
                UTC_End_Time__c = '15:00');
        List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ mondayAfternoonHours,
            mondayMorningHours };
        Integer minutesToAdd = 150;

        Datetime result = BusinessHoursUtilities.AddMinutes(startDate, businessHours, minutesToAdd);

        Datetime expectedResult = Datetime.newInstance(2017, 6, 19, 13, 40, 0);

        System.assertEquals(expectedResult, result);
    }
}