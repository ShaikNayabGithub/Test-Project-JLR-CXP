@isTest
public class aopcom_WebRequestControllerRetailerTest {
    static testMethod void validateWebReqControllerRetailer(){
        aopcom_WebRequestControllerRetailers retailer=new aopcom_WebRequestControllerRetailers();
        //We give values to all fields of retailer
        retailer.firstname='Test';
        retailer.lastname='Test'; 
        retailer.birthday=Date.today();
        retailer.email='test@test.com';
        retailer.street='test street';
        retailer.homePhone='8888 88888';
        retailer.mobilePhone='666666666';
        retailer.language='ES';
        //retailer.country='Test country';
        retailer.country='United Kingdom';
        retailer.city='Test city';
        retailer.postalCode='99999';
        retailer.state='Test State';
        retailer.EmailConsentAux=true;
        retailer.PhoneConsentAux=true;
        retailer.PostConsentAux=true;
        retailer.SMSConsentAux=true;


        aop_NationalityToISOCode__c test_nationality = new aop_NationalityToISOCode__c(
        aop_Checkfront_Instance__c='jaguarworldseries.checkfront.com',
        Name='United Kingdom'
        );
        insert test_nationality;
        
        //It takes some accounts whose Secondary_Dealer_Code is different to null
        List<Account> acc=[SELECT Secondary_Dealer_Code__c
                                 FROM Account
                                 WHERE Secondary_Dealer_Code__c!=null];
        //If at least an account has been generated, we are going in
        if(acc.size()>0){
            retailer.cicode=acc.get(0).Secondary_Dealer_Code__c;
        }else{//If there is not an account, we are going in
            retailer.cicode='22222';
        }
        retailer.retailername='test name';
        
        retailer.takeItems();
        retailer.takeItems2();
        //retailer.bringLanguage();
        retailer.getPurchase();
        retailer.selectValues();
        //retailer.setRequest();
        retailer.cicode='22222';
        //retailer.setRequest();
        retailer.checkErrors();
        retailer.verify();
        retailer.checkCICode(); 
        //retailer.insertRequest();
        retailer.setRequest();  
        aop_Area_Configuration__c  test_config = new aop_Area_Configuration__c  
            (aop_Qualify_if_Opportunity__c =true, aop_AWS_Path__c='https://s3-eu-west-1.amazonaws.com/aopuat-uk', 
            aop_Checkfront_AOP_Id__c='9', aop_Auto_Rejection_Enabled__c= true, aop_Auto_Qualification__c='Rules',
            aop_Checkfront_Instance__c='jaguarworldseries.checkfront.com', aop_Checkfront_Token__c='OWE3NjVmY2JhOTViOGMxMTRhZmZkMTI3OGY5MGEwODAwMWZmOTM3Zjo5YjUwZmQzNWMxZGY1ZWQ5ZmJjMWZmZGUwMDlhMGY2YWI2M2VlMzhhMDRmYjBlOTI5NTdmMGI0NDM3MGE1ODE1',
            aop_Community_Permission_Set__c='0PS8E000000CnTb', aop_Community_URL__c='https://uat-retailers.cs87.force.com/TAoP',
            aop_Customer_Queue_Name__c='TAOPT Customer UK', aop_NSC_Contact_Email__c='eharrin5@jaguarlandrover.com',aop_NSC_Contact_Phone__c='07771914126',
            aop_Rebooking_Window__c=10,aop_Retailer_Queue_Name__c='TAOPT Retailer UK',aop_Spotify_Link__c='https://play.spotify.com/',
            aop_Minimum_Age__c=18);
        insert test_config;
        retailer.insertRequest();
        
        Request__c req = [SELECT aop_Home_Phone__c FROM Request__c WHERE First_Name__c = 'Test' AND Last_Name__c = 'Test' ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('888888888', req.aop_Home_Phone__c);
        
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('recaptcha_response_field', 'captcha');   
        System.currentPageReference().getParameters().put('recaptcha_challenge_field', 'challenge');    
        
        
        retailer.verify();
        
    }
}