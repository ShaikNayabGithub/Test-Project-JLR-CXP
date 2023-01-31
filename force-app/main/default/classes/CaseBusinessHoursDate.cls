/**
 * Created by Ethan Sargent on 22/10/19.
 */

public with sharing class CaseBusinessHoursDate
{
    public static final string BUSINESS_HOURS_STRING = 'GMT (Used for Case Business Hours)';
    public static final Integer WORK_START = 9;
    public static final Integer WORK_END = 17;

    @InvocableMethod(label='Set Case Calculation Date')
    public static void setCalculationStart(List<Case> dateCases)
    {
        List<String> caseIds = new List<String>();
        for (Case c : dateCases) caseIds.add(c.Id);
        List<Case> cases = [SELECT Id, BusinessHours_Calculation_Date__c, CreatedDate FROM Case WHERE Id IN :caseIds];

        for (Case c : cases)
        {
            Datetime dt = c.CreatedDate;
            if (dt.hour() < WORK_START)
            {
                dt = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 9, 0, 0);
            }
            if (dt.hour() >= WORK_END)
            {
                dt = Datetime.newInstance(dt.year(), dt.month(), dt.day() + 1, 9, 0, 0);
            }
            if (dt.format('E') == 'Sat')
            {
                dt.addDays(2);
            }
            if (dt.format('E') == 'Sun')
            {
                dt.addDays(1);
            }
            System.debug(c.Id);
            System.debug('Fine');
            c.BusinessHours_Calculation_Date__c = dt;
            System.debug('All Fine');
        }
        try
        {
            update cases;
        }
        catch (Exception e)
        {
            System.debug('Error: ' + e.getMessage());
        }
    }
}