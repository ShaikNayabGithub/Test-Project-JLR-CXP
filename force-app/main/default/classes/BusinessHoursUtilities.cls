public class BusinessHoursUtilities {
	public static DateTime AddMinutes(Datetime startDate, List<Business_Hours__c> businessHours, 
			Integer minutesToAdd)
	{
        if(minutesToAdd == null){
            return startDate;
        }
        
		if(businessHours == null || businessHours.Size() == 0) {
			return startDate.AddMinutes(minutesToAdd);
		}

		Datetime currentDate = Datetime.newInstance(startDate.getTime());

		Business_Hours__c businessHour = GetNextHours(businessHours, startDate);
		if(businessHour == null) {
			Date nextDay = currentDate.date().addDays(1);
			Time startOfDay = Time.newInstance(0, 0, 0, 0);
			Datetime tomorrow = Datetime.newInstance(nextDay, startOfDay);
			return AddMinutes(tomorrow, businessHours, minutesToAdd);
		}

		Time startTime = GetTime(businessHour.UTC_Start_Time__c);
		Time endTime = GetTime(businessHour.UTC_End_Time__c);

		Integer minutesPermitted = 0;
		if(startTime > currentDate.Time()) {
			currentDate = Datetime.newInstance(currentDate.date(), startTime);
			minutesPermitted = GetMinutes(endTime) - GetMinutes(startTime);
		} else {
			minutesPermitted = GetMinutes(endTime) - GetMinutes(currentDate.Time());
		}

		if(minutesPermitted >= minutesToAdd) {
			return currentDate.AddMinutes(minutesToAdd);
		} else {
			currentDate = currentDate.AddMinutes(minutesPermitted);
			return AddMinutes(currentDate, businessHours, minutesToAdd - minutesPermitted);
		}
	}


	private static Time GetTime(String timeString)
	{
		List<String> splitString = timeString.split(':');
		return Time.newInstance(Integer.valueOf(splitString[0]), Integer.valueOf(splitString[1]), 0, 0);
	}

	private static Integer GetMinutes(Time inputTime)
	{
		Integer minutes = inputTime.minute();
		return minutes + (60 * inputTime.hour());
	}

	private static Business_Hours__c GetNextHours(List<Business_Hours__c> businessHours, Datetime startDate)
	{
		String currentDay = startDate.format('EEEE');
		Time earliestTime = null;
		Integer earliestIndex = -1;

		for(Integer i = 0; i < businessHours.Size(); i++) {
			if(!businessHours[i].Days__c.contains(currentDay)) continue;

			Time thisStartTime = GetTime(businessHours[i].UTC_Start_Time__c);
			Time thisEndTime = GetTime(businessHours[i].UTC_End_Time__c);
			if(thisEndTime > startDate.time() && (earliestTime == null || thisStartTime < earliestTime)) {
				earliestTime = thisStartTime;
				earliestIndex = i;
			}
		}

		if(earliestIndex > -1) {
			return businessHours[earliestIndex];
		}
		return null;
	}
}