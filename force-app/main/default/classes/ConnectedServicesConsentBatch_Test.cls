@isTest
public class ConnectedServicesConsentBatch_Test {
    static testMethod void getConsents_Test1() {
        DataUseLegalBasis lb = new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar');
        insert lb;

        DataUsePurpose dupurpose = new DataUsePurpose(LegalBasisId = lb.Id, Name = 'Vehicle InControl / Connected Car', Translatable_Value__c = 'Vehicle InControl / Connected Car', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP');
        insert dupurpose;

        CreateTestData tdata = new CreateTestData();
        Account acc = tdata.createPersonalAccount();
        acc.et4ae5__HasOptedOutOfMobile__pc = true;
        acc.PersonDoNotCall = true;
        acc.PersonHasOptedOutOfEmail = true;
        acc.Direct_Mail_Opt_Out__pc = true;
        insert acc;

        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Land Rover');
        vehicle.VIN__c = '1234Test';
        update vehicle;

        Role__c role = new Role__c();
        role.Account__c = acc.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;

        acc = [Select Id, LastName, PersonEmail, PersonIndividualId From Account Where Id = :acc.Id];

        Connected_Services_Consent__c csc = new Connected_Services_Consent__c(VIN__c = vehicle.VIN__c, Last_Name__c = acc.LastName, Email_Address__c = acc.PersonEmail, VHS_Accepted__c = 'Y', VHS_Accepted_Date__c = '20/06/2022');
        insert csc;

        test.startTest();

        Database.executeBatch(new ConnectedServicesConsentBatch(), 50);
        

        test.stopTest();

        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();
        String connectedCar = consentSettings.get('Purpose_Conntected_Car').CXP_Name__c;
        Set<Id> purposeIds = new Set<Id>();

        for (DataUsePurpose dup : [Select Id, Name, LegalBasis.Name, LegalBasisId From DataUsePurpose Where Translatable_Value__c = :connectedCar And LegalBasis.Retailer_Only__c = false]) {
            purposeIds.add(dup.Id);
        }

        DateTime captureDate = DateTime.newInstance(2022,6,20);
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurposeId, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId = :acc.PersonIndividualId And DataUsePurposeId in :purposeIds And Retailer__c = null Order By CaptureDate asc]) {
            system.assertEquals(cptc.PrivacyConsentStatus, 'OptIn');
            system.assertEquals(cptc.CaptureDate, captureDate);
        }

        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.Schedule('ScheduledClassTest', CRON_EXP, new ConnectedServicesConsentBatch());

    }
}