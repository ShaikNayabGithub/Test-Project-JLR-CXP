@isTest
public class OpportunityToOrderLinkRemover_Test {
    
    static testMethod void getAssociatedAssets_ReturnsListOfOne_IfOneAssetHasGivenOrderNumber()
    {
        OpportunityLineItem newItem = new OpportunityLineItem(Vista_Order_Number__c = '12345');
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(AccountId = testAcc.Id, Order_Number__c = '12345', Name = 'newAsset', Brand__c = vehSpec.Id);
        insert newAsset;
        
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        Map<string, Asset> assetMap = remover.getAssociatedAssets(new List<OpportunityLineItem>{newItem});
        
        system.assertEquals(true, assetMap.containsKey('12345'));
    }
    
    static testMethod void getAssociatedAssets_ReturnsListOfTwo_IfTwoAssetsHaveGivenOrderNumber()
    {
        OpportunityLineItem newItem = new OpportunityLineItem(Vista_Order_Number__c = '12345');
        OpportunityLineItem newItem2 = new OpportunityLineItem(Vista_Order_Number__c = '54321');
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(AccountId = testAcc.Id, Order_Number__c = '12345', Name = 'newAsset', Brand__c = vehSpec.Id);
        Asset newAsset2 = new Asset(AccountId = testAcc.Id, Order_Number__c = '54321', Name = 'newAsset', Brand__c = vehSpec.Id);
        Asset newAsset3 = new Asset(AccountId = testAcc.Id, Order_Number__c = '67890', Name = 'newAsset', Brand__c = vehSpec.Id);
        insert new List<Asset>{newAsset, newAsset2, newAsset3};
        
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        Map<string, Asset> assetMap = remover.getAssociatedAssets(new List<OpportunityLineItem>{newItem, newItem2});
        
        system.assertEquals(2, assetMap.size());
    }
    
    static testMethod void getAssociatedOrders_ReturnsOne_IfOneOrderHasGivenOrderNumber()
    {
        OpportunityLineItem newItem = new OpportunityLineItem(Vista_Order_Number__c = '12345');
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        Order newOrder = new Order(AccountId = testAcc.Id, Vista_Order_Number__c = '12345', Status = 'Draft', EffectiveDate = Date.today());
        insert newOrder;
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        Map<string, Order> orderMap = remover.getAssociatedOrders(new List<OpportunityLineItem>{newItem});
        
        system.assertEquals(true, orderMap.containsKey('12345'));
    }
    
    static testMethod void getAssociatedOrders_ReturnsTwo_IfTwoHaveGivenOrderNumber()
    {
        OpportunityLineItem newItem = new OpportunityLineItem(Vista_Order_Number__c = '12345');
        OpportunityLineItem newItem2 = new OpportunityLineItem(Vista_Order_Number__c = '54321');
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        Order newOrder = new Order(AccountId = testAcc.Id, Vista_Order_Number__c = '12345', Status = 'Draft', EffectiveDate = Date.today());
        Order newOrder2 = new Order(AccountId = testAcc.Id, Vista_Order_Number__c = '54321', Status = 'Draft', EffectiveDate = Date.today());
        Order newOrder3 = new Order(AccountId = testAcc.Id, Vista_Order_Number__c = '678990', Status = 'Draft', EffectiveDate = Date.today());
        insert new List<Order>{newOrder, newOrder2, newOrder3};
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        Map<string, Order> orderMap = remover.getAssociatedOrders(new List<OpportunityLineItem>{newItem, newItem2});
        
        system.assertEquals(2, orderMap.size());
    }
    
