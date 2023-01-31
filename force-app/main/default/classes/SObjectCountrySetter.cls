public class SObjectCountrySetter{
    private final static String ISOFieldName = 'Country_ISO_Code__c';
    
    private final CountryMapper countryMapper = new CountryMapper();// bad, inject when have time!
    
    public void SetCountryFromOwner(List<SObject> records, List<Schema.DescribeFieldResult> addressCountryFields)
    {
        List<String> addressFieldNames = DescribeFieldResultExtensions.GetNames(addressCountryFields);
        
        Map<Id, User> userMap = SObjectUtilities.GetOwnerMap(records);
        Map<String, String> countryMappings = this.countryMapper.GetCountryMappingsByCode(userMap.Values());
        
        for(SObject record: records) {
            String country = this.GetCountry(record, addressFieldNames);
            
            if(String.isNotEmpty(country)) {
                this.SetISOCode(record, country);
            }
            else {
                String recordCode = this.GetCountryCode(record, userMap);
                country = countryMappings.get(recordCode);
                
                record.put(ISOFieldName, recordCode);
                SObjectUtilities.SetMultiple(record, addressFieldNames, country);
            }
        }
    }

    public void EqualiseCountryAndCodes(List<SObject> records, List<SObject> oldRecords, Schema.DescribeFieldResult addressCountryField)
    {
        Set<String> isoCodes = SObjectUtilities.GetFieldValues(records, ISOFieldName);
        Map<String, String> countryMappings = this.countryMapper.GetCountryMappingsByCode(isoCodes);
        
        for(integer i = 0; i < records.size(); i++){
            this.EqualiseCountryAndCode(records[i], oldRecords[i], addressCountryField, countryMappings);
        }
    }
    
    private String GetCountryCode(SObject record, Map<Id, User> userMap)
    {
        String recordCode = (String)record.get(ISOFieldName);
                
        if(String.isEmpty(recordCode)) {
            Id recordOwner = (Id)record.get('OwnerId');
            if(record.getSObjectType() == Schema.Contact.getSObjectType())
            {
                recordOwner = (Id)record.get('ownerid');
            }
            if(record.getSObjectType() == Schema.Account.getSObjectType())
            {
                recordOwner = (Id)record.get('ownerid');
            }
            if(recordOwner == null)
            {
                recordOwner = UserInfo.getUserId();
            }
            if(recordOwner.getSObjectType().getDescribe().getName() != 'User'){
                recordOwner = UserInfo.getUserId();
            }
            recordCode = userMap.get(recordOwner).Country_ISO_Code__c;
        }
        return recordCode;
    }
    
    private String GetCountry(SObject record, List<String> countryFields)
    {
        String country = '';
        for(String countryField : countryFields){
            if(String.isNotEmpty(country)) { break; }
            country = (String)record.get(countryField);
        }
        return country;
    }

    private void EqualiseCountryAndCode(SObject record, SObject oldRecord, Schema.DescribeFieldResult addressCountryField, Map<String, String> countryMappings)
    {
        string addressFieldName = addressCountryField.getName();
        String addressCountry = (String)record.get(addressFieldName);
        String isoCode = (String)record.get(ISOFieldName);

        boolean isoCodeChanged = (String.isNotEmpty(isoCode) && isoCode != (String)oldRecord.get(ISOFieldName));
        boolean countryNameChanged = (String.isNotEmpty(addressCountry) && !addressCountry.equals((String)oldRecord.get(addressFieldName)));

        if(!isoCodeChanged && countryNameChanged){
            this.SetISOCode(record, addressCountry);
        } else if(isoCodeChanged && !countryNameChanged){
            record.put(addressFieldName, countryMappings.get(isoCode));
        }
    }

    private void SetISOCode(SObject record, String countryLabel)//change this!
    {
        aop_NationalityToISOCode__c countryCodeMapping = this.countryMapper.GetSettingByLabel(countryLabel);
        if(countryCodeMapping == null) {return;}
        record.put(ISOFieldName, countryCodeMapping.aop_ISO_Code__c);
    }
}