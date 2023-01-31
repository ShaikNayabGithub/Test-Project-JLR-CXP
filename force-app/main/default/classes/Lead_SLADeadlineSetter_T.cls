@isTest
public class Lead_SLADeadlineSetter_T {
	static testMethod void SetSLADeadline_SetsLead1SLADeadlineTo0530_GivenNowIs0130AndEmptyMap() 
    {
    	Lead_SLADeadlineSetter slaDeadlineSetter = new Lead_SLADeadlineSetter();

    	Lead lead1 = new Lead();

    	List<Lead> leads = new List<Lead>{ lead1 };
    	Map<String, List<Business_Hours__c>> businessHoursByOwnerId = new Map<String, List<Business_Hours__c>>{ };

    	DateTime dummyNow = Datetime.newInstance(0, 0, 0, 1, 30, 0);
    	DateTimeExtension.Now = dummyNow;

    	slaDeadlineSetter.SetSLADeadline(leads, businessHoursByOwnerId);

    	Datetime expected = Datetime.newInstance(0, 0, 0, 5, 30, 0);
    	System.assertEquals(expected, lead1.SLA_Deadline__c);
    }

    static testMethod void SetSLADeadline_SetsLead1SLADeadlineTo0900_GivenNowIs0130And5To10HoursByUser1AndLeadOwnedByUser1() 
    {
    	Lead_SLADeadlineSetter slaDeadlineSetter = new Lead_SLADeadlineSetter();

    	User user1;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		user1 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	}

    	Lead lead1 = new Lead(OwnerId = user1.Id);
    	Business_Hours__c businessHours1 = new Business_Hours__c(Days__c = 'Monday',
    			UTC_Start_Time__c = '05:00',
    			UTC_End_Time__c = '10:00');

    	List<Lead> leads = new List<Lead>{ lead1 };
    	Map<String, List<Business_Hours__c>> businessHoursByOwnerId = new Map<String, List<Business_Hours__c>>{
    			user1.Id => new List<Business_Hours__c> { businessHours1 } };

    	DateTime dummyNow = Datetime.newInstance(2017, 6, 19, 1, 30, 0);
    	DateTimeExtension.Now = dummyNow;

    	slaDeadlineSetter.SetSLADeadline(leads, businessHoursByOwnerId);

    	Datetime expected = Datetime.newInstance(2017, 6, 19, 9, 0, 0);
    	System.assertEquals(expected, lead1.SLA_Deadline__c);
    }
}