@isTest
public class aop_CheckfrontWebServiceTest {
    
    public static Map<string, id> createContact()
    {
        List<sObject> toInsert = new List<sObject>();
        
        Campaign newCampaign = new Campaign(aop_Checkfront_Item_ID__c = '2', aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        toInsert.add(newCampaign);
        
        Contact newContact = new Contact(LastName = 'Bananas', Email = 'potato@farm.com');
        toInsert.add(newContact);
        
        insert toInsert;
        
        Map<string, id> idMap = new Map<string,id>();
        idMap.put('Contact', newContact.Id);
        idMap.put('Campaign', newCampaign.Id);
        
        return idMap;
    }
    
    
    static TestMethod void TestWebServiceCreatesNoCampaignMemberIfWrongTID()
    {
        Map<string,id> idMap = createContact();
        
        string stringJSON = '{"@attributes":{"version":"3.8.0.7","host":"abc.com"},"booking":{"@attributes":{"booking_id":"56"},"status":"","code":"TXJG-010216","created_date":"1454335252","staff_id":{},"source_ip":"141.77.255.13","start_date":"1454437800","end_date":"1454441400","customer":{"name":"Joe Patman","email":"joe@patman.com","region":{},"address":"4020 LAKESIDE","city":"West Mids","country":"GB","phone":"+491217885400","postal_zip":"B377YN"},"meta":{"customer_tid":"No contact with this id","customfield1":"ABC","customfield2":"Custom Field 2","customer_account_id":{},"mobile_device":{}},"order":{"@attributes":{"currency_id":"USD"},"sub_total":"10.00","tax_total":"0.00","paid_total":"0.00","total":"10.00","taxes":{},"items":{"item":{"@attributes":{"line_id":"1","item_id":"2"},"start_date":"1454437800","end_date":"1454441400","sku":"testSKU","slip":{},"package_id":"0","status":"PRE","total":"10.00","tax_total":"0.00","qty":"1"}}}}}';
        string postURI = 'https://aopdev-jlraopdev.cs86.force.com/CheckfrontIntegration/services/apexrest/checkfrontwebservice';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = postURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(stringJSON);
        RestContext.request = req;
        RestContext.response = res;
        
        aop_CheckfrontWebService.doPost();
        
        List<CampaignMember> newMembers = [SELECT Id FROM CampaignMember WHERE ContactId =: idMap.get('Contact') AND CampaignId =: idMap.get('Campaign')];
        
        System.assert(newMembers.isEmpty());
    }

}