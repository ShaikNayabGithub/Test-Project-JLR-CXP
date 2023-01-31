public class PrimaryAccountContactGateway{
    public static Id jlrContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    Public List<Account> getSecondaryAccountDetails(Set<Id> accIds){
        
        return [SELECT Id, Primary_Account__c, Name,Country_ISO_Code__c , Owner_Retailer__c,RecordTypeId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone, Fax, Industry, Website, Site, Site__c, Started_Trading__c, Stopped_Trading__c, Region_or_Market__c, ADDRESS_2__c, ADDRESS_3__c, ADDRESS_4__c, Address_local__c, Has_Address_MX__c, Has_Email_OR_Phone__c, Has_Phone__c, Has_Email_Address__c, Has_Email_Phone_Address__c, B2B_Type__c, B2C_Type__c, Incorrect_Phone_Number__c, Incorrect_Email__c, Incorrect_Address__c, Account_Type__c, Retailer_Email__c,  Brand__c FROM Account WHERE Id IN :accIds];
        
    }
    
    Public List<Contact> getPrimaryContactDetails(Set<Id> accIds){
        
        return [SELECT Id, AccountId, FirstName,Country_ISO_Code__c , LastName, Title,  Phone, Fax, MobilePhone, HomePhone, OtherPhone, Email,  Email2__c, Email3__c,  RecordTypeId FROM Contact WHERE AccountId IN :accIds AND RecordTypeId = :jlrContactRecordType];
        
    }
    
    Public List<Account> getPotentialPrimaryAccountDetails(List<Account> accs){
        List<String> names = New List<String>();
        List<String> countryIsoCodes = new List<String>();
        for(Account acc : accs){
            names.add(acc.Name);
            if(acc.Country_ISO_Code__c !=  null && !countryIsoCodes.contains(acc.Country_ISO_Code__c)){
                countryIsoCodes.add(acc.Country_ISO_Code__c);
            }
        }
      
       return [SELECT Id,name,Country_ISO_Code__c , (SELECT Id, AccountId, FirstName, LastName, Title,  Phone, Fax, MobilePhone, HomePhone, OtherPhone, Email,  Email2__c, Email3__c,  RecordTypeId FROM Contacts where RecordTypeId = :jlrContactRecordType ) FROM Account WHERE Name in :names AND Country_Iso_Code__c IN :countryIsoCodes And  RecordTypeId = :goldenCorporateRecordType];
        

        
    }
    
    
}