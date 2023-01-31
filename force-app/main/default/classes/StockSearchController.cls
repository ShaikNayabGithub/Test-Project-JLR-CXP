public without sharing class StockSearchController {
    
    //result fields
    public String offerPrice { get; set; }
    public String transferNotes { get; set; }
    public boolean ShowPopup { get; set; }
    //utility classes
    private List<SelectVehicle> vehicles;
    private RequestVehicleTransfer requester;
    //if requesting vehicles from NSC, allow multiple vehicles to be selected, otherwise only allow one vehicle to be transferred
    public boolean fromNSC {get; set;}
    public String singleVehicleId {get; set;}
    public AssetSearchFilter_Controller asf {get; set;}
    
    public StockSearchController(){
        fromNSC = false;
        showPopup = false;
        vehicles = new List<SelectVehicle>();
        asf = new AssetSearchFilter_Controller();
    }
    
    public void FromNSC(){
        fromNSC = true;
        InitialSearch();
    }
    
    public void FromRetailer(){
        fromNSC = false;
        InitialSearch();
    }
    
    public void InitialSearch(){
        //need to determine ISO code of current user
        String isoCode = '';
        Id currentAccount;
        List<User> currentUser = [SELECT ContactId, Contact.AccountId, Market__c FROM User WHERE Id = :UserInfo.getUserId()];
   	    if(currentUser.size() > 0){
       	    isoCode = currentUser[0].Market__c;
           	if(currentUser[0].ContactId != null && currentUser[0].Contact.AccountId != null){
               	currentAccount = currentUser[0].Contact.AccountId;
           	}
        }
        //build extra search clause
        asf.AddWhereClause('Status IN (\'For Sale\', \'For Sale or Transfer\')');
        if(isoCode != null){
        	asf.AddWhereClause('Account.Region_or_Market__c = \'' + isoCode + '\'');
        }
        else{
        	asf.AddWhereClause('Account.Region_or_Market__c = null');
        }
        if(fromNSC){
            asf.AddWhereClause('Account.NSC_Importer__c IN (\'NSC\', \'Importer\')');
        }
        else{
            asf.AddWhereClause('Account.NSC_Importer__c = \'\'');
            if(currentAccount != null){
                asf.AddWhereClause('AccountId != \'' + currentAccount + '\'');
            }
        }
        //add extra columns
        asf.AddSearchColumn('AccountId, Account.Name, Account.Queue_ID__c, Price');
        asf.PerformSearch();
        //matchingVehicles = asf.AssetSearchResults == null ? false : asf.AssetSearchResults.size() > 0;
    }
    
    public boolean getMatchingVehicles(){
        boolean matchingVehicles = getNumberVehicles() > 0;
        return getNumberVehicles() > 0;
    }
    
    public Integer getNumberVehicles(){
        if(asf.AssetSearchResults == null){
            return 0;
        }
        return asf.AssetSearchResults.size();
    }
    
    public List<SelectVehicle> getVehicles(){
        if(asf.resultsUpdated){
            vehicles = CaretakeResults(asf.AssetSearchResults);
            asf.resultsUpdated = false;
        }
        return vehicles;
    }
    
    public List<Asset> getSelectedVehicles(){
        List<Asset> selectedVehicles = new List<Asset>();
        for(SelectVehicle sv : getVehicles()){
            if(sv.isSelected) selectedVehicles.add(sv.vehicle);
        }
        return selectedVehicles;
    }
    
    //given a list of Assets from the searcher, we need to convert to List of SelectVehicle and compute number of results
    public List<SelectVehicle> caretakeResults(List<Asset> passedResults){
        //convert to new vehicle class so we can access the tick box
        List<SelectVehicle> tempList = new List<SelectVehicle>();
        for(Asset a : passedResults){
            tempList.add(new SelectVehicle(a));
        }
        return tempList;
    }
    
    public void ShowPopup() {
        //has the user selected any vehicles?
        boolean vehicleSelected = false;
        for(SelectVehicle sv : getVehicles()){
            if(sv.isSelected){
                vehicleSelected = true;
            }
        }
        if(vehicleSelected){
            ShowPopup = true;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_No_Vehicles_Selected));
        }
    }
    
    public void CancelPopup() {
        ShowPopup = false;
    }
    
    public PageReference RequestApproval(){
        if(String.IsBlank(transferNotes)){ //transfer notes is mandatory
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_Transfer_Notes_Mandatory));
            return null;
        }
        //create a list of the selected Asset Ids
        List<Asset> assets = new List<Asset>();
        for(SelectVehicle sv : getVehicles()){
            if(sv.isSelected){
                assets.add(sv.vehicle);
            }
        }
        if(assets.size() > 0) {
          for(Asset a : assets){
            a.Historic_Status__c = a.Status;
            a.Status = 'Transfer Requested';
          }
          update assets;
            requester = new RequestVehicleTransfer();
            if(fromNSC){
                offerPrice = null;
            }
            if(requester.SubmitForApproval(assets, transferNotes, offerPrice)){
                //display 'success' message and clear search results
                String successMessage = String.format(System.Label.Stock_Search_Success, new List<String>{'' + assets.size()});
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, successMessage)); 
                vehicles.clear();
                showPopup = false;
                transferNotes = '';
                offerPrice = '';
            }
            else{
              for(Asset a : assets){
                    a.Status = a.Historic_Status__c;
                }
                update assets;
            }
        }
        return null;
    }
    
    public PageReference Cancel(){
        PageReference cancelPage = new PageReference('/' + Asset.sObjectType.getDescribe().getKeyPrefix());
        cancelPage.setRedirect(true);
        return cancelPage;
    }
    
    //when displaying page as 'from retailer' we don't show checkboxes, therefore need to 'tick' the select vehicle when selected in the popup
    public void SelectSingleVehicle(){
        if(String.IsNotBlank(singleVehicleId)){
            offerPrice = '';
            for(SelectVehicle v : getVehicles()){
                if(v.vehicle.Id == singleVehicleId){
                    v.isSelected = true;
                    //set offerPrice to the price of the current vehicle
                    if(v.vehicle.Price != null){
                        offerPrice = '' + v.vehicle.Price;
                    }
                }
                else{
                    v.isSelected = false;
                }
            }
        }
        ShowPopup();
    }
    
    public Map<Id, boolean> getVehicleLocked(){
        Map<Id, boolean> vehicleLocked = new Map<Id, boolean>();
        for(SelectVehicle v : getVehicles()){
            vehicleLocked.put(v.vehicle.Id, Approval.IsLocked(v.vehicle)); 
        }
        return vehicleLocked;
    }
    
    public class SelectVehicle{
        public Asset vehicle {get; set;}
        public boolean isSelected {get; set;}
        
        public SelectVehicle(Asset passedVehicle){
            this.vehicle = passedVehicle;
            this.isSelected = false;
        }
    }
}