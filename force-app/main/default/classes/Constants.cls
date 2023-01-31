/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 12/08/2019.
 */

public with sharing class Constants {

    //SOQL
    public static final Integer SOQL_DEFAULT_MAX_RESULTS = 500;
    
    public static String shuhoActivityUpdateType;

    // Makes
    public static final string MAKE_NAME_JAGUAR = 'Jaguar';
    public static final string MAKE_NAME_LAND_ROVER = 'Land Rover';

    //Record Types
    public static final String RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MAKE = 'Make';
    public static final String RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MODEL = 'Model';
    public static final String RECORD_TYPE_NAME_PRODUCT2_VARIANT = 'Derivative';
    public static final String RECORD_TYPE_NAME_PRODUCT2_SERVICE_PLAN = 'Service_Plans';
    public static final String RECORD_TYPE_NAME_ACCOUNT_INDIVIDUAL = 'Individual';
    public static final String RECORD_TYPE_NAME_OFFERS_SERVICE_PLAN = 'Service_Plans';

    //Resource Types
    public static final String RESOURCE_TYPE_CONTACT = 'Contact';
    public static final String RESOURCE_TYPE_RETAIL_DELIVERY_ADVICE = 'RetailDeliveryAdvice';

    //Http
    public static final String HTTP_HEADER_KEYS_AUTHORIZATION = 'Authorization';
    public static final String HTTP_HEADER_KEYS_CONTENT_TYPE = 'Content-Type';
    public static final String URL_PROTOCOLS_HTTP = 'http';
    public static final String URL_PROTOCOLS_HTTPS = 'https';
    public static final String MIME_TYPES_JSON = 'application/json';

    //Mulesoft Settings
    public static final String CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_RETAIL_UPDATE = 'MulesoftRetailUpdate';
    public static final String CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_VALIDATE_QFF = 'MulesoftValidateQFF';
    public static final String CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_SEND_TO_VITAL = 'MulesoftSendToVital';
    public static final String CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_CXP_TO_CDK = 'MulesoftCDK';


    // Loyalty Points Transaction Types
    public static final String LOYALTY_TYPE_PERSON_ACCOUNT = 'Individual';
    public static final String LOYALTY_TYPE_CORPORATE_ACCOUNT = 'Corporate';

    // Loyalty Verification Types
    public static final String LOYALTY_VERIFICATION_TYPE_QBR = 'BusinessVerificationResult';
    public static final String LOYALTY_VERIFICATION_TYPE_QFF = 'LoyaltyVerificationResult';

    // Loyalty Point Delivery Status'
    public static final String LOYALTY_TRANSACTION_WAITING = 'Waiting to be Sent';
    public static final String LOYALTY_TRANSACTION_SENT = 'Sent';
    public static final String LOYALTY_TRANSACTION_REJECTED = 'Rejected';
    public static final String LOYALTY_TRANSACTION_APPROVED = 'Approved';

    //Regional Settings
    public static final String CURRENCY_CODE_AUD = 'AUD';
    public static final String COUNTRY_CODE_AU = 'AU';
    public static final List<String> COUNTRY_ISO_CODES_AUSTRALIA = new List<String>{ 'AU', 'AUS' };

    //Rest Service Parameters
    public static final String REST_PARAMETERS_DATE_START = 'dateStart';

    //Loyalty
    public static final Integer LOYALTY_PARTNER_REF_LENGTH = 8;

    //Service Plans
    public static final String SERVICE_PLAN_TYPE_RETAIL = 'Retail';
    public static final String SERVICE_PLAN_TYPE_CORPORATE = 'Corporate';
    public static final String SERVICE_PLAN_TYPE_COMPLIMENTARY = 'Complimentary';

    // Pickles Configuration
    public static final String HEAD_OFFICE_ACCOUNT_NAME = 'OUV - 09992 - 09991';

    // Asset Role role types
    public static final String ASSET_ROLE_CURRENT_OWNER = 'Current Owner';

    //Assets
    public static final Integer MAX_RESULTS_ASSET_LIST = 100;
    public static final Integer MAX_RESULTS_ASSET_SEARCH = 50;

    // Accounts
    public static final Set<String> ACCOUNT_RECORD_TYPES_CORPORATE = new Set<String> {'Corporate_Golden_Record', 'Corporate'};

    public static string RETAILER_COMMUNITY_URL {
        get {
            ConnectApi.CommunityPage cp = ConnectApi.Communities.getCommunities();
            for (ConnectApi.Community com : cp.communities)
            {
                if (com.urlPathPrefix == 'CXP') return (string)com.siteUrl;
            }
            return null;
        }
    }
    
    public static Boolean contactBeforeInsert = true;
    public static Boolean contactAfterInsert = true;
    public static Boolean contactBeforeUpdate = true;
    public static Boolean contactAfterUpdate = true;
    
    public static Boolean assetBeforeInsert = true;
    public static Boolean assetAfterInsert = true;
    public static Boolean assetBeforeUpdate = true;
    public static Boolean assetAfterUpdate = true;
}