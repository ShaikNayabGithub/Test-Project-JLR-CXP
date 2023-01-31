public class OpportunityLookupExpander {
    public Opportunity Expand(Opportunity opportunity)//rename to GetFull
    {
        opportunity = this.RetrieveOpportunityWithContactRoles(opportunity);//will refresh the opportunity!! (ContactRoles are read only and this had to be done to retrieve them)
        this.ExpandAccount(opportunity);
        this.ExpandRetailer(opportunity);
        /*this.ExpandOpportunityOwner(opportunity);
        this.ExpandAccountOwner(opportunity);*/
        return opportunity;
    }
    
    /*private Opportunity Retrieve(Opportunity opportunity)
    {
        return [Select AccountId, Owner.DMS_Id__c, LeadSource, Brand__c, Primary_Model_Interest__c, Derivative__c, DMS_Opportunity_ID__c, Description, Budget__c, StageName,
            Account.Name, Account.Phone, Account.Site__c, Account.ntt_Jaguar_Status__c, Account.ntt_Land_Rover_Status__c, Account.RecordTypeId, 
            Account.RecordType.DeveloperName, Account.Preferred_Sales_Retailer__c, Account.OwnerId, Account.DMS_Identifier__c, Account.BillingCity, 
            Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, Account.Owner.DMS_Id__c,
            Account.Preferred_Sales_Retailer__r.Name, Account.Preferred_Sales_Retailer__r.Primary_Dealer_Code__c, Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c,
            (Select Contact.LastName, Contact.FirstName, Contact.MobilePhone, Contact.Salutation, Contact.Gender__c, Contact.HomePhone, 
            Contact.OtherPhone, Contact.Fax, Contact.Email, Contact.Email2__c, Contact.DMS_Identifier__c, Contact.Language__c, 
            Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, 
            Contact.MailingStreet, Contact.Owner.DMS_Id__c From OpportunityContactRoles Where IsPrimary=true) 
            From Opportunity
              Where Id=:opportunity.Id];
    }*/
    
    
    private Opportunity RetrieveOpportunityWithContactRoles(Opportunity opportunity)
    {
        return [Select Account.Id, Owner.DMS_Id__c, Approved_for_DMS_Hidden__c, Pricebook2Id, LeadSource, Brand__c, Primary_Model_Interest__c, Derivative__c, DMS_Opportunity_ID__c, Description, Budget__c, LastModifiedDate, TimeLastSentToDMS__c, StageName,
            (Select Product2.Name, Product2.Alternative_Name__c, Model__r.Name, Brand__r.Name From OpportunityLineItems Limit 1),
            (Select Contact.LastName, Contact.FirstName, Contact.MobilePhone, Contact.Salutation, Contact.Gender__c, Contact.HomePhone, Contact.TimeLastSentToDMS__c,
            Contact.OtherPhone, Contact.Fax, Contact.Email, Contact.Email2__c, Contact.DMS_Identifier__c, Contact.Language__c, Contact.IndividualId, 
            Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.LastModifiedDate,
            Contact.MailingStreet, Contact.Account.Owner.DMS_Id__c From OpportunityContactRoles Where IsPrimary=true OR Role='Primary Contact' Limit 1) 
            From Opportunity Where Id=:opportunity.Id];
    }
    
    
    private void ExpandAccount(Opportunity opportunity)
    {
        List<Account> accounts = [Select Name, Phone, Site__c, ntt_Jaguar_Status__c, ntt_Land_Rover_Status__c, RecordTypeId, RecordType.DeveloperName, LastModifiedDate, TimeLastSentToDMS__c,
            Preferred_Sales_Retailer__c, Owner.DMS_Id__c, DMS_Identifier__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet 
            From Account Where Id =:opportunity.Account.Id];
            
        if(accounts.size() == 0) {  opportunity.Account = new Account(); return; }
        opportunity.Account = accounts[0];
    }
    
    /*
    private void ExpandOpportunityOwner(Opportunity opportunity)
    {
        opportunity.Owner = [Select DMS_Id__c From User Where Id=:opportunity.OwnerId];
    }
    
    
    private void ExpandAccountOwner(Opportunity opportunity)
    {
        if(opportunity.Account == null){
            this.ExpandAccount(opportunity);
            if(opportunity.Account == null){ return; }
        }
        opportunity.Account.Owner = [Select DMS_Id__c From User Where Id=:opportunity.Account.OwnerId];
    }*/
    
    
    private void ExpandRetailer(Opportunity opportunity)
    {
        if(opportunity.Account == null){
            this.ExpandAccount(opportunity);
            if(opportunity.Account == null){ return; }
        }
        List<Account> retailers = [Select Name, Primary_Dealer_Code__c, Dealer_CI_Code__c From Account Where Id =:opportunity.Account.Preferred_Sales_Retailer__c];
        
        if(retailers.size() == 0) { opportunity.Account.Preferred_Sales_Retailer__r = new Account(); return; }
        opportunity.Account.Preferred_Sales_Retailer__r = retailers[0];
    }
}