public class BRSRequestUtilities {
    public static final String ModelFieldName = BRS_Request__c.Models__c.getDescribe().getName();
    public static final String DerivativeFieldName = BRS_Request__c.Derivatives__c.getDescribe().getName();
    public static final String FeatureFieldName = BRS_Request__c.Features__c.getDescribe().getName();
    
    public static String FailureStatus = 'Processing Failed';
    public static String SuccessStatus = 'Successfully Processed';
    public static String UnprocessedStatus = 'Unprocessed';
    public static String FeaturesAddedStatus = 'Features Added';
}