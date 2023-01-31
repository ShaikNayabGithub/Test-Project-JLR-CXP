@IsTest
public with sharing class QuoteEventControllerTest {
    private static final String CORPORATE_RECORD_TYPE_NAME = 'Corporate';
    private static final String INDIVIDUAL_RECORD_TYPE_NAME = 'Individual';

    @TestSetup
    static void initData() {
        Account accIndividual = new Account(
            LastName = 'Test Account 1',
            Phone = '123',
            PersonEmail = '123@test.com',
            PersonMobilePhone = '1234',
            MENA_Reference2__c = '123',
            RecordTypeId = QuoteEventController.getRecordTypeByName(INDIVIDUAL_RECORD_TYPE_NAME)
        );
        insert accIndividual;

        Account accCorporate = new Account(
            Name = 'Test Account 2',
            RecordTypeId = QuoteEventController.getRecordTypeByName(CORPORATE_RECORD_TYPE_NAME)
        );
        insert accCorporate;

        Contact contactItem = new Contact(
            LastName = 'Test Contact',
            Phone = '123',
            Email = '123@test.com',
            MobilePhone = '1234',
            AccountId = accCorporate.Id
        );

        insert contactItem;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity for Test',
            AccountId = accIndividual.Id,
            Primary_Contact__c = contactItem.Id,
            CloseDate = Date.today(),
            StageName = 'Qualify'
        );

        insert opp;
    }

    @IsTest
    public static void publishEvent_test() {
        List<Opportunity> opportunityItem = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Test Opportunity for Test'
            AND StageName = 'Qualify'
        ];

        Test.startTest();
        QuoteEventController.publishEvent(opportunityItem[0].Id);
        Test.stopTest();
    }
}