@isTest
public class aop_ISOCodeControllerTest {
    static TestMethod void TestControllerSetsContact()
    {
        PageReference pageRef = Page.aop_PrintSinglePass;
        Test.setCurrentPage(pageRef);
        
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        Campaign newCamp = new Campaign(Name = 'WalkInTestCamp', RecordTypeId = rt.Id, ExpectedResponse = 0.20, Market_ID__c = 'IN');
        insert newCamp;
        
        Contact newContact = new Contact(FirstName = 'Contact', LastName = 'WalkInContact', email = 'a@b.com');
        insert newContact;
        
        CampaignMember campMem = new CampaignMember();
        campMem.CampaignId = newCamp.Id;
        campMem.ContactId = newContact.Id;
        insert campMem;
        
        aop_ISOCodeController codeController = new aop_ISOCodeController(new ApexPages.StandardController(campMem));
        
        Contact contact = codeController.getContact();
        
        System.assertEquals(newContact.Id, contact.Id);
    }

}