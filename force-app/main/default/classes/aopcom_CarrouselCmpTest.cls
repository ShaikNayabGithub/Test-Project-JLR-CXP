@isTest
private class aopcom_CarrouselCmpTest {
        
    static testMethod void validatebringEventFeatures() {
            
        //It takes a specific record type
        List<RecordType> rt=[SELECT Id FROM RecordType WHERE DeveloperName='Corporate'];
        //It creates a new Account with the record type obtained before
        Account acc=new Account (Account_Score__c = 0.0 , 
                                 International_Account__c =false, Name='TestClass',RecordTypeId=rt.get(0).Id);
        //It inserts the new Account
        insert acc;
        //It creates a new Contact related to the Account created before
        Contact cont = new Contact (AccountId =acc.Id, aop_Country__c='Italy',  
                                    DoNotCall=false,Email='standardcontact@testorg.com', 
                                    FirstName='Test', LastName='Test', Gender__c='Male',HasOptedOutOfEmail=false,
                                    HasOptedOutOfFax=false,HomePhone='918232323',Jaguar_Email_Opt_Out__c=false, Jaguar_Gold_Starred__c=false,
                                    Jaguar_Opt_Out__c=false,Language__c='Czech' );
        //It inserts the new aop_Area_Configuration__c
        insert cont;
        //It obtains the profile related to "Customer Community Login User"
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];
        //It creates a new User whose profile was obtained before. The Account is related to the Contact created before
        User user1 = new User(Alias = 'userTest', Email='stand@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, ContactId=cont.Id, TimeZoneSidKey='America/Los_Angeles', UserName='stand@testorg.com');
        //It inserts the new User
        System.RunAs(new User(Id=UserInfo.getUserId())){
        insert user1;
        }
        //It creates a new Campaign   
        Campaign camp= new Campaign(Name='testCampaign',aop_Checkfront_Instance__c='test.checkfront.instance',  aop_Event_Features__c='Smart Cone, Demonstration Laps', Market_ID__c = 'IN');
        //It inserts the new Campaign
        insert camp;
        //It creates a new CampaignMember using data from the Campaign and Contact created before    
        CampaignMember cmember= new CampaignMember (aop_CF_Status__c = ' Pending',aop_Send_Results_Notification__c = false, 
                                                    aop_Session_End__c = Datetime.valueOf('2030-5-26 12:00:00'),aop_Session_Start__c = Datetime.valueOf('2030-5-25 13:00:00'), 
                                                    CampaignId=camp.Id, ContactId=cont.Id);
        //It inserts the new CampaignMember
        insert cmember;
        //It runs in a context with user1   
        System.runAs(user1){
            aopcom_CarrouselCmp.bringEventFeatures();
        }

    }
    
}