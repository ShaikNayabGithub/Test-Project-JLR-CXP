@isTest
public class BatchToUpdateDefaultflagTest {
    static testMethod void createOpp(){
        //Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Sales Executive AUS'];
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'JLR System Administrator'];
        //Create User
        User owner = new User(Country_ISO_Code__c = 'AU', Username = 'xyztest123@test.com', LastName = 'Test1 default', 
                              Email = 'abc1@bbtest.com', Alias = 'barry', EmailEncodingKey = 'UTF-8', ProfileId = userProfile.id, TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', market__c = 'AU');
        insert owner;
        //create Opportunity
        Opportunity opp = new Opportunity(
        	Name = 'TestOpp',
            ownerId = owner.Id,
            StageName = 'Qualified',
			CloseDate = Date.parse('12/12/2020')           
        );
        insert opp;
        Test.startTest();
        	BatchToUpdateDefaultflag obj = new BatchToUpdateDefaultflag();
        	Database.executeBatch(obj);
        Test.stopTest();
    }

}