public without sharing class SaveVehicleEnquiry {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone { get; set; }
    public Boolean isPhone{ get; set; }
    public Boolean isEmail{ get; set; }
    public Boolean isSms{ get; set; }
    public String errorMsg {get; set;}
    public String strleadtype{get; set;}
    public String strDescription{get; set;}
    
      
    public Lead l;
    Saved_Vehicle_for_Lead__c savedVehicle;
    public string createLead(SaveVehicleEnquiry objVE,Id assetId)
    {
     String marketQueue = '';        
     id userid;
     try{
             this.errorMsg = 'success';
        System.debug('firstName :: '+objVE.phone);
        System.debug('lastName :: '+objVE.email);
        System.debug('assetId :: '+assetId);
         if(String.isEmpty(objVE.firstName) || String.isEmpty(objVE.lastName) 
                    || String.isEmpty(objVE.email)|| String.isEmpty(objVE.phone)){
                this.errorMsg = Label.Required_Error_Message;
                return this.errorMsg;
            }
         if(!String.isEmpty(objVE.phone ) && ( objVE.phone.length() < 8 || objVE.phone.length() >= 13 ) && 
                  (JUDAANUtil.getSimpleMarket().toUpperCase() == 'BR')
                   ){
                this.errorMsg = Label.Brazil_Phone_Number;
                return errorMsg;
            }
        if(this.l == null){
            this.l = new Lead();   
        }
        
        String market = ApexPages.currentPage().getParameters().get('market'); 
        if(market != 'br' && market != 'jp'){
        l.DoNotCall = !objVE.isPhone ? true : false;
        l.HasOptedOutOfEmail = !objVE.isEmail ? true : false;
        l.et4ae5__HasOptedOutOfMobile__c = !objVE.isSMS? true : false;
        
        l.OSA_Enquiry_Type__c= objVE.strleadtype;
        l.MobilePhone = objVE.phone;
        l.description= objVE.strDescription;
        }
       
        else{
         l.Phone = objVE.phone;
        }
        
        l.LastName = objVE.lastName;
        l.FirstName = objVE.firstName;
        l.Email = objVE.email;
       
        l.Account_Type__c = 'Private';
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('UDAAN').getRecordTypeId();
        l.LeadSource = 'UDAAN';
        l.Rating = 'Warm';
        l.Type__c = 'Product';
        l.Sub_Type__c = 'Retail';
        l.Purchase_Type__c = 'New Vehicle';
        l.Country_ISO_Code__c = JUDAANUtil.getSimpleMarket().toUpperCase();
        
       
        List<Asset> LstAsset =  [select AccountId,Id,Product2.Productcode,Account.Retailer_Emails__c, product2.model__r.productcode from 
                                 Asset where Id =:assetId];
                                 
        //system.debug('--code'+LstAsset[0].product2.model__r.productcode);   
        //system.debug('--11111'+JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).id); 
            
        l.Primary_Model_Interest__c = LstAsset[0].product2.model__r.productcode == NULL? null : JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).id;   
        l.Preferred_Retailer__c = LstAsset[0].AccountId; 
        l.Brand__c = LstAsset[0].product2.model__r.productcode == NULL? null : JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).Make__c;
        
        if( market == 'sg'){
         
          marketQueue = Label.SG_UDAAN_Lead;
        }
        else if( market == 'hk'){
       
         marketQueue = Label.HK_UDAAN_Lead ;
         }
         else if( market == 'th'){
        
         marketQueue = Label.TH_UDAAN_Lead;
        }
        if(marketQueue  != '' && marketQueue != null){
        userid =  [select id,name from group where type='Queue' and name=: marketQueue  ].Id;
        if(!Test.isRunningTest())
        l.ownerid = userId ;
        } 
           
          
         upsert l;
        
        system.debug('----userId '+userId );
         if( market == 'br'){
         List<Campaign> lstCampaign  = [Select id from Campaign Where name like: '%'+Label.OSA_BRAZIL_Campaign_Name  and isActive = true limit 1];
         CampaignMember cm= New CampaignMember(CampaignId=lstCampaign[0].Id, LeadID= l.Id);
         insert cm;
         
        }
       
         createSaveVehicleLead(l.id,assetId,objVE.email);
         if( market == 'jp' && LstAsset[0].Account.Retailer_Emails__c != null){
         sendEmailtoRetailer(LstAsset[0].Account.Retailer_Emails__c,l, 'OSA_Lead_Creation_Notification' );
         }
         System.debug('Created Lead :: '+l.id);
         
     }catch(Exception e)
     {
         System.debug('Exception caught '+e.getStackTraceString());
         System.debug('Exception caught '+e.getMessage());
     }
        return errorMsg;
    }
    public void createSaveVehicleLead(Id leadId,Id assetId,String email)
    {
        savedVehicle = new Saved_Vehicle_for_Lead__c();
        this.savedVehicle.Lead__c = leadId;
        this.savedVehicle.Saved_Vehicle__c = assetId;
        this.savedVehicle.Customer_Email__c = email;
        insert this.savedVehicle;
    }
    
     private void sendEmailtoRetailer(String retailerEmails, sObject relatedOpp, String emailTempName){
        EmailTemplate et = [SELECT Id ,subject, body FROM EmailTemplate WHERE DeveloperName =:emailTempName];
        List<string> toAddress = new List<string>();        
        List<String> lstretailerEmails = retailerEmails.split(',');
        Contact c = [select id, Email from Contact where email <> null limit 1];

        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setToAddresses(lstretailerEmails);
         
            mail.setTargetObjectId(c.id);
            //mail.setPlainTextBody(et.body);
            mail.setWhatId(relatedOpp.id);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            mail.setTreatTargetObjectAsRecipient(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        
        try {
            Messaging.sendEmail(allmsg);
           
            system.debug('--- allmsg;'+allmsg);
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
   }
}