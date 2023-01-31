@isTest
public with sharing class SGFinanceCalculatorTest {
	static testMethod void testTotal()
	{
	    test.startTest();
		Decimal total = SGFinanceCalculator.calculateLocalPriceforBudget(1000, 500, 36);
		test.stopTest();
        System.assertEquals(total, (((1000*36)*12/((Decimal.valueOf(System.label.Flat_Interest_Rate) * 36)+12))+500));
	}
	static testMethod void testInstallment()
	{
		test.startTest();
		Decimal installment = SGFinanceCalculator.getFinanceOffer(3000000, 120000, 0.35, 36);
		test.stopTest();
        system.assertEquals(installment, (((3000000-120000)*(0.35/100)*36/12+(3000000-120000))/36));
	}

}