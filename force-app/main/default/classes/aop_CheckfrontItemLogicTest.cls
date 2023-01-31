@isTest
private class aop_CheckfrontItemLogicTest {

    static testMethod void TestGetAreaConfigReturnsAreaConfigWhenSupplied() {
        Id userID = UserInfo.getUserId();
        PermissionSet permSet = [SELECT Id FROM PermissionSet LIMIT 1];
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_AWS_Path__c = 'x', aop_Checkfront_AOP_Id__c = 'x', aop_Checkfront_Instance__c = 'CFTEST.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = permSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
                 
        insert areaConfig;
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        
        aop_Area_Configuration__c result = itemLogic.GetAreaConfig('CFTEST.com');
        
        System.assertEquals(areaConfig.Id, result.Id);
    }
    
    static testMethod void TestSetCampaignImagesSets5ImagesIf5InParserItem()
    {
        Campaign newCamp = new Campaign();
        
        aop_CheckfrontItemParser.aop_NewItem newItem = new aop_CheckfrontItemParser.aop_NewItem();
        aop_CheckfrontItemParser.aop_Image one = new aop_CheckfrontItemParser.aop_Image();
        one.src = 'abc';
        aop_CheckfrontItemParser.aop_Image two = new aop_CheckfrontItemParser.aop_Image();
        two.src = 'def';
        aop_CheckfrontItemParser.aop_Image three = new aop_CheckfrontItemParser.aop_Image();
        three.src = 'ghi';
        aop_CheckfrontItemParser.aop_Image four = new aop_CheckfrontItemParser.aop_Image();
        four.src = 'jkl';
        aop_CheckfrontItemParser.aop_Image five = new aop_CheckfrontItemParser.aop_Image();
        five.src = 'mno';
        
        aop_CheckfrontItemParser.aop_Images images = new aop_CheckfrontItemParser.aop_Images();
        images.one=one;
        images.two=two;
        images.three = three;
        images.four = four;
        images.five = five;
        
        newItem.image = images;
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        
        Campaign result = itemLogic.SetCampaignImages(newCamp, newItem);
        
        System.assertEquals('abc', result.aop_Event_Image_1__c);
        System.assertEquals('def', result.aop_Event_Image_2__c);
        System.assertEquals('ghi', result.aop_Event_Image_3__c);
        System.assertEquals('jkl', result.aop_Event_Image_4__c);
        System.assertEquals('mno', result.aop_Event_Image_5__c);
    }
    
    static testMethod void TestSetStartAndEndDateSetsDatesOnCampaignWhenProvided()
    {
        aop_checkfrontItemCalloutParser.aop_Container item = new aop_checkfrontItemCalloutParser.aop_Container();
        Map<string, aop_checkfrontItemCalloutParser.aop_CalloutEvent> eventMap = new Map<string, aop_checkfrontItemCalloutParser.aop_CalloutEvent>();
        aop_checkfrontItemCalloutParser.aop_CalloutEvent newEvent = new aop_checkfrontItemCalloutParser.aop_CalloutEvent();
        eventMap.put('event1', newEvent);
        item.events = eventMap;
        newEvent.start_date = '20160302';
        newEvent.end_date = '20160506';     
        Campaign newCamp = new Campaign(Name = 'NewCamp', ExpectedResponse = 6, Market_ID__c = 'IN');
        insert newCamp;
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        Campaign result = itemLogic.SetStartAndEndDate(item, newCamp);
        Date newDate = Date.newInstance(2016, 05, 06);
        
        System.assertEquals(newDate, result.EndDate);
    }
    
    static testMethod void TestCreateNewCampaignCreatesCampaignWithItemName()
    {
        List<RecordType> tyeList = [SELECT Id FROM RecordType WHERE Name =: 'Make' AND sObjectType =: 'Vehicle_Specification__c' LIMIT 1];
        if(!tyeList.isEmpty())
        {
            Vehicle_Specification__c vehSpc = new Vehicle_Specification__c(Name = 'Jaguar', RecordTypeId = tyeList[0].Id);
            insert vehSpc;
        }
        Id userID = UserInfo.getUserId();
        aop_CheckfrontItemParser.aop_ItemContainer container = new aop_CheckfrontItemParser.aop_ItemContainer();
        aop_area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_New_Record_Owner__c = userId);
        aop_CheckfrontItemParser.aop_NewItem  item = new aop_CheckfrontItemParser.aop_NewItem();
        item.name = 'item name';
        item.item_id = 1;
        item.sku = 'item sku';
        item.visibility = '*';
        container.item = item;
        container.host = 'test.checkfront.com';
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        Campaign result = itemLogic.CreateNewCampaign(container, areaConfig);
        
