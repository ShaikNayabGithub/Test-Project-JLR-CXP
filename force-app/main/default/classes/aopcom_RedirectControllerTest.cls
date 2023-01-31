@isTest
public without sharing class aopcom_RedirectControllerTest {
    
    static testMethod void validateredirect(){
       
        //It creates a new "aop_NationalityToISOCode__c" object and it fills its fields
        aop_NationalityToISOCode__c customSet= new aop_NationalityToISOCode__c();
        customSet.aop_Checkfront_Instance__c='checkfront.test.com';
        customSet.aop_ISO_Code__c='TES';
        customSet.Name='test';
        //It inserts the new aop_NationalityToISOCode__c
        insert customSet;
              
        //It creates a new Area Configuration using information from the "aop_NationalityToISOCode__c" object created before 
        aop_Area_Configuration__c aconf=new aop_Area_Configuration__c(aop_Customer_Queue_Name__c='test',
                                                                      aop_Minimum_Age__c=18, aop_NSC_Contact_Email__c='test@test.com',
                                                                      aop_NSC_Contact_Phone__c='464637832',aop_Rebooking_Window__c=12,
                                                                      aop_Retailer_Queue_Name__c='test', aop_Spotify_Link__c='test.link.com',
                                                                      aop_Checkfront_Instance__c= customSet.aop_Checkfront_Instance__c,
                                                                      aop_AWS_Path__c='aws.test.url', aop_Checkfront_AOP_Id__c='AAA',
                                                                      aop_Checkfront_Token__c ='SDFREGTSSDSSSS', aop_Community_Permission_Set__c='1',
                                                                      aop_Community_URL__c='www.url.com');
        //It inserts the new aop_Area_Configuration__c
        insert aconf;
        //It takes a specific record type
        List<RecordType> rt=[SELECT Id FROM RecordType WHERE DeveloperName='Corporate'];
        //It creates a new Account with the record type obtained before
        Account acc=new Account (Account_Score__c = 0.0 , 
                                 International_Account__c =false, Name='TestClass',RecordTypeId=rt.get(0).Id);
        //It inserts the new Account
        insert acc;
        //It creates a new Contact related to the Account created before
        Contact cont = new Contact (AccountId =acc.Id, aop_Country__c= 'United Kingdom',//customSet.aop_ISO_Code__c,  
                                    DoNotCall=false,Email='standardcontact@testorg.com', 
                                    FirstName='Test', LastName='Test', Gender__c='Male',HasOptedOutOfEmail=false,
                                    HasOptedOutOfFax=false,HomePhone='918232323',Jaguar_Email_Opt_Out__c=false, Jaguar_Gold_Starred__c=false,
                                    Jaguar_Opt_Out__c=false,Language__c='Czech' );
        //It inserts the new Contact
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
        Campaign camp= new Campaign(Name='testCampaign',aop_Checkfront_Instance__c=customSet.aop_Checkfront_Instance__c, Market_ID__c = 'IN');
        //It inserts the new Campaign
        insert camp;
        //It creates a new CampaignMember using data from the Campaign and Contact created before
        CampaignMember cmember= new CampaignMember (aop_CF_Status__c = ' Pending',aop_Send_Results_Notification__c = false, 
                                                    aop_Session_End__c = Datetime.valueOf('2030-5-24 12:00:00'),aop_Session_Start__c = Datetime.valueOf('2030-5-25 13:00:00'), 
                                                    CampaignId=camp.Id, ContactId=cont.Id);
        //It inserts the new CampaignMember
        insert cmember;
        //It runs in a context with user1
        System.runAs(user1){
            aopcom_RedirectController redirect=new aopcom_RedirectController();
            redirect.redirect();
            
        }        
    }
        
}