@isTest
private class aopcom_LocationCmpTest {
    static testMethod void validategetLocation() {
        List<RecordType> rt=[SELECT Id FROM RecordType WHERE DeveloperName='Corporate'];
        Account acc=new Account (Account_Score__c = 0.0 , 
                                International_Account__c =false, Name='TestClass',RecordTypeId=rt.get(0).Id);
        insert acc;
        
        Contact cont = new Contact (AccountId =acc.Id, aop_Country__c='Italy',  
                                      DoNotCall=false,Email='standardcontact@testorg.com', 
                                      FirstName='Test', LastName='Test', Gender__c='Male',HasOptedOutOfEmail=false,
                                      HasOptedOutOfFax=false,HomePhone='918232323',Jaguar_Email_Opt_Out__c=false, Jaguar_Gold_Starred__c=false,
                                      Jaguar_Opt_Out__c=false,Language__c='Czech' );
        insert cont;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];

        User user1 = new User(Alias = 'userTest', Email='stand@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, ContactId=cont.Id, TimeZoneSidKey='America/Los_Angeles', UserName='stand@testorg.com');
        System.RunAs(new User(Id=UserInfo.getUserId())){
        insert user1;
        }
        
        Campaign camp= new Campaign(Name='testCampaign',aop_Checkfront_Instance__c='test.checkfront.instance', Market_ID__c = 'IN');
        insert camp;
        
        CampaignMember cmember= new CampaignMember (aop_CF_Status__c = ' Pending',aop_Send_Results_Notification__c = false, 
                                                    aop_Session_End__c = Datetime.valueOf('2030-5-24 12:00:00'),aop_Session_Start__c = Datetime.valueOf('2030-5-25 13:00:00'), 
                                                    CampaignId=camp.Id, ContactId=cont.Id);     
        insert cmember;
        System.runAs(user1){
            aopcom_LocationCmp.getLocation();
        }
    }   
}