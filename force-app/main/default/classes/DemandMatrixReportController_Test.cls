@isTest
public class DemandMatrixReportController_Test {
    
    static TestMethod void searchForAccountsTest(){
        DemandMatrixReportController.CXPpermission();
        DemandMatrixReportController.Portalpermission();
        DemandMatrixReportController.fetchCountryValues();
        DemandMatrixReportController.fetchColumnValues();
        DemandMatrixReportController.fetchTableData('2020-01-01', '2020-02-02', null);
    }

}