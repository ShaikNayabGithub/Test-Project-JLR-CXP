/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 22/09/2019.
 */

public with sharing class RecordTypeUtility {

    private static String RECORD_TYPE_INDIVIDUAL = 'Individual';
    private static String RECORD_TYPE_CORPORATE = 'Corporate';
    private static String RECORD_TYPE_INDIVIDUAL_GOLDEN_RECORD = 'Individual_Golden_Record';
    private static String RECORD_TYPE_CORPORATE_GOLDEN_RECORD = 'Corporate_Golden_Record';
    private static String RECORD_TYPE_PRODUCT2_SERVICE_PLAN = 'Service_Plans';

    public static String getRecordTypeId(String objectType, String recordTypeName)
    {
        return getRecordType(objectType, recordTypeName).Id;
    }

    public static RecordType getRecordType(String objectType, String recordTypeName)
    {
        RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = :objectType
                AND Name = :recordTypeName
        ];
        return rt;
    }

    private static Id getAccountRecordTypeId(String devName) {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();
    }

    private static Id getProduct2RecordTypeId(String devName) {
        return Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();
    }

    public static Id getRecordTypeId_Account_Individual(){
        return getAccountRecordTypeId(RECORD_TYPE_INDIVIDUAL);
    }

    public static Id getRecordTypeId_Account_Corporate() {
        return getAccountRecordTypeId(RECORD_TYPE_CORPORATE);
    }

    public static Id getRecordTypeId_Account_IndividualGoldenRecord(){
        return getAccountRecordTypeId(RECORD_TYPE_INDIVIDUAL_GOLDEN_RECORD);
    }

    public static Id getRecordTypeId_Account_CorporateGoldenRecord(){
        return getAccountRecordTypeId(RECORD_TYPE_CORPORATE_GOLDEN_RECORD);
    }

    public static Id getRecordTypeId_Product2_Service_Plan(){
        return getProduct2RecordTypeId(RECORD_TYPE_PRODUCT2_SERVICE_PLAN);
    }
}