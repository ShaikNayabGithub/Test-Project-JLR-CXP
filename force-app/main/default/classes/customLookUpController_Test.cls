@isTest
public class customLookUpController_Test {
    
    @testSetup static void setup() {
        Finance_service_provider__c fsp = new Finance_service_provider__c();
        fsp.Name = 'MENA Finance Bank';
        fsp.Market__c = 'India';
        insert fsp;
        
        Contract_Field_Data__c fData = new Contract_Field_Data__c();
        fData.Name = 'CCM';
        fData.Contract_Field__c = 'Finance Type';
        fData.Market__c = 'IN';
        fData.Country_ISO_Code__c = 'IN';
        insert fData;
        
        
        Id makeRecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        Id modelRecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c();
        vehSpec.recordtypeid = makeRecordTypeId;
        vehSpec.Name = 'Jaguar';
        insert vehSpec;
        
        vehSpec = new Vehicle_Specification__c();
        vehSpec.recordtypeid = modelRecordTypeId;
        vehSpec.Make__c = vehSpec.Id;
        vehSpec.Name = 'Land rover';
        insert vehSpec;
        
    }
    @isTest static void searchFinanceRecords(){
        customLookUpController.fetchLookUpValues('Finance','Finance_service_provider__c','Finance_Service_Dealer_With_Market__c','MENA');
    }
    @isTest static void searchMakeRecords(){
        customLookUpController.fetchVehicleValues('Jaguar','Vehicle_Specification__c',null);
    }
    @isTest static void searchModelRecords(){
        Vehicle_Specification__c vehiSpecify = [select id from Vehicle_Specification__c where name = 'Jaguar'];
        customLookUpController.fetchVehicleValues('Jaguar','Vehicle_Specification__c',vehiSpecify.Id);
    }
     @isTest static void fetchContactDataValues_Test(){
          customLookUpController.fetchContactDataValues('CCM','Contract_Field_Data__c','IN','Finance Type');
     }
}