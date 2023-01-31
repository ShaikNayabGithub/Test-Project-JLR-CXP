@isTest
public class Batch_cVoiceMenaRoadSideExtract_Test {  
    
    @testSetup static void setup() {
        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE'));
        insert dupList;
        
        Account acc = new Account();        
        acc.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;      
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            acc.LastName += chars.substring(randomNum, randomNum+1);
        }
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';        
        acc.PersonEmail = 'test123@test.com';
        acc.Owner_Retailer__c = '1234567';
        acc.Country_ISO_Code__pc='JP';
        acc.BillingCountry='Japan';
        acc.Is_Primary__c = false;
        insert acc;  
        Event_Details__c eventDetails = new Event_Details__c();
        eventDetails.Incident_Country_Code__c='AE';
        eventDetails.Event_DateTime__c=system.now();
        insert eventDetails;
    }
    
    
    public static testMethod void testBatch() {
        Test.startTest();      
        Account acc = [Select id from account limit 1];
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.AccountId = acc.Id;
        insert ass; 
        Event_Details__c ent = [select Vin__c from Event_Details__c limit 1];
        ent.Vin__c=ass.Id;
        update ent; 
        Database.executeBatch(new Batch_cVoiceMenaRoadSideExtract(), 200);
        Test.stopTest();
    }
    
    public static testMethod void testBatchMENA() {
        Test.startTest();
        Account acc = [Select id from account limit 1];
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.AccountId = acc.Id;
        insert ass; 
        Event_Details__c ent = [select Vin__c from Event_Details__c limit 1];
        ent.Vin__c=ass.Id;       
        update ent; 
        Database.executeBatch(new Batch_cVoiceMenaRoadSideExtract(), 200);
        Test.stopTest();
    }
}