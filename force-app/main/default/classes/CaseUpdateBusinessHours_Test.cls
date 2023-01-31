@isTest
public class CaseUpdateBusinessHours_Test {
    
    
    static testmethod void TestCaseUpdateBusinessHours()
    {
        CaseUpdateBusinessHours test = new CaseUpdateBusinessHours();
        
        BusinessHours bh = [SELECT ID, Name FROM BUSINESSHOURS WHERE Name =: 'IN' LIMIT 1];
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'JLR System Administrator'];
        User owner = new User(Country_ISO_Code__c = bh.name, Username = 'xyzabc@b.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', ProfileId = userProfile.id, LanguageLocaleKey = 'en_US', market__c = 'BR');
        insert owner;
        Case c = new Case(Case_Contact_Email__c = 'test123@test.com');
        
        System.runAs(owner)
        {
            insert c;
        }
                
        List<Case> caseList = new List<Case>();
        caseList = [SELECT ID, OwnerId FROM Case];
        
        test.updateBusinessHoursFromOwner(caseList);
        
        Case checkCase = [SELECT ID, BusinessHoursID FROM Case WHERE ID =: c.id];
        
        System.AssertEquals(checkCase.BusinessHoursID, bh.id);
        
    }
    
    
}