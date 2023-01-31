public class QueueNameCreator {
    public String BuildQueueName(Account account)
	{
		String accountName = account.Name.replace('Jaguar Land Rover', 'JLR');
		Integer maxAccountNameSize = 22;
		Integer maxCitySize = 10;
		
		String ciCodeElement = '';
		if(String.isNotEmpty(account.Dealer_CI_Code__c)) { ciCodeElement = account.Dealer_CI_Code__c; }
		if(String.isNotEmpty(account.Dealer_CI_Code_2__c) && account.Dealer_CI_Code_2__c != account.Dealer_CI_Code__c) {
			if(String.isNotEmpty(ciCodeElement)) { 
				maxAccountNameSize = 18;
				maxCitySize = 7;
				ciCodeElement += '/'; 
			}
			ciCodeElement += account.Dealer_CI_Code_2__c; 
		}
		
		maxAccountNameSize = this.AddSpareLength(account.BillingCity, maxCitySize, maxAccountNameSize);
		maxCitySize = this.AddSpareLength(accountName, maxAccountNameSize, maxCitySize);
		
		accountName = accountName.left(maxAccountNameSize);
		
		String cityString = '';
		if(String.IsNotEmpty(account.BillingCity)) { 
			cityString = (account.BillingCity + ' ').left(maxCitySize); 
		}
		
		return String.Format('{0} {1}{2}', new List<String> { accountName, cityString, ciCodeElement });
	}
	
	private Integer AddSpareLength(String inputString, Integer inputMax, Integer currentOutputMax)
	{
		Integer deltaLength = inputMax;
		if(String.isNotEmpty(inputString)) { deltaLength = inputMax - inputString.length(); }
		if(deltaLength < 0) { deltaLength = 0; }
		
		return currentOutputMax + deltaLength;
	}
}