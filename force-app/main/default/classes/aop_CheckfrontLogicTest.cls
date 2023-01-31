@isTest
public class aop_CheckfrontLogicTest {
    
    public static aop_CheckfrontWebService.aop_Checkfront SetUpBooking() 
    {
        aop_CheckfrontWebService.aop_Checkfront newBooking =  new aop_CheckfrontWebService.aop_Checkfront();
        Map<string,string> newAttributes = new Map<string, string>();
        Map<string,string> bookingAttributes = new Map<string,string>();
        newAttributes.put('host', 'abc.com');
        bookingAttributes.put('booking_id', 'bid');        
		
        aop_CheckfrontWebService.aop_Booking newCFBooking = new aop_CheckfrontWebService.aop_Booking();
        aop_CheckfrontWebService.aop_order newOrder = new aop_CheckfrontWebService.aop_order();
        aop_CheckfrontWebService.aop_Item newItem = new aop_CheckfrontWebService.aop_Item();
        aop_CheckfrontWebService.aop_Items newItems = new aop_CheckfrontWebService.aop_Items();
        aop_CheckfrontWebService.aop_Meta newMeta = new aop_CheckfrontWebService.aop_Meta();
        
        newItem.sku = 'testSKU';
        newItems.item = newItem;
        newOrder.items = newItems;
        newCFBooking.order = newOrder;
        newBooking.booking = newCFBooking;
        newBooking.booking.meta = newMeta;
        newBooking.booking.code = 'abc';
        newBooking.booking.attributes = bookingAttributes;
        newBooking.attributes = newAttributes;
        
        return newBooking;
    }
    
    public static Contact CreateTestContact()
    {
        Contact newContact = new Contact(LastName = 'Bananas', FirstName = 'Sharon', Email = 'potato@farm.com');
        insert newContact;
        return newContact;
    }
    
