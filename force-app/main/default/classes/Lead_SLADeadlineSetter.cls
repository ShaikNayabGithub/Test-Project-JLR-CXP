public class Lead_SLADeadlineSetter {
	private static final Integer SLA_MINUTES = 60*4;


	public void SetSLADeadline(List<Lead> leads, Map<String, List<Business_Hours__c>> businessHoursByOwnerId)
	{
		for(Lead lead : leads) {
			List<Business_Hours__c> businessHours = businessHoursByOwnerId.get(lead.OwnerId);
			if(businessHours == null || businessHours.Size() == 0) {
				lead.SLA_Deadline__c = DateTimeExtension.Now.addMinutes(SLA_MINUTES);
				continue;
			}

			lead.SLA_Deadline__c = BusinessHoursUtilities.AddMinutes(DateTimeExtension.Now, businessHours, SLA_MINUTES);
		}
	}
}