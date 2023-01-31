@isTest
public class BusinessHours_ByOwnerMapper_T {
	static testmethod void MapByOwner_ReturnsEmptyMap_GivenCollections()
    {
    	BusinessHours_ByOwnerMapper businessHourMapper = new BusinessHours_ByOwnerMapper();

    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>(); 
		Map<Id, List<SObject>> usersByAccountId = new Map<Id, List<SObject>>();

		Map<String, List<Business_Hours__c>> result = businessHourMapper.MapByOwner(businessHours, 
				usersByAccountId);

		System.assertEquals(0, result.Size());
    }

    static testmethod void MapByOwner_ReturnsBusinessHours1ByUserId1_GivenBusinessHours1AndUser1ByAccount1()
    {
    	BusinessHours_ByOwnerMapper businessHourMapper = new BusinessHours_ByOwnerMapper();

    	String name1 = 't1';
    	Account retailer1 = TestClass_AccountCreator.CreateRetailer();
    	Business_Hours__c businessHours1 = new Business_Hours__c(Name = name1, Account__c = retailer1.Id);

    	User user1;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		user1 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	}

    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 }; 
		Map<Id, List<SObject>> usersByAccountId = new Map<Id, List<SObject>>{ 
				retailer1.Id => new List<User> { user1 } };


		Map<String, List<Business_Hours__c>> result = businessHourMapper.MapByOwner(businessHours, 
				usersByAccountId);


		System.assertEquals(name1, result.get(user1.Id)[0].Name);
    }

    static testmethod void MapByOwner_ReturnsBusinessHours1ByUserId1_GivenBusinessHours1AndUser1And2ByAccount1()
    {
    	BusinessHours_ByOwnerMapper businessHourMapper = new BusinessHours_ByOwnerMapper();

    	String name1 = 't1';
    	Account retailer1 = TestClass_AccountCreator.CreateRetailer();
    	Business_Hours__c businessHours1 = new Business_Hours__c(Name = name1, Account__c = retailer1.Id);

    	User user1;
    	User user2;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		user1 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    		user2 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	}

    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 }; 
		Map<Id, List<SObject>> usersByAccountId = new Map<Id, List<SObject>>{ 
				retailer1.Id => new List<User> { user1, user2 } };


		Map<String, List<Business_Hours__c>> result = businessHourMapper.MapByOwner(businessHours, 
				usersByAccountId);


		System.assertEquals(name1, result.get(user1.Id)[0].Name);
    }

    static testmethod void MapByOwner_ReturnsBusinessHours1ByUserId2_GivenBusinessHours1AndUser1And2ByAccount1()
    {
    	BusinessHours_ByOwnerMapper businessHourMapper = new BusinessHours_ByOwnerMapper();

    	String name1 = 't1';
    	Account retailer1 = TestClass_AccountCreator.CreateRetailer();
    	Business_Hours__c businessHours1 = new Business_Hours__c(Name = name1, Account__c = retailer1.Id);

    	User user1;
    	User user2;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		user1 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    		user2 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	}

    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 }; 
		Map<Id, List<SObject>> usersByAccountId = new Map<Id, List<SObject>>{ 
				retailer1.Id => new List<User> { user1, user2 } };


		Map<String, List<Business_Hours__c>> result = businessHourMapper.MapByOwner(businessHours, 
				usersByAccountId);


		System.assertEquals(name1, result.get(user2.Id)[0].Name);
    }

    static testmethod void MapByOwner_ReturnsBusinessHours1ByQueueId1_GivenBusinessHours1AndAccount1WithQueueId1()
    {
    	BusinessHours_ByOwnerMapper businessHourMapper = new BusinessHours_ByOwnerMapper();

    	String name1 = 't1';

    	Group queue1;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		queue1 = new Group(Type = 'Queue', Name = 'q1', DoesSendEmailToMembers = false);
    		insert queue1;
    	}

    	Account retailer1 = TestClass_AccountCreator.CreateRetailer();
    	retailer1.Queue_Id__c = queue1.Id;
    	
    	Business_Hours__c businessHours1 = new Business_Hours__c(Name = name1, Account__c = retailer1.Id,
    			Account__r = retailer1);

    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 }; 
		Map<Id, List<SObject>> usersByAccountId = new Map<Id, List<SObject>>{ };


		Map<String, List<Business_Hours__c>> result = businessHourMapper.MapByOwner(businessHours, 
				usersByAccountId);


		System.assertEquals(name1, result.get(queue1.Id)[0].Name);
    }

    static testmethod void MapByOwner_ReturnsBusinessHours1ByQueueId1_GivenBusinessHours1AndUser1And2ByAccount1WithQueueId1()
    {
    	BusinessHours_ByOwnerMapper businessHourMapper = new BusinessHours_ByOwnerMapper();

    	String name1 = 't1';

    	Group queue1;
    	User user1;
    	User user2;
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		queue1 = new Group(Type = 'Queue', Name = 'q1', DoesSendEmailToMembers = false);
    		insert queue1;
    		user1 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    		user2 = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
    	}

    	Account retailer1 = TestClass_AccountCreator.CreateRetailer();
    	retailer1.Queue_Id__c = queue1.Id;
    	
    	Business_Hours__c businessHours1 = new Business_Hours__c(Name = name1, Account__c = retailer1.Id,
    			Account__r = retailer1);

    	List<Business_Hours__c> businessHours = new List<Business_Hours__c>{ businessHours1 }; 
		Map<Id, List<SObject>> usersByAccountId = new Map<Id, List<SObject>>{ 
				retailer1.Id => new List<User> { user1, user2 } };


		Map<String, List<Business_Hours__c>> result = businessHourMapper.MapByOwner(businessHours, 
				usersByAccountId);


		System.assertEquals(name1, result.get(queue1.Id)[0].Name);
    }
}