    static TestMethod void TestCheckForExistingCampaignReturnsNullIfNoCampaign()
    {
        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        Map<string,string> itemAttributes = new Map<string,string>();
        itemAttributes.put('item_id', '');
        newBooking.booking.order.items.item.attributes = itemAttributes;
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        Campaign result = businessLogic.CheckForExistingCampaign(newBooking);
        
        System.assertEquals(null, result); 
    }
    
    
    static TestMethod void TestCheckForExistingCampaignReturnsCampaignIfExists()
    {

        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        Campaign newCampaign = new Campaign(aop_Checkfront_Item_Id__c = '4', aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        Map<string,string> itemAttributes = new Map<string,string>();
        itemAttributes.put('item_id', '4');
        newBooking.booking.order.items.item.attributes = itemAttributes;
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        Campaign result = businessLogic.CheckForExistingCampaign(newBooking);
        
        System.assertNotEquals(null, result);
        System.assertEquals(newCampaign.Id, result.Id);
        
    }
    
    static TestMethod void TestCheckForExistingMemberReturnsNullIfNoneExisting()
    {

        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        Campaign newCampaign = new Campaign(aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        CampaignMember result = businessLogic.CheckForExistingMember(newCampaign, newBooking);
        
        System.assertEquals(null, result);
        
    }
    
    static TestMethod void TestCheckForExistingMemberReturnsMemberIfExisting()
    {

        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        Campaign newCampaign = new Campaign(aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        
        Contact newContact = CreateTestContact();
        
        CampaignMember newMember = new CampaignMember(CampaignId = newCampaign.Id, ContactId = newContact.Id, aop_CF_Booking_ID__c = 'abc');
        insert newMember;
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        CampaignMember result = businessLogic.CheckForExistingMember(newCampaign, newBooking);
        
        System.assertEquals(newMember.Id, result.Id);
        
    }
    
    
    static TestMethod void TestCheckForExistingContactReturnsContactIfExisting()
    {
        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        Contact newContact = CreateTestContact();
        
        newBooking.booking.meta.customer_tid = newContact.Id;
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        Contact result = businessLogic.CheckExistingContact(newContact.Id);
        
        System.assertEquals(newContact.Id, result.Id);
        
    }
    
    static TestMethod void TestCheckForExistingContactReturnsNullIfNoContact()
    {

        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        newBooking.booking.meta.customer_tid = 'No contact with this id';
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        Contact result = businessLogic.CheckExistingContact('No  tid');
        
        System.assertEquals(null, result);
        
    }
    
    static TestMethod void TestUpdateExistingMemberUpdatesDates()
    {

        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        newBooking.booking.status = '';
        newBooking.booking.start_date = '1394128800';
        newBooking.booking.end_date = '1394129800';
        
        Campaign newCampaign = new Campaign(aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        
        Contact newContact = CreateTestContact();
        
        CampaignMember newMember = new CampaignMember(CampaignId = newCampaign.Id, ContactId = newContact.Id, aop_CF_Booking_ID__c = 'abc');
        insert newMember;
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        businessLogic.UpsertCampaignMember(newMember, newBooking);
        
        DateTime expected = DateTime.newInstance(2014, 03, 06, 18, 0, 0);
        DateTime expectedEnd = DateTime.newInstance(2014, 03, 06, 18, 16, 40);
        
        System.assertEquals(expected, newMember.aop_Session_Start__c);
        System.assertEquals(expectedEnd, newMember.aop_Session_End__c);
        
        
    }
    
    static TestMethod void TestHandleCheckfrontJSON()
    {

         aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        
        Campaign newCampaign = new Campaign(aop_Checkfront_Item_Id__c = '4', aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        
        Contact newContact = CreateTestContact();
        
        CampaignMember newMember = new CampaignMember(CampaignId = newCampaign.Id, ContactId = newContact.Id, aop_CF_Booking_ID__c = 'abc');
        insert newMember;
        
        newBooking.booking.status = '';
        newBooking.booking.start_date = '1394128800';
        newBooking.booking.end_date = '1394129800';
        Map<string,string> itemAttributes = new Map<string,string>();
        itemAttributes.put('item_id', '4');
        newBooking.booking.order.items.item.attributes = itemAttributes;
        
        
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        businessLogic.HandleCheckfrontJSON(newBooking);
        
        DateTime expected = DateTime.newInstance(2014, 03, 06, 18, 0, 0);
        DateTime expectedEnd = DateTime.newInstance(2014, 03, 06, 18, 16, 40);
        
        List<CampaignMember> updatedMems = [SELECT Id, aop_Session_Start__C, aop_Session_End__C FROM CampaignMember WHERE Id =: newMember.Id];
        
        System.assertEquals(expected, updatedMems[0].aop_Session_Start__c);
        System.assertEquals(expectedEnd, updatedMems[0].aop_Session_End__c);
        
    }
    
    static TestMethod void TestCreateNewCampaignMemberCreatesNewMember()
    {
        Campaign newCampaign = new Campaign(aop_Checkfront_Item_Id__c = '4', aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        newBooking.booking.Status = '';
        Contact newContact = CreateTestContact();
        
        aop_CheckfrontLogic cfLogic = new aop_CheckfrontLogic();
        CampaignMember newMem = cfLogic.CreateNewCampaignMember(newBooking, newCampaign, newContact);
        
        System.assertEquals(newContact.Id, newMem.ContactId);
        System.assertEquals(newCampaign.Id, newMem.CampaignId);
    }
    
	static TestMethod void TestGetTidFromCallbackReturnsNullIfCFTokenNullOnConfig()
    {
        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        Id userID = UserInfo.getUserId();
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_Community_URL__c = 'facebook.com', aop_Community_Permission_Set__C = 'permSet', aop_New_Record_Owner__c = userID, aop_Checkfront_AOP_Id__c = '3', aop_AWS_Path__c = 'path', aop_Retailer_Queue_Name__C = 'name', aop_Customer_Queue_Name__c = 'name', aop_Spotify_Link__C = 'x.com', aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '0299', aop_NSC_Contact_Email__c = 'a@b.com', aop_Minimum_Age__C = 12, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_Token__c = 'none token');
        insert areaConfig;
        Test.startTest();
        aop_CheckfrontLogic cfLogic = new aop_CheckfrontLogic();
        Test.setMock(HttpCalloutMock.class, new aop_CheckfrontWebServiceMock());
        string tid = cfLogic.GetTidFromCallback(newBooking, areaConfig);
        Test.stopTest();
        
        System.assertEquals(null, tid);
    }
    
    static testMethod void TestSendDuplicateEmailReturnsEmailWithBodyContainingBookingCFId()
    {
        aop_CheckfrontWebService.aop_Checkfront newBooking = SetUpBooking();
        Contact newCon = CreateTestContact();
        aop_Area_Configuration__c areaConfig = new aop_Area_Configuration__c(aop_Community_URL__c = 'facebook.com', aop_Community_Permission_Set__C = 'permSet', aop_New_Record_Owner__c = userInfo.getUserID(), aop_Checkfront_AOP_Id__c = '3', aop_AWS_Path__c = 'path', aop_Retailer_Queue_Name__C = 'name', aop_Customer_Queue_Name__c = 'name', aop_Spotify_Link__C = 'x.com', aop_Rebooking_Window__c = 1.2, aop_NSC_Contact_Phone__c = '0299', aop_NSC_Contact_Email__c = 'a@b.com', aop_Minimum_Age__C = 12, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_Token__c = 'none token');
		aop_CheckfrontLogic cfLogic = new aop_CheckfrontLogic();
        
        Messaging.SingleEmailMessage email = cfLogic.SendDuplicateEmail(areaConfig, newBooking, newCon);
        system.assertEquals(true, email.getHtmlBody().contains(newBooking.booking.code));
    }
    
    static testMethod void CheckForSecondBookingReturnsNotNullIfContactAlreadyACampaignMember()
    {
        Contact existingContact = CreateTestContact();
        Campaign newCampaign = new Campaign(aop_Checkfront_Item_Id__c = '4', aop_SKU__c = 'testSKU', aop_Checkfront_Instance__c = 'abc.com', Name = 'TestCamp', ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCampaign;
        CampaignMember cMember = new CampaignMember(ContactId = existingContact.Id, CampaignId = newCampaign.Id);
        insert cMember;
        
        aop_CheckfrontLogic cfLogic = new aop_CheckfrontLogic();
        
        CampaignMember result = cfLogic.CheckForSecondBooking(existingContact, newCampaign);
        
        system.assertNotEquals(null, result);
    }    

}