@isTest
public class CountryMapper_Test {
    static testmethod void GetCountryMappingsByCodeSetString_ReturnsDummy_GivenDM()
    {
        Set<String> isoCodes = new Set<String>();
        
        String code1 = 'DM';
        String country1 = 'Dummy';
        TestClass_NationalityToISOCodeCreator.Create(code1, country1);
        CountryMapper countryMapper = new CountryMapper();
        isoCodes.add(code1);
        
        Map<String, String> results = countryMapper.GetCountryMappingsByCode(isoCodes);
        
        System.assertEquals(country1, results.get(code1));
    }
    
    static testmethod void GetCountryMappingsByCodeListUser_ReturnsDummy_GivenDM()
    {
        List<User> users = new List<User>();
        
        String code1 = 'DM';
        String country1 = 'Dummy';
        TestClass_NationalityToISOCodeCreator.Create(code1, country1);
        CountryMapper countryMapper = new CountryMapper();
        User user = new User();
        user.Country_ISO_Code__c = code1;
        users.add(user);
        
        Map<String, String> results = countryMapper.GetCountryMappingsByCode(users);
        
        System.assertEquals(country1, results.get(code1));
    }
    
    static testmethod void MapRecordsByOwnerCountry_ReturnsEmptyMap_GivenEmptyList()
    {
        List<SObject> records = new List<SObject>();
        
        CountryMapper countryMapper = new CountryMapper();
        Map<String, List<SObject>> result = countryMapper.MapRecordsByOwnerCountry(records);
        
        System.AssertNotEquals(null, result);
    }
    
    static testmethod void MapRecordsByOwnerCountry_ReturnsMapIndiaLead_GivenLeadOwnedByIndiaUser()
    {
        User testUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'JLR System Administrator' limit 1][0]);
        
        System.RunAs(testUser) {
            TestClass_NationalityToISOCodeCreator.Create(testUser.Country_ISO_Code__c, 'India');
            
            List<SObject> records = new List<SObject>();
            Lead lead = new Lead();
            lead.OwnerId = testUser.Id;
            records.add(lead);
            
            CountryMapper countryMapper = new CountryMapper();
            Map<String, List<SObject>> result = countryMapper.MapRecordsByOwnerCountry(records);
            
            System.AssertEquals(lead, result.get('India')[0]);
        }
    }
}