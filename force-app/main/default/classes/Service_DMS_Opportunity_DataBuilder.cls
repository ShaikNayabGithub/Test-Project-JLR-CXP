public class Service_DMS_Opportunity_DataBuilder
{
    private static final Schema.DescribeFieldResult LINEITEM_OPPORTUNITY_ID_FIELD = Schema.OpportunityLineItem.OpportunityId.getDescribe();
    private static final Schema.DescribeFieldResult OPPORTUNITY_ID_FIELD = Schema.OpportunityLineItem.OpportunityId.getDescribe();
    private static final Schema.DescribeFieldResult OPPORTUNITY_ACCOUNT_ID_FIELD = Schema.Opportunity.AccountId.getDescribe();
    private static final Schema.DescribeFieldResult CONTACT_ACCOUNT_ID_FIELD = Schema.Contact.AccountId.getDescribe();
    private static final Schema.DescribeFieldResult ASSET_ACCOUNT_ID_FIELD = Schema.Contact.AccountId.getDescribe();

    private Id retailerAccountId;
    private Map<Id, Account> accounts;
    private List<Asset> assets;
    private Map<Id,Opportunity> opportunities;
    private Map<Id,List<OpportunityLineItem>> opportunityLineItems;
    private Map<Id,List<Contact>> contactsByAccountId;
    private Set<Id> accountsIds;
    //private Set<Id> orderNumbers;
    private Set<String> orderNumbers;

    List<Service_DMS_Opportunity_Data.OpportunityItem> opportunityResponseItems;

    public Service_DMS_Opportunity_DataBuilder(Id retailerAccountId){
        this.retailerAccountId = retailerAccountId;
    }

    public List<Service_DMS_Opportunity_Data.OpportunityItem> Build(){
         opportunityResponseItems = new  List<Service_DMS_Opportunity_Data.OpportunityItem>();
         contactsByAccountId = new Map<Id,List<Contact>>();
         //accountsByOpportunityId = new Map<Id,Contact>();

         retrieveData();

         for(Opportunity opp : opportunities.values()){
            Service_DMS_Opportunity_Data.OpportunityItem opportunityItem = buildOpportunity(opp);

            if(opportunityItem != null){
                opportunityResponseItems.add(opportunityItem);
            }
         }

         return opportunityResponseItems;
    }

    private Service_DMS_Opportunity_Data.OpportunityItem buildOpportunity(Opportunity opportunity){
                
        Service_DMS_Opportunity_Data.OpportunityItem item = new Service_DMS_Opportunity_Data.OpportunityItem(opportunity);


        System.debug(contactsByAccountId.keySet());
        
        if(accounts.containsKey(opportunity.AccountId)){
            item.Account = new Service_DMS_Opportunity_Data.AccountItem(accounts.get(opportunity.AccountId));
        }

        //Assets
        //Map<Id,List<Asset>> assetsByAccountId = 

        if(contactsByAccountId.containsKey(opportunity.AccountId) && opportunityLineItems != null && opportunityLineItems.containsKey(opportunity.Id)){ 
            Set<Id> individualIds = new Set<Id>();
            for (Contact c : contactsByAccountId.get(opportunity.AccountId)) {
                individualIds.add(c.IndividualId);
            }

            Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
            if (!individualIds.isEmpty()) {
                for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :individualIds And Channel__c in ('Email','Telephone') And DataUsePurpose.LegalBasis.Retailer_Only__c = false]) {
                    List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
                    Boolean allSurveyOptOut = true;
                    if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
                    
                    consentList.add(cptc);
                    consentMap.put(cptc.PartyId, consentList);
                }
            }

            if(opportunityLineItems != null && opportunityLineItems.containsKey(opportunity.Id)){
                List<OpportunityLineItem> oppItems = opportunityLineItems.get(opportunity.Id);
                
                for(Contact c : contactsByAccountId.get(opportunity.AccountId)){
                    Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForIndividual(new Set<Id>{c.IndividualId}, consentMap, oppItems[0].Brand__r.Name);
                    item.Contacts.add(new Service_DMS_Opportunity_Data.ContactItem(c, Suppressions.get('OPTOUT_PHONE'), Suppressions.get('OPTOUT_EMAIL')));
                }
            
                for(OpportunityLineItem oppLineItem : oppItems){
                    item.LineItems.add(new Service_DMS_Opportunity_Data.LineItem(oppLineItem));
                    
                    //Try and find a related asset
                    if(oppLineItem.Asset__c != null && item.Vehicle == null){
                        item.Vehicle = new Service_DMS_Opportunity_Data.Vehicle(oppLineItem.Asset__r);
                        continue;
                    }

                    if(assets.size() == 0 ) continue;

                    Asset vehicle = findAsset(oppLineItem.Vista_Order_Number__c);           
                    if(vehicle != null){
                        item.Vehicle = new Service_DMS_Opportunity_Data.Vehicle(vehicle);
                    }
                }
            }
        }
        if(item.Vehicle == null){
            item.Vehicle = new Service_DMS_Opportunity_Data.Vehicle();
        }

        item.LineItemCount = item.LineItems.size();
        
        return item;
    }

    private Asset findAsset(String orderNumber){
        if(String.isBlank(orderNumber)) return null;

        //look for order number
        for(Asset a : assets){
            if(a.Order__r.name == orderNumber){
                return a;               
            }
        }
        
        for(Asset a : assets){
                if(a.Order_Number__c == orderNumber){
                return a;   
            }       
        }

        return null;
    }

    private void retrieveData(){
        retrieveOpportunityData();  

        if(accountsIds != null && accountsIds.size() > 0){
            retreiveAccounts();
            retrieveContacts();
            retreiveAssets();
        }
        if(opportunities != null && opportunities.size() > 0){
            retrieveOpportunityLineItems();
        }
    }

    private void retrieveOpportunityData(){
        

        List<Opportunity> lstOpportunities = [SELECT id, AccountId, StageName,CreatedDate, CreatedBy.DMS_ID__c, 
                                                    Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c,
                                                    Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c 
                                                FROM Opportunity
                                                WHERE IsWon = true and DMS_Opportunity_ID__c = null and TimeLastSentToDMS__c = null
                                                AND PartnerAccountId =: retailerAccountId
                                                and Number_of_opportunity_products__c >= 1 //  Account.Preferred_Sales_Retailer__c in : retailerAccountIds
                                                    //AND Account.Country_iso_code__c in : countryIsoCode
                                                    //AND (Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c =: dealerCode OR Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c =: dealerCode)
                                                    ];

        if(lstOpportunities.size() > 0){
            accountsIds = SObjectUtilities.GetFieldValuesId(lstOpportunities,OPPORTUNITY_ACCOUNT_ID_FIELD.getName());
            System.debug(accountsIds);
        }           
        opportunities = new Map<Id, Opportunity> (lstOpportunities);
    }

    private void retreiveAssets(){
        System.debug(orderNumbers);
        Map<Id,Order> orders = new Map<Id,Order>([Select Id from order where Vista_Order_Number__c  in : orderNumbers]);

        


        assets = [SELECT Id, vin__c, brand__r.name, model__r.name, derivative__r.name, Product2.Name, Model_Year__c,
                                        Order_Number__c, Order__r.name,Registration_Number__c,Fuel_Type__c
                                        FROM Asset 
                                        WHERE AccountId in : accountsIds 
                                        or (order__c in : orders.keySet() and order__C != null)
                                        or (Order_Number__c in : orderNumbers and order_number__C != null)
                                        ];
    }


    private void retreiveAccounts(){
        accounts = new Map<Id, Account>([SELECT Id, Account.Name, Account.Account_Type__c, 
                                     Account.Phone, Account.Country_ISO_Code__c, Account.RecordType.Name,
                                     Account.BillingStreet,Account.BillingCity,
                                     Account.BillingState, IsPersonAccount, Retailer_Email__c,BillingPostalCode,
                                     LegalEntityID__c
                                     
                                     From Account
                                     WHERE Id in : accountsIds]);
    }

    private void retrieveContacts(){
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Salutation, AccountId, Phone, Email, IndividualId,
                                     MailingStreet, MailingCity, MailingState, Country_ISO_Code__c, Birthdate, Gender__c, MailingPostalCode
                                     FROM Contact where accountId in : accountsIds];
        if(contacts.size() == 0) return;
        contactsByAccountId = SObjectUtilities.MapByIdField(contacts,CONTACT_ACCOUNT_ID_FIELD);
    }

    private void retrieveOpportunityLineItems(){
        List<OpportunityLineItem> lineItems = [SELECT Id, OpportunityId, ProductCode, Brand__r.Name, Model__r.Name, CurrencyIsoCode, TotalPrice,
                                                Product_Derivative_Hidden__c, Asset__c, Asset__r.Name, Asset__r.Brand__r.Name, Asset__r.Vin__c,
                                                Asset__r.Model__r.Name, Asset__r.Derivative__r.Name, Asset__r.Model_Year__c, 
                                                Asset__r.Fuel_Type__c, Asset__r.Registration_Number__c, Asset__r.Model_Description__c,
                                                Asset__r.Product2.Name,Product2.RecordType.Name, Product2.Model__r.Name, Product2.Name,
                                                vista_order_number__c
                                                
                                                FROM OpportunityLineItem where OpportunityId in : opportunities.keySet()];

        if(lineItems.size() == 0) return;

        orderNumbers = SObjectUtilities.GetFieldValues(lineItems,'vista_order_number__c');
        opportunityLineItems = SObjectUtilities.MapByIdField(lineItems,OPPORTUNITY_ID_FIELD);
    }
}