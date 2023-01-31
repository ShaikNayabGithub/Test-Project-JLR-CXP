public class DMSMessager_India_Update implements I_DMSMessager_Update{//refactor
     private final I_HttpResponseAdapter responseAdapter;
     private final I_HttpMessager_Siebel messager;
    private final SOAPXMLAttributeConstructor attributeConstructor;
    private final DMS_PrefixHandler prefixHandler;
    
    public DMSMessager_India_Update(I_HttpMessager_Siebel messager, SOAPXMLAttributeConstructor attributeConstructor, I_HttpResponseAdapter responseAdapter, 
        DMS_PrefixHandler prefixHandler)
    {
        this.messager = messager;
        this.attributeConstructor = attributeConstructor;
        this.responseAdapter = responseAdapter;
        this.prefixHandler = prefixHandler;
    }
    
    public DMSOutboundResponse SendOpportunity(Opportunity opportunity)
    {
        
          string soapBody = this.BuildRequestMessageContent(opportunity);
                  
          HttpResponse response = this.messager.SendRequest(soapBody, true);
                system.debug('soapBody '+soapBody);
          system.debug('response '+response);
          return this.ProcessResponse(response, soapBody);
    }
    
    private DMSOutboundResponse ProcessResponse(HttpResponse response, string soapBody)
    {
        system.debug('ProcessResponse '+response);
         system.debug('ProcessResponse.getBody() '+response.getBody());
          string dmsException = this.messager.GetDMSInnerException(response.getBody());
          string errorMessage = '';
      	system.debug(response.getBody() + 'response');
        /// //MICHAEL: tidy up this method to get error code and makes sure will work against positive response messages 
        string[] splitOnNodeStart = response.getBody().split('<siebelf:errorcode>');
        
        string errorcode;
        
        if(splitOnNodeStart != null)
        {
            
            if(splitOnNodeStart.size() < 2){ 
              errorcode =  '';
            }
            else
            {
                
       system.debug('SplitonNoteStart' + splitOnNodeStart);
            errorcode = splitOnNodeStart[1].split('</siebelf:errorcode>')[0];
            }
            system.debug('errorcode '+errorcode);
        }
        else
        {
            errorMessage = 'Unknown Error. No Valid error code supplied. Please submit Page URL an Admin: ';
        }
        /// //MICHAEL: end get error code
        
       system.debug('Is String Empty1?');
        if( String.isNotEmpty(dmsException)){
            dmsException = dmsException.replace('&apos;', '\'');
        }
          Integration_Log__c log=new Integration_Log__c();
          log.Response__c=String.valueOf(response.getbody());
          log.request__c=String.valueOf(soapBody);
          log.service__c='DMS India Outbound';
     
     try{     
         
         system.debug('response.getStatusCode() '+response.getStatusCode());
         system.debug('dmsException '+dmsException);
           if(response.getStatusCode() == 500 || response.getStatusCode() == 503 || String.isNotEmpty(dmsException)){
          
            log.status__c='Error';
          }
          else
              log.status__c='Success';
          
       system.debug('Will it throw an error?');
        if(response.getStatusCode() == 503){
            throw new DMSOutbound_InvalidDataException(System.Label.DMSException_ServiceUnavailable);
        }
       system.debug('Is String Empty?');
        if(String.isNotEmpty(dmsException)){
            system.debug('dmsException '+dmsException);
                //MICHAEL: here check errorcode against metadata table and replace exception with value from table
            list<DMS_Error__mdt> retrievedMetaData = [SELECT Error_Message__c FROM DMS_Error__mdt WHERE Label = :errorcode];
            system.debug('Meta Data Retrieved');
            if(retrievedMetaData != null && retrievedMetaData.size() == 1)
            {
            system.debug('Meta Data Retrieved IF ');
                errorMessage = retrievedMetaData[0].Error_Message__c;
            }
            else
            {
            system.debug('Meta Data Retrieved IF ELSE');
                errorMessage = dmsException;//'Unknown Error. Please submit Page URL and the following error code to an Admin: ' + errorcode;
            }
            system.debug('Meta Data Retrieved - ErrorMessage: ' + errorMessage);
            throw new DMSOutbound_InvalidDataException('Siebel Exception: ' + errorMessage);// + dmsException/*+' Outbound message:   '+soapBody*/);
        }
        
      }
      catch(DMSOutbound_InvalidDataException e){}
      finally{
     
         insert log;  
      }  
        if(response.getStatusCode() == 200){
             return responseAdapter.Adapt(response);
        }else{
            //
            if(response.getStatusCode() != 0){
             Dom.Document responseDocument = response.getBodyDocument();
        	Dom.XmlNode envelope = responseDocument.getRootElement();
            Dom.XmlNode bodyNode = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
             string err  = envelope.getAttributeValue('FaultCode', 'http://schemas.xmlsoap.org/soap/envelope/');
             system.debug('env '+envelope);
             system.debug('err '+err);
             system.debug('##################');   
            }
            
            
            ///
            DMSOutboundResponse adaptedResponse = new DMSOutboundResponse();
        	adaptedResponse.IsSuccess = false;
            
            //adaptedResponse.ErrorMessage = dmsException;
            adaptedResponse.ErrorMessage = errorMessage;
            
            system.debug('dmsException ' + dmsException);
            return adaptedResponse;
        }
               
      
    
    }
    
    private string BuildRequestMessageContent(Opportunity opportunity)
    {
        // change added on 5th December 2016 to support multiple oli
        list<opportunitylineitem> opportunitylineitems = [select id, 
            Brand__r.Name, Model__r.Name,product2.model_alternative__c, Product2.Alternative_Name__c
        from opportunitylineitem where OpportunityId = :opportunity.id AND ( Product2.RecordType.Name = 'Derivative' OR 
        Product2.RecordType.Name = 'Model' )   limit 1];
        

        string brandName = '';
        if(opportunitylineitems != null && opportunitylineitems.size()> 0){
            brandName = opportunitylineitems[0].Brand__r.Name;
        }
            
        string customerType = this.RetrieveCustomerType(opportunity, brandName);
        
        Contact contact = opportunity.OpportunityContactRoles[0].Contact;
        Account account = opportunity.Account;

        Map<String,Boolean> Suppressions = new Map<String,Boolean>();
        if (contact.IndividualId != null) {
            Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
            for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId = :contact.IndividualId And Channel__c in ('Email','Phone')]) {
                List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
                Boolean allSurveyOptOut = true;
                if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
                
                consentList.add(cptc);
                consentMap.put(cptc.PartyId, consentList);
            }

            Suppressions = ConsentHandler.SuppressionsForIndividual(new Set<Id>{contact.IndividualId}, consentMap, opportunity.OpportunityLineItems[0].Brand__r.Name);
        }

        String pplValue;
        DMS_Models__mdt[] customMeta;
        
        if(OpportunityLineItems[0].product2.model_alternative__c!=null)
            pplValue=OpportunityLineItems[0].product2.model_alternative__c;
            else
            pplValue=OpportunityLineItems[0].Model__r.name;
            
         customMeta= [select DMS_Model_Name__c,id from DMS_Models__mdt where Model_Name__c =:pplValue];  
        
         if(customMeta!=null)
             if(!customMeta.isEmpty())
                 pplValue=customMeta[0].DMS_Model_Name__c;    

        return '<asi:JLRSFAInsertOrUpdate_Input><jlr:ListOfContactInterface>'+
            '<jlr:Contact Operation="'+ this.messager.GetSiebelDMLAction(contact.DMS_Identifier__c) + '">'+
               attributeConstructor.AddAttribute('DMSContactId', prefixHandler.RemovePrefix(contact.DMS_Identifier__c))+
               attributeConstructor.AddAttribute('MobilePhone', contact.MobilePhone)+
               attributeConstructor.AddAttribute('EmailAddress', contact.Email)+
               attributeConstructor.AddAttribute('Fax', contact.Fax)+
               attributeConstructor.AddAttribute('FirstName', contact.FirstName)+
               attributeConstructor.AddAttribute('HomePhone', contact.HomePhone)+
               attributeConstructor.AddAttribute('IntegrationId', contact.Id)+
               attributeConstructor.AddAttribute('LastName', contact.LastName)+
               attributeConstructor.AddAttribute('Gender', DMSAdapter_GenderPicklist_India.GetIndiaValue(contact.Gender__c))+
               attributeConstructor.AddAttribute('Title', contact.Salutation)+
               attributeConstructor.AddAttribute('NeverCall', Suppressions.get('OPTOUT_PHONE'))+
               attributeConstructor.AddAttribute('NeverEmai', Suppressions.get('OPTOUT_EMAIL'))+
               attributeConstructor.AddAttribute('WorkPhone', contact.OtherPhone)+
               attributeConstructor.AddAttribute('DMSUSERID', contact.Account.owner.DMS_Id__c)+
                this.BuildAccount(account) +
               '<jlr:Contact_Details>'+
                    BuildContactAddress(contact.Id, contact.MailingStreet, contact.MailingCity, contact.MailingState, contact.MailingPostalCode, contact.MailingCountry)+
               '</jlr:Contact_Details>'+
               '<jlr:ListOfOpportunity>'+
                 ' <jlr:Opportunity Operation="'+ this.messager.GetSiebelDMLAction(opportunity.DMS_Opportunity_ID__c) + '">'+
                     attributeConstructor.AddAttribute('DMSOptyId', opportunity.DMS_Opportunity_ID__c)+
                     attributeConstructor.AddAttribute('SourceofContact', DMSAdapter_LeadSourcePicklist_India.GetIndiaValue(opportunity.LeadSource))+
                     attributeConstructor.AddAttribute('CustomerType', customerType)+
                     attributeConstructor.AddAttribute('Description', opportunity.Description)+
                     attributeConstructor.AddAttribute('IntegrationId', opportunity.Id)+
                     //attributeConstructor.AddAttribute('Budget', String.valueOf(opportunity.Budget__c))+
                     attributeConstructor.AddAttribute('IntendedApplication', DMSAdapter_AccountRecordType_India.GetIndiaValue(account.RecordType.DeveloperName))+
                     attributeConstructor.AddAttribute('LOB', brandName)+
                     attributeConstructor.AddAttribute('PPL', pplValue)+
                     attributeConstructor.AddAttribute('PL', OpportunityLineItems[0].Product2.Alternative_Name__c)+
                     attributeConstructor.AddAttribute('DMSUSERID', opportunity.Owner.DMS_Id__c)+
                  '</jlr:Opportunity>'+
               '</jlr:ListOfOpportunity>'+
            '</jlr:Contact>'+
         '</jlr:ListOfContactInterface></asi:JLRSFAInsertOrUpdate_Input>';
    }
    
    private string RetrieveCustomerType(Opportunity opportunity, string brandName)
    {
        if(brandName == 'Jaguar'){
            return DMSAdapter_CustomerTypePicklist_India.GetIndiaValue(opportunity.Account.ntt_Jaguar_Status__c);
        }else if(brandName == 'Land Rover'){
            return DMSAdapter_CustomerTypePicklist_India.GetIndiaValue(opportunity.Account.ntt_Land_Rover_Status__c);
        }
        return '';
    }

    private string BuildAccount(Account account)
    {
      if(account.RecordType.DeveloperName != 'Corporate'){ return ''; }
      return '<jlr:ListOfAccount2>'+
                  '<jlr:Account2 Operation="'+ this.messager.GetSiebelDMLAction(account.DMS_Identifier__c) + '">'+
                     attributeConstructor.AddAttribute('DMSAccountId', prefixHandler.RemovePrefix(account.DMS_Identifier__c))+
                     attributeConstructor.AddAttribute('IntegrationId', account.Id)+
                     attributeConstructor.AddAttribute('Site', account.Site__c)+
                     attributeConstructor.AddAttribute('MainPhoneNumber', account.Phone)+
                     attributeConstructor.AddAttribute('Name', account.Name)+
                     attributeConstructor.AddAttribute('AccountType', 'Not Specified')+
                     attributeConstructor.AddAttribute('DMSUSERID', account.owner.DMS_Id__c)+
                     '<jlr:Account_Details>'+
                        BuildAccountAddress(account.Id, account.BillingStreet, account.BillingCity, account.BillingState, account.BillingPostalCode, account.BillingCountry)+
                     '</jlr:Account_Details>'+
                  '</jlr:Account2>'+
               '</jlr:ListOfAccount2>';
    }

    private string BuildContactAddress(Id id, string street, string city, string state, string postCode, string country)//refactor
    {
        if(String.isEmpty(postCode) || String.isEmpty(state) || String.isEmpty(country)){ return ''; }
        return '<jlr:Contact_Address IsPrimaryMVG="Y" Operation="Insert">'+
                     attributeConstructor.AddAttribute('ContactAddressIdentifier', id + String.valueOf(DateTime.now()))+
                     attributeConstructor.AddAttribute('City', (String.isNotEmpty(city) ? city.toUpperCase() : ''))+
                     attributeConstructor.AddAttribute('Country',  (String.isNotEmpty(country) ? country.toLowerCase().capitalize() : ''))+
                     attributeConstructor.AddAttribute('PinCode', postCode)+
                     attributeConstructor.AddAttribute('State', state)+
                     attributeConstructor.AddAttribute('Address1', street)+
                  '</jlr:Contact_Address>';
    }

    private string BuildAccountAddress(Id id, string street, string city, string state, string postCode, string country)
    {
        if(String.isEmpty(postCode) || String.isEmpty(state) || String.isEmpty(country)){ return ''; }
        return '<jlr:Contact_Account_BusinessAddress IsPrimaryMVG="Y" Operation="Insert">'+
                     attributeConstructor.AddAttribute('AccountAddressIdentifier', id + String.valueOf(DateTime.now()))+
                     attributeConstructor.AddAttribute('City', (String.isNotEmpty(city) ? city.toUpperCase() : ''))+
                     attributeConstructor.AddAttribute('Country',  (String.isNotEmpty(country) ? country.toLowerCase().capitalize() : ''))+
                     attributeConstructor.AddAttribute('PinCode', postCode)+
                     attributeConstructor.AddAttribute('State', state)+
                     attributeConstructor.AddAttribute('AddressLine1', street)+
                  '</jlr:Contact_Account_BusinessAddress>';
    }
}