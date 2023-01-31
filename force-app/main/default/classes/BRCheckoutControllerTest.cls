/* *************************************************************************************************************    
Class Name    : BRCheckoutControllerTest

Description   : This class is used for testing functionality of 
BRCheckoutController 
CreatedDate   : 09 Mar 2018         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                
2        2.0          Mixed DML fixed and reduce SOQL queries           chernan3               14/07/2019                      
3        3.0          setUpData() to @testSetup                         jpateman               14/07/2019                      

***************************************************************************************************************** */
@isTest
private class BRCheckoutControllerTest
{
    Static List<Asset> assetList = new List<Asset>();
   // Static User usr = new User();
    Static Saved_Vehicle_for_Lead__c savedVehLead = new Saved_Vehicle_for_Lead__c ();
    Static Vehicle_Specification__c vehiclespec= new Vehicle_Specification__c();
  
/* **************************************************
    Method Name: setUpData
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to create test data
    ****************************************************** */ 
        
  
    static testMethod void testAPOVehicleScenario() 
    {
       
       BRCheckoutController brcheckout = new BRCheckoutController();
    }   
}