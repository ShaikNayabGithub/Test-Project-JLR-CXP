@isTest
public class FinanceContractHandler_Test {

    static testmethod void ContractHandler_SetsAccountToRenew_WhenContractJourneyStageEqualsRenew() {
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true); //build Asset with Person Account as Owner
        insert vehicle;
        Contract financeContract = new Contract(AccountId=vehicle.AccountId, Asset__c=vehicle.Id);
        insert financeContract;
        financeContract.Customer_Journey_Stage_Update__c = 'Renew';
        update financeContract;
        Account vehicleAccount = [SELECT Customer_Journey_Stage__c FROM Account WHERE Id = :vehicle.AccountId];
        System.assertEquals('Renew', vehicleAccount.Customer_Journey_Stage__c);
    }    

}