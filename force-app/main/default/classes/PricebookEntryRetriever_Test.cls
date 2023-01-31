@isTest
public class PricebookEntryRetriever_Test{
	
    static testmethod void RetrieveMapList_ReturnsEmptyList_GivenEmptyMap()
    {
        Map<String, List<SObject>> recordsByCountry = new Map<String, List<SObject>>();
        
        PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();
        List<PricebookEntry> result = pricebookEntryRetriever.Retrieve(recordsByCountry, Campaign.Product__c.getDescribe());
        
        System.AssertNotEquals(null, result);
    }
    
    //when adding a record that has a Product populated (eg Campaign) ensure that if the User has an ISO Code set
    //the correct PricebookEntry is pulled from the relevant Pricebook (that is named the same as the Campaign User's country name)
    //containing the Product
    static testmethod void RetrieveMapList_ReturnsResultsForIndia(){
    	Map<String, List<SObject>> recordsByCountry = new Map<String, List<SObject>>();
    	Pricebook2 indiaPb = TestClass_PricebookCreator.CreatePricebook('India'); //TestClass_PricebookCreator saves Pricebook record
    	PricebookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(indiaPb); //TestClass_PriceBookEntryBuilder saves PricebookEntry record
    		
    	//create a new Campaign and assign the Product
    	//first we need to obtain a product id that we have in the Pricebook
    	List<PricebookEntry> pbes = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :indiaPb.Id];
    	Campaign newCampaign = new Campaign(Name='Test Campaign', Product__c=pbes[0].Product2Id);
    	newCampaign.Estimated_Number_of_Vehicle_Sales__c = 1; //Campaign must have Estimated_Number_of_Vehicle_Sales set
    	//assign an Owner with country as India
    	User testUser;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		testUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
    	}
        TestClass_NationalityToISOCodeCreator.Create(testUser.Country_ISO_Code__c, 'India');
        newCampaign.OwnerId = testUser.Id;
        newCampaign.Market_ID__c = 'IN';
    	insert newCampaign;

    	recordsByCountry.put('India', new List<sObject>{newCampaign});
    	
    	PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();    
    	List<PricebookEntry> result = pricebookEntryRetriever.Retrieve(recordsByCountry, Campaign.Product__c.getDescribe());
    	//test that the only result is returning the pricebook for India (use the name because PricebookEntryRetriever does not return Pricebook Id)
    	System.assertEquals('India', result[0].Pricebook2.Name);
    }
    
    //same test as previous but ensure that Pricebook is created for a country other than that assigned to the Campaign User
    static testmethod void RetrieveMapList_ReturnsEmptyListForIndia(){
    	Map<String, List<SObject>> recordsByCountry = new Map<String, List<SObject>>();
    	Pricebook2 vietnamPb = TestClass_PricebookCreator.CreatePricebook('Vietnam'); //TestClass_PricebookCreator saves Pricebook record
    	PricebookEntry pbe = TestClass_PricebookEntryBuilder.BuildPriceBookEntry(vietnamPb);
    		
    	//create a new Campaign and assign the Product
    	//first we need to obtain a product id that we have in the Pricebook
    	List<PricebookEntry> pbes = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :vietnamPb.Id];
    	Campaign newCampaign = new Campaign(Name='Test Campaign', Product__c=pbes[0].Product2Id, Market_ID__c = 'IN');
    	newCampaign.Estimated_Number_of_Vehicle_Sales__c = 1; //Campaign must have Estimated_Number_of_Vehicle_Sales set
    	//assign an Owner with country as India
    	User testUser;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		testUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
    	}
        TestClass_NationalityToISOCodeCreator.Create(testUser.Country_ISO_Code__c, 'India');
        newCampaign.OwnerId = testUser.Id;
    	insert newCampaign;

    	recordsByCountry.put('India', new List<sObject>{newCampaign});
    	
    	PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();    
    	List<PricebookEntry> result = pricebookEntryRetriever.Retrieve(recordsByCountry, Campaign.Product__c.getDescribe());
    	//test no Pricebook Entries are returned because we do not have an 'India' pricebook
    	System.assertEquals(0, result.size());
    }
    
    /*static testmethod void RetrieveMapList_ReturnsEmptyList_GivenEmptyMap()
    {
        Map<String, List<SObject>> recordsByCountry = new Map<String, List<SObject>>();
        
        String country = 'India';
        
        TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(pricebook);
        Campaign campaign = new Campaign();
        campaign.Product__c = 
        
        PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();
        List<PricebookEntry> result = pricebookEntryRetriever.Retrieve(recordsByCountry, Campaign.Product__c.getDescribe());
        
        System.AssertNotEquals(null, result);
    }*/
}