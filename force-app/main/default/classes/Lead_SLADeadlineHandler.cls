public class Lead_SLADeadlineHandler {
	private final BusinessHours_ByOwnerMapper businessHoursMapper;
	private final Lead_SLADeadlineSetter slaDeadlineSetter;

	private static final String LEAD_OWNER_ID_FIELD = Schema.Lead.OwnerId.getDescribe().getName();
	private static final Schema.DescribeFieldResult USER_ACCOUNT_ID_FIELD = Schema.User.AccountId.getDescribe();


	public Lead_SLADeadlineHandler(BusinessHours_ByOwnerMapper businessHoursMapper,
			Lead_SLADeadlineSetter slaDeadlineSetter)
	{
		this.businessHoursMapper = businessHoursMapper;
		this.slaDeadlineSetter = slaDeadlineSetter;
	}


	public void SetSLADeadline(List<Lead> leads)
	{
		Set<String> ownerIds = SObjectUtilities.GetFieldValues(leads, LEAD_OWNER_ID_FIELD);

		List<User> users = [SELECT AccountId FROM User WHERE Id IN: ownerIds];
		Map<Id, List<SObject>> usersByAccountId = SObjectUtilities.MapByIdField(users, USER_ACCOUNT_ID_FIELD);
		
		List<Business_Hours__c> businessHours = [SELECT Account__c, Account__r.Queue_Id__c, Days__c, 
				UTC_Start_Time__c, UTC_End_Time__c FROM Business_Hours__c 
				WHERE Account__r.Queue_Id__c IN: ownerIds OR Account__c IN: usersByAccountId.keySet()];

		Map<String, List<Business_Hours__c>> businessHoursByOwnerId = this.businessHoursMapper.MapByOwner(businessHours, 
				usersByAccountId);

		this.slaDeadlineSetter.SetSLADeadline(leads, businessHoursByOwnerId);
	}
}