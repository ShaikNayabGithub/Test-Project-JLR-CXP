@RestResource(urlMapping='/Account/createB2CPrimary')
global with sharing class AUSDataRemAccountFixB2CRestController {
  @HttpPost
    global static AUSDataRemRestUtils.RestResponseModel createB2CPrimary(List<String> model) {
        SavePoint sp = Database.setSavepoint();
        AUSDataRemRestUtils.RestResponseModel response = new AUSDataRemRestUtils.RestResponseModel();
        try {
            List<Account> accs = [SELECT Id, IsDeleted,OwnerId, BillingCountry, Owner_retailer__c, Is_primary__c, PersonMailingStreet,
                              primary_account__c, primary_account__pc, lastName, firstName, name, Mena_reference2__c, Phone,
                              personEmail, PersonMobilePhone, IsPersonAccount, All_Communications_opt_out__pc,
                              PersonDoNotCall, PersonHasOptedOutOfEmail, Direct_Mail_Opt_Out__pc, et4ae5__HasOptedOutOfMobile__pc,
                              Deceased_Date__pc, PersonAssistantPhone, PersonHomePhone, PersonOtherPhone, Assistant_Phone_Hidden__pc,
                              Other_Phone_Hidden__pc, Work_Order_contact_Home_Phone__pc, Work_Order_contact_Mobile_Phone__pc,
                              Work_Order_contact_Work_Phone__pc, BillingStreet, PersonContactId, Country_ISO_Code__c,
                              RecordTypeId
                          FROM Account 
                          where primary_account__c = null
                          and vital_ref__c != null
                          and IsPersonAccount = true
                          and id in :model];
            
            if(accs.size() != model.size() ) {
                AUSDataRemRestUtils.setError(response, 'can not find one of accounts ' + model, null);
                return response;
            }
            
            AUSDataRem_AccountHandler accountHandlerObject = new AUSDataRem_AccountHandler();
            accountHandlerObject.PostCreate(accs,null);
            return response;
            
        } catch(Exception e) {
            Database.rollback(sp);
            AUSDataRemRestUtils.setError(response, e.getMessage(), e.getStackTraceString());
        }
        return response;
    }
}