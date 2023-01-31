public class EVHC_Processor {
    
    final static String REASONLABEL='Reason';
    final static String LVL1CTGRY='Lvl1Ctgry';
    final static String LVL2CTGRY='Lvl2Ctgry';
    final static String TECHNICIAN='Technician';
    final static String SERVICE_ADVISOR='Service Advisor';
    final static String GREEN='Green';
    final static String ITEM3='00003'; 
    final static String ITEM1='00001';
    final static String ITEM4='00004';
    final static String ITEM2='00002';
    
    private Map<string,asset> mapvinToAsset=new Map<String,asset>();
    integer removezeros;
    List<Account> accountsToUpdateConsent=new List<Account>();
    Account acc;
    String tst;
    Asset assetToUpdate;
    List<Asset> assetsToUpdate=new List<Asset>();
    Map<String,Account> mapStringToAccount= new Map<String,Account>();
    Set<String> phoneAndEmails= new Set<String>();
    List<Account> listAccountsWithPhone;
    List<Account> listAccountsWithEmail;
    Account[] dealers;
    Account dealer;
    List<Evhc_item__c> listItems;
    
    public EVHC_Processor(){   
    } 
    
    private Id getidFromVin(String vin){
        
        id id;
        if(!mapvinToAsset.isEmpty())
            if(mapvinToAsset.get(vin)!=null)
            id=mapvinToAsset.get(vin).id;
        else
            id=null;
        
        return id;  
    }
    
    private void updateOptAccounts(List<Account> emailAccounts, List<Account> phoneAccounts, String countryIsoCode){
        Set<Id> individualEmailIds = new Set<Id>();
        Set<Id> individualPhoneIds = new Set<Id>();
        
        for(account acc:emailAccounts) {      
            if(acc.RecordTypeId != SObjectUtilities.RecordTypes.get('Account').get('Corporate').Id && acc.PersonIndividualId != null) individualEmailIds.add(acc.PersonIndividualId);     
        }
        
        for(account acc:phoneAccounts) {
            if(acc.RecordTypeId != SObjectUtilities.RecordTypes.get('Account').get('Corporate').Id && acc.PersonIndividualId != null) individualPhoneIds.add(acc.PersonIndividualId);   
        }
        
        Set<Id> globalIds = new Set<Id>();
        globalIds.addAll(individualEmailIds);
        globalIds.addAll(individualPhoneIds);
        
        if (!globalIds.isEmpty()) {
            Map<String, ContactPointTypeConsent> existingConsentMap = new Map<String, ContactPointTypeConsent>();
            for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurposeId, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c, Retailer__c from ContactPointTypeConsent Where PartyId in :globalIds And Channel__c IN ('Email','Telephone','SMS') And DataUsePurpose.LegalBasis.Retailer_Only__c = false Order By CaptureDate asc]) {
                existingConsentMap.put('' + cptc.PartyId + cptc.DataUsePurposeId + cptc.Channel__c, cptc);
            }
            
            Set<String> channels = new Set<String>();
            channels.add('Email');
            channels.add('Telephone');
            channels.add('SMS');
            
            List<ContactPointTypeConsent> upsertList = new List<ContactPointTypeConsent>();
            for (DataUsePurpose purpose : [Select Id, Available_Channels__c From DataUsePurpose Where Available_In_Markets__c INCLUDES (:countryIsoCode) And Available_Channels__c INCLUDES ('Email','Telephone','SMS')]) {
                for (Id individualId : globalIds) {
                    for (String channel : channels) {
                        if (!((channel == 'Email' && individualEmailIds.contains(individualId)) || ((channel == 'Telephone' || channel == 'SMS') && individualPhoneIds.contains(individualId)))) continue;
                        
                        String key = '' + individualId + purpose.Id + channel;
                        ContactPointTypeConsent cptc = new ContactPointTypeConsent(PartyId = individualId, DataUsePurposeId = purpose.Id, Channel__c = channel, PrivacyConsentStatus = 'NotSeen');
                        if (existingConsentMap.containsKey(key)) cptc = existingConsentMap.get(key);
                        
                        if (cptc.PrivacyConsentStatus != 'OptOut') {
                            cptc.PrivacyConsentStatus = 'OptOut';
                            cptc.CaptureDate = Datetime.now();
                            upsertList.add(cptc);
                        }
                    }
                }
            }
            
            if (!upsertList.isEmpty()) upsert upsertList;
        }
        
    }
    
    private boolean compareFields(String vin,String email,String phone){
        
        String accountEmail;
        String accountPhone;
        
        if(mapvinToAsset!=null)        
            if(mapvinToAsset.get(vin)!=null)
        {    
            acc= mapvinToAsset.get(vin).account;
            
            if(!mapvinToAsset.isEmpty() && !String.isBlank(phone))
            {   
                if(acc.PersonHomePhone==phone)
                    return true;
                else
                    if(acc.PersonMobilePhone==phone)
                    return true;
                else
                    if(acc.PersonOtherPhone==Phone)
                    return true;
                else
                    if(acc.phone==Phone)
                    return true;
                else
                    if(acc.PersonAssistantPhone==phone)
                    return true; 
            }
            
            if(!mapvinToAsset.isEmpty() && !String.isBlank(email))
            {                 
                if(acc.PersonEmail==email)
                    return true;
                else
                    if(acc.Retailer_Email__c==email)
                    return true;
                else
                    if(acc.email2__pc==email)
                    return true;
                else
                    if(acc.email3__pc==email)
                    return true;
                
            }
        }
        return false;
        
    } 
    
    public String processEVHCrecords(String request){
        
        EVHCData evhcJson;
        EVHC__c evhc;
        String evhcId;
        String inspection;
        String cat;
        String item;
        String reason;
        String techComments;
        String customerDec;
        String technician;
        String service_advisor;
        List<asset> listAssets;
        List<EVHC__c> listEvhc=new List<Evhc__c>();
        Set<String> evhcIds= new Set<String>();
        Set<String> vins=new Set<String>();
        Set<String> dealerCodes= new Set<String>();
        List<EVHCData.cls_CreateOrUpdateServiceOrRepairEventForVehicle> listEvents;
        Map<String,evhc__c> mapEvhcIdtoEvhc=new Map<String,evhc__c>();
        Map<String,List<evhc_item__c>> mapEVHCitemtoevhcid= new Map<String,List<evhc_item__c>>();
        List<evhc_item__c> itemsToInsert= new List<evhc_item__c>();
        Evhc_item__c evhcItem;
        Database.SaveResult[] insertResults;
        integer i=0;
        sobject record;
        String recdate;
        Double partsCost;
        Double labourCost;
        Double totalCost;
        Double otherCosts;
        String email;
        boolean emailOptedOut;
        boolean phoneOptedOut;
        String phoneOptedOutString;
        String dealerCode;
        String phoNum;
        
        try{
            evhcJson=EVHCData.parse(request);

            if(evhcJson!=null)
                if(evhcJson.BatchRequestBody!=null)
                if(evhcJson.BatchRequestBody.BatchMessages!=null)
                if(evhcJson.BatchRequestBody.BatchMessages.CreateOrUpdateServiceOrRepairEventForVehicle!=null)    
                listEvents=evhcJson.BatchRequestBody.BatchMessages.CreateOrUpdateServiceOrRepairEventForVehicle;
            
        } catch(Exception e){
            return String.valueof('Problem parsing the request: '+evhcJson); 
        }
        
        try {
            
            for(EVHCData.cls_CreateOrUpdateServiceOrRepairEventForVehicle creatorUpdate:listEvents){                
                //collect list of vins
                if(!String.isBlank(creatorUpdate.SerOrRep.Vehicle.vin))
                    vins.add(creatorUpdate.SerOrRep.Vehicle.vin);
                
                if(creatorUpdate.CRMHeader!=null && creatorUpdate.CRMHeader.DealerCode!=null) {
                    dealerCode=creatorUpdate.CRMHeader.DealerCode;
                }
                
                if(creatorUpdate.SerOrRep.Acct.Emails!=null && creatorUpdate.SerOrRep.Acct.Emails.email!=null) {
                    //check if the email coming from EVHC Service matches the email in the account of the asset
                    email=creatorUpdate.SerOrRep.Acct.Emails.email.EmailAddr;
                    emailOptedOut=creatorUpdate.SerOrRep.Acct.Emails.email.DoNotUseFlg;
                    if(emailOptedOut==true)
                        phoneAndEmails.add(email);       
                }
                
                if(creatorUpdate.SerOrRep.Acct.Tels!=null && creatorUpdate.SerOrRep.Acct.Tels.TEL[0]!=null) {
                    phoNum=creatorUpdate.SerOrRep.Acct.Tels.TEL[0].phNum;
                    phoneOptedOutString=creatorUpdate.SerOrRep.Acct.Tels.TEL[0].DoNotUseFlg;
                    if(Boolean.valueOf(phoneOptedOutString)!=null)
                        phoneOptedout=Boolean.valueOf(phoneOptedOutString);
                    if(phoneOptedOut==true)
                        phoneAndEmails.add(phoNum);
                }                                       
                
            }//END LOOP
        } catch(Exception ex){
            return ex.getMessage()+'Null values in one ore more fields'; 
        }    
        
        dealers = [select id,country_iso_code__c from account where (Primary_Dealer_Code__c =:dealerCode or Secondary_Dealer_Code__c=:dealerCode)];
        
        if(dealers.size()>0) dealer=dealers[0];
        
        if(!vins.isEmpty()) {
            //create map vin to asset
            listAssets=[select id,vin__c,mileage__c,mileage_uom__c,account.PersonEmail,account.Retailer_Email__c,account.Email2__pc,account.Email3__pc,account.PersonHomePhone, account.PersonMobilePhone,
                        account.PersonOtherPhone, account.Phone,account.PersonAssistantPhone 
                        from asset where vin__c in: vins];      
            
            for(asset asset:listAssets)
                mapvinToAsset.put(asset.vin__c,asset); 
            
            listAccountsWithEmail=[SELECT RecordTypeId,LegalEntityID__c,corporate__c,PersonIndividualId, OwnerId, PersonContact.FirstName, PersonContact.LastName,PersonEmail, Email2__pc, Email3__pc,Retailer_Email__c , PersonHomePhone, PersonMobilePhone,
                                   PersonOtherPhone, Phone,PersonAssistantPhone  FROM Account 
                                   WHERE (Retailer_Email__c IN: phoneAndEmails OR PersonEmail IN: phoneAndEmails OR Email2__pc IN: phoneAndEmails OR Email3__pc IN: phoneAndEmails)
                                   AND RecordTypeId !=: SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id ];
            
            listAccountsWithPhone=[SELECT  RecordTypeId,LegalEntityID__c,corporate__c,PersonIndividualId, OwnerId, PersonContact.FirstName, PersonContact.LastName,PersonEmail, Email2__pc, Email3__pc,Retailer_Email__c , PersonHomePhone, PersonMobilePhone,
                                   PersonOtherPhone, Phone,PersonAssistantPhone FROM Account
                                   where (PersonAssistantPhone IN: phoneAndEmails OR PersonHomePhone IN: phoneAndEmails OR PersonMobilePhone IN: phoneAndEmails
                                          OR PersonOtherPhone IN: phoneAndEmails OR Phone IN: phoneAndEmails)
                                   AND RecordTypeId !=: SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id];
            
            //update all the accounts in the system that opted out from phone or email 
            updateOptAccounts(listAccountsWithEmail, listAccountsWithPhone, dealer.country_iso_code__c); 
            
        }
        
        dealers= [select id,country_iso_code__c from account where (Primary_Dealer_Code__c =:dealerCode or Secondary_Dealer_Code__c=:dealerCode)];
        
        if(dealers.size()>0)
            dealer=dealers[0];
        
        
        //Create here map category and item from custom metadata
        
        for(EVHCData.cls_CreateOrUpdateServiceOrRepairEventForVehicle creatorUpdate:listEvents){
            if(creatorUpdate.SerOrRep.RprItms!=null){
                
                if(!String.isBlank(creatorUpdate.SerOrRep.UnqSrcSystmID))
                    EVHCiD=creatorUpdate.SerOrRep.UnqSrcSystmID;
                
                String mileage=String.valueOf(creatorUpdate.SerOrRep.MlgIn);
                String uom=creatorUpdate.SerOrRep.MlgUOM;
                
                String dealerId=creatorUpdate.SerOrRep.RprOrdrRef;
                String regNum=creatorUpdate.SerOrRep.Vehicle.RegNum;
                String evhcDate=creatorUpdate.SerOrRep.InspctnDt;
                
                dealerCode=creatorUpdate.CRMHeader.DealerCode;
                String vin=creatorUpdate.SerOrRep.Vehicle.vin;
                String custFirstName=creatorUpdate.SerOrRep.Acct.FstNm+' ';
                String custLastName=creatorUpdate.SerOrRep.Acct.LstNm;
                
                //Phone
                String phone;
                String phoneType;
                if(creatorUpdate.SerOrRep.Acct.Tels != null && creatorUpdate.SerOrRep.Acct.Tels.TEL[0] != null) {
                    phone=creatorUpdate.SerOrRep.Acct.Tels.TEL[0].phNum;
                    phoneType=creatorUpdate.SerOrRep.Acct.Tels.TEL[0].PhNumType;
                }
                
                //Email
                if(creatorUpdate.SerOrRep.Acct.Emails!=null && creatorUpdate.SerOrRep.Acct.Emails.email!=null) {
                    //check if the email coming from EVHC Service matches the email in the account of the asset
                    email=creatorUpdate.SerOrRep.Acct.Emails.email.EmailAddr;
                    emailOptedOut=creatorUpdate.SerOrRep.Acct.Emails.email.DoNotUseFlg;
                    
                } 
                
                if(custFirstName==null)
                    custFirstName='';
                if(custLastName==null)
                    custLastName='';
                
                String currencyIsoCode;
                
                evhc = new EVHC__c();
                evhc.Asset__c=getIdFromvin(vin);
                evhc.evhcid__c=evhcid;
                evhc.name=evhcid;
                if(dealer!=null)
                    evhc.dealer__c=dealer.id;
                
                if(compareFields(vin,email,'')){
                    evhc.email__c=email;
                }    
                else
                    evhc.emailMatch__c=false;   
                
                if(!String.isBlank(mileage) && !String.isBlank(uom)){
                    assetToUpdate=mapvinToAsset.get(vin);
                    if(assetToUpdate!=null && integer.valueOf(mileage)>0)                             
                        if(
                            (assetToUpdate.mileage__c==null)
                            || (assetToUpdate.mileage__c!=null && integer.valueOf(mileage)>assetToUpdate.mileage__c))
                    {   
                        assetToUpdate.mileage__c=Integer.valueOf(mileage);
                        assetsToUpdate.add(assetToUpdate);
                        
                    }                            
                }   
                
                if(!String.isBlank(uom))
                    mileage=mileage+' '+uom;
                
                evhc.mileage__c=mileage;
                
                evhc.dealer_id__c=dealerid;
                evhc.registration_number__c=regNum;
                evhc.name__c=custFirstName+custLastName;
                evhc.dealer_Code__c=dealerCode;
                
                if(compareFields(vin,'',phone)) 
                {
                    evhc.phone__c=phone;
                    evhc.phone_Type__c=phoneType;
                }
                else
                    evhc.phonematch__c=false;
                
                If(!String.isBlank(evhcDate))
                    evhc.date__c=date.valueof(evhcDate);
                
                if(evhc.asset__c!=null)
                    listEvhc.add(evhc);
                
                reason=creatorUpdate.SerOrRep.RprOrdrTyp;
                removezeros=integer.valueOf(reason);
                reason=String.valueOf(removezeros);
                
                
                //Reason
                Repair_Item_level__mdt[] customMeta= [select masterlabel,id from Repair_Item_level__mdt where CategoryLevel__c=:REASONLABEL and value__c=:reason];
                
                if(customMeta!=null)
                    if(!customMeta.isEmpty())
                    reason=customMeta[0].masterlabel; 
                
                evhc.reasonpicklist__c=reason;   
                
                //iterate over items
                
                for(EVHCData.cls_RprItm line: creatorUpdate.SerOrRep.RprItms.RprItm){
                    
                    inspection=line.InspctnStts;
                    
                    
                    removezeros=integer.valueOf(line.Lvl1Ctgry);
                    cat=String.valueOf(removezeros); 
                    
                    //Category
                    customMeta= [select masterlabel,id from Repair_Item_level__mdt where CategoryLevel__c=:LVL1CTGRY and value__c=:cat];
                    
                    if(customMeta!=null)
                        if(!customMeta.isEmpty())
                        cat=customMeta[0].masterlabel;
                    
                    removezeros=integer.valueOf(line.Lvl2Ctgry);
                    item=String.valueOf(removezeros);        
                    
                    //Item
                    customMeta= [select masterlabel,id from Repair_Item_level__mdt where CategoryLevel__c=:LVL2CTGRY and value__c=:item];
                    
                    if(customMeta!=null)
                        if(!customMeta.isEmpty())
                        item=customMeta[0].masterlabel;
                    
                    techComments=line.TchncnCmmnts;
                    customerDec=line.InspctnOutcm;
                    recDate=line.InspctnRcmmndedDueDt;
                    
                    if(line.TrdngPrtnrEmplys!=null && line.TrdngPrtnrEmplys.TrdngPrtnrEmply!=null)
                        if(line.TrdngPrtnrEmplys.TrdngPrtnrEmply.size()>=2)
                    {    
                        technician=line.TrdngPrtnrEmplys.TrdngPrtnrEmply[1].Emply.FrstNm+' '+line.TrdngPrtnrEmplys.TrdngPrtnrEmply[1].Emply.LstNm;
                        service_advisor=line.TrdngPrtnrEmplys.TrdngPrtnrEmply[0].Emply.FrstNm+' '+line.TrdngPrtnrEmplys.TrdngPrtnrEmply[0].Emply.LstNm;
                    }
                    
                    if(line.RprItmPrcs!=null)
                        if(line.RprItmPrcs.RprItmPrc!=null){
                            for(EVHCData.RprItmPrc it: line.RprItmPrcs.RprItmPrc){
                                
                                if(it.CrrncyCd!=null)
                                    currencyIsoCode=it.CrrncyCd;
                                
                                if(it.Itm==ITEM3)
                                    partsCost=it.Prc;
                                else
                                    if(it.Itm==ITEM1)
                                    labourCost=it.Prc;
                                else
                                    if(it.Itm==ITEM4)
                                    totalCost=it.Prc;
                                else
                                    if(it.Itm==ITEM2)
                                    otherCosts=it.Prc;              
                            }
                        }
                    
                    //create EVHC children
                    
                    evhcItem = new EVHC_Item__c();
                    evhcItem.categorypicklist__c=cat;
                    evhcItem.evhcId__c=evhc.evhcid__c;
                    evhcItem.itempicklist__c=item;
                    evhcItem.InspctnStts__c=inspection;
                    evhcItem.technician_Comments__c=techcomments;
                    evhcItem.Original_Customer_Decision__c=customerDec;
                    evhcItem.Original_Customer_Decision_picklist__c=customerDec;
                    evhcItem.Technician__c=technician;
                    evhcItem.service_advisor__c=service_advisor;
                    evhcItem.parts_cost__c=partsCost;
                    evhcItem.labour_costs__c=labourCost;
                    evhcItem.total_cost__c=totalCost;
                    evhcItem.other_costs__c=otherCosts;
                    if(currencyIsoCode!=null)
                        if(Currencyisocode.length()==3)
                        evhcItem.currencyISOCode=currencyIsoCode;  
                    
                    partsCost=0;
                    totalCost=0;
                    labourCost=0;
                    otherCosts=0;
                    
                    If(!String.isBlank(recDate))
                        evhcItem.Recommended_Date__c=date.valueof(recDate);
                    
                    
                    IF(mapEVHCitemtoevhcid.get(evhc.evhcid__c)!=null)
                        mapEVHCitemtoevhcid.get(evhc.evhcid__c).add(evhcItem);
                    else{
                        mapEVHCitemtoevhcid.put(evhc.evhcid__c,new List<evhc_Item__c>());
                        mapEVHCitemtoevhcid.get(evhc.evhcid__c).add(evhcItem);
                    }
                    
                }                        
            }
            
        }
        
        //insert evhc parent object
        insertResults = Database.Insert(listEvhc, false);
        
        //update the assets mileage
        update assetsToUpdate;
        
        //insert evhc item(children)
        evhc__c evhcData;
        Map<String,Id> mapEvhcIdToSystemId=new Map<String,Id>();
        
        if(insertResults!=null)
            for (Database.SaveResult sr : insertResults ) {
                
                if (sr.isSuccess()) {
                    
                    record=listEvhc.get(i);
                    if(record!=null)
                    {
                        evhcData=(EVHC__C)record;
                        listItems=mapEVHCitemtoevhcid.get(EVHCdATA.EVHCID__C);
                        
                        for(evhc_Item__c evhcDataItem:listItems){    
                            evhcDataItem.evhc__c=sr.getId();
                            itemsToInsert.add(evhcDataItem);
                            
                        }
                        
                    }    
                    
                }
                i++;      
            }
        
        insert itemsToInsert;
        
        return 'Success';
        
    }
}