@IsTest
private class SetCheckboxesForConvertedLead_Test {
    
    public static Lead createLead(boolean emailOptOut) 
    {
        Lead l = new Lead();
        l.LastName = 'TestLead';     
        l.Email = 'test@test.testing';
        l.Purchase_Type__c = 'New Vehicle';
        l.HasOptedOutOfEmail = emailOptOut;
        l.Company = 'Test Company';
        l.Industry = 'Banking';
        l.In_Market_Date__c = Date.newInstance(2018, 03, 31);
        l.Budget__c = 100000;
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        l.Brand__c = make.Id;     
        l.Primary_Model_Interest__c = TestClass_VehicleSpecificationBuilder.BuildModel(make).id;
        insert l;
        return l;
    }

    
    @IsTest(seeAllData=true)
    static void Test_ConvertedContactHasEmailOptOut_WhenLeadDoes()
    {
        Lead l = createLead(true);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.Assert(lcr.isSuccess());
        List<Lead> leads = [Select ConvertedContactId from Lead where Id = :l.Id];
        if (leads.size() > 0 && leads[0].ConvertedContactId != null) {
            List<Contact> contacts = [Select HasOptedOutOfEmail from Contact where Id = :leads[0].ConvertedContactId];
            if (contacts.size() > 0) {
                System.Assert(contacts[0].HasOptedOutOfEmail == true);
            }
        }
    }
    
    @IsTest(seeAllData=true)
    static void Test_ConvertedContactHasSMSOptOut_WhenLeadHasSMSOptOut()
    {
        Lead l = createLead(true);
        l.et4ae5__HasOptedOutOfMobile__c = false;
        update l;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.Assert(lcr.isSuccess());
    } 
    
    @IsTest(seeAllData=true)
    static void Test_ConvertedContactHasSMSOptOut_WhenLeadHasHasOptedOutOfMobile()
    {
        Lead l = createLead(true);
        l.et4ae5__HasOptedOutOfMobile__c = true;
        update l;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.Assert(lcr.isSuccess());
    } 

}