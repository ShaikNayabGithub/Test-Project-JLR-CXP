public class TransitionalRecordAccountCreator {
    
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    
    public Account tranNewAccountCreator(Transitional_Record__c tran ){
        Account acc = new Account();
        //Common
        acc.CustomerID__c = tran.Id;
        
        acc.BillingStreet = tran.Address_1__c +' '+ tran.Address_2__c;
        acc.BillingCity =  tran.Address_5_City__c;
        acc.BillingPostalCode = tran.Address_7_Postcode_Zipcode__c;
        acc.BillingCountry = tran.Address_8_Country__c;
        acc.Country_ISO_Code__c = tran.Country_Code__c;
        acc.Phone = tran.Business_Telephone_Number__c;
        //person account
        if(tran.Company_Name__c == null || tran.Company_Name__c == ''){
            acc.RecordTypeId = individualRecordType;
            acc.Country_ISO_Code__c = tran.Country_Code__c;
            acc.PersonTitle = tran.Title__c;
            acc.FirstName = tran.First_Name__c;
            acc.LastName = tran.Surname_Field_1__c;
            acc.Salutation = tran.Salutation__c;            
            // acc.aop_Country__pc  = tran.Address_8_Country__c;
            acc.PersonMobilePhone = tran.Mobile_Telephone_Number__c;           
            acc.PersonOtherPhone = tran.Home_Telephone_Number__c;           
            acc.PersonEmail = tran.Email_Address_1__c;
            if(tran.Complete_Suppression__c != null && tran.Complete_Suppression__c.toUpperCase() == 'TRUE'){
                acc.PersonHasOptedOutOfEmail = true;
                acc.PersonHasOptedOutOfFax = true;
                acc.et4ae5__HasOptedOutOfMobile__pc = true;
                acc.Direct_Mail_Opt_Out__pc = true;
            }
            acc.Gender__pc = tran.Gender__c;
            
            
        }else{
            acc.RecordTypeId = corporateRecordType;
            acc.Name = tran.Company_Name__c;
            acc.Retailer_Email__c = tran.Email_Address_1__c;
            //company 
        }
        
        return acc;
    }
    
    
    
    
}