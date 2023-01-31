@IsTest
public class LastSellingRetailerSetter_Test{

    static testmethod void Set_DoesNotSetLastSellingRetailer_GivenWonOpportunityRunAsUserWithoutContact()
    {       
         AssetHandler.IgnoreMMIT = true;// If we don't diable the MMIT code, we hit dml limits
         OpportunityHandler.IgnoreMMIT = true; //DJB added
         RecordSharer.DisableRecordSharing = true; //DJB added
        
        Opportunity opportunity;// = TestClass_ValidOpportunityBuilder.Build();
    
        User currentUser = new User(Id=UserInfo.getUserId()); // Added (see tracker)
        User testUser;
        System.runAs(currentUser){
            testUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
        }

        System.runAs(testUser){
            RecordSharer.DisableRecordSharing = true;
            AssetHandler.IgnoreMMIT = true;// If we don't diable the MMIT code, we hit dml limits
            OpportunityProductTriggerHandler.ignoreMMIT=true;
            OpportunityHandler.IgnoreMMIT = true; //DJB added
            RecordSharer.DisableRecordSharing = true; //DJB added            
            opportunity = TestClass_ValidOpportunityBuilder.opportunityWithopportunityitem();
            //insert opportunity;
            Test.startTest(); // Added (see tracker)
            opportunity.StageName = 'Handover';//sets IsWon (read only)
            update opportunity;//sets IsWon (read only)
            Test.stopTest(); // Added (see tracker)
        }
        
        opportunity = [select Account.Last_Selling_Retailer__c from Opportunity where id=:opportunity.Id];        
        System.assertEquals(null, opportunity.Account.Last_Selling_Retailer__c);
    }
    
    static testmethod void Set_DoesNotSetLastSellingRetailer_GivenNotWonOpportunityRunAsUserWithContact()
    {
        RecordSharer.DisableRecordSharing = true;
         AssetHandler.IgnoreMMIT = true;// If we don't diable the MMIT code, we hit dml limits
         OpportunityHandler.IgnoreMMIT = true; //DJB added
         RecordSharer.DisableRecordSharing = true; //DJB added
        Account account = TestClass_AccountCreator.CreateRetailer();
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        
        User currentUser = new User(Id=UserInfo.getUserId());
        User testUser;
        System.runAs(currentUser){
            testUser = TestClass_UserCreator.CreateRetailerUser(contact);
        }
        
        Opportunity opportunity;
        System.runAs(testUser){
            RecordSharer.DisableRecordSharing = true;
            AssetHandler.IgnoreMMIT = true;// If we don't diable the MMIT code, we hit dml limits
            OpportunityProductTriggerHandler.ignoreMMIT=true;
            RecordSharer.DisableRecordSharing = true; //DJB added            
            opportunity = TestClass_ValidOpportunityBuilder.Build();
            Test.startTest(); // Added (see tracker)
            insert opportunity;
            opportunity.StageName = 'Contacted';
            update opportunity;
            Test.stopTest(); // Added (see tracker)
        }
        
        opportunity = [select Account.Last_Selling_Retailer__c from Opportunity where id=:opportunity.Id];        
        System.assertEquals(null, opportunity.Account.Last_Selling_Retailer__c);
    }
    

    static testmethod void Set_SetsLastSellingRetailer_GivenWonOpportunityRunAsUserWithContact()
    {
        
        system.debug('SOQLLimitMarker1: ' +  Limits.getQueries());
        

        Account account = TestClass_AccountCreator.CreateRetailer();
   
        system.debug('SOQLLimitMarker2: ' +  Limits.getQueries());

       
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        
        User currentUser = new User(Id=UserInfo.getUserId());
        User testUser;
        System.runAs(currentUser){
            testUser = TestClass_UserCreator.CreateRetailerUser(contact);
        }

        system.debug('SOQLLimitMarker3: ' +  Limits.getQueries());  
      
        
        
        Opportunity opportunity;
        System.runAs(testUser){
            RecordSharer.DisableRecordSharing = true;
            AssetHandler.IgnoreMMIT = true;// If we don't diable the MMIT code, we hit dml limits
            OpportunityHandler.IgnoreMMIT = true; //DJB added
            AccountHandler.IgnoreTerritorySetter =true;
            OpportunityProductTriggerHandler.ignoreMMIT=true;            
            opportunity = TestClass_ValidOpportunityBuilder.opportunityWithopportunityitem();
            //insert opportunity;
        Test.startTest(); // Moved (see tracker)
            system.debug('SOQLLimitMarker4: ' +  Limits.getQueries());
            opportunity.stageName='Handover';
            update opportunity;
            Test.stopTest(); // Moved (see tracker)
        }
       
        opportunity = [select Account.Last_Selling_Retailer__c from Opportunity where id=:opportunity.Id];

        system.debug('SOQLLimitMarker6: ' +  Limits.getQueries());

        

        System.assertNotEquals(null, opportunity.Account.Last_Selling_Retailer__c);
    }
}