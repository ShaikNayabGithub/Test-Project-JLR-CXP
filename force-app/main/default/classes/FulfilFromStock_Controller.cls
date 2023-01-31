public with sharing class FulfilFromStock_Controller {
    
    public OpportunityLineItem opportunityProduct {get; set;}
    public Opportunity opportunity {get; set;}
    public String assetName {get; set {
        if(String.IsNotBlank(assetName)) { assetName = String.escapeSingleQuotes(assetName); }
    }}
    public boolean showVehicleSearch {get; set;}
    private Id retailerId;
    private Id pricebookId;
    private Id pricebookEntryId;
    private String pricebookName;
    public boolean retailerAssigned {get; set;}
    public String chosenAsset {get; set;}
    public Asset selectedVehicle {get; set;}
    public AssetSearchFilter_Controller asf {get; set;}
      
    public FulfilFromStock_Controller(){    
        Id opportunityId = ApexPages.currentPage().getParameters().get('Id');
        String isoCode = '';
        opportunity = [SELECT Id, Name, AccountId, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE Id = :opportunityId];
        //create a new OpportunityLineItem
        opportunityProduct = new OpportunityLineItem(OpportunityId=opportunity.Id);
        //need to obtain the current user's retailer details
        List<User> currentUser = [SELECT Contact.AccountId, Market__c FROM User WHERE Id = :UserInfo.getUserId() AND ContactId != null];
        if(currentUser.size() > 0){
            retailerId = currentUser[0].Contact.AccountId;
            isoCode = currentUser[0].Market__c;
            //find the corresponding Pricebook Name for the User's market
            List<aop_NationalityToISOCode__c> isoCodeConvert = [SELECT Name FROM aop_NationalityToISOCode__c WHERE aop_ISO_Code__c = :isoCode];
            if(isoCodeConvert.size() > 0){
                pricebookName = isoCodeConvert[0].Name;
                List<PricebookEntry> pbEntries = [SELECT Id FROM PricebookEntry WHERE Product2.Name = 'FROM STOCK' AND Pricebook2.Name = :pricebookName];
                if(pbEntries.size() > 0){
                    pricebookEntryId = pbEntries[0].Id;
                }
            }
        }
        retailerAssigned = retailerId != null;
        asf = new AssetSearchFilter_Controller();
        asf.withSharing = true;
        asf.AddSearchColumn('Brand__r.Name, Model__r.Name, Derivative__r.Name, Price');
        asf.AddWhereClause('Status IN (\'For Sale\', \'For Sale or Transfer\')');
        asf.AddWhereClause('Account.Region_or_Market__c = \'' + isoCode + '\'');
        showVehicleSearch = false;
    }
    
    public void ShowNoRetailerWarning(){
        if(!retailerAssigned){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Stock_Search_No_Retailer_Assigned));
        }
    }
    
    public void ShowVehicleSearch(){
        if(String.IsNotBlank(assetName)){
            if(String.IsBlank(asf.searchName) || asf.searchName != assetName){
                asf.searchName = assetName;
                asf.PerformSearch();
            }
        }
        showVehicleSearch = true;
    }
    
    public void HideVehicleSearch(){
        if(asf != null && asf.AssetSearchResults != null){
            asf.AssetSearchResults.clear();
            asf.ClearSearch();
        }
        showVehicleSearch = false;
    }
    
    public void SelectVehicle(){
        if(String.IsNotBlank(chosenAsset)){
            for(Asset v : asf.AssetSearchResults){
                if('' + v.Id == chosenAsset){
                    selectedVehicle = v;
                }
            }
        }
        if(selectedVehicle != null){
            opportunityProduct.Asset__c = selectedVehicle.Id;
            opportunityProduct.PricebookEntryId = pricebookEntryId;
            opportunityProduct.UnitPrice = selectedVehicle.Price;
            opportunityProduct.Quantity = 1;
            //ListPrice is not writeable
            HideVehicleSearch();
            assetName = selectedVehicle.Name;
        }
    }
    
    public PageReference Save(){
        //now we allow the user to enter text into the input field - do we want to check that they have pressed lookup icon afterwards?
        if(opportunityProduct.Asset__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Stock_Search_No_Stock_Selected));
            return null;
        }
        if(opportunityProduct.UnitPrice == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Stock_Search_Sales_Price_Mandatory));
            return null;
        }
        //mark the OpportuntyProduct Status as 'Fulfilled From Stock'
        opportunityProduct.Status__c = 'Fulfilled From Stock';
        //set the Asset Status to 'Owned' - and the Asset Account to the Opportunity Account - now done in Asset trigger
        if(opportunityProduct.PricebookEntryId == null){
            String noPricebookMessage = String.format(System.Label.Stock_Search_No_Pricebook_Entry, new List<String>{pricebookName});
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, noPricebookMessage));
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        try{
            insert opportunityProduct;
            //OpportunityProduct trigger sets the Brand/Model to the Make/Model of the product when inserted, therefore update these?
            opportunityProduct.Model__c = selectedVehicle.Model__c;
            opportunityProduct.Brand__c = selectedVehicle.Brand__c;
            opportunityProduct.Asset__c = selectedVehicle.Id;
            update opportunityProduct;
            //return to the Opportunity page
            PageReference oppPage = new PageReference('/' + opportunity.Id);
            oppPage.setRedirect(true);
            return oppPage;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }
    
    public PageReference Cancel(){
        PageReference oppPage = new PageReference('/' + opportunity.Id);
        oppPage.setRedirect(true);
        return oppPage;     
    }
    
}