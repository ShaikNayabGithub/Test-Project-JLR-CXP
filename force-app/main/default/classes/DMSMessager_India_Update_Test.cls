@isTest(seeAllData=true)
public class DMSMessager_India_Update_Test {
    static testmethod void SendResponses_CallsMessagerSendRequestOnce_GivenValidOpportunity()
    {
        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;JP'));
        insert dupList;

        Dummy_HttpResponseAdapter responseAdapter = new Dummy_HttpResponseAdapter();
        Dummy_Messager messager = new Dummy_Messager();
        SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('');
        DMSMessager_India_Update responseMessager = new DMSMessager_India_Update(messager, attributeConstructor, responseAdapter, prefixHandler);

        Opportunity input = BuildValidOpportunity();
        responseMessager.SendOpportunity(input);

        System.assertEquals(1, messager.sendRequestCallCount);
    }

    private static Opportunity BuildValidOpportunity()//very,very bad
    {
        Pricebook2 priceBook = new Pricebook2();
        priceBook.Name = 'test pricebook';
        pricebook.isActive = true;
        insert priceBook;
		User us = [SELECT Id FROM User WHERE IsActive = true AND userType = 'PowerPartner' LIMIT 1];
        System.debug(us + 'USER');
        
        // Code copied from TestClass_ValidOpportunityBuilder
        // and random function from same
        // as User must be a powerpartner to create the right
        // type of account in order to properly cover most of the code
        Account account = new Account();
        System.runAs(us)
        {
        account.RecordType = AccountUtilities.RecordTypes.get('Corporate');
        account.Name = 'test';
        account.phone=TestClass_ValidOpportunityBuilder.getRandom();
        account.billingcity='London';
        account.BillingState ='testState';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        account.retailer_email__c=TestClass_ValidOpportunityBuilder.getRandom()+'@test1223.com';
        insert account;
        }

        Opportunity opportunity = TestClass_ValidOpportunityBuilder.BuildWithAccount(account.Id);
        opportunity.Pricebook2Id = priceBook.Id;
        insert opportunity;
        Contact contact = TestClass_ValidContactBuilder.Build(account);

        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.IsPrimary=true;
        insert opportunityContactRole;
        OpportunityLineItem opportunityLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opportunity, priceBook);
        insert opportunityLineItem;

        return [Select AccountId, Owner.DMS_Id__c, LeadSource, Brand__c, Primary_Model_Interest__c, Derivative__c, DMS_Opportunity_ID__c, Description, Budget__c,
            Account.Name, Account.Phone, Account.Site__c, Account.ntt_Jaguar_Status__c, Account.ntt_Land_Rover_Status__c, Account.RecordTypeId, 
            Account.RecordType.DeveloperName, Account.Preferred_Sales_Retailer__c, Account.ownerid, Account.DMS_Identifier__c, Account.BillingCity, 
            Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, Account.owner.DMS_Id__c,
            Account.Preferred_Sales_Retailer__r.Name, Account.Preferred_Sales_Retailer__r.Primary_Dealer_Code__c, Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c,
            (Select Product2.Name, Product2.Alternative_Name__c, Model__r.Name, Brand__r.Name From OpportunityLineItems Limit 1),
            (Select Contact.LastName, Contact.FirstName, Contact.MobilePhone, Contact.Salutation, Contact.Gender__c, Contact.HomePhone, 
            Contact.OtherPhone, Contact.Fax, Contact.Email, Contact.Email2__c, Contact.DMS_Identifier__c, Contact.Language__c, Contact.DoNotCall, 
            Contact.HasOptedOutOfEmail, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, 
            Contact.MailingStreet, Contact.Account.owner.DMS_Id__c, Contact.IndividualId From OpportunityContactRoles Where IsPrimary=true) 
            From Opportunity
              Where Id=:opportunity.Id];
    }

    private class Dummy_Messager implements I_HttpMessager_Siebel{
        public integer sendRequestCallCount = 0;
        public string GetSiebelDMLAction(string dmsRecordId){
            return dmsRecordId;
        }
        public string GetDMSInnerException(string soapBody){
            return soapBody;
        }
        public HttpResponse SendRequest(string soapBody, boolean isOutbound){
            sendRequestCallCount++;
            return new HttpResponse();
        }
    }

    private class Dummy_HttpResponseAdapter implements I_HttpResponseAdapter{
        public integer adaptCallCount = 0;
        public DMSOutboundResponse Adapt(HttpResponse response){
            adaptCallCount++;
            return new DMSOutboundResponse();
        }
    }
}