@IsTest
public class LookupController_Test {
    
    
	static testmethod void getObjectById()
        {
            Account currentAcc = TestClass_AccountCreator.CreateRetailer();
        	system.debug('currentAcc '+currentAcc);
            
            LookupController.Searchable searcher = new LookupController.Searchable();
            List<String> fields = new List<String>();
            fields.add('Id');
            fields.add('Name');
        	//system.debug('fields '+fields);
            searcher.fields = fields;
        	system.debug('searcher.fields '+searcher.fields);
            searcher.objectName = 'Account';
        	system.debug('searcher.objectName '+searcher.objectName);
            
            String result;
            Test.startTest();
            result = LookupController.getOneRecordById(searcher, currentAcc.Id);
            Test.stopTest();
            
            system.debug('result'+result);
           List<Account> ac =  (List<Account>)JSON.deserialize(result,List<Account>.class);
         system.debug('ac'+ac);
          System.AssertEquals(currentAcc.Id, ac[0].Id);
        }
    
    static testmethod void getRecentObjects()
    {

        
            Account currentAcc = TestClass_AccountCreator.CreateRetailer();
        	system.debug('currentAcc '+currentAcc);
            
            LookupController.Searchable searcher = new LookupController.Searchable();
            List<String> fields = new List<String>();
            fields.add('Id');
            fields.add('Name');
        	//system.debug('fields '+fields);
            searcher.fields = fields;
        	system.debug('searcher.fields '+searcher.fields);
            searcher.objectName = 'Account';
        	system.debug('searcher.objectName '+searcher.objectName);
        	searcher.searchTerm = 'test';
        	system.debug('Search Term: ' + searcher.searchTerm);
        
        	String result;
        	Test.startTest();
        	result = LookupController.getRecent(searcher);
        	Test.stopTest();
        
        
            system.debug('result'+result);
           	List<Account> ac =  (List<Account>)JSON.deserialize(result,List<Account>.class);
         	system.debug('ac'+ac);
        	if(ac.size() > 0)
            {
          		System.AssertEquals(currentAcc.Id, ac[0].Id); 
            }
    }
    
    static testmethod void getRecordsWithSearchTerm()
    {
        
            Account currentAcc = TestClass_AccountCreator.CreateRetailer();
        	system.debug('currentAcc '+currentAcc);
            
            LookupController.Searchable searcher = new LookupController.Searchable();
            List<String> fields = new List<String>();
            fields.add('Id');
            fields.add('Name');
        	//system.debug('fields '+fields);
            searcher.fields = fields;
        	system.debug('searcher.fields '+searcher.fields);
            searcher.objectName = 'Account';
        	system.debug('searcher.objectName '+searcher.objectName);
        	searcher.searchTerm = 'test';
        	system.debug('Search Term: ' + searcher.searchTerm);
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
          Id [] fixedSearchResults= new Id[1];
       fixedSearchResults[0] = currentAcc.id;
       Test.setFixedSearchResults(fixedSearchResults);
        
        
        	String result;
        	Test.startTest();
        	result = LookupController.getRecords(searcher);
        	Test.stopTest();
        
        
            system.debug('result'+result);
           	List<List<Account>> ac =  (List<List<Account>>)JSON.deserialize(result,List<List<Account>>.class);
         	system.debug('ac'+ac);
          	System.AssertEquals(currentAcc.Id, ac[0][0].Id);
    }
}