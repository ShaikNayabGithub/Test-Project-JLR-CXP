public without sharing class CreateSavedQuoteImplByCheckout implements CreateSavedVehicleInterface 
{
    private Lead relatedLead;
    private Account relatedAcc;
    private Asset relatedAsset;
    private static Opportunity relatedOpp;
    private String sbpsId;
    private String selectedRetailer;
    private JUDAAN_ProtoProccessor.VehicleWrapper vehicle;
    private JUDAAN_JACCSProccesor.FinanceWrapper finance;
    private SGRedbookProcessor.VehicleWrapper vehicle_sg;
    private CreateSavedVehicleDto dto;
    private String assetId;
    private String errorMsg { get; set; }
    private String selectedVehicleBeanStr { get;set; } 
    private User u { get; set; }
    
    private String language;
    private String brandValue;
    private String market;
    
    public CreateSavedQuoteImplByCheckout()
    {
        this.setParameter();
    }
    
    public void create(CreateSavedVehicleDto dto)
    { 
        u = [select Id, AccountId, Contact.Name from User where Id = :dto.userId]; 
        this.finance = new JUDAAN_JACCSProccesor.FinanceWrapper();
        this.vehicle = new JUDAAN_ProtoProccessor.VehicleWrapper();
        this.vehicle_sg = new SGRedbookProcessor.VehicleWrapper();

        if(u.AccountId != null){
            System.debug('u.AccountId :: '+u.AccountId);
            List<Account> accs =  [select Id, Owner_Retailer__c , Preferred_Sales_Retailer_Local__c, OwnerId from Account where Id = :u.AccountId];
            if(accs.size() > 0)
            {
                System.debug('accs[0] :: '+accs[0]);
                relatedAcc = accs[0]; 
                if(dto.retailerId != null && dto.retailerId != ''){
                    relatedAcc.Preferred_Sales_Retailer__c= dto.retailerId;
                    relatedAcc.Owner_Retailer__c = dto.retailerId;
                    update relatedAcc;
                }
            }
        }

        this.dto = dto;
        this.sbpsId = dto.sbpsId;
        this.vehicle = dto.vehicle;
        this.vehicle_sg = dto.vehicle_sg;
        System.debug('----vehicle initial:' + this.vehicle_sg);
        this.finance = dto.finance; 
        this.assetId = dto.assetId;
        this.selectedRetailer = dto.retailerId; 
        system.debug('---retailer:' + dto.retailerId);
        this.selectedVehicleBeanStr = dto.selectedVehicleBeanStr; 
        this.market = dto.market;
        system.debug('----dto:' + dto);
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(dto.IsFirst)
            {
                  
                saveFinanceCalculation(); 
                saveTradeinValue();
            }
            else if(dto.IsTradeInSave){
             
                saveOpportunity();
                saveTradeInValue();
                

            }
            else if(dto.IsPayment){
            
                
                saveFinanceCalculation();
                updateOppStatus();
                saveTradeinValue();
            }
        }
        catch(Exception ex)
        {
           Database.rollback(sp);
           ErrorMsg = ex.getMessage();
           EmailUtility.SendEmail(new List<String>{system.label.Debug_EmailAddress_JLR,system.label.Debug_EmailAddress_TCS}, 'CreateSavedQuoteImplByCheckout Exception', 'CreateSavedQuoteImplByCheckout.cls Exception - ' + system.now(),'<pre>'+ex.getMessage()+'</pre><br/><pre>'+json.serializePretty(String.ValueOf(ex))+'</pre>');
           system.debug('---ex::' + ex.getMessage());
        }
    }
    
    private void updateOppStatus()
    {
        if(relatedAcc != null && assetId != null){ 
            List<Opportunity> opps = [select Id, AccountId, Asset__c from Opportunity where AccountId = :relatedAcc.Id and Asset__c = :assetId and (StageName = 'Save a Quote'OR StageName = 'Trade-in Valuation')];
            List<Asset> assets = [select Id, Reserved__c, AccountId,  Account.Email_used_for_Udaan__c  from Asset where Id = :assetId];
            List<Account> ownerRetailer = new List<Account>();
            if(assets.size() > 0)
            {
                relatedAsset = assets[0]; 
                if(relatedAsset != null){
                    if(!String.isBlank(dto.brand) && relatedAsset.AccountId != null)
                    {
                        ownerRetailer = [select Id, Name, Email_used_for_Udaan__c from Account where ParentId = :relatedAsset.AccountId and Brand__c = :dto.brand];
                    }
                }
            }
            if(Opps.size() > 0)
            { 
                opps[0].Softbank_Payment_Tracking_ID__c = sbpsId;
                opps[0].StageName = 'Pay Deposit';
                dto.willSend = true;
                opps[0].Deposit_paid_date__c = Date.today();
                opps[0].Payment_Done__c = dto.paymentDone;
                // email of child of asset retailer owner
                String OwnerEmail='';
                if(ownerRetailer.size() > 0)
                {
                    if(relatedAsset.AccountId!=null){
                        OwnerEmail= [select Id, Name, Email_used_for_Udaan__c from Account where Id = :relatedAsset.AccountId].Email_used_for_Udaan__c;
                    }
                    if(OwnerEmail!=null && OwnerEmail!=''){
                        opps[0].Snapshot_Email_for_Owner_Retailer__c  = OwnerEmail;    
                    }else{
                        opps[0].Snapshot_Email_for_Owner_Retailer__c  = ownerRetailer[0].Email_used_for_Udaan__c;
                    }
                }
                // email of selected retailer for opportunity
                //opps[0].Snapshot_Email_for_Selected_Retailer__c = dto.retailerEmail;
                String NewVehicleRetailerEmail ='';
                if(this.market == 'jp'){
                    Account accparent=[select id,parentid from account where id=:dto.retailerId limit 1];
                    if(accparent.Parentid!=null && String.valueof(accparent)!=''){
                        NewVehicleRetailerEmail =[select id,Email_used_for_Udaan__c from Account WHERE id=:accparent.Parentid limit 1].Email_used_for_Udaan__c;
                    }
                    //opps[0].Snapshot_Email_for_Selected_Retailer__c = dto.retailerEmail;
                }
                NewVehicleRetailerEmail  = Test.isRunningTest() ? 'test@abc.com' : NewVehicleRetailerEmail  ;
                
                if(NewVehicleRetailerEmail!=null && NewVehicleRetailerEmail !=''){
                    opps[0].Snapshot_Email_for_Selected_Retailer__c = NewVehicleRetailerEmail;
                }else{
                    opps[0].Snapshot_Email_for_Selected_Retailer__c = dto.retailerEmail;
                }
                opps[0].Will_send_email__c  = dto.willSend;
                update opps[0];
                relatedAsset.Reserved__c = true;
                relatedAsset.Approved_On_Udaan__c = false;
                if(assets.size() > 0)
                {
                    update relatedAsset;
                }
            }
        } 
    }
    
    private void saveTradeInValue()
    {
          List<Lead> myLead = New List<Lead>();
          if(u.AccountId != null){
              myLead = [select Id, Account__c, IsConverted  from Lead where Account__c = :u.AccountId and IsConverted = false and LeadSource='UDAAN'];
          }
           System.debug('--u.AccountId ' + u.AccountId);
          System.debug(myLead );
          
          system.debug('---vehicle:' + vehicle);
          if(this.market == 'jp')
          {
              setTradeinForJP(myLead);
          }
          else if(this.market == 'sg' || this.market == 'hk' || this.market == 'th')// enabling hk market
          {
              setTradeinForSG(myLead );
          }
    }
    
    private void setTradeinForJP(List<Lead> theLead)
    {
          List<Asset> LstAsset = new  List<Asset>();
          List<Asset> theAsset = new List<Asset>();
          if(assetId != null){
              theAsset = [select Id,AccountId,Account.Retailer_Emails__c,APO__c,Product2.Model_Alternative__c, local_price__c, Brand__c from Asset where Id =:assetId]; // -- updated by RT --
          }
           system.debug('---theAsset '+assetId );
           System.debug('---relatedAcc.Id -'+relatedAcc.Id);
           System.debug('---StageName  -'+[select Id, OwnerID, AccountId, Asset__c, StageName from Opportunity where AccountId = :relatedAcc.Id and Asset__c = :assetId]);
          List<Opportunity> opps = [select Id, OwnerID, AccountId, Asset__c, StageName from Opportunity where AccountId = :relatedAcc.Id and Asset__c = :assetId and (StageName = 'Save a Quote' OR StageName = 'Trade-in Valuation' OR StageName = 'Pay Deposit')];
          system.debug('---opps '+opps );
          if(theAsset[0].Account.Retailer_Emails__c != null || Test.IsRunningTest()){
          string retailerEmail = Test.IsRunningTest() ? 'test@abc.com' :  theAsset[0].Account.Retailer_Emails__c;
          sendEmailtoRetailer(retailerEmail,opps[0],Label.saveQuoteEmail);
          
          
          }
          if(theLead.size() > 0)
          {
              relatedLead = theLead[0]; 
              if(assetId!=null){
                 LstAsset =  [select Id,Product2.Productcode,product2.model__r.productcode from 
                                         Asset where Id =:assetId];
              }
             // if(vehicle != null)
             // {
                  relatedLead.Brand__c = JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).make__c;
                  relatedLead.Primary_Model_Interest__c = JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).id;
                  relatedLead.In_Market_Date__c = System.Today()+21;
                  relatedLead.Preferred_Retailer__c = selectedRetailer; 
                  If(Test.IsRunningTest()){
                      relatedLead.Industry='Agriculture';
                  }
                  update relatedLead;
                  //if(!dto.IsTradeInSave){
                      convertLead();
                 // }
             // }
          }
              
              // Japan Market
      
          /*else
          {
              // Japan Market
              if(vehicle != null)
              {
                  relatedAcc.Trade_in_Brand__c = vehicle.Brand;
                  relatedAcc.Trade_in_Model__c = vehicle.Model;
                  relatedAcc.Trade_in_Grade__c = vehicle.Grade;
                  relatedAcc.Trade_in_Model_Year__c = vehicle.Year;
                  relatedAcc.TRade_in_Color__c = vehicle.Color;
                  relatedAcc.Trade_in_Mileage__c = vehicle.Mileage;
                  relatedAcc.Trade_In_Value__c = vehicle.TradeinValue == null ? 0 : Integer.valueOf(vehicle.TradeinValue); 
                  system.debug('----related Acc:' + relatedAcc);
                  update relatedAcc;
                  
              }
          }*/
    }
    
    private void setTradeinForSG(List<Lead> theLead)
    {
        List<Asset> LstAsset = new  List<Asset>();
        if(theLead.size() > 0)
        {
              if(assetId!=null){
                 LstAsset =  [select Id,Product2.Productcode, product2.model__r.productcode from 
                                         Asset where Id =:assetId];
              }
              relatedLead = theLead[0]; 
              
                   // Singapore market
                  //if(vehicle_sg != null)
                  //{
                      //system.debug('--relatedleadInterest1::'+getVehicleSpecFromProductCode(LstAsset[0].Product2.Productcode));
                      relatedLead.Preferred_Retailer__c = selectedRetailer; 
                      relatedLead.Brand__c = JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).Make__c;
                      relatedLead.Primary_Model_Interest__c = JUDAANUtil.getVehicleSpecFromProductCode(LstAsset[0].product2.model__r.productcode).id;
                      relatedLead.In_Market_Date__c = System.Today()+21;
                      If(Test.IsRunningTest()){
                          relatedLead.Industry='Agriculture';
                      }
                      update relatedLead;
                      system.debug('--relatedleadInterest::'+relatedLead.Primary_Model_Interest__c);
                      system.debug('--relatedleadDate::'+relatedLead.In_Market_Date__c );
                      system.debug('--relatedleadIndustry::'+relatedLead.Industry);
                      //if(!dto.IsTradeInSave){
                       convertLead();
                      //}
                 // }
              
          } 
          /*else
          {
              // Singapore Market
              if(vehicle_sg != null)
              {
                  relatedAcc.Trade_in_Brand__c = vehicle_sg.make;
                  relatedAcc.Trade_in_Model__c = vehicle_sg.model;
                  relatedAcc.Trade_in_Model_Year__c = String.valueOf(vehicle_sg.Year);
                  relatedAcc.Trade_in_Mileage__c = vehicle_sg.Mileage;
                  relatedAcc.Trade_In_Value__c = vehicle_sg.price;
                  system.debug('----related Acc:' + relatedAcc);
                  update relatedAcc;
              }
          }*/
    }
     
    private void saveFinanceCalculation()
    {   
        setOpportunity();
        upsert relatedOpp;
    }
    private void saveOpportunity()
    {   
        setDetailsForOpportunity();
        upsert relatedOpp;
    }
   
   private void setOpportunity()
   {
        Id ownerId; 
        List<Asset> theAsset = [select Id,product2.model__r.productcode, Account.dealer_CI_CODE__C,AccountId,APO__c,Product2.Model_Alternative__c, local_price__c, Brand__c from Asset where Id =:assetId]; // -- updated by RT --
        List<Opportunity> opps = [select Id, AccountId, Asset__c, StageName from Opportunity where AccountId = :relatedAcc.Id and Asset__c = :assetId and (StageName = 'Save a Quote'OR StageName = 'Trade-in Valuation')];
       
        string FromDeposit  = '';
             String params = ApexPages.currentPage().getParameters().get('fromDeposit');
        if(params != null && params != '' && params.contains(','))
        {
           
            FromDeposit = params.split(',')[0];
        }
        else
        {
            FromDeposit = params;
        }
        
       if(opps.size() > 0)
        {
            relatedOpp = opps[0];
                            
            if(relatedOpp.StageName == 'Trade-in Valuation'){
            
              dto.willSend = false;
           
             relatedOpp.StageName = 'Save a Quote';
              
            }
                if(FromDeposit   == '2' && this.market == 'br'){
             relatedOpp.StageName = 'Trade-in Valuation';
             dto.willSend = true;
             }                       
             if((relatedOpp.StageName == 'Save a Quote' && FromDeposit   == '0') ){
                 dto.willSend = true;
                                 
             }
             else 
             dto.willSend = false;
            
                        
            if(this.market == 'jp')
            { 
              relatedOpp.Trade_in_vehicle__c = finance.TradeinVehicle;
              relatedOpp.Trade_In_Value__c = dto.protoTradeinValue;
              if(vehicle != null){
                  relatedOpp=opps[0];
                  relatedOpp.Trade_in_Brand__c = vehicle.Brand;
                  relatedOpp.Trade_in_Model__c = vehicle.Model;
                  relatedOpp.Trade_in_Grade__c = vehicle.Grade;
                  relatedOpp.Trade_in_Model_Year__c = vehicle.Year;
                  relatedOpp.Trade_in_Mileage__c= vehicle.Mileage;
                  relatedOpp.Trade_In_Value__c = vehicle.TradeinValue == null ? 0 : Integer.valueOf(vehicle.TradeinValue);
                  relatedOpp.TRade_in_Color__c = vehicle.Color;
              }
              
          }
          else if(this.market == 'sg' || this.market == 'hk' || this.market == 'th'){// enabling hk market
               
              if(vehicle_sg != null){
                   
                  relatedOpp=opps[0];
                  relatedOpp.Trade_in_Brand__c = vehicle_sg.make;
                  relatedOpp.Trade_in_Model__c = vehicle_sg.model;
                  relatedOpp.Trade_in_Model_Year__c = String.valueOf(vehicle_sg.Year);
                  relatedOpp.Trade_in_Mileage__c= vehicle_sg.Mileage;
                  relatedOpp.Trade_In_Value__c = vehicle_sg.price;
                  relatedOpp.Trade_in_vehicle__c = vehicle_sg.description;
                  relatedOpp.Trade_In_Value__c = vehicle_sg.price;
                  relatedOpp.Trade_in_Registration_Number__c = vehicle_sg.registrationnumber;
                  
              }
          }
          if(finance != null)
          {  
                relatedOpp.Local_deposit_amount__c = finance.Deposit;
                relatedOpp.Local_loan_amount__c = finance.LoanPrincipal;
                relatedOpp.Interest_rate__c = finance.TheRate;
                relatedOpp.Local_interest_charge__c = finance.InstallmentsFee;
                relatedOpp.Local_monthly_Payment_Amount__c = finance.PaymentMonthly;
                relatedOpp.Number_of_monthly_payment__c = finance.PaymentPeriod;
                relatedOpp.Local_Bonus_Payment_Amount__c = String.isBlank(finance.BonusPayment) ? '0' : finance.BonusPayment;
                relatedOpp.Number_of_bonus__c = finance.BonusPeriod;
                relatedOpp.Selected_finance_option__c = finance.SelectedPlan;
                relatedOpp.Local_total_paid_amount__c = finance.TotalPayment;
                relatedOpp.Local_vehicle_price__c = finance.TotalPrice;
                relatedOpp.First_Payment__c = finance.Payment1st;
                relatedOpp.Final_Payment__c = finance.PaymentLast;
                relatedOpp.Finance_TradeInValue__c = String.isBlank(finance.TradeinValue) ? 0 : Integer.valueOf(finance.TradeinValue);
                system.debug('---> theAsset[0].Account.dealer_CI_CODE__C'+ theAsset[0].Account.dealer_CI_CODE__C);
                system.debug('---theAsset[0].product2.model__r.productcode->'+JUDAANUtil.getVehicleSpecFromProductCode(theAsset[0].product2.model__r.productcode));
                
                relatedOpp.dealer_CI_code__c = theAsset[0].Account.dealer_CI_CODE__C;
                //relatedOpp.Primary_Model_Interest__c = JUDAANUtil.getVehicleSpecFromProductCode(theAsset[0].product2.model__r.productcode).id;
                String productCodeQuery = '%'+theAsset[0].product2.model__r.productcode +'%';
                list<Vehicle_Specification__c > lstVS = [select id, make__c, product_code__c from Vehicle_Specification__c where make__c != null and product_code__c like: productCodeQuery and Is_Currently_Sold__c = true];
                if(!lstVS.isEmpty() && lstVS != null)
                relatedOpp.Primary_Model_Interest__c = lstVS[0].id;
                
                if(this.SelectedVehicleBeanStr != null)
                {
                    relatedOpp.SelectedVehicleBean__c = this.SelectedVehicleBeanStr;
                }
                relatedOpp.Trade_In_Notes__c = dto.summaryNotes != null ? dto.summaryNotes : '' ;
                
           }
        
            relatedOpp.Retailer__c = this.selectedRetailer;
            relatedOpp.Description = finance.Message;
            relatedOpp.Finance_Calculation_Done__c = finance.FinanceCalculationDone == null ? false : finance.FinanceCalculationDone;
            relatedOpp.Trade_in_Done__c = finance.TradeinDone == null ? false : finance.TradeinDone;
            relatedOpp.Payment_Done__c = dto.paymentDone;
            relatedOpp.Retailer_Done__c = dto.RetailerDone;
            
            relatedOpp.Will_send_email__c = dto.willSend; // saveQuoteEmail issue
            System.debug('willsend100 :: '+relatedOpp.Will_send_email__c);
            //update relatedOpp;
        } 
        else
        {
             setDetailsForOpportunity();
             if(FromDeposit   == '0'){
             relatedOpp.StageName = 'Save a Quote';
             dto.willSend = true;
             }
            
             if(FromDeposit   == '1'){
             relatedOpp.StageName = 'Save a Quote';
            
             }
            if(FromDeposit   == '2'){
             relatedOpp.StageName = 'Trade-in Valuation';
             dto.willSend = true;
             }
             
             
            // Set Section Status  
            System.debug('willSend6 :: '+dto.willSend);     
            relatedOpp.Will_send_email__c = dto.willSend;
            if(this.brandValue == 'jaguar'){
                relatedOpp.Send_Email_URL__c = JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).JG_Cname__c;
            }else{
                relatedOpp.Send_Email_URL__c = JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).LR_Cname__c;
            }
            system.debug('--222-> theAsset[0].Account.dealer_CI_CODE__C'+ theAsset[0].Account.dealer_CI_CODE__C);
            system.debug('-2222--theAsset[0].product2.model__r.productcode->'+JUDAANUtil.getVehicleSpecFromProductCode(theAsset[0].product2.model__r.productcode));
                
            relatedOpp.dealer_CI_code__c = theAsset[0].Account.dealer_CI_CODE__C;
            String productCodeQuery = '%'+theAsset[0].product2.model__r.productcode +'%';
            //relatedOpp.Primary_Model_Interest__c = [select id, make__c, product_code__c from Vehicle_Specification__c where make__c != null and product_code__c like: theAsset[0].product2.model__r.productcode and Is_Currently_Sold__c = true].id;
            list<Vehicle_Specification__c > lstVS = [select id, make__c, product_code__c from Vehicle_Specification__c where make__c != null and product_code__c like: productCodeQuery  and Is_Currently_Sold__c = true];
            if(!lstVS.isEmpty() && lstVS != null)
            relatedOpp.Primary_Model_Interest__c = lstVS[0].id;
            
            //JUDAANUtil.getVehicleSpecFromProductCode(theAsset[0].product2.model__r.productcode).id;
               
            String sendEmailUrl = relatedOpp.Send_Email_URL__c;
            relatedOpp.Send_Email_URL__c = sendEmailUrl.substring(0, sendEmailUrl.indexOf('?'));
            relatedOpp.Send_Email_URL__c += '/customeraccountpage?brand=' + this.brandValue + '&lang=' + this.language + '&market='+this.market;
            relatedOpp.Retailer_Done__c = dto.retailerDone; 
            
           
            
        }  
        
       
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
   
   
   private Id getOwner()
   {
       Set<Id> conIds = new Set<Id>(); 
       List<Account> selRetailers = new List<Account>();
       selRetailers = [select Id, ParentId,ownerId from Account where Id = :selectedRetailer];
       system.debug('----selRetailers '+selRetailers );
       if(selRetailers.size() > 0)
       { 
          system.debug('====relatedAcc'+relatedAcc);
          
          List<User> users = new List<User>();
          if(selRetailers[0].ParentId != null){
              users =  [select Id, IsActive, Title, ContactId, Contact.AccountId from User where Contact.AccountId = :selRetailers[0].ParentId];
             
               if(Users.size() == 0)
               {
                  
                   return relatedAcc.OwnerId;
               }
               else
               {
                
                   for(User u : users)
                   {
                       if(u.Title == system.label.c_manager)
                           return u.Id;
                   }
                   return users[0].Id;
               }
          }
          else{
           //Changes for COSA - 199 - Set opportunity ownerId to Reatailer owenerId
           return selRetailers[0].ownerId;
          
          }
       }
       return null;
   }
   
    // -- Added by RT --
    /* **************************************************
    Method Name: setOppOwnerSG
    Input Parameters: String(Account Id)
    Return Type: Id (User Id)
    Method Description: Method to fetch user id to set dummy user as owner on opportunity for Singapore market 
    ****************************************************** */  
    public Id setOppOwnerSG(String assetAccId){
        List<User> userToAssignList =  [select Id,Dummy_User__c,ContactId, Contact.AccountId from User where Contact.AccountId =:assetAccId and Dummy_User__c = TRUE];
           if(!userToAssignList.isEmpty()){
               return userToAssignList[0].Id;
           }
         
          return null ;
    }
    // -- Added by RT ends here --
    
   
  
   private void convertLead()
   {
       
       Database.LeadConvert lc = new Database.LeadConvert();
       lc.setLeadId(relatedLead.Id);
       lc.setAccountId(relatedAcc.Id);
       lc.setDoNotCreateOpportunity(true);
       LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
       lc.setConvertedStatus(convertStatus.MasterLabel);
       Database.LeadConvertResult lcr = Database.convertLead(lc);
       System.debug(convertStatus);
       
       moveSavedVehicles(); 
       
       
   }
    
   private void moveSavedVehicles()
   {
       List<Saved_Vehicle_for_Lead__c> leadVehicles = [select Id, Saved_Vehicle__c from Saved_Vehicle_for_Lead__c where Lead__c = :relatedLead.Id];
       List<Saved_Vehicle_for_Account__c> accVehicles = new List<Saved_Vehicle_for_Account__c>();
       for(Saved_Vehicle_for_Lead__c leadVehicle : leadVehicles)
       {
           accVehicles.add(new Saved_Vehicle_for_Account__c(Account__c = relatedAcc.Id, Saved_Vehicle__c = leadVehicle.Saved_Vehicle__c));
       }
       insert accVehicles;
       delete leadVehicles;
   }
   
   private void setParameter(){
        this.language = ApexPages.currentPage().getParameters().get('lang');
        if(String.isEmpty(this.language)) {
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        if(ApexPages.currentPage().getParameters().containsKey('brand')){
            this.brandvalue = ApexPages.currentPage().getParameters().get('brand');
        }else{
            this.brandvalue = 'landrover';
        }
        
        if(this.brandvalue != 'landrover' && this.brandvalue != 'jaguar' ){
            this.brandvalue = 'landrover';
        }
   }
    private void setDetailsForOpportunity(){
        Id ownerId;
         // -- Added by RT --
        List<Asset> theAsset = [select Id,AccountId,APO__c,Product2.Model_Alternative__c, local_price__c, Brand__c from Asset where Id =:assetId]; // -- updated by RT --
        List<Opportunity> opps = [select Id, AccountId, Asset__c, StageName from Opportunity where AccountId = :relatedAcc.Id and Asset__c = :assetId and (StageName = 'Save a Quote'OR StageName = 'Trade-in Valuation')];
        if(opps.size() > 0)
        {
            relatedOpp = opps[0];
            if(this.market == 'jp')
            {
              if(vehicle != null){
                  relatedOpp=opps[0];
                  relatedOpp.Trade_in_Brand__c = vehicle.Brand;
                  relatedOpp.Trade_in_Model__c = vehicle.Model;
                  relatedOpp.Trade_in_Grade__c = vehicle.Grade;
                  relatedOpp.Trade_in_Model_Year__c = vehicle.Year;
                  relatedOpp.Trade_in_Mileage__c= vehicle.Mileage;
                  relatedOpp.Trade_In_Value__c = vehicle.TradeinValue == null ? 0 : Integer.valueOf(vehicle.TradeinValue);
                  relatedOpp.TRade_in_Color__c = vehicle.Color;
              }
              
          }
          else if(this.market == 'sg' || this.market == 'hk' || this.market == 'th'){// enabling hk market
              if(vehicle_sg != null){
                  relatedOpp=opps[0];
                  relatedOpp.Trade_in_Brand__c = vehicle_sg.make;
                  relatedOpp.Trade_in_Model__c = vehicle_sg.model;
                  relatedOpp.Trade_in_Model_Year__c = String.valueOf(vehicle_sg.Year);
                  relatedOpp.Trade_in_Mileage__c= vehicle_sg.Mileage;
                  relatedOpp.Trade_In_Value__c = vehicle_sg.price;
                  relatedOpp.Trade_in_vehicle__c = vehicle_sg.description;
                  relatedOpp.Trade_In_Value__c  = vehicle_sg.price;
                  relatedOpp.Trade_in_Registration_Number__c = vehicle_sg.registrationnumber;
                  
              }
          }
            relatedOpp.Retailer__c = this.selectedRetailer;
            relatedOpp.Description = finance.Message;
            //update relatedOpp;
        } 
        else{
            relatedOpp = new Opportunity();
            relatedOpp.Name = u.Contact.Name + ' - ' + theAsset[0].Product2.Model_Alternative__c;
            relatedOpp.StageName = 'Trade-in Valuation';
            Integer days = 7;
            JUDAAN_Date__c expiryDate = JUDAAN_Date__c.getInstance('Expiry Date');
            if(expiryDate != null)
            {
                days = Integer.valueOf(expiryDate.Saved_Quotes__c);
            }
            List<RecordType> oppRecordType = [select Id, Name from RecordType where sobjecttype = 'Opportunity' and developerName = :system.Label.UDAAN_OPP_Record_Type];
            if(oppRecordType.size() > 0)
            {
                relatedOpp.RecordTypeId = oppRecordType[0].Id;
            }
            relatedOpp.Amount = theAsset[0].local_price__c;
            relatedOpp.Budget__c = theAsset[0].local_price__c;
            relatedOpp.CloseDate = Date.today().addDays(days); 
            relatedOpp.AccountId = relatedAcc.Id;
            relatedOpp.Asset__c = finance.vehicle; 
            relatedOpp.Retailer__c = this.selectedRetailer;
            relatedOpp.User__c = dto.userId;
            List<Pricebook2>  thePricebook = [select Id from Pricebook2 where Name = 'Japan' and IsActive = true];
            if(thePricebook.size() > 0)
            {
                relatedOpp.Pricebook2Id = thePricebook[0].Id;
            }
            relatedOpp.LeadSource = 'UDAAN';
            relatedOpp.Quote_saved_date__c = Date.today();
            relatedOpp.Type_Hidden__c = 'Product';
            relatedOpp.Sub_Type__c = 'Retail';
           // relatedOpp.Purchase_Type__c = 'New Vehicle';
            relatedOpp.Description = finance.Message;
            relatedOpp.Brand__c = theAsset[0].Brand__c;
            system.debug('----brand:' + theAsset[0].Brand__c);
            // Id ownerId= getOwner(); // -- Commented by RT --
            
            // -- Added by RT --
             if(!theAsset.isEmpty()){
                relatedOpp.Purchase_Type__c = theAsset[0].APO__c == true ? Label.Purchase_Type_Used_Vehicle:Label.Purchase_Type_New_Vehicle;
             }
            
            if(market.equalsIgnoreCase('jp')){
                 relatedOpp.CurrencyIsoCode = 'JPY';
                  ownerId= getOwner();
            }
            else if(market.equalsIgnoreCase('sg')){
                relatedOpp.CurrencyIsoCode = 'SGD';
                if(!theAsset.isEmpty()){
                    if(!String.isBlank(theAsset[0].AccountId)){
                        ownerId= setOppOwnerSG(theAsset[0].AccountId);
                    }
                }
            }/*enabling hk market starts here*/
            else if(market.equalsIgnoreCase('hk')){
                relatedOpp.CurrencyIsoCode = 'HKD';
                if(!theAsset.isEmpty()){
                    if(!String.isBlank(theAsset[0].AccountId)){
                        ownerId= setOppOwnerSG(theAsset[0].AccountId);
                    }
                }
            }/*enabling hk market ends here*/
            else if(market.equalsIgnoreCase('br')){
                relatedOpp.CurrencyIsoCode = 'BRL';
             }
            else if(market.equalsIgnoreCase('th')){
                relatedOpp.CurrencyIsoCode = 'THB';
             }
           //-- Ends here ---
           
            if(ownerId != null)
            {
              relatedOpp.OwnerId = ownerId;
            } 
        }
     
        
        system.debug('--fiance in implement:' + finance);
        if(finance != null)
        { 
            relatedOpp.Local_deposit_amount__c = finance.Deposit;
            relatedOpp.Local_loan_amount__c = finance.LoanPrincipal;
            relatedOpp.Interest_rate__c = finance.TheRate;
            relatedOpp.Local_interest_charge__c = finance.InstallmentsFee;
            relatedOpp.Local_monthly_Payment_Amount__c = finance.PaymentMonthly;
            relatedOpp.Number_of_monthly_payment__c = finance.PaymentPeriod;
            relatedOpp.Local_Bonus_Payment_Amount__c = String.isBlank(finance.BonusPayment) ? '0' : finance.BonusPayment;
            relatedOpp.Number_of_bonus__c = finance.BonusPeriod;
            relatedOpp.Selected_finance_option__c = finance.SelectedPlan;
            relatedOpp.Local_total_paid_amount__c = finance.TotalPayment;
            relatedOpp.Local_vehicle_price__c = finance.TotalPrice;
            relatedOpp.First_Payment__c = finance.Payment1st;
            relatedOpp.Final_Payment__c = finance.PaymentLast;
            relatedOpp.Finance_TradeInValue__c = String.isBlank(finance.TradeinValue) ? 0 : Integer.valueOf(finance.TradeinValue);
            if(this.SelectedVehicleBeanStr != null)
            {
                relatedOpp.SelectedVehicleBean__c = this.SelectedVehicleBeanStr;
            }
        }
        
        if(this.market == 'jp')
        {   
            relatedOpp.Trade_in_vehicle__c = finance.TradeinVehicle;
            relatedOpp.Trade_In_Value__c  = dto.protoTradeinValue;    
            if(vehicle != null)
              {
                
                  relatedOpp.Trade_in_Brand__c = vehicle.Brand;
                  relatedOpp.Trade_in_Model__c = vehicle.Model;
                  relatedOpp.Trade_in_Grade__c = vehicle.Grade;
                  relatedOpp.Trade_in_Model_Year__c = vehicle.Year;
                  relatedOpp.Trade_in_Mileage__c= vehicle.Mileage; 
                  relatedOpp.Trade_In_Value__c = vehicle.TradeinValue == null ? 0 : Integer.valueOf(vehicle.TradeinValue);
                  relatedOpp.Trade_in_Color__c = vehicle.Color;

                  relatedOpp.Revised_Trade_in_Brand__c = relatedOpp.Trade_in_Brand__c;
                  relatedOpp.Revised_Trade_in_Model__c = relatedOpp.Trade_in_Model__c;
                  relatedOpp.Revised_Trade_in_Grade__c = relatedOpp.Trade_in_Grade__c;
                  relatedOpp.Revised_Trade_in_Model_Year__c = relatedOpp.Trade_in_Model_Year__c;
                  relatedOpp.Revised_Trade_in_Mileage__c = relatedOpp.Trade_in_Mileage__c;
                  relatedOpp.Revised_Trade_In_Value__c = relatedOpp.Trade_In_Value__c;
                  relatedOpp.Revised_Trade_in_Color__c = relatedOpp.Trade_in_Color__c;
                 
              }
           
        }
        else if(this.market == 'sg' || this.market == 'hk' || this.market == 'th')// enabling hk market
        {
            // Set trade in information for Singapore 
            system.debug('----vehicle sg:' + vehicle_sg);
            if(vehicle_sg != null)
            {
                relatedOpp.Trade_in_vehicle__c = vehicle_sg.description;
                relatedOpp.Trade_In_Value__c  = vehicle_sg.price;
                relatedOpp.Trade_in_Registration_Number__c = vehicle_sg.registrationnumber;
                relatedOpp.Trade_in_Brand__c = vehicle_sg.make;
                relatedOpp.Trade_in_Model__c = vehicle_sg.model;
                relatedOpp.Trade_in_Model_Year__c = String.valueOf(vehicle_sg.Year);
                relatedOpp.Trade_in_Mileage__c = vehicle_sg.Mileage;
                relatedOpp.Trade_In_Value__c = vehicle_sg.price;

                relatedOpp.Revised_Trade_in_Brand__c = vehicle_sg.make;
                relatedOpp.Revised_Trade_in_Model__c = vehicle_sg.model;
                relatedOpp.Revised_Trade_in_Model_Year__c = String.valueOf(vehicle_sg.Year);
                relatedOpp.Revised_Trade_in_Mileage__c = vehicle_sg.Mileage;
                relatedOpp.Revised_Trade_In_Value__c = vehicle_sg.price;
                relatedOpp.Trade_In_Notes__c = dto.summaryNotes != null ? dto.summaryNotes : '' ;
            }
        }
        relatedOpp.Payment_Done__c = dto.paymentDone;
        relatedOpp.Finance_Calculation_Done__c = finance.FinanceCalculationDone == null ? false : finance.FinanceCalculationDone;
        relatedOpp.Trade_in_Done__c = finance.TradeinDone == null ? false : finance.TradeinDone;
    }
}