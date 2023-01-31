public with sharing class QuoteEventController {
    private static final String CORPORATE_RECORD_TYPE_NAME = 'Corporate';
    private static final String INDIVIDUAL_RECORD_TYPE_NAME = 'Individual';

    @AuraEnabled
    public static void publishEvent(String recordId) {
        List<String> accountIds = new List<String>();
        if (String.isNotBlank(recordId)) {
            List<Opportunity> opportunityItems = [
                SELECT Id, AccountId, Primary_Contact__r.AccountId, Account.RecordTypeId, Primary_Contact__r.Account.RecordTypeId
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
            ];

            if (!opportunityItems.isEmpty() && opportunityItems[0].Account.RecordTypeId.equals(getRecordTypeByName(INDIVIDUAL_RECORD_TYPE_NAME))) {
                accountIds.add(opportunityItems[0].AccountId);
            }

            if (!opportunityItems.isEmpty() && opportunityItems[0].Account.RecordTypeId.equals(getRecordTypeByName(CORPORATE_RECORD_TYPE_NAME) ))  {    
                accountIds.add(opportunityItems[0].AccountId);
            }
        }

        Create_KR_DMS_Quote_Event__e event = new Create_KR_DMS_Quote_Event__e(
            AccountIds__c = JSON.serialize(accountIds),
            OpportunityId__c = recordId
        );

        Database.SaveResult result = EventBus.publish(event);
        if (!result.isSuccess()) {
            for (Database.Error error : result.getErrors()) {
                System.debug('Error returned: ' + error.getStatusCode() + ' - ' + error.getMessage());
            }
        }
    }

    @TestVisible
    private static Id getRecordTypeByName(String recordTypeName) {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }
}