@isTest
public class NewLeadControllerTest {

    public static testmethod void NewLeadTest(){
        NewLeadController.getPicklistValues('Vehicle_Model_Offline__c');
        NewLeadController.getVehicleModelValuesByBrand();
        
        Lead lead = new Lead(LastName = 'test', MobilePhone = '0096170075588');
        NewLeadController.saveLead(lead);
    }
}