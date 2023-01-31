@isTest
private class aop_CheckfrontItemWebServiceTest {

    static testMethod void TestDoPostResultsInCampaignCreationWithValidJSON() {
    	Id userID = UserInfo.getUserId();
    	PermissionSet permSet = [SELECT Id FROM PermissionSet LIMIT 1];
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_New_Record_Owner__c = userId, aop_AWS_Path__c = 'x', aop_Checkfront_AOP_Id__c = '5', aop_Checkfront_Instance__c = 'test.checkfront.com', aop_Checkfront_Token__c = 'x',
                 aop_Community_Permission_Set__c = permSet.id, aop_Community_URL__c= 'x', aop_Retailer_Queue_Name__c ='x', 
                 aop_Customer_Queue_Name__c = 'x', aop_Spotify_Link__c = 'x', aop_Minimum_Age__c = 5, aop_Rebooking_Window__c = 5, 
                 aop_NSC_Contact_Phone__c ='341', aop_NSC_Contact_Email__c = 'x@X.com');
                 
        insert areaConfig;
        string stringJSON = '{"version":"3.8.0.31","host":"test.checkfront.com","type":"item","action":"insert","item":{"unit":"H","item_id":5,"sku":"newitemtesting","url":"","lock":1,"visibility":"*","name":"New Item Testing","pos":0,"summary":"","details":"","meta":{"display_mode":"dropdown","item_package_rate":"","delay":0},"stock":1,"unlimited":0,"video":{"id":"","start":0},"image":{},"category_id":5,"rated":1,"product_group_type":"","product_group_children":"","type":"I"}}';
        string postURI = 'https://aopdev-jlraopdev.cs86.force.com/CheckfrontIntegration/services/apexrest/checkfrontitemwebservice';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = postURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(stringJSON);
        RestContext.request = req;
        RestContext.response = res;
        
        aop_CheckfrontItemWebService.doPost();
        
        List<Campaign> campList  = [SELECT Id FROM Campaign WHERE Name = 'New Item Testing' LIMIT 1];
        System.assertEquals(1, campList.size());
        
    }
}