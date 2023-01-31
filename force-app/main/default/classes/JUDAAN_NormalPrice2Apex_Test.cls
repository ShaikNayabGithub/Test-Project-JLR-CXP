@IsTest
private class JUDAAN_NormalPrice2Apex_Test {
	
	static testMethod void testParse() {
		String json = '{\"requestid\":\"abcde12345\",\"calcResult\":\"0\",\"loanPrincipal\":4500000,\"payment1st\":72800,\"paymentMonthly\":70300,\"bonusAdditionalCost\":50000,\"numOfBonus\":10,\"installmentsFee\":220500,\"installmentsTotal\":4720500,\"totalPayments\":5220500,\"paymentPeriod\":60}';
		JUDAAN_NormalPrice2Apex obj = JUDAAN_NormalPrice2Apex.parse(json);
		System.assert(obj != null);
	}
}