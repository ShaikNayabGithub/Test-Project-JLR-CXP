public class OpportunityHandler {
    //public static Boolean IsFirstTimeSubmitForApproval = true;
    private final String HANDOVER = 'Handover';
    private final String RDA = 'Negotiation & Approval';
    private final String TEST_DRIVE = 'Test Drive';
    private final String RETAILER_LOST = 'Retailer Lost';
    private final String IS_NEW_LOST = 'Lost';
    private Boolean oppAUPreUpdate = true;
    private Boolean oppAUPostUpdate = true;
    Public static Boolean shuhoRecurrsionCheck = true; 
    Public static Boolean accountJagANDLRStatusInsertCheck = true;
    Public static Boolean accountJagANDLRStatusUpdateCheck = true;
    Public static Boolean removeOrderNumberFromLineItemCheck = true;
    
    public static Boolean ignoreMMIT = false;
    
    // public static User loggedInUser = [SELECT Id, Market__c, Country_ISO_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
    public static User loggedInUser = getUserInformation(UserInfo.getUserId());
    public static Boolean taskCreation = false;
    public static Boolean testDriveEventCreation = false;
    public static Boolean taskvalidation = false;
    public static Id taskRecordtypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Task').getRecordTypeId();
    public static Id taskMandatoryRecordtypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Mandatory_AGT').getRecordTypeId();
    public static Id eventRecordtypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Event').getRecordTypeId();
    
    public static User getUserInformation(Id userId) {
        if(loggedInUser == null || loggedInUser.Id != userId) {
            loggedInUser = [SELECT Id, Market__c, Country_ISO_Code__c FROM User WHERE Id = :userId];
        }
        return loggedInUser;
    }
    
    public void PreCreate(List<Opportunity> opportunities) {
        DefaultPurchaseTypeToNewVehicle(opportunities);
        DefaultCountryIsoCodeToAccount(opportunities);
        MMIT_OpportunityInfoSetter_Opportunity_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_Opportunity_F();
        MMIT_OpportunityInfoSetter_Opportunity mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();
        set<Id> ownerSet = new set<Id>();
        for (Opportunity oppty : opportunities){
            ownerSet.add(oppty.OwnerId);
        }
        Map<Id,user> userMap = new Map<Id,user>([SELECT Id, name from user WHERE Id IN : ownerSet]);
        
        for(Opportunity opp : opportunities){
            String ownerName;
            user u = userMap.get(opp.OwnerId);
            ownerName = u.Name.toLowerCase();
            if (ownerName != null && ownerName.contains('default')){
                opp.Owned_By_Default_User__c = true;
            }else{
                opp.Owned_By_Default_User__c = false;
            }
            //CXPD-756
            opp.Primary_Account__c = opp.PrimaryAccountId__c;
            
            
        }
        if (ignoreMMIT == false) {
            mmitOpportunityInfoSetter.SetVehicleInfo(opportunities);
        }
        
    }
    
    public void PostCreate(List<Opportunity> opportunities) {
        // OpportunityContactRoleCreator_Factory opportunityContactRoleCreatorFactory = new OpportunityContactRoleCreator_Factory();
        // OpportunityContactRoleCreator opportunityContactRoleBuilder = opportunityContactRoleCreatorFactory.Create();
        String jsonStr = json.serialize(opportunities);
        if(!system.isFuture() && !System.isBatch()){
            OpportunityContactRoleCreator.Create(jsonStr);
        }
        
        //Opportunity_AccountJLRStatusSetter accountJLRStatusSetter = new Opportunity_AccountJLRStatusSetter(); 
        //CustomerJourneySetterStatusAccount cJSSA = new CustomerJourneySetterStatusAccount();
        //List<Account> accs = cJSSA.getAccountsRelatedToOpp(opportunities);
        //cJSSA.setAccountsRelatedToOppToSELECT(accs);
        // opportunityContactRoleBuilder.Create(opportunities);
        // if(loggedInUser == null || (loggedInUser != null && loggedInUser.Market__c == null ) || (loggedInUser != null && loggedInUser.Market__c == null && loggedInUser.Market__c != 'Australia' ) ){
        //CreateServiceAppointmentOnInsert(opportunities);
        //CreateTestDriveOnInsert(opportunities);  
        if(loggedInUser.Market__c != 'Australia' ){            
            CreateTestDriveHandOver(opportunities, null);       
        }
        if(!system.isFuture() && !system.isBatch() && accountJagANDLRStatusInsertCheck){
            String oppJsonStr = json.serialize(opportunities);
            AccountJagANDLRStatusHandler.updateLRAndJaguarStatus(oppJsonStr,null);
            accountJagANDLRStatusInsertCheck = false;
        }
        //accountJLRStatusSetter.SetJLRStatuses(opportunities); 
        
        //JP Noone using         createTaskOnStageChangedOnPostInsert(opportunities); //Added By Masthan to create Tasks for new RDA Process
        
        AccountCustomerJourneyStatusHandler.SetAccountCustomerJourneyStage(opportunities, null);
        RecordSharer sharer = new RecordSharer();
        try {
            sharer.Share_Opportunities(opportunities);          //LB don't want the trigger to error if the sharing fails 
        } catch (Exception e) {
        }
    }
    
    public void PreUpdate(List<Opportunity> currentOpportunities, Map<Id, Opportunity> oldOpportunities) {
        DefaultPurchaseTypeToNewVehicle(currentOpportunities);
        List<Opportunity> oppsHaveBeenLost = new List<Opportunity>();
        //Australia Critical Opp Bug Start 
        OpportunityOwnershipChangeLogic OOCL = new OpportunityOwnershipChangeLogic();
        List<Opportunity>  newOppChanged = new   List<Opportunity>();
        Map<Id,Opportunity> oldMapId = new   Map<Id,Opportunity>();
        Set<Id> ownerIds = new Set<Id>();
        //*
        Set<Id> owners = new Set<Id>();
        for (Opportunity currOpp : currentOpportunities){
            owners.add(currOpp.OwnerId);
        }
        Map<Id, user> userMap = new Map<Id, user>([SELECT Id, name from user WHERE Id IN :owners]);
        //*
        //End
        List<String> opptyLostStageList = new List<String>{'Retailer Lost', 'NSC Lost', 'Lost'};//1.0 - CXPD-1360
            for (Opportunity currentOpp : currentOpportunities) {
                Opportunity oldOpp = oldOpportunities.get(currentOpp.Id);
                //1.0 - CXPD-1360
                if(currentOpp.StageName != oldOpp.StageName &&
                   String.isNotBlank(currentOpp.StageName) &&
                   opptyLostStageList.contains(currentOpp.StageName))
                {
                    currentOpp.CloseDate = Date.today();
                }
                
                //CXPD-756
                if(currentOpp.AccountId != oldOpp.AccountId)
                {
                    currentOpp.Primary_Account__c = currentOpp.PrimaryAccountId__c;
                }
                //Australia Critical Opp Bug Start
                if(currentOpp.OwnerId != null && oldOpp.OwnerId != null && currentOpp.OwnerId != oldOpp.OwnerId){
                    newOppChanged.add(currentOpp); 
                    oldMapId.put(oldOpp.id,oldOpp);
                    ownerIds.add(currentOpp.OwnerId);
                    ownerIds.add(oldOpp.OwnerId);
                    //owners.add(currentOpp.OwnerId);                
                }
                
                //End
                String ownerName;
                User u = userMap.get(currentOpp.OwnerId);
                ownerName = u.Name.toLowerCase();
                if (ownerName != null && ownerName.contains('default')){
                    currentOpp.Owned_By_Default_User__c = true;
                }else{
                    currentOpp.Owned_By_Default_User__c = false;
                }    
                
                if ((currentOpp.Retailer_Loss_Category__c != null && (oldOpp.Retailer_Loss_Category__c == '' || oldOpp.Retailer_Loss_Category__c == null))
                    || (currentOpp.Agency_Loss_Category__c != null && (oldOpp.Agency_Loss_Category__c == '' || oldOpp.Agency_Loss_Category__c == null))
                    || (currentOpp.IsWon == false && currentOpp.IsClosed == True && (oldOpp.IsClosed == false))
                   ) {
                       System.debug('lost another one');
                       oppsHaveBeenLost.add(currentOpp);
                   }
            }
        if(newOppChanged != null && newOppChanged.size() > 0 && oldMapId != null && oldMapId.size() > 0 && ownerIds != null && ownerIds.size() > 0){
            OOCL.processOpportunityOwnershipChange(newOppChanged,oldMapId,ownerIds);
        }
        if(removeOrderNumberFromLineItemCheck
           && oppsHaveBeenLost != null
           && !oppsHaveBeenLost.isEmpty()
           && !system.isFuture()
           && !system.isBatch()){
               String oppJsonStr = json.serialize(oppsHaveBeenLost);
               OpportunityLineItemUpdateHelper.removeOrderNumberFromLineItemAndStampOnOpp(oppJsonStr);
               removeOrderNumberFromLineItemCheck = false;
           }
        //   ManageOpportunitySharingForPartnerCommunityUserChange(currentOpportunities,oldOpportunities);        
        MMIT_OpportunityInfoSetter_Opportunity_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_Opportunity_F();
        MMIT_OpportunityInfoSetter_Opportunity mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();
        LastSellingRetailerSetter lastSellingRetailerSetter = new LastSellingRetailerSetter();
        
        lastSellingRetailerSetter.Set(currentOpportunities, oldOpportunities);
        /* if(loggedInUser == null || (loggedInUser != null && loggedInUser.Market__c == null ) || (loggedInUser != null && loggedInUser.Market__c == null && loggedInUser.Market__c != 'Australia' ) ){
CreateServiceAppointmentOnUpdate(currentOpportunities, oldOpportunities);  
//future method ^
}*/
        
        //CreateTestDriveOnUpdate(currentOpportunities, oldOpportunities); //moved to PostUpdate
        //setHasVinFieldWhenisPresentInOppItem(currentOpportunities,oldOpportunities);
        if (ignoreMMIT == false) {
            mmitOpportunityInfoSetter.SetVehicleInfo(currentOpportunities, new Map<Id, Opportunity>(oldOpportunities));
        }
        
        CalculateDMSStatus(currentOpportunities);
        //Added By Masthan Andela as part of CXPDA-754
        OpportunityNewStageUpdateForDMS.preUpdate_OpportunityNewStageUpdateForDMS(currentOpportunities, oldOpportunities);
        
        //JP   taskValidationOnStageChangedPreUpdate(currentOpportunities, oldOpportunities); //Added By Masthan to validate Tasks for new RDA Process //Why is this trigggered all the time!?! Joe
        
        // Added By Australia to enforce some additinal validation
        OpportunityTriggerHandlerAU.PreUpdate(currentOpportunities, oldOpportunities);
    }
    
    public void PostUpdate(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        
        List<Opportunity> wonOpps = new List<Opportunity>();
        Set<Id> cxpCampaignIds = new Set<Id>();
        List<Campaign> cxpCampaigns = new List<Campaign>();
        List<Opportunity> setToRetailerLost = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity newOpp : opps) {
            Opportunity oldOpp = oldOpps.get(newOpp.Id);
            
            if (newOpp.Probability == 100 && oldOpp.Probability != 100) {
                //AUS Opportunities should not be locked even if they are Close/Won
                if (newOpp.Country_ISO_Code__c != 'AU'){
                    wonOpps.add(newOpp);
                }
                
                if (newOpp.CampaignId != null) {
                    cxpCampaignIds.add(newOpp.CampaignId);
                }
            }
            
            
            if (
                (newOpp.StageName == RETAILER_LOST && oldOpp.StageName != RETAILER_LOST)
                ||
                (newOpp.StageName == IS_NEW_LOST && oldOpp.StageName != IS_NEW_LOST)
            ) {
                oppIds.add(newOpp.Id);
                setToRetailerLost.add(newOpp);
            }
            
            if (newOpp.CampaignId != oldOpp.CampaignId) {
                
                if (newOpp.CampaignId != null) {
                    cxpCampaignIds.add(newOpp.CampaignId);
                }
                if (oldOpp.CampaignId != null) {
                    cxpCampaignIds.add(newOpp.CampaignId);
                }
                
                
            }
        }
        
        
        if (!cxpCampaignIds.isEmpty()) {
            for (Id eyedee : cxpCampaignIds) {
                Campaign cp = new Campaign();
                cp.Id = eyedee;
                cxpCampaigns.add(cp);
                
            }
            coopStatsRollUpLogic rollup = new coopStatsRollUpLogic();
            rollup.updateCooPParentsStatFields(cxpCampaigns);
            
            
        }
        
        if (wonOpps.size() > 0) {
            LockWonOpps.lock(wonOpps);
        }
        
        
        if (setToRetailerLost.size() > 0) {
            //CXPD-1450 Starts Here
            List<asset> assetLstForOwnerUpdate = new list<Asset>();
            List<opportunityLineItem> retaierLostOli = [select Id, Asset__c, opportunity.owner.Contact.AccountId from opportunityLineItem where opportunityId In :oppIds AND Asset__c !=null AND opportunity.Owner_Account_Country_ISO_Code__c ='IN' ];
            for(opportunityLineItem oli:retaierLostOli)
            {
                if(oli.opportunity?.owner?.Contact?.AccountId !=null)
                {
                    assetLstForOwnerUpdate.add(new Asset(id=oli.Asset__c, accountId=oli.opportunity.owner.Contact.AccountId, Key_Contact__c=null));
                }
                oli.Asset__c=null;
            }
            if(!retaierLostOli.isEmpty())
            {
                update retaierLostOli;
                update assetLstForOwnerUpdate;
            }
            //CXPD-1450 Ends Here
            SubmitForApproval.submit(setToRetailerLost);
        }
        
        setHasVinFieldWhenisPresentInOppItem(opps, oldOpps); //on Handover, mark Has_Vin__c on Opportunity if OpportunityProduct has Asset populated (regardless of whether this has a Vin/Vista Order Number)
        
        //Opportunity_AccountJLRStatusSetter accountJLRStatusSetter = new Opportunity_AccountJLRStatusSetter();
        
        //accountJLRStatusSetter.SetJLRStatuses(opps, new Map<Id, Opportunity>(oldOpps)); //find
        
        //SetCustomerJourneyStage(opps, oldOpps);
        
        List<Opportunity> recentOpps = new List<Opportunity>();
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp: opps){
            accIds.add(opp.AccountId);
        }
        System.debug('accIds'+accIds);
        List<Account> accList = new List<Account>();
        if(!accIds.isEmpty()) accList = [SELECT Id, Recent_Opportunity_Created_Date__c FROM Account WHERE Id IN: accIds];
        Map<Id, Account> accMap = new Map<Id, Account>();
        for(Account acc: accList){
            accMap.put(acc.Id,acc);
        }
        System.debug('accMap'+accMap);
        for(Opportunity opp: opps){
            Account acc = accMap.get(opp.AccountId);
            System.debug('Account with recent opps'+acc);
            System.debug('Recent Opportunity'+opp);
            if(acc!=NULL && opp.Created_Date_Time__c == acc.Recent_Opportunity_Created_Date__c){
                recentOpps.add(opp);
            }
        }
        System.debug('recent opportunity:'+recentOpps);
        if(!recentOpps.isEmpty() && recentOpps != null){
            System.debug('recent opportunity:'+recentOpps);
            AccountCustomerJourneyStatusHandler.SetAccountCustomerJourneyStage(recentOpps, oldOpps); 
        }

        //CXPD-2448 changes begin
        List<String> stages = new List<String>{'Take Order','Order Taken','Order','Handover','Handover & RDA','Won'};
        List<String> countryCodesToExclude = system.label.RDAHandoverCountryCodes.split(',');
        System.debug('countryCodesToExclude: '+countryCodesToExclude);
        System.debug('loggedInUser.Country_ISO_Code__c: '+loggedInUser.Country_ISO_Code__c);
        List<Opportunity> oppListToUpdateAsset = new List<Opportunity>();
        for(Opportunity opp: opps){
            System.debug('opp.StageName: '+opp.StageName);
            if(stages.contains(opp.StageName) && !countryCodesToExclude.contains(loggedInUser.Country_ISO_Code__c)){
                oppListToUpdateAsset.add(opp);
                System.debug('oppListToUpdateAsset1: '+oppListToUpdateAsset);
            }
        }
        System.debug('oppListToUpdateAsset: '+oppListToUpdateAsset);
        if(oppListToUpdateAsset!=NULL) RelatedAssetUpdate(oppListToUpdateAsset);
        //CXPD-2448 changes end
        
        //JP  createTaskOnStageChangedOnPostUpdate(opps, oldOpps); //Added By Masthan to create Tasks for new RDA Process
        // if(loggedInUser == null || (loggedInUser != null && loggedInUser.Market__c == null ) || (loggedInUser != null && loggedInUser.Market__c == null && loggedInUser.Market__c != 'Australia' ) ){
        //CreateTestDriveOnUpdate(opps, oldOpps); 
        if(loggedInUser.Market__c != 'Australia' ){
            CreateTestDriveHandOver(opps, oldOpps); 
            //^future Method
        }
        
        RecordSharer sharer = new RecordSharer();
        try {
            sharer.Share_Opportunities(opps);          //LB don't want the trigger to error if the sharing fails 
        } catch (Exception e) {
        }
        
        //Added By Masthan Andela as part of Golden Record Changes
        OpportunityPrimaryAccountUpdater.accountUpdater(opps, oldOpps);
        // OpportunityRDAHandler.createRDA(opps, oldOpps);
        //OpportunityRDAHandler.createRDANewOrUsed(opps, oldOpps);
        
        // Added By Australia as we want to ensure when an opportunity is marked as lost its asset is removed
        OpportunityTriggerHandlerAU.PostUpdate(opps, oldOpps);
        UpdateContractStatus(opps, oldOpps);
        if(!system.isFuture() && !system.isBatch() && accountJagANDLRStatusUpdateCheck){
            String oppJsonStr = json.serialize(opps);
            String oldOppJsonStr = json.serialize(oldOpps);
            AccountJagANDLRStatusHandler.updateLRAndJaguarStatus(oppJsonStr, oldOppJsonStr);
            accountJagANDLRStatusUpdateCheck = false;
        }
        ProcessSalesTargetCounts.checkOppCount(opps, oldOpps);
        set<id> oppIdsSet = new set<id>();
        for(opportunity opp : opps){
            if((opp.Test_Drive_Complete__c != null && opp.Test_Drive_Complete__c != oldOpps.get(opp.Id).Test_Drive_Complete__c)
               || (opp.Appraisal__c != null && opp.Appraisal__c != oldOpps.get(opp.Id).Appraisal__c)
               || (opp.Order__c != null && opp.Order__c != oldOpps.get(opp.Id).Order__c)
               || (opp.Registration_Date__c != null && opp.Registration_Date__c != oldOpps.get(opp.Id).Registration_Date__c)
               || (opp.Quotation__c != null && opp.Quotation__c != oldOpps.get(opp.Id).Quotation__c)
               || (opp.Welcome_Questionnaire__c != null && opp.Welcome_Questionnaire__c != oldOpps.get(opp.Id).Welcome_Questionnaire__c)){
                   oppIdsSet.add(opp.Id);
               }
        }
        String oppStr = json.serialize(opps);
        String oldOppStr = json.serialize(oldOpps);
        if(!system.isfuture() 
           && !system.isBatch()
           && oppStr != null
           && !oppIdsSet.isEmpty()
           && shuhoRecurrsionCheck
           && oldOppStr != null){
               System.debug('<<< Create Event >>>-->1'+shuhoRecurrsionCheck);
               shuhoRecurrsionCheck = false;
               System.debug('<<< Create Event >>>-->2'+shuhoRecurrsionCheck);
               ProcessSuhoEventStageHandler.ProcessSuhoEventStage(oppStr,oldOppStr);
               
           }
        
    }
    
    public void UpdateContractStatus(List<Opportunity> opportunities,map<Id,Opportunity> oldOppMap) {
        set<id> lostoppIdsSet = new set<id>();
        set<id> wonoppIdsSet = new set<id>();
        set<id> retailerLostIdsSet = new set<id>();
        Id recTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
        for(Opportunity opp : opportunities){
            if(opp.isclosed 
               && opp.Country_ISO_Code__c != 'AU'
               && (opp.isclosed != oldOppMap.get(opp.Id).isclosed && opp.Country_ISO_Code__c != 'IN'
                   || (opp.isWon 
                       && opp.StageName == 'Handover' 
                       && opp.Country_ISO_Code__c == 'IN' 
                       && opp.StageName != oldOppMap.get(opp.Id).StageName))){
                           
                           if(opp.isWon){
                               wonoppIdsSet.add(opp.Id);
                           }else if(!opp.isWon){
                               lostoppIdsSet.add(opp.Id);
                           }
                       }
            if(opp.StageName == 'Retailer Lost' && opp.StageName != oldOppMap.get(opp.Id).StageName){
                retailerLostIdsSet.add(opp.Id);
            }
        }
        
        if(retailerLostIdsSet != null && !retailerLostIdsSet.isEmpty()){
            map<Id,Contract> ContractUpdateMap = new map<Id,Contract>();
            for(Contract cont : [select id,Contract_Status__c,opportunity__c 
                                 from Contract 
                                 where recordTypeid =:recTypeId 
                                 and opportunity__c in:retailerLostIdsSet 
                                 and opportunity__c != null
                                 and Contract_Status__c != 'Cancelled' 
                                 and Country_ISO_Code__c != 'AU']){
                                     
                                     Contract contNewIns = new Contract();
                                     contNewIns.id = cont.Id;
                                     contNewIns.Contract_Status__c = 'Cancelled';
                                     contNewIns.Asset__c = null;
                                     ContractUpdateMap.put(contNewIns.Id,contNewIns);
                                 }
            if(ContractUpdateMap != null && !ContractUpdateMap.isEmpty()){
                update ContractUpdateMap.values();
            }
        }
        
        if(lostoppIdsSet != null && !lostoppIdsSet.isEmpty()){
            map<Id,Contract> ContractUpdateMap = new map<Id,Contract>();
            for(Contract cont : [select id,Contract_Status__c,opportunity__c 
                                 from Contract 
                                 where recordTypeid =:recTypeId 
                                 and opportunity__c in:lostoppIdsSet 
                                 and opportunity__c != null
                                 and Contract_Status__c != 'Cancelled' 
                                 and Country_ISO_Code__c != 'AU']){
                                     
                                     Contract contNewIns = new Contract();
                                     contNewIns.id = cont.Id;
                                     contNewIns.Contract_Status__c = 'Cancelled';
                                     contNewIns.Asset__c = null;
                                     ContractUpdateMap.put(contNewIns.Id,contNewIns);
                                 }
            if(ContractUpdateMap != null && !ContractUpdateMap.isEmpty()){
                update ContractUpdateMap.values();
            }
        }
        system.debug('wonoppIdsSet --> '+wonoppIdsSet);
        if(wonoppIdsSet != null && !wonoppIdsSet.isEmpty()){
            map<Id,Contract> ContractUpdateMap = new map<Id,Contract>();
            for(Contract cont : [select id,Contract_Status__c,opportunity__c from Contract 
                                 where recordTypeid =:recTypeId 
                                 and opportunity__c in:wonoppIdsSet 
                                 and opportunity__c != null
                                 and Contract_Status__c != 'Live Contract'
                                 and Country_ISO_Code__c != 'AU']){
                                     Contract contNewIns = new Contract();
                                     contNewIns.id = cont.Id;
                                     contNewIns.Contract_Status__c = 'Live Contract';
                                     ContractUpdateMap.put(contNewIns.Id,contNewIns);
                                 }
            if(ContractUpdateMap != null && !ContractUpdateMap.isEmpty()){
                system.debug('ContractUpdateMap --> '+ContractUpdateMap);
                update ContractUpdateMap.values();
            }
        }
    }
    
    public void CalculateDMSStatus(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            if (String.isNotBlank(opp.DMS_Opportunity_ID__c)) {
                opp.DMS_Status__c = 'Processed'; continue;
            }
            
            if (String.isNotBlank(opp.DMS_Reason__c)) {
                opp.DMS_Status__c = 'Error'; continue;
            }
            
            if (opp.TimeLastSentToDMS__c != null) {
                opp.DMS_Status__c = 'Processing'; continue;
            }
            
            opp.DMS_Status__c = 'Not Sent';
        }
    }
    
    public void CreateTestDriveHandOver(List<Opportunity> opps, Map<Id, Opportunity> oldOpportunitiesMap)
    {
        if(testDriveEventCreation) return;
        testDriveEventCreation = true;        
        List<Id> OppIds = new List<Id>();
        Opportunity oldOpp;
        try
        {
            for (Opportunity opp : opps) {
                if(oldOpportunitiesMap!= null) oldOpp = oldOpportunitiesMap.get(opp.Id);
                
                if(oldOpportunitiesMap!= null) oldOpp = oldOpportunitiesMap.get(opp.Id);
                if ((oldOpp != null && oldOpp.StageName != TEST_DRIVE && opp.StageName == TEST_DRIVE) || (opp.StageName == HANDOVER && oldOpp != null  && oldOpp.StageName != HANDOVER) || (oldOpp != null && oldOpp.StageName != 'Handover & RDA' && opp.StageName == 'Handover & RDA') || (oldOpp == null && (opp.StageName == TEST_DRIVE || opp.StageName == HANDOVER || opp.StageName == 'Handover & RDA'))) 
                {
                    OppIds.add(opp.id);
                }
            }   
            if(OppIds.size() > 0)
            {
                //Call future method to create events
                if(system.isBatch() || system.isFuture())
                {
                    CreateOpportunityEvents(OppIds, loggedInUser.id);                
                }
                else
                { 
                    CreateOpptyEventsFuture(OppIds, loggedInUser.id);
                }
            }
            
        }
        catch(Exception e)
        {
            system.debug('Exception occurred - Method:CreateTestDriveHandOver--' + e);
        }
    }
    
    //CXPD-828
    @future
    public static void CreateOpptyEventsFuture(List<Id> OpportunityIds, Id usrId)
    {
        system.debug('---Executing Future Method---');
        CreateOpportunityEvents(OpportunityIds, usrId);
    }
    
    public static void CreateOpportunityEvents(List<Id> OpportunityIds, Id usrId)
    {
        system.debug('---CreateOpportunityEvents--');
        List<Opportunity> opps = [Select id, name, stagename,AccountId,asset__c, ownerId from opportunity where id IN: OpportunityIds ];
        // User usr = [SELECT Id, Market__c, Country_ISO_Code__c FROM User WHERE Id = :usrId];
        User usr = getUserInformation(usrId);
        Id testDriveRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
        Id serviceAppointmentRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Service_Appointment').getRecordTypeId();
        Set<String> AccountIdsList = SObjectUtilities.GetFieldValues(opps, Opportunity.AccountId.getDescribe().getName());
        Map<Id, Account> accounts;
        List<Event> listOfEvent = new List<Event>();
        List<task> listOfTasks = new List<task>();
        Boolean tskCreate = false;
        
        if (!AccountIdsList.isEmpty()) {
            accounts = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN:AccountIdsList]);
        }
        try{
            for (Opportunity opp : opps) {
                Event evnt = new Event();
                task tsk = new task();
                evnt.DurationInMinutes = 0;
                if (opp.AccountId != null && accounts.get(opp.AccountId) != null && accounts.get(opp.AccountId).PersonContactId != null)
                    evnt.WhoId = accounts.get(opp.AccountId).PersonContactId;
                
                if (opp.StageName == 'Test Drive') {      
                    evnt.Subject = System.Label.Test_Drive;
                    evnt.WhatId = opp.Id; 
                    evnt.ActivityDateTime = System.today();
                    evnt.StartDateTime = System.today();
                    if (testDriveRecordTypeId != null) {
                        evnt.RecordTypeId = testDriveRecordTypeId;
                    }
                    
                }
                if (opp.StageName == 'Handover' || opp.StageName == 'Handover & RDA') {      
                    evnt.Subject = System.Label.Service_Appointment;
                    evnt.WhatId = opp.Asset__c;
                    evnt.Service_Type__c = '1st Service'; 
                    evnt.ActivityDateTime = System.today() + 365;
                    evnt.StartDateTime = System.today() + 365;
                    if (serviceAppointmentRecordTypeId != null) {
                        evnt.RecordTypeId = serviceAppointmentRecordTypeId;
                    }
                    //tskCreate = true;
                    
                }
                listOfEvent.add(evnt);            
                
                
                if ((opp.StageName == 'Handover & RDA' || opp.StageName == 'Handover') && (usr.Market__c != 'Australia' || usr.Market__c != 'MENA') && (usr.Country_ISO_Code__c != 'AU' || usr.Country_ISO_Code__c != 'NZ' ) ){     
                    system.debug('Create Tasks --' + opp.StageName + '--' + usr.Market__c + '--' + usr.Country_ISO_Code__c);
                    tsk.OwnerId = opp.ownerId;
                    tsk.whatId = opp.Id;
                    tsk.Subject = System.Label.X8_Week_Post_Handover_Call;
                    tsk.ActivityDate = system.today() + 56;
                    tsk.Status = 'Not Started';
                    tsk.Priority = 'Normal';
                    listOfTasks.add(tsk);
                    tsk = new task();
                    tsk.OwnerId = opp.ownerId;
                    tsk.whatId = opp.Id;
                    tsk.Subject = System.Label.Handover_Call;
                    tsk.ActivityDate = system.today() + 2;
                    tsk.Status = 'Not Started';
                    tsk.Priority = 'Normal';
                    listOfTasks.add(tsk);
                    
                }
                
            }
            if (listOfEvent.size() > 0) {
                system.debug('Events being inserted');
                insert listOfEvent;
            }
            if (listOfTasks.size() > 0) {
                system.debug('Tasks being inserted');
                insert listOfTasks;
            }
        }
        catch(Exception e)
        {
            system.debug('Exception while Event and Task Creation---' + e);
        }
    }    
    
    public void setHasVinFieldWhenisPresentInOppItem(List<Opportunity> currentOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
        
        List<OpportunityLineItem> oppItemsToupdate = new List<OpportunityLineItem>();
        Set<Id> OpportunityIds = new Set<Id>();
        for (Opportunity opp : currentOpportunities) {
            Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
            if ((opp.StageName == HANDOVER || opp.StageName == RDA) && (oldOpp.StageName != HANDOVER && oldOpp.StageName != RDA)) {
                OpportunityIds.add(opp.Id);
            }
        }
        
        if (OpportunityIds.isEmpty()) {
            return;
        }
        
        
        List<OpportunityLineItem> opportunityLineItems = [SELECT Id,OpportunityId,Has_VIN__c,Asset__c FROM OpportunityLineItem WHERE Opportunity.Id IN:OpportunityIds];
        for (OpportunityLineItem oli : opportunityLineItems) {
            if (oli.Asset__c != null) {
                oli.Has_VIN__c = 1;
                oppItemsToupdate.add(oli);
            }
        }
        
        if (!oppItemsToupdate.isEmpty()) {
            update oppItemsToupdate;
        }
    }
    
    
    /*private void SetCustomerJourneyStage(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        Set<Id> accountIdsForEnjoy = new Set<Id>();
        Set<Id> accountIdsForRenew = new Set<Id>();
        List<Opportunity> oppsForRenew = new List<Opportunity>();
        for (Opportunity opp : opps) {
            Opportunity oldOpp = oldOpps.get(opp.Id);
            if (opp.AccountId != null) {
                if (opp.Customer_Journey_Stage_Update__c == 'Enjoy' && oldOpp.Customer_Journey_Stage_Update__c != 'Enjoy') {
                    accountIdsForEnjoy.add(opp.AccountId);
                }
                if (opp.Customer_Journey_Stage_Update__c == 'Renew' && oldOpp.Customer_Journey_Stage_Update__c != 'Renew') {
                    accountIdsForRenew.add(opp.AccountId);
                    oppsForRenew.add(opp);
                }
            }
        }
        List<Account> accountsToUpdate = new List<Account>();
        if (accountIdsForEnjoy.isEmpty() && accountIdsForRenew.isEmpty()) {
            return;
        }
        List<Account> affectedAccounts = [SELECT Id, Customer_Journey_Stage__c FROM Account WHERE Id IN :accountIdsForEnjoy OR Id IN :accountIdsForRenew];
        //if Opportunity is 'Enjoy' and respective Account is 'Take the Keys', change Account to 'Enjoy'
        for (Account a : affectedAccounts) {
            if (accountIdsForEnjoy.contains(a.Id) && a.Customer_Journey_Stage__c == 'Take the Keys') {
                a.Customer_Journey_Stage__c = 'Enjoy';
                accountsToUpdate.add(a);
            }
        }
        //if Opportunity is 'Renew', determine if there is a Finance Contract for the Account
        Map<Id, Contract> financeContracts = new Map<Id, Contract>();
        for (Opportunity opp : oppsForRenew) {
            if (opp.AccountId != null) {
                financeContracts.put(opp.AccountId, null);
            }
        }
        if (!financeContracts.isEmpty()) {
            for (Contract c : [SELECT Id, AccountId, Asset__c FROM Contract WHERE AccountId IN :financeContracts.keySet()]) {
                for (Opportunity opp : oppsForRenew) {
                    if (opp.AccountId == c.AccountId && opp.Asset__c != null && opp.Asset__c == c.Asset__c) {
                        financeContracts.put(c.AccountId, c);
                    }
                }
            }
            for (Account a : affectedAccounts) {
                if (accountIdsForRenew.contains(a.Id)) {
                    if (!financeContracts.containsKey(a.Id) || financeContracts.get(a.Id) == null) {
                        a.Customer_Journey_Stage__c = 'Renew';
                        accountsToUpdate.add(a);
                    }
                }
            }
        }
        if (accountsToUpdate != null && !accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }*/
    
    /*private void removeOrderNumberFromLineItemAndStampOnOpp(List<Opportunity> lostOpps) {
System.debug('removeOrderNumberFromLineItemAndStampOnOpp ' + lostOpps);
if (!lostOpps.isEmpty()) {
System.debug('lost opp not empty');
List<OpportunityLineItem> lineItemsRemove = new List<OpportunityLineItem>();
//create map OppId to oppLineItems
List<OpportunityLineItem> opportunityLineItems = [
SELECT Id, OpportunityId, Vista_Order_Number__c
FROM OpportunityLineItem
WHERE Vista_Order_Number__c != ''
AND Opportunity.Id IN:lostOpps
];
for (Opportunity opp : lostOpps) {
for (OpportunityLineItem item : opportunityLineItems) {
if (item.OpportunityId == opp.Id) {
opp.Vista_Order_Number__c = item.Vista_Order_Number__c;
item.Vista_Order_Number__c = '';
lineItemsRemove.add(item);
}
}


}
OpportunityProductTriggerHandler.skipLogic = true;
update lineItemsRemove;
OpportunityProductTriggerHandler.skipLogic = false;

}

}*/
    
    // Created "createTaskOnStageChangedOnPostUpdate" Method for creating task based on the Market 
    /*JP Not being used
private void createTaskOnStageChangedOnPostUpdate(List<Opportunity> newTriggerList, Map<Id, Opportunity> oldTriggerMap) {
if (taskCreation) return;
taskCreation = true;
Map<String, New_Task_Create_Conditions__mdt> taskMetadataMap = getTaskCreateConditions();
List<SObject> newActivityList = new List<SObject>();
for (Opportunity newOpportunity : newTriggerList) {
// String intialMapKey = loggedInUser.Country_ISO_Code__c;
String intialMapKey = loggedInUser.Country_ISO_Code__c + '-' + newOpportunity.StageName;
// system.debug('intialMapKey'+ intialMapKey+': mapKey'+mapKey);
System.debug('taskMetadataMap' + taskMetadataMap);
if (newOpportunity.StageName != oldTriggerMap.get(newOpportunity.Id).StageName &&
taskMetadataMap.get(intialMapKey) != null) {
System.debug('taskMetadataMap' + taskMetadataMap.get(intialMapKey));
Integer daysToAdd = taskMetadataMap.get(intialMapKey).Expected_Due_Date__c != null ? (Integer) taskMetadataMap.get(intialMapKey).Expected_Due_Date__c : 0;
if (taskMetadataMap.get(intialMapKey).Is_Event__c) {
newActivityList.add(new Event(WhatId = newOpportunity.Id, OwnerId = newOpportunity.OwnerId, //Type=taskMetadataMap.get(mapKey).Type__c,
Subject = taskMetadataMap.get(intialMapKey).Subject__c, StartDateTime = System.now(), EndDateTime = System.now().addMinutes(30),   //Status='Not Started',
RecordTypeId = eventRecordtypeId));
} else {
newActivityList.add(new Task(WhatId = newOpportunity.Id, OwnerId = newOpportunity.OwnerId, Type = taskMetadataMap.get(intialMapKey).Type__c,
Subject = taskMetadataMap.get(intialMapKey).Subject__c, Status = 'Not Started',
RecordTypeId = taskMetadataMap.get(intialMapKey).Is_Task_Mandatory__c ? taskMandatoryRecordtypeId : taskRecordtypeId,
Priority = taskMetadataMap.get(intialMapKey).Is_Priority_High__c ? 'High' : 'Normal',
ActivityDate = System.now().date().addDays(daysToAdd)));
}

}*/ /*else if(newOpportunity.StageName != oldTriggerMap.get(newOpportunity.Id).StageName &&
taskMetadataMap.get(mapKey) != null ){      
Integer daysToAdd = taskMetadataMap.get(mapKey).Expected_Due_Date__c != null ? (Integer)taskMetadataMap.get(mapKey).Expected_Due_Date__c : 0; 
if(taskMetadataMap.get(mapKey).Is_Event__c){
newActivityList.add(new Event(WhatId = newOpportunity.Id, OwnerId =newOpportunity.OwnerId, //Type=taskMetadataMap.get(mapKey).Type__c, 
Subject= taskMetadataMap.get(mapKey).Subject__c,StartDateTime = system.now(),EndDateTime= system.now().addminutes(30)   //Status='Not Started',
// RecordTypeId = taskMetadataMap.get(mapKey).Is_Task_Mandatory__c ? taskMandatoryRecordtypeId : taskRecordtypeId,
//Priority = taskMetadataMap.get(mapKey).Is_Priority_High__c ? 'High': 'Normal' , 
));
}else{ 
newActivityList.add(new Task(WhatId = newOpportunity.Id, OwnerId =newOpportunity.OwnerId, Type= taskMetadataMap.get(mapKey).Type__c, 
Subject= taskMetadataMap.get(mapKey).Subject__c,Status='Not Started',  
RecordTypeId = taskMetadataMap.get(mapKey).Is_Task_Mandatory__c ? taskMandatoryRecordtypeId : taskRecordtypeId,
Priority = taskMetadataMap.get(mapKey).Is_Priority_High__c ? 'High': 'Normal',
ActivityDate =system.now().date().addDays(daysToAdd))); 
}
} */
    /*   
}
System.debug('newActivityList' + newActivityList);


if (newActivityList.size() > 0) insert newActivityList;
System.debug('newActivityList' + newActivityList);

}

// Created "createTaskOnStageChangedOnPostInsert" Method for creating task based on the Market 

private void createTaskOnStageChangedOnPostInsert(List<Opportunity> newTriggerList) {

if (taskCreation) return;
taskCreation = true;
Map<String, New_Task_Create_Conditions__mdt> taskMetadataMap = getTaskCreateConditions();
List<SObject> newActivityList = new List<SObject>();
for (Opportunity newOpportunity : newTriggerList) {
String mapKey = loggedInUser.Country_ISO_Code__c + '-' + newOpportunity.StageName;
if (Trigger.isInsert && taskMetadataMap.get(mapKey) != null) {
Integer daysToAdd = taskMetadataMap.get(mapKey).Expected_Due_Date__c != null ? (Integer) taskMetadataMap.get(mapKey).Expected_Due_Date__c : 0;
if (taskMetadataMap.get(mapKey).Is_Event__c) {
newActivityList.add(new Event(WhatId = newOpportunity.Id, OwnerId = newOpportunity.OwnerId, //Type=taskMetadataMap.get(mapKey).Type__c,
Subject = taskMetadataMap.get(mapKey).Subject__c, StartDateTime = System.now(), EndDateTime = System.now().addMinutes(30),   //Status='Not Started',
RecordTypeId = eventRecordtypeId
));
} else {

newActivityList.add(new Task(WhatId = newOpportunity.Id, OwnerId = newOpportunity.OwnerId, Type = taskMetadataMap.get(mapKey).Type__c,
Subject = taskMetadataMap.get(mapKey).Subject__c, Status = 'Not Started',
RecordTypeId = taskMetadataMap.get(mapKey).Is_Task_Mandatory__c ? taskMandatoryRecordtypeId : taskRecordtypeId,
Priority = taskMetadataMap.get(mapKey).Is_Priority_High__c ? 'High' : 'Normal',
ActivityDate = System.now().date().addDays(daysToAdd)));
}

}

}
if (newActivityList.size() > 0) insert newActivityList;
}

// Created "taskValidationOnStageChangedPreUpdate" Method for validation for mandatory tasks for the new RDA process 
private void taskValidationOnStageChangedPreUpdate(List<Opportunity> newTriggerList, Map<Id, Opportunity> oldTriggerMap) {
if (taskvalidation) return;
taskvalidation = true;

Map<Id, Opportunity> newOpportunityMap = new Map<Id, Opportunity>([
SELECT Id, (
SELECT Id, WhatId, OwnerId,Subject, Type, Status
FROM Tasks
WHERE RecordTypeId = :taskMandatoryRecordtypeId
AND Status != 'completed'
)
FROM Opportunity
WHERE Id IN :newTriggerList
]);
for (Opportunity newOpportunity : newTriggerList) {

if (newOpportunity.StageName != oldTriggerMap.get(newOpportunity.Id).StageName && newOpportunityMap.get(newOpportunity.Id).Tasks != null &&
newOpportunityMap.get(newOpportunity.Id).Tasks.size() > 0) {
newOpportunity.addError('Please close Respective tasks');
}
}

}

// Created "getTaskCreateConditions" to retrive metadata records
private Map<String, New_Task_Create_Conditions__mdt> getTaskCreateConditions() {
Map<String, New_Task_Create_Conditions__mdt> taskMetadataMap = new Map<String, New_Task_Create_Conditions__mdt>();
for (New_Task_Create_Conditions__mdt singleTask : [
SELECT Label,DeveloperName, Is_Priority_High__c, Subject__c, New_Stage_Name__c, Old_Stage_Name__c, Type__c,
Expected_Due_Date__c,Is_Task_Mandatory__c,Is_Event__c
FROM New_Task_Create_Conditions__mdt
]) {
taskMetadataMap.put(singleTask.Label, singleTask);
}
return taskMetadataMap;

}
*/
    private void DefaultPurchaseTypeToNewVehicle(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            if (opp.Type == 'Product' && opp.Purchase_Type__c == null) {
                opp.Purchase_Type__c = 'New Vehicle';
            }
        }
    }
    
    private void DefaultCountryIsoCodeToAccount(List<Opportunity> opportunities) {
        
        Set<Id> accIdSet = new Set<Id> ();
        Map<Id, Account> accMap;// = new Map<Id,Account>();
        for (Opportunity opp : opportunities) {
            if (opp.Country_iso_code__c == null && opp.AccountId != null) {
                
                accIdSet.add(opp.AccountId);
                
            }
        }
        if(accIdSet != null && accIdSet.size() > 0){
            accMap = new Map<ID, Account>([SELECT Id, Country_Iso_code__c,Country_Iso_code__pc FROM Account where Id IN :accIdSet]);
            
        }
        if(accMap != null){
            for (Opportunity opp : opportunities) {
                if ((opp.Country_iso_code__c == null || opp.Country_iso_code__c == null) && opp.AccountId != null) {
                    Account acc = accMap.get( opp.AccountId);
                    if(acc != null){
                        if(acc.Country_iso_code__c != null && acc.Country_iso_code__c != ''){
                            opp.Country_ISO_Code__c= acc.Country_iso_code__c;
                        }
                        if(acc.Country_iso_code__pc != null && acc.Country_iso_code__pc != '' && opp.Country_ISO_Code__c == null){
                            opp.Country_ISO_Code__c = acc.Country_iso_code__pc;
                        }
                    }
                }
            }
        }    
    }
    
    public static void CXPOpps(List<Opportunity> oppsList, Map<Id, Opportunity> oldMap) {
        List<string> recIds = new List<string>();
        for(Opportunity rec : oppsList){
            if(rec.Country_ISO_Code__c == 'GE' && rec.stagename == 'Order Taken' && 
               (oldMap == null || oldMap != null && oldMap.get(rec.id).stagename != rec.stagename))
                recIds.add(rec.id);
        }
        System.debug('recIds::::'+recIds);
        If(!System.isFuture() && !system.isBatch())
            OpportunityHandler.CXPtoIncadea(recIds);
    }
    
    @future(callout=true)
    public static void CXPtoIncadea(List<String> recIds) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        BaseMulesoftConnector conn = new BaseMulesoftConnector('MulesoftIncadea');
        for(string rec : recIds){
            CXPtoIncadeaWrapper.inputWrapper requestPayload = new CXPtoIncadeaWrapper.inputWrapper(rec);
            String body = Json.serialize(requestPayload);
            System.debug(body);
            String response = conn.doCallout(HttpMethods.POST, body);
            If(response.containsAny(label.CDK_Lead_Success_Message ))
                oppsToUpdate.add(new Opportunity(id = rec, Sent_to_Incadea__c = True));
            else
                oppsToUpdate.add(new Opportunity(id = rec, Incadea_Integration_Error__c = response, Incadea_Error__c = true));
        }
        
        if(oppsToUpdate.size()>0)
            update oppsToUpdate;
    }
    
    //CXPD-2448 changes begin
    public static void RelatedAssetUpdate(List<Opportunity> oppList){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp: oppList){
            oppIds.add(opp.Id);
        }
        Map<Id, List<OpportunityLineItem>> oliMap = new Map<Id, List<OpportunityLineItem>>();
        Set<Id> assetIds = new Set<Id>();
        List<OpportunityLineItem> oliList = [SELECT Id, CreatedDate, Asset__c, Asset__r.AccountId, OpportunityId, 
                                             Opportunity.AccountId, Opportunity.StageName FROM OpportunityLineItem 
                                             WHERE OpportunityId =:oppIds and Asset__c!=NULL];
        for(OpportunityLineItem oli: oliList){
            if(oli.Asset__c!=NULL) assetIds.add(oli.Asset__c);
        }
        
        List<Asset> assetList = [SELECT Id, AccountId FROM Asset WHERE Id=:assetIds];
        Map<Id, Asset> assetMap = new Map<Id, Asset>(assetList);
        List<Asset> updateAssetList = new List<Asset>();
        System.debug('assetMap: '+assetMap);
        for(OpportunityLineItem oliNew: oliList){
            Asset updateAsset = assetMap.get(oliNew.Asset__c);
            if(updateAsset.AccountId!=oliNew.Opportunity.AccountId){
                updateAsset.AccountId = oliNew.Opportunity.AccountId;
                updateAssetList.add(updateAsset);
            }
        }
        System.debug('updateassetList --> '+updateAssetList);
        if(updateAssetList!=NULL) update updateAssetList;
    }
    //CXPD-2448 changes end
    
}