    static testMethod void getContactMapFromContactsAndUsers_ReturnsMapOf2_Given2MatchingContactsAndUsers()
    {
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        Contact newCon = new Contact(LastName = 'lastname', AccountId = testAcc.ID, Email = 'a@bc.com');
        Contact newCon2 = new Contact(LastName = 'last2name', AccountId = testAcc.ID, Email = 'ab@bc.com');
        insert new List<Contact>{newCon, newCon2};
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User'];
        Profile prof2 = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newUser1 = new User(Username = 'xyzabcxyz@bcd.com', LastName = 'abc', Email = 'aauauau@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazzan', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof2.Id, LanguageLocaleKey = 'en_US');
        insert newUser1;
        User newUser;
        User newUser2;        
        system.runAs(newUser1)
        {
            newUser = new User(Username = 'xyzabc@bcd.com', LastName = 'abc', Email = 'a@b.com', Alias = 'barry', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'bazza', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US', ContactID = newCon.Id, Partner_Manager__c = userInfo.getUserId());
            newUser2 = new User(Username = '2xyzabc@bcd.com', LastName = 'ab2c', Email = 'a@2b.com', Alias = 'barr2y', 
                                EmailEncodingKey = 'UTF-8', CommunityNickname = 'baz2za', TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_US', ProfileId = prof.Id, LanguageLocaleKey = 'en_US', ContactID = newCon2.Id, Partner_Manager__c = userInfo.getUserId());
            insert new List<User>{newUser, newUser2};
        }
        
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        Map<Id, Contact> conMap = remover.getContactMapFromContactsAndUsers(new List<User>{newUser, newUser2}, new List<Contact>{newCon, newCon2});
        system.assertEquals(2, conMap.size());
    }
    
    static testMethod void getRelatedOpportunities_ReturnsTwoOpps_GivenToLineItems()
    {
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        Opportunity newOpp = new Opportunity(AccountId = testAcc.Id, StageName = 'Contacted', CloseDate = Date.today(), Name = 'neopp');
        Opportunity newOpp2 = new Opportunity(AccountId = testAcc.Id, StageName = 'Contacted', CloseDate = Date.today(), Name = 'neopp2');
        insert new List<Opportunity>{newOpp, newOpp2};
        OpportunityLineItem newItem = new OpportunityLineItem(OpportunityId = newOpp.Id);   
        OpportunityLineItem newItem2 = new OpportunityLineItem(OpportunityId = newOpp2.Id);
        
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        Map<Id, Opportunity> result = remover.getRelatedOpportunities(new List<OpportunityLineItem>{newItem, newItem2});
        
        system.assertEquals(2, result.size());        
    }
    
    Static testMethod void GetProductsWhereOrderNumberRemoved_ReturnsOneItem_IfOneChanged()
    {
        Account testAcc = New Account(Name = 'accName');
        insert testAcc;
        Opportunity newOpp = New Opportunity(AccountId = testAcc.Id, StageName = 'Contacted', CloseDate = Date.today(), Name = 'neopp');
        insert newOpp;
        Opportunity newOpp2 = New Opportunity(AccountId = testAcc.Id, StageName = 'Contacted', CloseDate = Date.today(), Name = 'ne2opp');
        insert newOpp2;
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = New PriceBook2(Name = 'Testing12');
        insert pBook;
        Product2 newProd = New Product2(Name = 'newprod12', ProductCode = 'a12', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd, 5);  //insert newProd;
        PriceBookEntry standardPBE = New PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1234, IsActive = True, UseStandardPrice = False);
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 5);
        OpportunityLineItem newItem = New OpportunityLineItem(Vista_Order_Number__c = '12345', PricebookEntryId = standardPBE.Id, OpportunityID = newOpp.Id,
                                                               Quantity = 1, TotalPrice = 1);
        OpportunityLineItem newItem2 = New OpportunityLineItem(Vista_Order_Number__c = '54321', PricebookEntryId = standardPBE.Id, OpportunityID = newOpp2.Id,
                                                               Quantity = 1, TotalPrice = 1);
        insert New List<OpportunityLineItem>{newItem, newItem2}; 
        Map<Id,OpportunityLineItem> oldItems = New Map<Id, OpportunityLineItem>();
        Map<Id,OpportunityLineItem> newItems = New Map<Id, OpportunityLineItem>();
        
        oldItems.put(newItem.Id, newItem);
        oldItems.put(newItem2.Id, newItem2);
        
        OpportunityLineItem newItem3 = New OpportunityLineItem(Id = newItem.Id, Vista_Order_Number__c = '67890');
        newItems.put(newItem.Id, newItem3);
        newItems.put(newItem2.Id, newItem2);
        
        OpportunityToOrderLinkRemover remover = New OpportunityToOrderLinkRemover();
        List<OpportunityLineItem> itemList = remover.GetProductsWhereOrderNumberRemoved(oldItems, newItems.values());
        system.assertEquals(1, itemList.size());                                     
    }
    
    Static testMethod void DeleteAssetRoles_DeletesRole_FromGivenAsset()
    {
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(AccountId = testAcc.Id, Order_Number__c = 'testvis', Name = 'newAsset', Brand__c = vehSpec.Id);
        insert newAsset;
        Role__c newRole = new Role__c(Account__c = testAcc.Id, Vehicle__c = newAsset.ID,Role__c = 'Current Owner');
        insert newRole;
        
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        remover.DeleteAssetRoles(new List<Asset>{newAsset});
        
        List<Role__c> roleList = [SELECT Id FROM Role__c WHERE Id =: newRole.Id];
        
        system.assertEquals(true, roleList.isEmpty());
    }
    
    static testMethod void removeLinksToOrderAndAsset_RemovesOppFromOrder_IfOrderNumberRemovedFromProd()
    {
        Account testAcc = new Account(Name = 'accName');
        insert testAcc;
        Order newOrder = new Order(AccountId = testAcc.Id, Vista_Order_Number__c = '12345', Status = 'Draft', EffectiveDate = Date.today());
        insert newOrder;
        Opportunity newOpp = new Opportunity(AccountId = testAcc.Id, StageName = 'Contacted', CloseDate = Date.today(), Name = 'neopp');
        insert newOpp;
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = new PriceBook2(Name = 'Testing12');
        insert pBook;
        Product2 newProd = new Product2(Name = 'newprod12', ProductCode = 'a12', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd,5);  //insert newProd;
        PriceBookEntry standardPBE = new PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1234, IsActive = true, UseStandardPrice = false);
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 5);
        OpportunityLineItem newItem = new OpportunityLineItem(Vista_Order_Number__c = '12345', PricebookEntryId = standardPBE.Id, OpportunityID = newOpp.Id,
                                                               Quantity = 1, TotalPrice = 1);
        insert newItem; 
        OpportunityLineItem newItem2 = new OpportunityLineItem(Id = newItem.Id, Vista_Order_Number__c = null);
        Map<Id, OpportunityLineItem> oldMap = new Map<Id, OpportunityLineItem>();
        oldMap.put(newItem.Id, newItem);
        
        OpportunityToOrderLinkRemover remover = new OpportunityToOrderLinkRemover();
        remover.removeLinksToOrderAndAsset(oldMap, new List<OpportunityLineItem>{newItem2});
        
        Order result = [SELECT OpportunityId FROM Order WHERE Id =: newOrder.ID];
        system.assertEquals(null, result.OpportunityId);
    }     
}