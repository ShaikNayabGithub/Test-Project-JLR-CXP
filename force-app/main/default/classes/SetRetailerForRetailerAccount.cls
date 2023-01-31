public class SetRetailerForRetailerAccount {
    
    public void setRetailer(List<Account> accounts) {
        
        // Get the account owner ID and other variables.
        List<Account> accountsQuery = [SELECT Id, Account.owner.Contact.AccountId, Account.owner.ContactId, Account.owner.UserType, Account.Preferred_Sales_Retailer__c, Country_ISO_Code__c FROM Account WHERE Id IN :accounts limit 1];
        
        //Exclude for Lead Converted accounts.
        Set<string> leadConvertISOCodes = new Set<string>();
        /**
        for(MENA_Lead_Conversion_settings__mdt rec : [Select Country_Code__c, Owner_Id__c from MENA_Lead_Conversion_settings__mdt where Used_In__c = 'Lead Handler'])
            leadConvertISOCodes.add(rec.Country_Code__c);
        **/
        for(MENA_Lead_Conversion_settings__mdt rec: MENA_Lead_Conversion_settings__mdt.getAll().values()) {
            if(rec.Used_In__c == 'Lead Handler') {
                leadConvertISOCodes.add(rec.Country_Code__c);
            }
        }
        
        // check the owner is a retailer PC user, otherwise exit
        // if(!test.isRunningTest()){
            if(accountsQuery.size() != 1  || accountsQuery[0].owner.ContactId == NULL || accountsQuery[0].owner.UserType!='PowerPartner' || leadConvertISOCodes.contains(accountsQuery[0].Country_ISO_Code__c)) {
                return;
            }
        // }
        
        // new object to update (avoids final exception)
        Account accountToUpdate = new Account(Id = accountsQuery[0].Id);
        
        // Set Preferred Retailer
        accountToUpdate.Preferred_Sales_Retailer__c = accountsQuery[0].owner.Contact.AccountId; update accountToUpdate; // Update Account
        
        // Update
        // update accountToUpdate;
        
    }
    
}