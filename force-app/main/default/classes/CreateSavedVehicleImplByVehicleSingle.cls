public without sharing class CreateSavedVehicleImplByVehicleSingle implements CreateSavedVehicleInterface {
   
    private User user;
    private Lead lead;
    private Saved_Vehicle_for_Lead__c savedVehicle;
    private CreateSavedVehicleDto dto;
    public void create(CreateSavedVehicleDto dto){
        this.dto = dto;
        if(this.user == null){
            if(dto.userId == null){
                List<User> userList = UserDao.getUserById(UserInfo.getUserId());
                if(userList.size() != 0){
                    this.user = userList.get(0);
                }
            }else{
                List<User> userList = UserDao.getUserById(this.dto.userId);
                if(userList.size() != 0){
                    this.user = userList.get(0);
                }
            }
        }
        if(this.lead == null){
            List<Lead> leadList = LeadDao.getLeadByAccountId(this.user.AccountId);
            if(leadList.size() != 0){
                this.lead = leadList.get(0);   
            }else{
                this.createLead();
            }
        }
        this.createSavedVehicle();
        this.createURLParameterMap();
    }
    
    private void createLead(){
        this.lead = new Lead();   
        this.lead.LastName = this.user.lastName;
        this.lead.FirstName = this.user.firstName;
        this.lead.Email = this.user.email;
        this.lead.Account_Type__c = 'Private';
        this.lead.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Lead, RecordTypeDao.lead_Udaan);
        this.lead.LeadSource = 'UDAAN';
        this.lead.Rating = 'Warm';
        this.lead.Type__c = 'Product';
        this.lead.Sub_Type__c = 'Retail';
        this.lead.Purchase_Type__c = 'New Vehicle';
        this.lead.Account__c = this.user.AccountId;
        this.lead.Country_ISO_Code__c = 'JP';
        insert lead;
    }
    
    private void createSavedVehicle(){
    	boolean isVehicleSaved;
        this.savedVehicle = new Saved_Vehicle_for_Lead__c();
        String brandvalue;
            if(this.dto.urlParameterMap.get('brand') == 'landrover')
                 brandvalue = 'Land Rover';
            else
                brandvalue = ApexPages.currentPage().getParameters().get('brand');
         List<Saved_Vehicle_for_Lead__c> svLeadList = SavedVehicleDao.getSavedVehicleForLeadByAccountId(this.user.AccountId, brandvalue);
        if(svLeadList != null && !svLeadList.isEmpty()){
					isVehicleSaved = false;
                    for(Saved_Vehicle_for_Lead__c saveVehicleobj :svLeadList)
                    {   
                        if(saveVehicleobj.Saved_Vehicle__c == this.dto.assetId)
                           isVehicleSaved = true;
                    }
                    }
        if(isVehicleSaved != true)
        {
        this.savedVehicle.Lead__c = this.lead.Id;
        this.savedVehicle.Saved_Vehicle__c = this.dto.assetId;
        this.savedVehicle.Customer_Email__c = this.user.Email;
        if(this.dto.urlParameterMap.get('brand') == 'jaguar'){
            this.savedVehicle.Saved_Vehicle_URL__c = JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).JG_Cname__c;
        }else{
            this.savedVehicle.Saved_Vehicle_URL__c = JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).LR_Cname__c;
        }
        String url = this.savedVehicle.Saved_Vehicle_URL__c;
        this.savedVehicle.Saved_Vehicle_URL__c = url.substring(0, url.indexOf('?'));
        this.savedVehicle.Saved_Vehicle_URL__c += '/customeraccountpage?brand=' + this.dto.urlParameterMap.get('brand') + '&lang=' + this.dto.urlParameterMap.get('lang') + '&market=' + this.dto.urlParameterMap.get('market');
        
        insert this.savedVehicle;
        }
    }
    
    private void createURLParameterMap(){
        if(this.dto.assetId!=null){
            this.dto.urlParameterMap.put('id', this.dto.assetId);
        }
    }
   
}