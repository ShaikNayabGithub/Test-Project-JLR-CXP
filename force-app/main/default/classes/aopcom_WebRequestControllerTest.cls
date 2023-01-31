@isTest
public class aopcom_WebRequestControllerTest {
    static testMethod void validateWebReqController(){
        
    
        Vehicle_specification__c testVehicle1 =new Vehicle_specification__c (Make__c = null, aop_JLR_Owned__c= true );
        insert testVehicle1;
        system.debug('valor de testVehicle1= '+testVehicle1);
        //Vehicle_specification__c testVehicle2 =new Vehicle_specification__c (Make__c=   'a0Z24000007bJHYEA2');
        Vehicle_Specification__c testVehicle2 = TestClass_VehicleSpecificationBuilder.BuildMake();
        
        aopcom_WebRequestController retailer=new aopcom_WebRequestController();
        //We give values to all fields of retailer
        retailer.firstname='Test';
        retailer.lastname='Test';
        retailer.birthday=Date.today();
        retailer.email='test@test.com';
        retailer.street='test street';
        retailer.homePhone='888888888';
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
        retailer.validLicenseAux=true;
        retailer.Purch='test';

        
        aop_NationalityToISOCode__c test_nationality = new aop_NationalityToISOCode__c(
        aop_Checkfront_Instance__c='jaguarworldseries.checkfront.com',
        Name='United Kingdom'
        );
        insert test_nationality;
        
        /*
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
        */
        
        system.debug('valor de testVehicle2= '+testVehicle2);
        //It takes all the Vehicle specification that have no maker as a 'parent' (Make__c)
        List<Vehicle_specification__c> maker=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,
                                             Is_India__c,Is_Japan__c,LastModifiedById,LastModifiedDate,LastReferencedDate,
                                             LastViewedDate,Make__c,Model_Code__c,Model__c,Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                             FROM Vehicle_Specification__c 
                                             WHERE Make__c = null AND aop_JLR_Owned__c= true ];
        system.debug('valor de maker '+maker);
        //If the size of maker is greater than 0, we are going in
        if(maker.size()>0){
            retailer.IntMake=String.valueOf(maker.get(0).Id);
            }
        //It takes all the Vehicle specification that have no maker as a 'parent' (Make__c)
        List<Vehicle_specification__c> model=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,Is_India__c,Is_Japan__c,
                                              LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Make__c,Model_Code__c,Model__c,
                                              Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                              FROM Vehicle_Specification__c 
                                              WHERE Make__c != null];
        system.debug('valor de model '+model);
        //If the size of model is greater than 0, we are going in
        if(model.size()>0){
            retailer.IntMod=String.valueOf(model.get(0).Id);
            }
        retailer.validLicense=true;
 
        retailer.takeItems();
        retailer.takeItems2();
        retailer.getPurchase();
        retailer.selectValues();
        retailer.checkErrors();
        retailer.verify();
        retailer.takeItems();
       /*
        Request__c  test_request = new Request__c(aop_Valid_Driving_License__c=false, Consent_Email__c=false, Consent_Phone__c=false, 
                                                 Consent_Post__c=false, Consent_SMS__c=false,
                                                 CurrencyIsoCode='GBP', Email__c='dazfifa2@outlook.com',Finance_Interest__c=false,
                                                 aop_Status__c='Submitted', Last_Name__c='Proof', aop_Country__c='United Kingdom',
                                                 Language__c='English (UK)', aop_Source__c='Campaign', RecordTypeId='0128E0000008dKqQAI',
                                                 aop_Event_Type__c='AOP Request', OwnerId='0058E000000xDDgQAM');
        
        insert test_request;  
        
        aop_Area_Configuration__c  test_config = new aop_Area_Configuration__c  
            (aop_Qualify_if_Opportunity__c =true, aop_AWS_Path__c='https://s3-eu-west-1.amazonaws.com/aopuat-uk', 
            aop_Checkfront_AOP_Id__c='9', aop_Auto_Rejection_Enabled__c= true, aop_Auto_Qualification__c='Rules',
            aop_Checkfront_Instance__c='jaguarworldseries.checkfront.com', aop_Checkfront_Token__c='OWE3NjVmY2JhOTViOGMxMTRhZmZkMTI3OGY5MGEwODAwMWZmOTM3Zjo5YjUwZmQzNWMxZGY1ZWQ5ZmJjMWZmZGUwMDlhMGY2YWI2M2VlMzhhMDRmYjBlOTI5NTdmMGI0NDM3MGE1ODE1',
            aop_Community_Permission_Set__c='0PS8E000000CnTb', aop_Community_URL__c='https://uat-retailers.cs87.force.com/TAoP',
            aop_Customer_Queue_Name__c='TAOPT Customer UK', aop_NSC_Contact_Email__c='eharrin5@jaguarlandrover.com',aop_NSC_Contact_Phone__c='07771914126',
            aop_Rebooking_Window__c=10,aop_Retailer_Queue_Name__c='TAOPT Retailer UK',aop_Spotify_Link__c='https://play.spotify.com/',
            aop_Minimum_Age__c=18, Name='UK', aop_New_Record_Owner__c= '0058E0000014AZ9QAM');
        insert test_config;
*/
        
        //If the sizes of model and maker are greater than 0, we are going in
        if(model.size()>0 && maker.size()>0){     
            //retailer.setRequest();
            }
        
    }
}