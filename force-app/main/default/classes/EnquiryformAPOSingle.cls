/*
*
Description :  This class called for APOVehiclesinglepage When Enquiryform is saved.
Created Date : 6 Aug 2018
Author : TCS TEAM OFFSHORE  
*
*/
public without sharing class EnquiryformAPOSingle{

    //Create case when Enquiry form is saved and populate case details.
    //Commented this method for new business requirement instead of case , lead should be created
    public void createCaseforAPOVehicle(Case apoCase, String nscEmailId){
      
      /*
        Case objCase = new Case();
        objCase.AssetId = ApexPages.currentPage().getParameters().get('id');
        
        List<Asset> lstAsset = [Select Id, AccountId, Product2.Specification_Pack_Alternative__c,Product2.APO_Body_Style_Alternative__c,Product2.Model_Alternative__c,Account.Queue_Id__c from Asset Where Id =:  objCase.AssetId  ];
        List<Account> lstAccount = [Select Id,name,OwnerId,Email_used_for_Udaan__c,Queue_Id__c from Account Where Id =: lstAsset[0].AccountId];
       
        System.debug('lstAccount :: '+lstAccount);
        
        
        
        ID AccID  = [Select AccountID from User where id =: Userinfo.getUserid()].AccountId;
        Account objAccount = [Select Id,name,OwnerId from Account Where Id =:AccID   ];

        System.debug('AccID  :: '+AccID  );
        
        //objCase.Retailer__c= lstAccount[0].id;
        objCase.AccountId = AccID;
        
      
       
        //objCase.Retailer_Email_Email__c  = lstAccount[0].Email_used_for_Udaan__c;
        objCase.type= apoCase.type;
        objCase.origin = 'OSA Query';
        objCase.description= apoCase.description;
        objCase.Subject = Label.OSA_Asset_Query +' '+ lstAsset[0].Product2.Model_Alternative__c +' '+lstAsset[0].Product2.APO_Body_Style_Alternative__c + ' '+lstAsset[0].Product2.Specification_Pack_Alternative__c  ;
        
        objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enquiry').getRecordTypeId();
       // if(lstAccount[0].Queue_Id__c != null && lstAccount[0].Queue_Id__c != '')
          //  objCase.OwnerId  = Id.valueof(lstAccount[0].Queue_Id__c) ;
        //else
            objCase.OwnerId =  Id.valueof(objAccount.ownerId );  
             
        objCase.Status = 'Solved';
        objCase.Contact_By__c = apoCase.Contact_By__c ;
        objCase.Actual_Category_1__c='Request';
        objCase.Actual_Category_2__c='Dealer/Retailer';
        objCase.Solution_Summary__c=apoCase.description;
        //Insert case record with Enquiry Record type and Owner = Account.Queue_Id__c
           
        insert objCase;
        system.debug('----acc'+lstAccount[0].name);
        if(objCase != null ){
            String emailContentTemplate = Label.Retailer_NSC_Notification_Inquiry_Registered+'\r\n'+'\r\n'+getBaseURlForEMail()+'/'+objCase.Id+'\r\n'+'\r\n'+Label.Retailer_Notification_Inquiry_Footer ;
            String emailToRetailer =  String.format(emailContentTemplate ,new String[]{lstAccount[0].name});
            EmailUtility.SendEmail( new List<String>{lstAccount[0].Email_used_for_Udaan__c},'',Label.Retailer_NSC_Notification_Inquiry_Registered_Subject,'',emailToRetailer ,null,false,null,true  );
            
            String emailContentTemplate1 = Label.Retailer_NSC_Notification_Inquiry_Registered+'\r\n'+'\r\n'+getBaseURlForEMail()+'/'+objCase.Id+'\r\n'+'\r\n'+Label.NSC_Notification_Inquiry_Followup+'\r\n'+'\r\n'+Label.NSC_Notification_Inquiry_Footer;
            String emailToRetailer1 =  String.format(emailContentTemplate1 ,new String[]{lstAccount[0].name});
            EmailUtility.SendEmail( new List<String>{nscEmailId},'',Label.Retailer_NSC_Notification_Inquiry_Registered_Subject,'',emailToRetailer1 ,null,false,null,true  );
        }
        
       */
    }//End Method
    
       //Create Lead for Enquiry on vehiclesingle page
 
    public void createLead(Case apoCase,String selectedRetailer, list<string> lstString){
    
      
          
        Lead objLead  = new Lead();
        String assetId = ApexPages.currentPage().getParameters().get('id');
        // COSA-371: Additional column Dealer_CI_Code__c added to the SOQL 
        List<Asset> lstAsset = [Select Id, Account.Retailer_Emails__c,apo__c,vin__c, AccountId,Product2.Model__r.productcode, model__r.productcode,Account.ownerid, Product2.Specification_Pack_Alternative__c,Product2.APO_Body_Style_Alternative__c,Product2.Model_Alternative__c,Account.Queue_Id__c,Account.Dealer_CI_Code__c  from Asset Where Id =:  assetId   ];
        //List<Account> lstAccount = [Select Id,name,OwnerId,Email_used_for_Udaan__c,Queue_Id__c from Account Where Id =: lstAsset[0].AccountId];
       
        String market = ApexPages.currentPage().getParameters().get('market');
        ID AccID;
        if(!Test.isRunningTest()){
        AccID  = [Select AccountID from User where id =: Userinfo.getUserid()].AccountId;
        Account objAccount = [Select Id,name,OwnerId from Account Where Id =:AccID   ];
        System.debug(' Userinfo.getUserid():: '+ Userinfo.getUserid());
        System.debug('AccID  :: '+AccID  );
        System.debug('objAccount :: '+objAccount );
        }
       objLead.OSA_Enquiry_Type__c= apoCase.type;
       
        objLead.description= apoCase.description;
        objLead.description += '\n\r VIN / Licese Plate : ' + lstAsset[0].vin__c;
       
        id userid;
        String marketQueue = '';        
        User objUser = [Select lastname, firstname,email, phone, AccountID from User where id =: Userinfo.getUserid()];
        system.debug('selectedRetailer-- '+selectedRetailer);
        if(selectedRetailer !=  null && selectedRetailer != '' && market == 'jp'){
            // COSA-371 Changes start: The following line has been added to get the Retailer Queue based on the Dealer_CI_Code__c
            List<Account> AccDealerCodeId = [select id, Dealer_CI_Code__c from Account where id =: selectedRetailer limit 1];
            if(AccDealerCodeId!=null && AccDealerCodeId.size()>0){
                //List<Group> queueIdList = [select Id from Group where Type = 'Queue' AND NAME LIKE :'%' +lstAsset[0].Account.Dealer_CI_Code__c + '%'];
                system.debug('Selected Retailers Dealer_CI_Code__c '+ AccDealerCodeId[0].Dealer_CI_Code__c);
                List<Group> queueIdList = [select Id, NAME from Group where Type = 'Queue' AND NAME LIKE :'%' +AccDealerCodeId[0].Dealer_CI_Code__c + '%'];
                if(queueIdList!=null && queueIdList.size()>0){
                    userid =  queueIdList[0].Id;
                    system.debug('Queue Name is --'+queueIdList[0].Name);
                }else{
                    system.debug('Queue not found');
                }
                 //getOwner(selectedRetailer);
            //COSA-371 Changes end:
            system.debug('userid-- '+userid );
            }                
        }
        else{
        userid = lstAsset[0].Account.ownerid;
        }
        system.debug('---lstAsset[0]'+lstAsset[0]);
         system.debug('---lstAsset[0]'+lstAsset[0].Account.ownerid);
        if( market == 'sg'){
         // userid = [select id,name from group where type='Queue' and name=: Label.SG_UDAAN_Lead].Id; 
          marketQueue = Label.SG_UDAAN_Lead;
        }
        else if( market == 'hk'){
         //userid =  [select id,name from group where type='Queue' and name=: Label.HK_UDAAN_Lead ].Id; 
         marketQueue = Label.HK_UDAAN_Lead ;
         }
         else if( market == 'th'){
         //userid =  [select id,name from group where type='Queue' and name=: Label.TH_UDAAN_Lead ].Id; 
         marketQueue = Label.TH_UDAAN_Lead;
        }
        if(marketQueue  != '' && marketQueue != null){
        userid =  [select id,name from group where type='Queue' and name=: marketQueue  ].Id;
        }
        
        system.debug('----userId '+userId );
        if(!Test.isRunningTest())
        objLead.ownerid = userId ;
        objLead.LastName = objUser.lastName;
        objLead.FirstName = objUser.firstName;
        objLead.Email = objUser.email;
        objLead.Phone = objUser.phone;
        objLead.Account_Type__c = 'Private';
        objLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('UDAAN').getRecordTypeId();
        objLead.LeadSource = 'UDAAN Enquiry';
        objLead.Rating = 'Warm';
        objLead.Type__c = 'Product';
        objLead.Sub_Type__c = 'Retail';
        objLead.Purchase_Type__c = !lstAsset[0].apo__c ? 'New Vehicle' : 'Used Vehicle'; // this field is mandatory when type is product;
        objLead.Preferred_Retailer__c = selectedRetailer != '' && selectedRetailer != null ? selectedRetailer : lstAsset[0].accountid ;
        objLead.Account__c = AccID;
        objLead.Country_ISO_Code__c = JUDAANUtil.getSimpleMarket().toUpperCase();
        if(!Test.isRunningTest()){
        objLead.Brand__c = JUDAANUtil.getVehicleSpecFromProductCode(lstAsset[0].product2.model__r.productcode).make__c;
        objLead.Primary_Model_Interest__c = JUDAANUtil.getVehicleSpecFromProductCode(lstAsset[0].model__r.productcode).id;
        }
         if(lstString.contains(Label.Enquiry_Email)){
         objLead.HasOptedOutOfEmail= true;
         
        }
        
        if(lstString.contains(Label.Enquiry_Phone_Number)){
        objLead.DoNotCall= true;
        }
        if(lstString.contains(Label.Enquiry_Sms)){
        objLead.et4ae5__HasOptedOutOfMobile__c= true;
        }
       
        
        system.debug('----objLead'+objLead);
        insert objLead;
          system.debug('----lstAsset[0].Account.Retailer_Emails__c'+lstAsset[0].Account.Retailer_Emails__c);
        try{
        if(market == 'jp' && lstAsset[0].Account.Retailer_Emails__c != null){
         system.debug('----objLead'+objLead);
         sendEmailtoRetailer(lstAsset[0].Account.Retailer_Emails__c, objlead, 'OSA_Lead_Creation_Notification' );
         system.debug('----sendEmailtoRetailer');
        }
        }catch(exception ex){
        system.debug('----ex'+ex.getMessage());
        }
    }
    
   /*  public Id getOwner(String selectedRetailer)
   {
       Set<Id> conIds = new Set<Id>(); 
       List<Account> selRetailers = new List<Account>();
       selRetailers = [select Id, ParentId,ownerId from Account where Id = :selectedRetailer];
       system.debug('----selRetailers '+selRetailers );
       if(selRetailers.size() > 0)
       { 
          
          
          List<User> users = new List<User>();
          if(selRetailers[0].ParentId != null){
              users =  [select Id, IsActive, Title, ContactId, Contact.AccountId from User where Contact.AccountId = :selRetailers[0].ParentId];
             
               if(Users.size() == 0)
               {
                  
                   return selRetailers[0].OwnerId;
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
    */
    public  string getBaseURlForEMail(){
        if(URL.getSalesforceBaseUrl().toExternalForm().contains('online-sales-advisor'))
            return label.Production_URL;
        else{
            return URL.getSalesforceBaseUrl().toExternalForm();
        }
    }
    
    // case insert for feedback
    public string getBaseURlForEMailNSE(){
        if(URL.getSalesforceBaseUrl().toExternalForm().contains('online-sales-advisor'))
            return label.NSE_Feedback_Case_Link_Prod;
        else{
            return label.NSE_Feedback_Case_Link_Test;
        }
    }
public string createCaseforFeedback(string comment,string nscEmail,string brand,String accountId,String queueName,String countryCode)
    {
        try{
        Case objFeedbackCase = new Case();
        List<Group> queueIdList = [select Id from Group where Type = 'Queue' AND NAME =: queueName  limit 1];
        objFeedbackCase.origin = 'OSA Feedback';
        objFeedbackCase.Status = 'Solved';
       // objFeedbackCase.Actual_Category_1__c = 'Suggestion'; - commented by Marta Diniz - CXPD-971
        objFeedbackCase.Type = 'Suggestion';
        objFeedbackCase.Description = comment;
        if(brand == 'jaguar')
        objFeedbackCase.Brand2__c = 'Jaguar';
        else
        objFeedbackCase.Brand2__c = 'Land Rover';    
        //objFeedbackCase.OwnerId = '0050E000002ipFO';
        objFeedbackCase.OwnerId = queueIdList.get(0).id;
        objFeedbackCase.Country_ISO_Code__c = countryCode;
        if(accountId != null)
        objFeedbackCase.AccountId = accountId;
        objFeedbackCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enquiry').getRecordTypeId();
        insert objFeedbackCase;
        if(objFeedbackCase != null)
        {
           String emailContentTemplate1 = Label.Feedback_NSC_Notification+'\r\n'+'\r\n'+getBaseURlForEMailNSE()+'/'+objFeedbackCase.Id+'\r\n'+'\r\n'+Label.NSC_Notification_Inquiry_Footer;
           EmailUtility.SendEmail( new List<String>{nscEmail},'',Label.Feedback_NSC_Notification_Subject,'',emailContentTemplate1 ,null,false,null,true  );
        }
        }
        catch(Exception e)
        {
            System.debug('Exception occured '+e.getStackTraceString());
        }
        return 'true';
    }


  private void sendEmailtoRetailer(String retailerEmails, sObject relatedOpp, String emailTempName){
        EmailTemplate et = [SELECT Id ,subject, body FROM EmailTemplate WHERE DeveloperName =:emailTempName];
        List<string> toAddress = new List<string>();        
        List<String> lstretailerEmails = retailerEmails.split(',');
        //Contact c = [select id, Email from Contact where email <> null limit 1];

        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setToAddresses(lstretailerEmails);
         
            mail.setTargetObjectId(relatedOpp.id);
            //mail.setPlainTextBody(et.body);
            //mail.setWhatId(c.id);
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