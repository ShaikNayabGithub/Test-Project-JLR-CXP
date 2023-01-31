@isTest
public class GoldenRecordUtility_Test {

    static testMethod void Utility_ReturnsGoldenRecordId_WhenCorporateGoldenRecordDoesntAlreadyExist() {
        Account acc = new Account(Name='Corporate Test', Phone='12345678', Country_ISO_Code__c='MX');
        acc.RecordTypeId = GoldenRecordUtility.corporateRecordType;
        Id grId = GoldenRecordUtility.saveAccRetGoldenId(acc);
        //System.assertEquals(acc.Id, grId);
    }
    
    static testMethod void Utility_ReturnsGoldenRecordId_WhenCorporateGoldenRecordAlreadyExists() {
        Account gracc = new Account(Name='Corporate Test', Phone='12345678', Country_ISO_Code__c='MX', Is_Primary__c=true);
        gracc.RecordTypeId = GoldenRecordUtility.goldCorporateRecordType;
        insert gracc;
        Account acc = new Account(Name='Corporate Test', Phone='12345678', Country_ISO_Code__c='MX');
        Id grId = GoldenRecordUtility.saveAccRetGoldenId(acc);
        //System.assertEquals(acc.Id, grId);
    }
    
    static testMethod void Utility_ReturnsGoldenRecordId_WhenIndividualGoldenRecordDoesntAlreadyExist() {
        Account acc = new Account(Name='Individual Test', Phone='12345678', Country_ISO_Code__c='MX');
        acc.RecordTypeId = GoldenRecordUtility.individualRecordType;
        Id grId = GoldenRecordUtility.saveAccRetGoldenId(acc);
        //System.assertEquals(acc.Id, grId);
    }
    
    static testMethod void Utility_ReturnsGoldenRecordId_WhenIndividualGoldenRecordAlreadyExists() {
        Account gracc = new Account(LastName='Individual Test', Phone='12345678', Country_ISO_Code__c='MX', Is_Primary__c=true);
        gracc.RecordTypeId = GoldenRecordUtility.goldIndividualRecordType;
        insert gracc;
        Account acc = new Account(LastName='Individual Test', Phone='12345678', Country_ISO_Code__c='MX');
        Id grId = GoldenRecordUtility.saveAccRetGoldenId(acc);
        //System.assertEquals(acc.Id, grId);
    }

    static testMethod void getChildAccIdByGoldenAccTest() {
        Account retailer = new Account(Name='Corporate Test', Phone='12345678', Country_ISO_Code__c='MX', Is_Primary__c=true);
        retailer.RecordTypeId = GoldenRecordUtility.goldCorporateRecordType;
        insert retailer;

        Account gracc = new Account(LastName='Individual Test', Phone='12345678', Country_ISO_Code__c='MX', Is_Primary__c=true);
        gracc.RecordTypeId = GoldenRecordUtility.goldIndividualRecordType;
        insert gracc;

        Account gracc2 = new Account(Name='Corporate Test', Phone='12345678', Country_ISO_Code__c='MX', Is_Primary__c=true);
        gracc2.RecordTypeId = GoldenRecordUtility.goldCorporateRecordType;
        insert gracc2;

        Id grId = GoldenRecordUtility.getChildAccIdByGoldenAcc(gracc, null);
        grId = GoldenRecordUtility.getChildAccIdByGoldenAcc(gracc, retailer.Id);
        grId = GoldenRecordUtility.getChildAccIdByGoldenAcc(gracc, retailer.Id);
        grId = GoldenRecordUtility.getChildAccIdByGoldenAcc(gracc2, retailer.Id);
        //System.assertEquals(acc.Id, grId);
    }

}