public class GoldenRecordUtility {

    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();

    //given an Account return the Golden Record (Primary Account) or create it if necessary
    public static Id saveAccRetGoldenId(Account singleAccount) { //singleAccount should have no Id - this should be called in place of save
        if(singleAccount.RecordTypeId != individualRecordType && singleAccount.RecordTypeId != corporateRecordType){
            return null;
        }
        //try to insert the Account - this will create as a Golden Record if there or no duplicates, or fail if there are
        try{
            if(singleAccount.RecordTypeId == individualRecordType){
                singleAccount.RecordTypeId = goldIndividualRecordType;
            }
            if(singleAccount.RecordTypeId == corporateRecordType){
                singleAccount.RecordTypeId = goldCorporateRecordType;
            }
            Database.SaveResult savedAccount = Database.insert(singleAccount);
            if(savedAccount != null && savedAccount.getId() != null){
                //this should be the Golden Record as no Owner_Retailer__c value is given
                Account goldenRecord = [SELECT Id, Is_Primary__c, Primary_Account__c FROM Account WHERE Id = :savedAccount.getId()];
                if(goldenRecord != null){
                    if(goldenRecord.Is_Primary__c){
                        return goldenRecord.Id;
                    }
                    else if(goldenRecord.Primary_Account__c != null){
                        return goldenRecord.Primary_Account__c;
                    }
                }
            }
        }
        catch(DMLException e){}
        //Golden Record already created previously, search for Golden Record
        String matchName = null;
        if(singleAccount.RecordTypeId == individualRecordType){
            matchName = singleAccount.LastName;
        }
        else if(singleAccount.RecordTypeId == corporateRecordType){
            matchName = singleAccount.Name;
        }
        String isoCode = singleAccount.Country_ISO_Code__c;
        String query = PrimaryAccountUpserter.buildQuery();
        query += ' WHERE Is_Primary__c= true AND (Name = :matchName OR LastName = :matchName) AND (Country_ISO_Code__c = :isoCode) AND (RecordTypeId = :goldIndividualRecordType OR RecordTypeId = :goldCorporateRecordType)';
        List<Account> goldenRecords = Database.query(query);
        Map<String, List<Account>> potentialMatches = PrimaryAccountUpserter.createAccountMap(goldenRecords);
        if(matchName != null && potentialMatches.containsKey(matchName)){
            return PrimaryAccountUpserter.getPrimaryAccountId(singleAccount, potentialMatches, singleAccount.RecordTypeId == individualRecordType).Id;
        }
        return null;
    }
    
    public static Id getChildAccIdByGoldenAcc(Account goldenRecord, Id retailerId) {
        if(goldenRecord == null || retailerId == null){
            return null;
        }
        List<Account> relatedAccounts = [SELECT Id FROM Account WHERE Primary_Account__c = :goldenRecord.Id AND Owner_Retailer__c = :retailerId AND Is_Primary__c = false];
        if(relatedAccounts.size() > 0){
            return relatedAccounts[0].Id; //there should only ever be one Account per Retailer per Golden Record
        }
        //there is no non-Primary account for this Golden Record so create one
        Account retailerAccount = goldenRecord.clone(false, false, false, false);
        retailerAccount.Owner_Retailer__c = retailerId;
        retailerAccount.Is_Primary__c = false;
        retailerAccount.Primary_Account__c = goldenRecord.Id;
        if(goldenRecord.RecordTypeId == goldIndividualRecordType){
            retailerAccount.RecordTypeId = individualRecordType;
        }
        else if(goldenRecord.RecordTypeId == goldCorporateRecordType){
            retailerAccount.RecordTypeId = corporateRecordType;
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(retailerAccount, dml);
        return retailerAccount.Id;
    }

}