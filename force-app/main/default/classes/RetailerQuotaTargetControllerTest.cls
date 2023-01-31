@isTest
public class RetailerQuotaTargetControllerTest {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id salestargetRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Sales_Target').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
    public static Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
    
    static TestMethod void SalesBoardReturnsZeroesInAllFieldsForNewUser() {
    Test.startTest();
        User portalUser = TestUtility.createPortaluser('Australia','Sales Executive');
        Test.stopTest();
        System.RunAs(portalUser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
             targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
            Map<String, RetailerQuotaTargetController.QuotaTargetWrapper> sw = RetailerQuotaTargetController.getRetailerQuotaTarget();
            
        }
    }
}