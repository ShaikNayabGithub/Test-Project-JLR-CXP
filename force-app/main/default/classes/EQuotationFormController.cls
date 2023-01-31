/*
Name : EQuotationFormController.apxc

Author: Suhan Jain - NTT Data

Purpose: This is the controller for eQuote lightning component. 

Created Date : 14/12/2020
*/

public with sharing class EQuotationFormController {
     
    // Init method to initialize the lightning component onload.
    @AuraEnabled
    public static QuoteValuesWrap initQuote(Id opportunityId, Id quoteId){
        system.debug('opportunityId'+opportunityId);
        system.debug('quoteId'+quoteId);
        QuoteValuesWrap preData= new QuoteValuesWrap();
        
        user currentUser=[select id, Name, FirstName, LastName, contact.Email, Contact.MobilePhone, Country_Iso_Code__c from user where Id=:userInfo.getUserId()];
        if(currentUser!=null)
        {
            preData.userDetail= new userDataWrap();
            preData.userDetail.countryIsoCode=currentUser.Country_Iso_Code__c;
            preData.userDetail.Name=currentUser.Name;
            preData.userDetail.Email=currentUser.contact.Email;
            preData.userDetail.Phone=currentUser.Contact.MobilePhone;
            Map<string,Add_On_Accessories__c> existingComplementoryMap= New Map<string,Add_On_Accessories__c>();
            
            if(quoteId !=null)
            {
                for(Add_On_Accessories__c objComp:[select id, Product_Name__c, Sequence__c, Price__c, Product_Id__c from Add_On_Accessories__c where Quote__c=:quoteId AND Product_Id__c!=null AND Category__c='Complementary' Order by Sequence__c ASC])
                {
                    existingComplementoryMap.put(objComp.Product_Id__c, objComp);
                }
            }
            List<String> visibleSectionLst= new List<String>();
            List<complementaryObj> complementaryProdLst= new List<complementaryObj>();
            if(existingComplementoryMap.containsKey('servicePlan'))
            {
                complementaryObj objCompRec= New complementaryObj();
                objCompRec.productName=existingComplementoryMap.get('servicePlan').Product_Name__c;
                objCompRec.inputPrice=0;
                objCompRec.inputType='Checkbox';
                objCompRec.uniqueName=existingComplementoryMap.get('servicePlan').Product_Id__c;
                objCompRec.orderNo=0;
                objCompRec.isSelected=true;
                complementaryProdLst.add(objCompRec);
            }
            for(E_Quotation_Master_Config__c masterConfig:[select id, Name, Section_Name__c, Product_Name__c, Type__c, Order_Number__c, recordtype.developerName from E_Quotation_Master_Config__c Where Country_ISO_Code__c includes (:currentUser.Country_Iso_Code__c) order by Order_Number__c ASC]){
                if(masterConfig.recordtype.developerName=='Section_Visibility_Configuration')
                    visibleSectionLst.add(masterConfig.Section_Name__c);
                else if(masterConfig.recordtype.developerName=='Complimentary_Configuration')
                {
                    complementaryObj objCompRec= New complementaryObj();
                    objCompRec.productName=masterConfig.Product_Name__c;
                    objCompRec.inputPrice= existingComplementoryMap.containsKey(masterConfig.id) ? existingComplementoryMap.get(masterConfig.id).Price__c:0;
                    objCompRec.inputType=masterConfig.Type__c;
                    objCompRec.uniqueName=masterConfig.id;
                    objCompRec.orderNo=(integer)masterConfig.Order_Number__c;
                    objCompRec.isSelected=existingComplementoryMap.containsKey(masterConfig.id)? true:false;
                    complementaryProdLst.add(objCompRec);
                }
                
            }
            preData.visibleSectionLst=visibleSectionLst;
            preData.complementaryProdLst=complementaryProdLst;
            
            string qString ='select Brand__c From';
            qString+= opportunityId !=null ? ' Opportunity where Id=:opportunityId ':' Quote__c where Id=:quoteId';
            sObject objDetails= database.query(qString);
            preData.brandId=string.valueOf(objDetails.get('Brand__c'));
            preData.Models= getModels(currentUser.Country_Iso_Code__c, preData.brandId);
        }
        
        if(quoteId !=null){
            List<string> quoteFieldsLst= new List<String>();   
            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Quote__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                if(fieldName !='createddate'&& fieldName !='createdbyid' && fieldName !='lastmodifieddate' && fieldName !='lastmodifiedbyid')
                quoteFieldsLst.add(fieldName);
            } 
            preData.quoteObj=database.query('select '+string.join(quoteFieldsLst, ', ')+', Model__r.Model_Alternative__c From Quote__C Where ID=\''+quoteId+'\'');
            preData.quoteObj.Sales_Consultant_Name__c=currentUser.Name;
            preData.quoteObj.Sales_Consultant_Email__c=currentUser.contact.Email;
            preData.quoteObj.Sales_Consultant_Contact_Number__c=currentUser.contact.MobilePhone;
            
            if(preData.quoteObj.Model__c !=null)
            {
                preData.ModelName=preData.quoteObj.Model__r.Model_Alternative__c;
                preData.Derivatives= getDerivatives(preData.ModelName,currentUser.Country_Iso_Code__c);
            }
            
        }else{
            preData.quoteObj= new Quote__c();
            preData.quoteObj=resetValues(preData.quoteObj);
            preData.quoteObj.Date__c=system.Today();
            preData.quoteObj.Pricelist_Reference_No__c=generateRefNumber();
            preData.ModelName='';
        }
        
        if(opportunityId!=null && quoteId==null)
        {
            opportunity parentOpp=[select id, 
                                   Account.Name, 
                                   Account.phone,
                                   Account.PersonEmail, 
                                   Account.Retailer_Email__c, 
                                   Account.isPersonAccount,
                                   Account.PersonMobilePhone,
                                   Brand__r.Name
                                   from Opportunity 
                                   where Id=:opportunityId ];
            if(parentOpp !=null)
            {
                preData.quoteObj.Customer_Name__c	= parentOpp.Account.Name;
                if(parentOpp.Account.isPersonAccount)
                {
                    preData.quoteObj.Email__c=  parentOpp.Account.PersonEmail;
                    preData.quoteObj.Contact_No__c=  parentOpp.Account.phone !=null ?parentOpp.Account.phone:parentOpp.Account.PersonMobilePhone;
                }else{
                    preData.quoteObj.Email__c=  parentOpp.Account.Retailer_Email__c;
                    preData.quoteObj.Contact_No__c=  parentOpp.Account.phone;  
                }
            }
        }        
        return preData;
    }
    
    //Method used to save Quote Incoming data from lightning component
    @AuraEnabled
    public static string saveQuoteApex(Quote__c Quote, String complementaryProdStr){
        list<complementaryObj> complementaryProdLst=(list<complementaryObj>)JSON.deserialize(complementaryProdStr, list<complementaryObj>.class);
        try{
            if(Quote !=null){
                list<Add_On_Accessories__c> addOnForDeleteLst= New list<Add_On_Accessories__c>();
                list<Add_On_Accessories__c> addOnForUpsertLst= New list<Add_On_Accessories__c>();
                Quote.Model__c=null;
                if(Quote.Derivative__c!=null)
                {
                    list<Product2> selecetdDeriavative=[select Id, Model__c from Product2 where Id=:Quote.Derivative__c];
                    if(!selecetdDeriavative.isEmpty())
                        Quote.Model__c=selecetdDeriavative[0].Model__c;
                }
                if(Quote.Id==null)
                {
                    //Quote.CreatedDate=system.now();
                    Quote.Related_Content_DocumentID__c=null;
                    Quote.Date__c=system.today();
                	Quote.Pricelist_Reference_No__c=generateRefNumber();
                }
                upsert Quote;
                
                Map<string,complementaryObj> newComplementoryMap= New Map<string,complementaryObj>();
                Map<string,Add_On_Accessories__c> existingComplementoryMap= New Map<string,Add_On_Accessories__c>();
                
                if(!complementaryProdLst.isEmpty())
                {
                    for(complementaryObj compRec:complementaryProdLst)
                    {
                        if( (compRec.isSelected && compRec.inputType=='Checkbox') || (compRec.inputType=='Currency' && compRec.inputPrice!=null && compRec.inputPrice !=0 & compRec.inputPrice !=0.0) )
                            newComplementoryMap.put(compRec.uniqueName,compRec); 
                    }
                }
                
                for(Add_On_Accessories__c objComp:[select id, Quote__c,Sequence__c, Category__c, Product_Name__c, Price__c, Product_Id__c from Add_On_Accessories__c where Quote__c=:Quote.Id AND Product_Id__c!=null AND Category__c='Complementary'])
                {
                    existingComplementoryMap.put(objComp.Product_Id__c, objComp);
                    
                    if(!newComplementoryMap.containsKey(objComp.Product_Id__c))
                        addOnForDeleteLst.add(objComp);
                }
                
                for(string mapKey:newComplementoryMap.keySet())
                {
                    complementaryObj newAddOn =newComplementoryMap.get(mapKey);
                    Add_On_Accessories__c updateAddOn = New Add_On_Accessories__c();
                    if(existingComplementoryMap.containsKey(mapKey))
                    {
                        updateAddOn=existingComplementoryMap.get(mapKey);
                    }
                    updateAddOn.Product_Name__c=newAddOn.productName;
                    updateAddOn.Price__c=newAddOn.inputPrice;
                    updateAddOn.Category__c='Complementary';
                    if(updateAddOn.Quote__c==null)
                        updateAddOn.Quote__c=Quote.Id;
                    updateAddOn.Sequence__c=newAddOn.orderNo;
                    updateAddOn.Product_Id__c=newAddOn.uniqueName;
                    addOnForUpsertLst.add(updateAddOn);
                }    
                
                if(!addOnForDeleteLst.isEmpty())
                    delete addOnForDeleteLst;
                
                if(!addOnForUpsertLst.isEmpty())
                    upsert addOnForUpsertLst;
                //congaPdfBackgroundMode(Quote.Id,'',Network.getNetworkId());
                return Quote.Id;
            } 
        }
        catch (DmlException ex) {
            system.debug('Exception ### '+ex.getDmlMessage(0)+ex.getLineNumber());
            throw new AurahandledException(ex.getDmlMessage(0));
            
        }catch(exception e){
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
        return null; 
    }
    
    //This method generates the Ref Id for each logged in user.
    public static string generateRefNumber(){
        string refNumber='';
        User currentUser=[select id, FirstName, LastName from User where Id=:userinfo.getUserId()];
        list<Quote__c> oldQuoteInfo =[select id, Pricelist_Reference_No__c from Quote__c where createddate =THIS_MONTH AND createdbyId=:currentUser.Id order by createddate Desc limit 1];
        if(oldQuoteInfo!=null && !oldQuoteInfo.isEmpty() && oldQuoteInfo[0].Pricelist_Reference_No__c !=null)
        {
            list<string> oldValues=oldQuoteInfo[0].Pricelist_Reference_No__c.split('-');
            refNumber= string.valueOf(integer.valueOf(oldValues[3])+1);
            refNumber=oldValues[0]+'-'+oldValues[1]+'-'+oldValues[2]+'-'+refNumber;
            //refNumber=oldQuoteInfo[0].Pricelist_Reference_No__c.substring(0, oldQuoteInfo[0].Pricelist_Reference_No__c.length()-1)+ string.valueOf(integer.valueOf(oldQuoteInfo[0].Pricelist_Reference_No__c.substring(oldQuoteInfo[0].Pricelist_Reference_No__c.length()-1,oldQuoteInfo[0].Pricelist_Reference_No__c.length()))+1);  
        }else{
            string refValue=currentUser.FirstName !=null ? currentUser.FirstName.substring(0,1):'';
            refValue += currentUser.lastName.substring(0,1);
            refValue += '-'+system.today().Year(); 
            refValue += '-'+ (system.today().Month() < 10 ? '0'+string.valueOf(system.today().Month()): string.valueOf(system.today().Month()));
            refNumber=refValue+'-001';  
        }
        return refNumber;
    }
    
    //This method is used to fetch the session id of the logged in user.
    public static String getSessionIdFrmVFPg(PageReference vfPageContainSessionId){
        String data = vfPageContainSessionId.getContent().toString();
        return data.substring(data.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), data.indexOf('Session_Id_End_Here'));
    }
    
    
    //This method is used to generate the conga template in the baground mode.
    @AuraEnabled
    public static string congaPdfBackgroundMode(String quoteId, string filename, string networkId) {
        HttpResponse res;
        Quote__c Quote;
        try{
            networkId=Network.getNetworkId();
            Quote=[select Id,Opportunity__c,Customer_Name__c, Model_Name__c, Country_ISO_Code__c,Related_Content_DocumentID__c from Quote__c where Id=:quoteId];    
            list<APXTConga4__Conga_Template__c> congaTemplate=[select id from APXTConga4__Conga_Template__c where (APXTConga4__Name__c='New Vehicle Quote' OR  APXTConga4__Name__c like 'New Vehicle Retailer Quote%') AND Country__c=:Quote.Country_ISO_Code__c order by APXTConga4__Name__c desc];    
            //list<APXTConga4__Conga_Merge_Query__c> congaQuerys=[select id from APXTConga4__Conga_Merge_Query__c where Name='ComplementaryItems'];    
            
            String sessId =''; //UserInfo.getSessionId();
            if(!test.isRunningTest())
                sessId=EQuotationFormController.getSessionIdFrmVFPg(Page.sessionIdVfPage);
            else
                sessId='sessionId'; 
            String servUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/'+ UserInfo.getOrganizationId();
            String url2 = 'https://composer.congamerge.com/composer8/index.html'+
                '?sessionId=' + sessId +
                '&serverUrl=' + EncodingUtil.urlEncode(servUrl, 'UTF-8');
            
            if (String.isNotBlank(quoteId)) {
                url2 += '&id=' + quoteId;
            }
            if (!congaTemplate.isEmpty()) {                    
                url2 += '&TemplateId=' + congaTemplate[0].Id;
            }
            if (string.isNotBlank(system.label.Conga_Complementary_Query_Id)) {
                url2 += '&QueryId=[ComplementaryItems]' + system.label.Conga_Complementary_Query_Id;
            }
            
            
            if(filename=='AutoGen')
            {
                filename=Quote.Model_Name__c+' Quote/'+Quote.Customer_Name__c+'/'+system.today().format(); 
            }
            
            if (String.isNotBlank(filename)) {
                filename = EncodingUtil.urlEncode(filename, 'UTF-8');
                //filename = filename.replace(‘ ‘, ‘%20’);
                url2 += '&OFN=' + filename;
            }
            
            url2 += '&SC0=1';
            url2 += '&SC1=SalesforceFile'+
                '&defaultPDF=1' +
                '&AttachmentParentID='+Quote.Opportunity__c+
                '&contentVisibility=AllUsers'+
                '&APIMODE=1';
            system.debug('networkId'+networkId);
            if(Quote.Related_Content_DocumentID__c!=null && string.isNotBlank(Quote.Related_Content_DocumentID__c))
            {
                url2 +='&ContentDocumentID='+Quote.Related_Content_DocumentID__c;
            }
            
            if(networkId !=null)
            {
                url2+='&ContentNetworkId='+networkId;
            }
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url2);
            req.setMethod('GET');
            req.setTimeout(60000);
            res = http.send(req);
            
            if(res.getBody()!=null && string.isNotBlank(res.getBody()))
            {
                ContentVersion contentV=[select ContentDocumentId from ContentVersion where Id=:res.getBody()];
                Quote.Related_Content_DocumentID__c=contentV.ContentDocumentId;
                update Quote;
            }
        }
        catch(exception e){
            system.debug('error Line @@@ '+e.getLineNumber());
            throw new AurahandledException(res.getBody());
        }
        //return res.getBody();
        return Quote.Opportunity__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> getTradeInVinApex(String searchString, string BrandId){
        searchString = String.escapeSingleQuotes(searchString);
        searchString = '%'+searchString+'%';
        user u=[select id, Country_ISo_Code__c from user where id=:userinfo.getUserId()];
        list<Asset> assetLst=[select id, Name, Vin__c, Model__c, Model__r.Model_Alternative__c, Model__r.ProductCode,  Derivative__c, Derivative__r.Service_Plan__c, Derivative__r.Service_Plan__r.Months__c, Derivative__r.Service_Plan__r.Miles_Kilometers__c, Derivative__r.Service_Plan__r.Service_Plan_Type__c, Derivative__r.Service_Plan__r.IsActive, Derivative__r.Name, Exterior_Colour__c, Interior_Color__c from Asset where Name Like :searchString AND AccountCountryCode__c=:u.Country_ISO_Code__c AND Brand__c=:BrandId];
        return assetLst;
    }
    
    
    //This methos fetches all the models of vehicle
    @AuraEnabled
    public static List<string> getModels(String CountryIsoCode, string brandId){
        
        Set<string> ModelsSet=new Set<string>();
        List<string> ModelsList=new List<string>();
        for(PricebookEntry pbe:[select Id, Product2.Name, Product2.Model_Alternative__c, Product2.ProductCode, Product2Id from PricebookEntry Where Product2.recordType.name='Model'AND IsActive = TRUE AND Product2.IsActive=TRUE AND PriceBook2.Country_ISO_Code__c =:CountryIsoCode AND product2.Make__c=:brandId])
        {
            /*selectInputs input= new selectInputs();
              input.label=pbe.Product2.Model_Alternative__c+' - '+pbe.Product2.ProductCode;
              input.value=pbe.Product2Id; */
            ModelsSet.add(pbe.Product2.Model_Alternative__c);
        }
        ModelsList.addAll(ModelsSet);
        ModelsList.sort();
        if(!test.isRunningTest())
            ModelsList.add(0, '--- None ---');
        return ModelsList;
    }
    
    @AuraEnabled
    public static List<selectInputs> getDerivatives(String Model, String CountryIsoCode){
        list<selectInputs> Derivatives=new list<selectInputs>();
        selectInputs initInput= new selectInputs();
        initInput.label='--- None ---';
        initInput.value='';
        Derivatives.add(initInput);
        if(Model !=null)
        {
            for(PricebookEntry pbe:[select Id, Product2.Model__c, Product2.name, Product2.ProductCode, Product2Id from PricebookEntry Where Product2.recordType.name='Derivative'AND IsActive = TRUE AND Product2.IsActive=TRUE AND PriceBook2.Country_ISO_Code__c =:CountryIsoCode AND Product2.Model__c!=null AND Product2.Model__r.Model_Alternative__c=:Model])
            {
                selectInputs input= new selectInputs();
                input.label=pbe.Product2.name;
                input.value=pbe.Product2Id;
                input.optionalValue=pbe.Product2.Model__c;
                Derivatives.add(input);
            }
        }
        return Derivatives;
    }
    
    @AuraEnabled
    public static String getSpDetails(String derivativeId){
        string servicePlan='';
        list<product2> derivative=[select id, Service_Plan__c, Service_Plan__r.Months__c,Service_Plan__r.Miles_Kilometers__c from product2 where Id=:derivativeId AND Service_Plan__c !=null AND Service_Plan__r.Service_Plan_Type__c='Complimentary Service' AND Service_Plan__r.IsActive=true];
        if(!derivative.isEmpty())
            servicePlan='Servicing '+ derivative[0].Service_Plan__r.Months__c/12 +' years or '+derivative[0].Service_Plan__r.Miles_Kilometers__c+'km';
        return servicePlan;
    }
    
    private static Quote__c resetValues(Quote__c quoteObj){
        quoteObj.Add_No_Retention_Fee__c=0;
        quoteObj.COE_Rebate_Amount__c=0;
        quoteObj.Insurance_Premium__c=0;
        quoteObj.Insurance_Premium_2__c=0;
        quoteObj.Less_Booking_Fee__c=0;
        quoteObj.Less_Discounts__c=0;
        quoteObj.Less_Outstanding_Loan__c=0;
        quoteObj.Loan_Amount__c=0;
        quoteObj.Overtrade__c=0;
        quoteObj.RRP__c=0;
        quoteObj.Lease_Offer__c=0;
        quoteObj.Valuation_Offer__c=0;
        quoteObj.JLR_Accessories_Total_Price__c=0;
        return quoteObj;
    }
    
    public class QuoteValuesWrap{
        //@AuraEnabled public customerDetailWrap CustomerDetail;
        @AuraEnabled public userDataWrap userDetail;
        @AuraEnabled public Quote__c quoteObj;
        @AuraEnabled public List<string> visibleSectionLst;
        @AuraEnabled Public List<string> Models;
        @AuraEnabled Public List<selectInputs> Derivatives;
        @AuraEnabled Public List<complementaryObj> complementaryProdLst;
        @AuraEnabled public string ModelName;
        @AuraEnabled public string brandId;
    }
    
    public class selectInputs{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        @AuraEnabled public string optionalValue;
    }
    
    
    
    public class complementaryObj{
        @AuraEnabled public string productName;
        @AuraEnabled public boolean isSelected;
        @AuraEnabled public double inputPrice;
        @AuraEnabled public string inputType;
        @AuraEnabled public string uniqueName;
        @AuraEnabled public integer orderNo;
    }
    
    /*public class customerDetailWrap{
    @AuraEnabled public string Name;
    @AuraEnabled public string Email;
    @AuraEnabled public string Phone;
    }*/
    
    public class userDataWrap{
        @AuraEnabled public string countryIsoCode;
        @AuraEnabled public string Name;
        @AuraEnabled public string Email;
        @AuraEnabled public string Phone;
    }
}