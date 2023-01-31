@isTest
public class GPC_ConsentManagementController_Test {
    static testMethod void getConsents_Test() {
        CreateTestData tdata = new CreateTestData();
        tdata.loadConsents();
        Account acc = tdata.createPersonalAccount();
        insert acc;
        Lead ld = tdata.createLead(acc);
        insert ld;

        test.startTest();

        GPC_ConsentManagementController.ConsentWrapper result;
        result = GPC_ConsentManagementController.getConsents(acc.Id);
        system.assertEquals(result.isIndividual, true);

        result = GPC_ConsentManagementController.getConsents(ld.Id);
        system.assertEquals(result.leadConverted, false);

        test.stopTest();

    }

    static testMethod void updateConsents_Test() {
        CreateTestData tdata = new CreateTestData();
        tdata.loadConsents();
        Account acc = tdata.createPersonalAccount();
        insert acc;
        acc = [Select Id, PersonIndividualId From Account where Id = :acc.Id];
        Lead ld = tdata.createLead(acc);
        ld.IndividualId = acc.PersonIndividualId;
        insert ld;


        DataUseLegalBasis legalBais = [Select Id From DataUseLegalBasis];
        DataUsePurpose purpose = [Select Id From DataUsePurpose];

        test.startTest();

        GPC_ConsentManagementController.updateConsents(acc.Id, legalBais.Id, purpose.Id, 'Email', 'OptIn');

        acc = [Select Id, PersonHasOptedOutOfEmail, PersonDoNotCall, et4ae5__HasOptedOutOfMobile__pc, Direct_Mail_Opt_Out__pc From Account where Id = :acc.Id];
        system.assertEquals(acc.PersonHasOptedOutOfEmail, false);
        system.assertEquals(acc.PersonDoNotCall, false);
        system.assertEquals(acc.et4ae5__HasOptedOutOfMobile__pc, false);
        system.assertEquals(acc.Direct_Mail_Opt_Out__pc, false);

        ld = [Select Id, HasOptedOutOfEmail, DoNotCall, et4ae5__HasOptedOutOfMobile__c, Whitemail_Opt_Out__c From Lead where Id = :ld.Id];
        system.assertEquals(ld.HasOptedOutOfEmail, false);
        system.assertEquals(ld.DoNotCall, false);
        system.assertEquals(ld.et4ae5__HasOptedOutOfMobile__c, false);
        system.assertEquals(ld.Whitemail_Opt_Out__c, false);

        GPC_ConsentManagementController.updateConsents(acc.Id, legalBais.Id, null, 'Email', 'OptOut');
        
        acc = [Select Id, PersonHasOptedOutOfEmail, PersonDoNotCall, et4ae5__HasOptedOutOfMobile__pc, Direct_Mail_Opt_Out__pc From Account where Id = :acc.Id];
        system.assertEquals(acc.PersonHasOptedOutOfEmail, true);
        system.assertEquals(acc.PersonDoNotCall, false);
        system.assertEquals(acc.et4ae5__HasOptedOutOfMobile__pc, false);
        system.assertEquals(acc.Direct_Mail_Opt_Out__pc, false);

        ld = [Select Id, HasOptedOutOfEmail, DoNotCall, et4ae5__HasOptedOutOfMobile__c, Whitemail_Opt_Out__c From Lead where Id = :ld.Id];
        system.assertEquals(ld.HasOptedOutOfEmail, true);
        system.assertEquals(ld.DoNotCall, false);
        system.assertEquals(ld.et4ae5__HasOptedOutOfMobile__c, false);
        system.assertEquals(ld.Whitemail_Opt_Out__c, false);

        GPC_ConsentManagementController.updateConsents(acc.Id, legalBais.Id, null, null, 'OptOut');
        
        acc = [Select Id, PersonHasOptedOutOfEmail, PersonDoNotCall, et4ae5__HasOptedOutOfMobile__pc, Direct_Mail_Opt_Out__pc From Account where Id = :acc.Id];
        system.assertEquals(acc.PersonHasOptedOutOfEmail, true);
        system.assertEquals(acc.PersonDoNotCall, true);
        system.assertEquals(acc.et4ae5__HasOptedOutOfMobile__pc, true);
        system.assertEquals(acc.Direct_Mail_Opt_Out__pc, true);

        ld = [Select Id, HasOptedOutOfEmail, DoNotCall, et4ae5__HasOptedOutOfMobile__c, Whitemail_Opt_Out__c From Lead where Id = :ld.Id];
        system.assertEquals(ld.HasOptedOutOfEmail, true);
        system.assertEquals(ld.DoNotCall, true);
        system.assertEquals(ld.et4ae5__HasOptedOutOfMobile__c, true);
        system.assertEquals(ld.Whitemail_Opt_Out__c, true);

        GPC_ConsentManagementController.getConsents(acc.Id);

        test.stopTest();
    }
}