public class BusinessHours_ByOwnerMapper {
	public Map<String, List<Business_Hours__c>> MapByOwner(List<Business_Hours__c> businessHours, 
			Map<Id, List<SObject>> usersByAccountId)
	{
		Map<String, List<Business_Hours__c>> businessHoursByOwnerId = new Map<String, List<Business_Hours__c>>();


		for(Business_Hours__c businessHour : businessHours) {
			List<SObject> businessHourUsers = usersByAccountId.get(businessHour.Account__c);
			Set<Id> businessHourOwnerIds = new Set<Id>();

			if(businessHourUsers != null){
				for(SObject user : businessHourUsers) {
					businessHourOwnerIds.add(user.Id);
				}
			} 
			if(String.isNotBlank(businessHour.Account__r.Queue_Id__c)) {
				businessHourOwnerIds.add(businessHour.Account__r.Queue_Id__c);
			}

			for(Id ownerId : businessHourOwnerIds) {
				List<Business_Hours__c> businessHourMappedList = businessHoursByOwnerId.get(ownerId);
				if(businessHourMappedList == null) {
					businessHourMappedList = new List<Business_Hours__c>();
					businessHoursByOwnerId.put(ownerId, businessHourMappedList);
				}
				businessHourMappedList.add(businessHour);
			}
		}


		return businessHoursByOwnerId;
	}
}