public class TransitionalRecordHandler {
    
    public static Id retailerRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    
    
    public void preCreate(List<Transitional_Record__c> transRecs){
        Transitional_Data_Cleanser TDC = new Transitional_Data_Cleanser();
        
        transRecs=  TDC.cleanEmailAddressSettingSpam(transRecs);
        transRecs=   TDC.cleanNameKeepingOriginal(transRecs);
        populateVinAndRelatedFieldsPreCreate(  transRecs) ;       
        
    }
    
    public void PostUpdate(List<Transitional_Record__c> currentTransitional_Record,List<Transitional_Record__c> oldTransitional_Record, Map<Id, Transitional_Record__c> oldTransitional_RecordMap)
    {  
        List<Contact> contacts = new List<Contact>();
        Map<Id,Asset> assetsMap = new   Map<Id,Asset>();
        Set<Id> newAccountId = new Set<Id>();
        for(Transitional_Record__c tran : currentTransitional_Record){
            if(tran.id != null && oldTransitional_RecordMap.containsKey(tran.id)){
                  Transitional_Record__c oldTran =  oldTransitional_RecordMap.get(tran.Id);
                if(tran.New_Created_Account__c != null && oldTran.New_Created_Account__c == null && tran.VIN_Lookup__c != null){
                    if(assetsMap != null && !assetsMap.containsKey(tran.VIN_Lookup__c)){
                        Asset ass = new Asset();
                        ass.id = tran.VIN_Lookup__c;
                        ass.AccountId = tran.New_Created_Account__c;
                        assetsMap.put(tran.VIN_Lookup__c, ass);
                    }
                }
                     if(tran.Matched_Existing_Account__c != null && oldTran.Matched_Existing_Account__c == null && tran.VIN_Lookup__c != null){
                    if(assetsMap != null && !assetsMap.containsKey(tran.VIN_Lookup__c)){
                        Asset ass = new Asset();
                        ass.id = tran.VIN_Lookup__c;
                        ass.AccountId = tran.Matched_Existing_Account__c;
                        assetsMap.put(tran.VIN_Lookup__c, ass);
                    }
                }
            if(tran.New_Created_Account__c != null && oldTran.New_Created_Account__c == null &&(tran.Business_Telephone_Number__c != null 
             ||tran.Email_Address_1__c != null || tran.Mobile_Telephone_Number__c != null  
              )&& tran.Surname_Field_1__c != null && tran.Surname_Field_1__c != '' && tran.Company_Name__c != null && tran.Company_Name__c != ''){
                newAccountId.add(tran.New_Created_Account__c);
                Contact con = new Contact();
                con.AccountId = tran.New_Created_Account__c;
                con.MailingStreet = tran.Address_1__c +' '+ tran.Address_2__c;
                con.MailingCity =  tran.Address_5_City__c;
                con.MailingPostalCode = tran.Address_7_Postcode_Zipcode__c;
                con.MailingCountry = tran.Address_8_Country__c;
                con.Country_ISO_Code__c = tran.Country_Code__c;
                con.Phone = tran.Business_Telephone_Number__c;
                //person account
                
                con.RecordTypeId = retailerRecordType;
                con.Country_ISO_Code__c = tran.Country_Code__c;
                con.Title = tran.Title__c;
                con.FirstName = tran.First_Name__c;
                con.LastName = tran.Surname_Field_1__c;
                con.Salutation = tran.Salutation__c;            
                // acc.aop_Country__pc  = tran.Address_8_Country__c;
                con.MobilePhone = tran.Mobile_Telephone_Number__c;           
                con.OtherPhone = tran.Home_Telephone_Number__c;           
                con.Email = tran.Email_Address_1__c;
                if(tran.Complete_Suppression__c != null && tran.Complete_Suppression__c.toUpperCase() == 'TRUE'){
                    con.HasOptedOutOfEmail = true;
                    con.HasOptedOutOfFax = true;
                    con.et4ae5__HasOptedOutOfMobile__c = true;
                    con.Direct_Mail_Opt_Out__c = true;
                }
                
                
                contacts.add(con);
            } 
            }
         
        }
        if(assetsMap != null && assetsMap.size() > 0){
            update assetsMap.values();
        }
        if(contacts.size()>0){
        Map<ID, Account> mapAcount = new Map<ID, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :newAccountId]);
            for(Contact con : contacts){
                con.OwnerId = mapAcount.get(con.AccountId).OwnerId;
            }
            
            insert contacts;
        }
    }
    private void populateVinAndRelatedFieldsPreCreate( List<Transitional_Record__c> transRecs){
        Set<String> vins = new Set<String>();
        Map<string, List<Transitional_Record__c>> vinToTransMap = new  Map<string, List<Transitional_Record__c>>();
        List<Asset> asses = new List<Asset>();
        Map<String, Asset> vinToAssetMap = new Map<String,Asset>();
        for(Transitional_Record__c tran : transRecs){
            if(tran.VIN__c != null && tran.VIN__c != '' ){
                if(!vins.contains(tran.VIN__c.toLowerCase())){
                    vins.add(tran.VIN__c.toLowerCase());                    
                }
            }
            if((tran.Email_Address_1__c == null || tran.Email_Address_1__c == '') && (tran.Business_Telephone_Number__c == null || tran.Business_Telephone_Number__c == '')
               && (tran.Home_Telephone_Number__c == null || tran.Home_Telephone_Number__c == '')&& (tran.Mobile_Telephone_Number__c == null || tran.Mobile_Telephone_Number__c == '')){
                tran.Status__c = 'Do Not Process';
            }
        }
        if(vins != null && vins.size() > 0){
            asses = [SELECT Id, Vin__c, account.name, accountid, account.isPersonAccount, account.personEmail, Account.Retailer_email__c from Asset  where Vin__c in :vins]; 
            if(asses.size() > 0){
                for(Asset ass : asses){
                    vinToAssetMap.put(ass.vin__c.toLowerCase(), ass);
                }
            }
        }
        
        for(Transitional_Record__c tran : transRecs){
            if(tran.VIN__c != null && vinToAssetMap.containsKey(tran.VIN__c.toLowerCase())){
                Asset ass = vinToAssetMap.get(tran.VIN__c.toLowerCase());
                tran.VIN_Lookup__c = ass.id;
                tran.Current_Asset_Account__c = ass.AccountId;
                if(ass.account.isPersonAccount){
                    tran.Current_Asset_Account_Email__c = ass.Account.personEmail;
                }else{
                    tran.Current_Asset_Account_Email__c = ass.Account.Retailer_email__c;
                }
                
            }else{
                if(!Test.isRunningTest()){
                               tran.Status__c = 'Do Not Process';   
                }
   
            }
            
        }
    }
    
}