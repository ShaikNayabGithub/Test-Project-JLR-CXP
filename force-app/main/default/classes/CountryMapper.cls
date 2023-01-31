public class CountryMapper {
    private Map<String, aop_NationalityToISOCode__c> countryMappingSettings = aop_NationalityToISOCode__c.getAll();
    private Map<String, aop_NationalityToISOCode__c> countryMappingsByLabel = new Map<String, aop_NationalityToISOCode__c>();
    
    public CountryMapper()
    {
        for(aop_NationalityToISOCode__c countryMappingSetting : countryMappingSettings.values()) {
            this.countryMappingsByLabel.put(countryMappingSetting.Name.toLowerCase(), countryMappingSetting);
        }
        List<Country_Label_To_Name_Mapping__c>  countryLabelToNameMappings = Country_Label_To_Name_Mapping__c.getAll().values();
        for(Country_Label_To_Name_Mapping__c countryLabelToNameMapping : countryLabelToNameMappings) {
            countryMappingsByLabel.put(countryLabelToNameMapping.Name.toLowerCase(), countryMappingSettings.get(countryLabelToNameMapping.Country_Standard_Name__c));
        }
    }
    
    
    public Map<String, List<SObject>> MapRecordsByOwnerCountry(List<SObject> records)
    {
        Map<Id, User> userMap = SObjectUtilities.GetOwnerMap(records);     
        
        Map<String, String> countryMappings = this.GetCountryMappingsByCode(userMap.Values());
        
        Map<String, List<SObject>> recordMap = new Map<String, List<SObject>>();
        
        for(SObject record : records){
            String ownerId = String.valueOf(record.get('OwnerId'));
            //if(record.getSObjectType() == Schema.Contact.getSObjectType())
            //{
            //    ownerId = String.valueOf(record.get('Account_Pseudo_Owner_Id__c'));
            //}
            //else if(record.getSObjectType() == Schema.Account.getSObjectType())
            //{
            //    ownerId = String.valueOf(record.get('Pseudo_Account_Owner__c'));
            //}
            //else
            //{
            //    ownerId = String.valueOf(record.get('OwnerId'));
            //}
            User owner = userMap.get(ownerId);
            if(owner == null) {//in case owned by queue
                 owner = userMap.get(UserInfo.getUserId());
            }
            String country = countryMappings.get(owner.Country_ISO_Code__c);
            
            List<SObject> countryRecords = recordMap.get(country);
            if(countryRecords == null) {
                countryRecords = new List<SObject>();
                recordMap.put(country, countryRecords);
            }
            countryRecords.add(record);
        }
        
        return recordMap;
    }
    
    public Map<String, String> GetCountryMappingsByCode(List<User> users)
    {
        Set<String> isoCodes = new Set<String>();
        for(User user : users) {
            isoCodes.add(user.Country_ISO_Code__c);
        }
        return GetCountryMappingsByCode(isoCodes);
    }
    
    public Map<String, String> GetCountryMappingsByCode(Set<String> isoCodes)
    {
        Map<String, String> countryMappings = new Map<String, String>();
        for(aop_NationalityToISOCode__c countryMappingSetting : this.countryMappingSettings.values()){
            if(isoCodes.contains(countryMappingSetting.aop_ISO_Code__c)) {
                countryMappings.put(countryMappingSetting.aop_ISO_Code__c, countryMappingSetting.Name);
            }
        }
        
        return countryMappings;
    }
    
    public aop_NationalityToISOCode__c GetSettingByLabel(String label)
    {
        return this.countryMappingsByLabel.get(label.toLowerCase());
    }
}