        System.assertNotEquals(null, result);
        System.assertEquals('item name', result.Name);
    }
    
    static testMethod void TestRetrieveExistingCampaignReturnsCampaignIfOneMatches()
    {
        Campaign newCamp = new Campaign(Name = 'neCamp', ExpectedResponse = 7, aop_Checkfront_Instance__c = 'test.checkfront.com', aop_Checkfront_Item_ID__c = '4', Market_ID__c = 'IN');
        insert newCamp;
        aop_CheckfrontItemParser.aop_ItemContainer container = new aop_CheckfrontItemParser.aop_ItemContainer();
        container.host = 'test.checkfront.com';
        aop_CheckfrontItemParser.aop_NewItem item = new  aop_CheckfrontItemParser.aop_NewItem();
        item.item_id = 4;
        container.item = item;
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        Campaign result = itemLogic.RetrieveExistingCampaign(container);
        
        System.assertNotEquals(null, result);
    }
    
    static testMethod void TestSetCampaignParamFromCalloutReturnsCampaignWithFeaturePicklist()
    {
        aop_Event_Feature_Mapping__c  featureMap = new aop_Event_Feature_Mapping__c(Name = 'smartcone', Feature_Picklist_String__c = 'Smart Cone');
        insert featureMap;
        aop_CheckfrontItemCalloutParser.aop_Container calloutContainer = new aop_CheckfrontItemCalloutParser.aop_Container();
        aop_CheckfrontItemCalloutParser.aop_CalloutItem newItem = new aop_CheckfrontItemCalloutParser.aop_CalloutItem();
        aop_CheckfrontItemCalloutParser.aop_CalloutParam newParam = new aop_CheckfrontItemCalloutParser.aop_CalloutParam();
        Map<string, aop_CheckfrontItemCalloutParser.aop_CalloutParam> paramMap = new Map<string, aop_CheckfrontItemCalloutParser.aop_CalloutParam>();
        paramMap.put('smartcone', newParam);
        newItem.param = paramMap;
        calloutContainer.item = newItem;
        Campaign newCamp = new Campaign(Name = 'newCamp', Market_ID__c = 'IN');
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        Campaign result = itemLogic.SetCampaignParamFromCallout(calloutContainer, newCamp);
        
        System.assertEquals('Smart Cone;', result.aop_Event_Features__c);
        
    }
    
    static testMethod void TestHandleCampaignCreationCreatesCampaignIfValidContainerPassed()
    {
        Id userID = UserInfo.getUserId();
        PermissionSet permSet = [SELECT Id FROM PermissionSet LIMIT 1];
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_New_Record_Owner__c = userId, aop_AWS_Path__c = 'x', aop_Checkfront_AOP_Id__c = '5', aop_Checkfront_Instance__c = 'test.checkfront.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = permSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
                 
        insert areaConfig;
        
        aop_CheckfrontItemParser.aop_ItemContainer container = new aop_CheckfrontItemParser.aop_ItemContainer();
        aop_CheckfrontItemParser.aop_NewItem  item = new aop_CheckfrontItemParser.aop_NewItem();
        item.name = 'item name';
        item.item_id = 1;
        item.category_id = 5;
        item.sku = 'item sku';
        item.visibility = '*';
        container.item = item;
        container.type = 'item';
        container.action = 'insert';
        container.host = 'test.checkfront.com';
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        itemLogic.HandleCampaignCreation(container);
        
        List<Campaign> campList = [SELECT Id FROM Campaign WHERE Name =: item.name];
        
        System.assertEquals(1, campList.size());
    }
    
    static testMethod void TestHandleCampaignCreationDoesNothingIfUpdatingInvalidCampaign()
    {
        Id userID = UserInfo.getUserId();
        PermissionSet permSet = [SELECT Id FROM PermissionSet LIMIT 1];
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_New_Record_Owner__c = userId, aop_AWS_Path__c = 'x', aop_Checkfront_AOP_Id__c = '5', aop_Checkfront_Instance__c = 'test.checkfront.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = permSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
                 
        insert areaConfig;
        
        aop_CheckfrontItemParser.aop_ItemContainer container = new aop_CheckfrontItemParser.aop_ItemContainer();
        aop_CheckfrontItemParser.aop_NewItem  item = new aop_CheckfrontItemParser.aop_NewItem();
        item.name = 'item name';
        item.item_id = 8;
        item.category_id = 5;
        item.sku = 'item sku';
        item.visibility = '*';
        container.item = item;
        container.type = 'item';
        container.action = 'update';
        container.host = 'test.checkfront.com';
        
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        itemLogic.HandleCampaignCreation(container);
        
        List<Campaign> campList = [SELECT Id FROM Campaign WHERE Name =: item.name];
        
        System.assertEquals(0, campList.size());
    }
    
    static testMethod void TestHandleUpdateCalloutReturnsNullIfNullsPassedIn()
    {
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        aop_CheckfrontItemCalloutParser.aop_Container result = itemLogic.HandleUpdateCallout(null, null);
        
        System.assertEquals(null, result);
    }
    
    static testMethod void TestUpdateExistingCampaignDoesNothingIfNullsPassedIn()
    {
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE DeveloperName = 'aop_Game_Event' AND sObjectType = 'Campaign'];
        Campaign newCam = new Campaign(Name = 'abc campaign', ExpectedResponse = 12, RecordTypeId = rtList[0].Id, Market_ID__c = 'IN');
        insert newCam;
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        itemLogic.UpdateExistingCampaign(null, newCam, null);
        
        Campaign result = [SELECT Status FROM Campaign WHERE Id =: newCam.Id LIMIT 1];
        
        System.assertEquals(null, result.Status);
    }
    
    static TestMethod void TestHandleUpdateCalloutReturnsPopulatedContainer()
    {
        aop_CheckfrontItemParser.aop_ItemContainer container = new aop_CheckfrontItemParser.aop_ItemContainer();
        aop_CheckfrontItemParser.aop_NewItem newItem= new aop_CheckfrontItemParser.aop_NewItem();
        newItem.item_id = 2;
        container.item = newItem;
        Id userID = UserInfo.getUserId();
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_Community_URL__c = 'facebook.com', aop_Community_Permission_Set__C = 'permSet', aop_New_Record_Owner__c = userID, aop_Checkfront_AOP_Id__c = '3', aop_AWS_Path__c = 'path', aop_Retailer_Queue_Name__C = 'name', aop_Customer_Queue_Name__c = 'name', aop_Spotify_Link__C = 'x.com', aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '0299', aop_NSC_Contact_Email__c = 'a@b.com', aop_Minimum_Age__C = 12, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_Token__c = 'none token');
        insert areaConfig;
        Test.startTest();
        aop_CheckfrontItemLogic cfLogic = new aop_CheckfrontItemLogic();
        Test.setMock(HttpCalloutMock.class, new aop_CheckfrontWebServiceMock());
        aop_CheckfrontItemCalloutParser.aop_Container parseContainer= cfLogic.HandleUpdateCallout(areaConfig, container);
        Test.stopTest();
        
        System.assertEquals('3.0', parseContainer.version);
    }
    
    static testMethod void TestUpdateExistingCampaignUpdatesCampaignName()
    {
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE DeveloperName = 'aop_Game_Event' AND sObjectType = 'Campaign'];
        Id userID = UserInfo.getUserId();
        PermissionSet permSet = [SELECT Id FROM PermissionSet LIMIT 1];
        Campaign newCam = new Campaign(Name = 'abc campaign', ExpectedResponse = 12, RecordTypeId = rtList[0].Id, Market_ID__c = 'IN');
        insert newCam;
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_Community_URL__c = 'facebook.com', aop_Community_Permission_Set__C = 'permSet', aop_New_Record_Owner__c = userID, aop_Checkfront_AOP_Id__c = '3', aop_AWS_Path__c = 'path', aop_Retailer_Queue_Name__C = 'name', aop_Customer_Queue_Name__c = 'name', aop_Spotify_Link__C = 'x.com', aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '0299', aop_NSC_Contact_Email__c = 'a@b.com', aop_Minimum_Age__C = 12, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_Token__c = 'none token');
        insert areaConfig;
        aop_CheckfrontItemParser.aop_ItemContainer container = new aop_CheckfrontItemParser.aop_ItemContainer();
        aop_CheckfrontItemParser.aop_NewItem  item = new aop_CheckfrontItemParser.aop_NewItem();
        item.name = 'item name';
        item.item_id = 8;
        item.category_id = 5;
        item.sku = 'item sku';
        item.visibility = '*';
        item.image = new aop_CheckfrontItemParser.aop_Images();
        item.meta = new aop_CheckfrontItemParser.aop_ItemMeta();
        container.item = item;
        container.type = 'item';
        container.action = 'update';
        container.host = 'test.checkfront.com';
        Test.startTest();
        aop_CheckfrontItemLogic itemLogic = new aop_CheckfrontItemLogic();
        Test.setMock(HttpCalloutMock.class, new aop_CheckfrontWebServiceMock());
        itemLogic.UpdateExistingCampaign(container, newCam, areaConfig);
        
        Campaign result = [SELECT Name FROM Campaign WHERE Id =: newCam.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals('item name', result.Name);
    }
    
}