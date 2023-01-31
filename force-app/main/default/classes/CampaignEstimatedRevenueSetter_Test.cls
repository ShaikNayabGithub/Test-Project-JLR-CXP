@isTest
public class CampaignEstimatedRevenueSetter_Test {
    
/*	
	static testmethod void CampaignExpectedRevenueUpdatedToZero(){ //Campaign.Estimated_Number_of_Vehicle_Sales__c cannot be 0
    	Map<String, List<SObject>> recordsByCountry = new Map<String, List<SObject>>();
    	Pricebook2 indiaPb = TestClass_PricebookCreator.CreatePricebook('India'); //TestClass_PricebookCreator saves Pricebook record
    		
    	//create a new Campaign and assign the Product
    	//first we need to obtain a product id that we have in the Pricebook
    	List<PricebookEntry> pbes = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :indiaPb.Id];
    	Campaign newCampaign = new Campaign(Name='Test Campaign', Product__c=pbes[0].Product2Id);
    	newCampaign.Estimated_Number_of_Vehicle_Sales__c = 0; //setting Estimated_Number_of_Vehicle_Sales__c to 0 ensures that the new ExpectedRevenue will be 0 after method call
		newCampaign.ExpectedRevenue = 100; //set the ExpectedRevenue to something to show that the value is updated after call to SetEstimatedRevenue() method
    	//assign an Owner with country as India
    	User testUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
        TestClass_NationalityToISOCodeCreator.Create(testUser.Country_ISO_Code__c, 'India');
        newCampaign.OwnerId = testUser.Id;
    	insert newCampaign;
    	
    	//set up a new CountryMapper and PricebookEntryRetriever to pass to parameters
    	CountryMapper countryMapper = new CountryMapper();
    	PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();   

		CampaignEstimatedRevenueSetter campaignSetter = new CampaignEstimatedRevenueSetter(countryMapper, pricebookEntryRetriever);
		List<Campaign> campaignList = new List<Campaign>{newCampaign};
		campaignSetter.SetEstimatedRevenue(campaignList);
		
		//retrieve Campaign from soql
		newCampaign = [SELECT ExpectedRevenue FROM Campaign WHERE Id = :newCampaign.Id];
		//test that the ExpectedRevenue has been correctly updated
		System.assertEquals(0, newCampaign.ExpectedRevenue);
	}
*/
	
	static testmethod void CampaignExpectedRevenueUpdatedToNonZero(){
    	Map<String, List<SObject>> recordsByCountry = new Map<String, List<SObject>>();
    	Pricebook2 indiaPb = TestClass_PricebookCreator.CreatePricebook('India'); //TestClass_PricebookCreator saves Pricebook record
    	//create the PricebookEntry
    	PricebookEntry indiaPbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(indiaPb);	
    		
    	//create a new Campaign and assign the Product
    	//first we need to obtain a product id that we have in the Pricebook
    	List<PricebookEntry> pbes = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Id = :indiaPbe.Id];
    	//access the pbe we are interested in and change the UnitPrice to 3 - this way we know what the ExpectedRevenue should be after running SetEstimatedRevenue() method (6)
		PricebookEntry specificPbe = pbes[0];
		Id specificProd = specificPbe.Product2Id; 
    	specificPbe.UnitPrice = 3;
    	update specificPbe;
    	Campaign newCampaign = new Campaign(Name='Test Campaign', Product__c=specificProd, Market_ID__c = 'IN');
    	newCampaign.Estimated_Number_of_Vehicle_Sales__c = 2;
		newCampaign.ExpectedRevenue = 0; //set the ExpectedRevenue to zero to show that the value is updated after call to SetEstimatedRevenue() method
    	//assign an Owner with country as India
    	User testUser;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		testUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
    	}
        TestClass_NationalityToISOCodeCreator.Create(testUser.Country_ISO_Code__c, 'India');
        newCampaign.OwnerId = testUser.Id;
    	insert newCampaign;
    	
    	//set up a new CountryMapper and PricebookEntryRetriever to pass to parameters
    	CountryMapper countryMapper = new CountryMapper();
    	PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();   

		CampaignEstimatedRevenueSetter campaignSetter = new CampaignEstimatedRevenueSetter(countryMapper, pricebookEntryRetriever);
		List<Campaign> campaignList = new List<Campaign>{newCampaign};
		campaignSetter.SetEstimatedRevenue(campaignList);
		
		//retrieve Campaign from soql
		newCampaign = [SELECT ExpectedRevenue FROM Campaign WHERE Id = :newCampaign.Id];
		//test that the ExpectedRevenue has been correctly updated
		System.assertEquals(6, newCampaign.ExpectedRevenue);
	}
    
}