public class CaseUpdateBusinessHours 
{
    public void updateBusinessHoursFromOwner(List<Case> cases)
    {
        Map<Id, User> ownerMap = SObjectUtilities.GetOwnerMap(cases);
        Set<String> countryIsoCodes = SObjectUtilities.GetFieldValues(ownerMap.values(), 
                Schema.User.Country_ISO_Code__c.getDescribe().getName());

        Map<String, BusinessHours> businessHoursByName = GetBusinessHoursByName(countryIsoCodes);

        for(Case currentCase : cases) {
            User owner = ownerMap.get(currentCase.ownerId);
            if(owner == null) { continue; }

            BusinessHours businessHours = businessHoursByName.get(owner.Country_ISO_Code__c);
            if(businessHours == null) { continue; }

            currentCase.BusinessHoursId = businessHours.Id;
        }
    }

    private Map<String, BusinessHours> GetBusinessHoursByName(Set<String> names) {
        List<BusinessHours> busHrs = [SELECT Id, Name FROM BusinessHours WHERE Name IN:names];
        Map<String, BusinessHours> businessHoursByName = new Map<String, BusinessHours>();

        for(BusinessHours businessHour : busHrs) {
            businessHoursByName.put(businessHour.Name, businessHour);
        }

        return businessHoursByName;
    }
}