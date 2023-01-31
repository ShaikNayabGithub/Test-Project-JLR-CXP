@isTest
public class OwnerISOCodeSetter_T {
    static testmethod void SetISOCodes_DoesNotFail_GivenEmptyList()
    {
        OwnerISOCodeSetter ownerISOSetter = new OwnerISOCodeSetter();
        
        List<Lead> records = new List<Lead>();
        
        ownerISOSetter.SetISOCodes(records);
        
        System.Assert(true);
    }
    
    static testmethod void SetISOCodes_ReturnsSetsOwnersISOCodeToJP_GivenLeadOwnedByUserWithISOCodeJP()
    {
        User testOwner = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
        testOwner.Market__c = 'JP';
        testOwner.Country_ISO_Code__c = 'JP';
        update testOwner;
        
        OwnerISOCodeSetter ownerISOSetter = new OwnerISOCodeSetter();
        
        List<Lead> records = new List<Lead>();
        System.runAs(new User(Id=UserInfo.getUserId())) {
	        Lead lead = TestClass_LeadCreator.CreateLead();
	        lead.OwnerId = testOwner.Id;
	        records.add(lead);
        }
        
        ownerISOSetter.SetISOCodes(records);
        
        System.AssertEquals(testOwner.country_ISO_code__c, records[0].Owner_ISO_Code__c);
    }
}