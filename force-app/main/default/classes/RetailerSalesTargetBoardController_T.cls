@isTest
public class RetailerSalesTargetBoardController_T {

    static TestMethod void SalesBoardReturnsZeroesInAllFieldsForNewUser() {
        User portalManagerUser; 
        System.RunAs( New User(Id = UserInfo.getUserId()) ){
    	 portalManagerUser = TestUtility.createPortaluser('JP','Sales Manager/Receptionist'); 
         }
        Test.startTest();
        
    	User portalUser = TestUtility.createPortalsubOrdinateuser('exeUser','JP','Sales Executive', portalManagerUser.Id);
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());  
        insert new Sales_Target__c(Target_Year__c = ''+financialDetails.financailYear, Salesperson__c = portaluser.Id);
      
        System.RunAs(portalManagerUser){
            List<RetailerUsersSalesTargetBoardController.SalesTargetWrapper> sw = RetailerUsersSalesTargetBoardController.getTargetRecords('Opportunity_Sales_Target');
            System.assertEquals(0, sw[0].salesTarget.January_Target__c);
        }
        test.stopTest();
    }
    
    static TestMethod void SaveSalesBoardPopulatesCorrectlyForNewUser() {
    	 User portalManagerUser; 
        System.RunAs( New User(Id = UserInfo.getUserId()) ){
    	 portalManagerUser = TestUtility.createPortaluser('JP','Sales Manager/Receptionist'); 
         }
        Test.startTest();
    	User portalUser = TestUtility.createPortalsubOrdinateuser('exeUser','JP','Sales Executive', portalManagerUser.Id);
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());  
      System.RunAs(portalManagerUser){
            List<RetailerUsersSalesTargetBoardController.SalesTargetWrapper> sw = RetailerUsersSalesTargetBoardController.getTargetRecords('Opportunity_Sales_Target');
            sw[0].salesTarget.January_Target__c = 10;
            String strsw = JSON.serialize(sw);
            System.debug(strsw);
            RetailerUsersSalesTargetBoardController.saveTargetRecords(strsw);
        }
        Sales_Target__c st = [SELECT Id, January_Target__c FROM Sales_Target__c LIMIT 1];
        System.assertEquals(10, st.January_Target__c);
    }
}