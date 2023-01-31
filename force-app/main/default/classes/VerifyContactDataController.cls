public without sharing class VerifyContactDataController {
    @AuraEnabled 
    public static Account getAccountDetail(Id accountId) {   
        Account accountObj = [SELECT Id, Phone, PersonMobilePhone, PersonHomePhone, PersonEmail, Email2__pc, Email3__pc, 
                              Phone_Verified_Date__c, Phone_Verified_By__c, Phone_Verified_By__r.Name, 
                              Mobile_Verified_Date__c, Mobile_Verified_By__c, Mobile_Verified_By__r.Name, 
                              HomePhone_Verified_Date__c, HomePhone_Verified_By__c, HomePhone_Verified_By__r.Name, 
                              PersonEmail_Verified_Date__c, PersonEmail_Verified_By__c, PersonEmail_Verified_By__r.Name, 
                              Email2_Verified_Date__c, Email2_Verified_By__c, Email2_Verified_By__r.Name, 
                              Email3_Verified_Date__c, Email3_Verified_By__c, Email3_Verified_By__r.Name 
                              FROM Account 
                              WHERE Id = :accountId];   
        return accountObj;
    }
    
    @AuraEnabled
    public static String updateAccountDetail(Account accountObj, Map < String, Boolean > verifyCheckboxMap) {
        String message = '';
        System.debug('### verifyCheckboxMap ### ' + verifyCheckboxMap);
        if(accountObj != null && verifyCheckboxMap != null) {
            // Account dbAccountObj = getAccountDetail(accountObj.Id);
            
            for(String key: verifyCheckboxMap.keySet()) {
                // Check if passed boolean is true
                if(verifyCheckboxMap.get(key)) {
                    if(key == 'Phone' && accountObj.Phone_Verified_Date__c == null) {
                        accountObj.Phone_Verified_Date__c = System.today();
                        accountObj.Phone_Verified_By__c = UserInfo.getUserId();
                    } 
                    else if(key == 'Mobile' && accountObj.Mobile_Verified_Date__c == null) {
                        accountObj.Mobile_Verified_Date__c = System.today();
                        accountObj.Mobile_Verified_By__c = UserInfo.getUserId();
                    } 
                    else if(key == 'HomePhone' && accountObj.HomePhone_Verified_Date__c == null) {
                        accountObj.HomePhone_Verified_Date__c = System.today();
                        accountObj.HomePhone_Verified_By__c = UserInfo.getUserId();
                    } 
                    else if(key == 'PersonEmail' && accountObj.PersonEmail_Verified_Date__c == null) {
                        accountObj.PersonEmail_Verified_Date__c = System.today();
                        accountObj.PersonEmail_Verified_By__c = UserInfo.getUserId();
                    } 
                    else if(key == 'Email2' && accountObj.Email2_Verified_Date__c == null) {
                        accountObj.Email2_Verified_Date__c = System.today();
                        accountObj.Email2_Verified_By__c = UserInfo.getUserId();
                    } 
                    else if(key == 'Email3' && accountObj.Email3_Verified_Date__c == null) {
                        accountObj.Email3_Verified_Date__c = System.today();
                        accountObj.Email3_Verified_By__c = UserInfo.getUserId();
                    }
                } else {
                    if(key == 'Phone') {
                        accountObj.Phone_Verified_Date__c = null;
                        accountObj.Phone_Verified_By__c = null;
                    } 
                    else if(key == 'Mobile') {
                        accountObj.Mobile_Verified_Date__c = null;
                        accountObj.Mobile_Verified_By__c = null;
                    } 
                    else if(key == 'HomePhone') {
                        accountObj.HomePhone_Verified_Date__c = null;
                        accountObj.HomePhone_Verified_By__c = null;
                    } 
                    else if(key == 'PersonEmail') {
                        accountObj.PersonEmail_Verified_Date__c = null;
                        accountObj.PersonEmail_Verified_By__c = null;
                    } 
                    else if(key == 'Email2') {
                        accountObj.Email2_Verified_Date__c = null;
                        accountObj.Email2_Verified_By__c = null;
                    } 
                    else if(key == 'Email3') {
                        accountObj.Email3_Verified_Date__c = null;
                        accountObj.Email3_Verified_By__c = null;
                    }
                }
            }
            System.debug('### accountObj ### ' + accountObj);
            try {
                update accountObj;
                message = 'Success';
            } catch(Exception ex) {
                message = ex.getMessage();
            }
        } else {
            message = 'No Contact Information sent for Verification';            
        }
        return message;
    }
    
    public static void updateContactVerifyFields(List<Account> accounts, Map< Id, Account> oldAccountMap) {
        if(accounts != null && !accounts.isEmpty()) {
            for(Account accObj: accounts) {
                Account dbAccObj = oldAccountMap.get(accObj.Id);
                if(dbAccObj != null) {
                    // Update Phone Fields
                    if(accObj.Phone == null || accObj.Phone == '' || accObj.Phone != dbAccObj.Phone) {
                        accObj.Phone_Verified_Date__c = null;
                        accObj.Phone_Verified_By__c = null;
                    }
                    // Update PersonMobilePhone Fields
                    if(accObj.PersonMobilePhone == null || accObj.PersonMobilePhone == '' || accObj.PersonMobilePhone != dbAccObj.PersonMobilePhone) {
                        accObj.Mobile_Verified_Date__c = null;
                        accObj.Mobile_Verified_By__c = null;
                    }
                    // Update PersonHomePhone Fields
                    if(accObj.PersonHomePhone == null || accObj.PersonHomePhone == '' || accObj.PersonHomePhone != dbAccObj.PersonHomePhone) {
                        accObj.HomePhone_Verified_Date__c = null;
                        accObj.HomePhone_Verified_By__c = null;
                    }
                    // Update PersonEmail Fields
                    if(String.isBlank(accObj.PersonEmail) || !((accObj.PersonEmail).equals(dbAccObj.PersonEmail))) {
                        accObj.PersonEmail_Verified_Date__c = null;
                        accObj.PersonEmail_Verified_By__c = null;
                    }
                    // Update Email2 Fields
                    if(String.isBlank(accObj.Email2__pc) || !((accObj.Email2__pc).equals(dbAccObj.Email2__pc))) {
                        accObj.Email2_Verified_Date__c = null;
                        accObj.Email2_Verified_By__c = null;
                    }
                    // Update Email3 Fields
                    if(String.isBlank(accObj.Email3__pc) || !((accObj.Email3__pc).equals(dbAccObj.Email3__pc))) {
                        accObj.Email3_Verified_Date__c = null;
                        accObj.Email3_Verified_By__c = null;
                    }
                }
            }
        }
    }
}