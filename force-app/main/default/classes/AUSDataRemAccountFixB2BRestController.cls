@RestResource(urlMapping='/Account/createB2BPrimary')
global with sharing class AUSDataRemAccountFixB2BRestController {
  @HttpPost
    global static AUSDataRemRestUtils.RestResponseModel createB2CPrimary(List<String> model) {
        SavePoint sp = Database.setSavepoint();
        System.debug(model);
        AUSDataRemRestUtils.RestResponseModel response = new AUSDataRemRestUtils.RestResponseModel();
        try {
            List<Account> accs = [SELECT Id, IsDeleted,OwnerId, BillingCountry, Owner_retailer__c, Is_primary__c, PersonMailingStreet,
                          primary_account__c, primary_account__pc, lastName, firstName, name, Mena_reference2__c, Phone,
                          personEmail, PersonMobilePhone, IsPersonAccount, Website, BillingPostalCode,
                          PersonDoNotCall, PersonHasOptedOutOfEmail        , Retailer_Email__c, Assistant_Phone_Hidden__pc,        
                                              PersonAssistantPhone, PersonHomePhone, PersonOtherPhone, Other_Phone_Hidden__pc,
                                  RecordTypeId, Create_Secondary_Account__c,
                          Work_Order_contact_Home_Phone__pc, Work_Order_contact_Mobile_Phone__pc,
                          Work_Order_contact_Work_Phone__pc, BillingStreet, Country_ISO_Code__c
                      FROM Account 
                      where primary_account__c = null
                      and vital_ref__c != null
                      and IsPersonAccount = False
                      and id in :model];
            if(accs.size() != model.size() ) {
                AUSDataRemRestUtils.setError(response, 'can not find one of accounts ' + model, null);
                System.debug(response);
                return response;
            }
            
            System.debug(accs);
            AUSDataRem_AccountHandler accountHandlerObject = new AUSDataRem_AccountHandler();
            accountHandlerObject.PostCreate(accs,null);
            return response;
            
        } catch(Exception e) {
            Database.rollback(sp);
            AUSDataRemRestUtils.setError(response, e.getMessage(), e.getStackTraceString());
            System.debug(response);
        }
        System.debug(response);
        return response;
    }
}