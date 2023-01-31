/**
* Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 5/12/2019.
*/

@IsTest
public with sharing class Constants_Test {
    
    @IsTest
    public static void doTest(){
        String temp = Constants.COUNTRY_CODE_AU;
        //SOQL
        Integer myInt = Constants.SOQL_DEFAULT_MAX_RESULTS;
        
        // Makes
        temp = Constants.MAKE_NAME_JAGUAR;
        temp = Constants.MAKE_NAME_LAND_ROVER;
        
        //Record Types
        temp = Constants.RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MAKE;
        temp = Constants.RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MODEL;
        temp = Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT;
        temp = Constants.RECORD_TYPE_NAME_PRODUCT2_SERVICE_PLAN;
        temp = Constants.RECORD_TYPE_NAME_ACCOUNT_INDIVIDUAL;
        temp = Constants.RECORD_TYPE_NAME_OFFERS_SERVICE_PLAN;
        
        //Resource Types
        temp = Constants.RESOURCE_TYPE_CONTACT;
        temp = Constants.RESOURCE_TYPE_RETAIL_DELIVERY_ADVICE;
        
        //Http
        temp = Constants.HTTP_HEADER_KEYS_AUTHORIZATION;
        temp = Constants.HTTP_HEADER_KEYS_CONTENT_TYPE;
        temp = Constants.URL_PROTOCOLS_HTTP;
        temp = Constants.URL_PROTOCOLS_HTTPS;
        temp = Constants.MIME_TYPES_JSON;
        
        //Mulesoft Settings
        temp = Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_RETAIL_UPDATE;
        temp = Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_VALIDATE_QFF;
        temp = Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_SEND_TO_VITAL;
        
        
        // Loyalty Points Transaction Types
        temp = Constants.LOYALTY_TYPE_PERSON_ACCOUNT;
        temp = Constants.LOYALTY_TYPE_CORPORATE_ACCOUNT;
        
        // Loyalty Verification Types
        temp = Constants.LOYALTY_VERIFICATION_TYPE_QBR;
        temp = Constants.LOYALTY_VERIFICATION_TYPE_QFF;
        
        // Loyalty Point Delivery Status'
        temp = Constants.LOYALTY_TRANSACTION_WAITING;
        temp = Constants.LOYALTY_TRANSACTION_SENT;
        temp = Constants.LOYALTY_TRANSACTION_REJECTED;
        temp = Constants.LOYALTY_TRANSACTION_APPROVED;
        
        //Regional Settings
        temp = Constants.CURRENCY_CODE_AUD;
        temp = Constants.COUNTRY_CODE_AU;
        
        //Rest Service Parameters
        temp = Constants.REST_PARAMETERS_DATE_START;
        
        //Loyalty
        myInt = Constants.LOYALTY_PARTNER_REF_LENGTH;
        
        //Service Plans
        temp = Constants.SERVICE_PLAN_TYPE_RETAIL;
        temp = Constants.SERVICE_PLAN_TYPE_CORPORATE;
        temp = Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY;
        
        // Pickles Configuration
        temp = Constants.HEAD_OFFICE_ACCOUNT_NAME;
        
        // Asset Role role types
        temp = Constants.ASSET_ROLE_CURRENT_OWNER;
    }
    
    @IsTest(SeeAllData = true)
    public static void comUrlTest(){
        system.assertNotEquals(Constants.RETAILER_COMMUNITY_URL,null);
    }
}