public with sharing class VistaProductSearchController{

    public String searchString {get; set;}
    public List<Product2> searchResults {get; private set;}
    private Integer maxResults = 100;
    private String productType = 'Model';
    
    public VistaProductSearchController(){
        if(ApexPages.currentPage().getParameters().containsKey('lksrch')){
            searchString = ApexPages.currentPage().getParameters().get('lksrch');
            Search();
        }
    }
    
    public void Search(){
        String searchToken = '%';
        searchResults = new List<Product2>();
        if(String.IsNotBlank(searchString)){
            searchToken = '%' + searchString + '%';
        }
        List<PricebookEntry> pbes = [SELECT Product2.Id FROM PricebookEntry WHERE Product2.RecordType.DeveloperName = :productType AND Product2.Name != 'FROM STOCK' AND Product2.Name LIKE :searchToken AND Pricebook2Id IN :MyPricebooks LIMIT :maxResults+1];
        Set<Id> allProdIds = new Set<Id>();
        for(PricebookEntry pbe : pbes){
            allProdIds.add(pbe.Product2.Id);
        }
        Set<Id> searchProdIds = new Set<Id>();
        if(allProdIds.size() == maxResults+1){
            List<Id> prodIdList = new List<Id>(allProdIds);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_More_Results_Available));
            for(Integer i=0; i<maxResults; i++){
                searchProdIds.add(prodIdList[i]);
            }
        }
        else searchProdIds.addAll(allProdIds);
        searchResults = [SELECT Id, Name, Make__c, Make__r.Name, Model__c, Model__r.Name FROM Product2 WHERE Id IN :searchProdIds];
        if(searchResults.size() == 0){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Stock_Search_No_Results));
        }
    }
    
    public List<Id> MyPricebooks{
        get{
            if(MyPricebooks == null){
                MyPricebooks = new List<Id>();
                List<Id> recordIds = new List<Id>();
                for(Pricebook2 pb : PriceBookUtilities.ExistingPricebooks.values()){
                    recordIds.add(pb.Id);
                }
                for(UserRecordAccess accessRecord : [SELECT RecordId FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :recordIds AND HasReadAccess = true]){
                    MyPricebooks.add(accessRecord.RecordId);
                }
            }
            return MyPricebooks;
        }
        set;
    }
    
    public void SetMaxResults(Integer newValue){
        maxResults = newValue;
    }
    
    public void SetModelSearch(){
        productType = 'Model';
    }
    
    public void SetDerivativeSearch(){
        productType = 'Derivative';
    }
    
}