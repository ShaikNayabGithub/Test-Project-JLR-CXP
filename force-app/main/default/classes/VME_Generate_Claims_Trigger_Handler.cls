/*--
||      Name : VME_Generate_Claims_Trigger_Handler.apxc
||      Created By: Sumit Kumar @Marlabs Private Limited
||      Purpose : This will have the logic of Channel Martrix Calculation and Sales Link , on top Claim generation
||      Created Date : 7/4/2019
||      Modified By:<Your Name>
||      Modified Date :<Date>
||      Reason :<Reason>
--*/
public class VME_Generate_Claims_Trigger_Handler {

    public VME_Generate_Claims_Trigger_Handler() {}
    public void onAfterUpdate(Map < Id, Asset > newMap, Map < Id, Asset > oldMap, List < Asset > newList, List < Asset > oldList) {
        /* Modified By : Sumit Kumar on 29th Nov 2019
                                Modified Reason : Updating retail Date in past for claim generation need to query the same L3
                                ** Note : Below hard coded for list index of 0 for getting one asset retail date and generate claim. 
                                                        Below code modification will not work for bulk upload.
                                                        If someone doing bulk upload then the batch size must to set to 1 for execution of this code seemlessly*/
        Date retailDatefromAsset = newList[0].VME_Retail_Date__c != null ? newList[0].VME_Retail_Date__c : System.today();
        System.debug('  your current context is ' + Trigger.isExecuting);
        Integer resultTrig = generationClaims(newMap, oldMap, newList, oldList, retailDatefromAsset, false);
    }
    //below method added 
    public void onBeforeUpdate(Map < Id, Asset > newMap, Map < Id, Asset > oldMap, List < Asset > newList, List < Asset > oldList) {
        //Instatiating Trigger Handler Service class
        VME_Generate_Claims_Trigger_Service generateClaimServiceInstance = new VME_Generate_Claims_Trigger_Service();
        generateClaimServiceInstance.checkSaleTypeCodeMatch(newMap, oldMap, newList, oldList, null, false);
    }
    //Added by Tamanna on 26.8.2019 to regenarate the claims
    public Integer regenerateClaims(Map < Id, Asset > newMap, Map < Id, Asset > oldMap, List < Asset > newList, List < Asset > oldList, Date retailDate) {
        System.debug('    ' + Trigger.isExecuting);
        return generationClaims(newMap, oldMap, newList, oldList, retailDate, false);
    }

    @TestVisible
    private Integer generationClaims(Map < Id, Asset > newAssetMap, Map < Id, Asset > oldAssetMap, List < Asset > newAssetList, List < Asset > oldAssetList, Date retailDate, Boolean activeSchemes) {

        //Master Map of Asset Id and Set of Scheme Id which is going to create Claims for it.
        Map < Id, List < VME_Schemes__c >> VIN_RelatedScheme_Final_Map = new Map < Id, List < VME_Schemes__c >> ();
        //map of Retail Scheme values to Scheme Id
        Map < String, Id > RetailBased_Scheme_Map = new Map < String, Id > ();
        //Map of Asset Id against Opportunity Customer Details
        Map < Id, OpportunityLineItem > Asset_OpportunityCustomer_Map = new Map < Id, OpportunityLineItem > ();
        //Map of Asset Id against Opportunity Customer Details
        Map < Id, Account > Asset_Retailer_Map = new Map < Id, Account > ();
        //Stroe map of asset against selected scheme id selected against Sales LINK
        Map < Id, Set < Id >> asset_Selected_Scheme_Set_Map = new Map < Id, Set < Id >> ();
        //Getting UserDetails
        User userDetails = new User();
        //Map of Date infor for Submitting claims
        Map < String, VME_CXP_Date_Info__mdt > dateInfoMap = new Map < String, VME_CXP_Date_Info__mdt > ();
        //Instatiating Trigger Handler Service class
        VME_Generate_Claims_Trigger_Service generateClaimServiceInstance = new VME_Generate_Claims_Trigger_Service();
        //Instatiating Trigger Handler Service class Wrapper
        VME_Generate_Claims_Trigger_Service.VME_GenerateClaim_Wrapper masterWrapper = new VME_Generate_Claims_Trigger_Service.VME_GenerateClaim_Wrapper();
        //Passing parameter and getting all claim list and others map[] to be inserted

        //If claims are already there then do the startGenerationProcess method check firstly-Tamanna
        masterWrapper = generateClaimServiceInstance.getMyClaimsGenerated(newAssetMap, oldAssetMap, newAssetList, oldAssetList, retailDate, activeSchemes);
        System.debug('masterWrapper ::' + masterWrapper);
        //List of Final Claims to be created against Asset
        List < VME_Claims__c > asset_Claims_List = new List < VME_Claims__c > ();
        Map < Id, Map < String, VME_Claims__c >> assetExistingClaimMap = new Map < Id, Map < String, VME_Claims__c >> ();
        Map < Id, Map < String, VME_Claims__c >> assetNewClaimMap = new Map < Id, Map < String, VME_Claims__c >> ();
        Map < Id, Set < String >> assetOldClaimMap = new Map < Id, Set < String >> ();
        List < VME_Claims__c > deletionClaimList = new List < VME_Claims__c > ();
        Map < String, VME_Claims__c > claimWithExIdMap = new Map < String, VME_Claims__c > ();
        Map < String, Integer > approvedStepCountMap = new Map < String, Integer > ();
        Set < Id > claimsIds = new Set < Id > ();
        Map < String, Approval.ProcessWorkItemRequest > claimWithProcessInstanceMap = new Map < String, Approval.ProcessWorkItemRequest > ();
        List < Approval.ProcessWorkItemRequest > pwiRequestList = new List < Approval.ProcessWorkItemRequest > ();
        Map < Id, Map < String, List < VME_Claims__c >>> claimStatusWithAsset = new Map < Id, Map < String, List < VME_Claims__c >>> ();

        //checking transaction status and wrppaer variable
        if (masterWrapper.statusOfTransaction == 'SUCCESS' && masterWrapper.errorMsgOfTransaction == '') {
            VIN_RelatedScheme_Final_Map = masterWrapper.VIN_RelatedScheme_Final_Wrap;
            RetailBased_Scheme_Map = masterWrapper.RetailBased_Scheme_Wrap;
            Asset_OpportunityCustomer_Map = masterWrapper.Asset_OpportunityCustomer_Wrap;
            Asset_Retailer_Map = masterWrapper.Asset_Retailer_Wrap;
            asset_Selected_Scheme_Set_Map = masterWrapper.asset_Selected_Scheme_Wrap;
            userDetails = [SELECT id, Name, Market__c, Country, Email, FirstName, LastName, IsActive, CurrencyIsoCode, DefaultCurrencyIsoCode, Country_ISO_Code__c, Profile.UserLicense.Name FROM User WHERE id =: UserInfo.getUserId()];
            for (VME_CXP_Date_Info__mdt sObj: [Select id, Label, Activity__c, Country__c, Days__c, Market__c, Type__c from VME_CXP_Date_Info__mdt]) {
                if (sObj.Market__c == userDetails.Market__c && sObj.Country__c == userDetails.Country_ISO_Code__c && sObj.Activity__c.containsIgnoreCase('submit')) {
                    dateInfoMap.put(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_' + sObj.Activity__c, sObj);
                }
            }
            //System.debug('dateInfoMap ::' + dateInfoMap);
            //Take all the claims against the VIN for comparison -Tamanna
            Map < Id, VME_Claims__c > previousClaimList = new Map < Id, VME_Claims__c > ([Select id, VME_VIN__c, VME_Maximum_Attempts__c,VME_Amount__c, VME_Status__c, VME_External_ID__c from VME_Claims__c where VME_VIN__c IN: newAssetMap.keySet()]);
            System.debug('previousClaimList' + previousClaimList);
            if (previousClaimList != null && previousClaimList.size() > 0) {
                //create the approval history tracking map
                Map < Id, ProcessDefinition > processDefinationMap = new Map < Id, ProcessDefinition > ([SELECT Id, Name, State, Type FROM ProcessDefinition WHERE Name LIKE 'VME_Claim_Level%'
                    AND Name LIKE '%_Approval_Process'
                ]);
                List < ProcessInstance > processInstancelist = [SELECT Id, ProcessDefinitionId, TargetObjectId, CreatedDate, Status, (SELECT Id, comments, StepStatus FROM StepsAndWorkitems where StepStatus =: 'Approved') FROM ProcessInstance where TargetObjectId IN: previousClaimList.keySet() AND Status = 'Pending'
                    AND ProcessDefinitionId IN: processDefinationMap.keySet() ORDER BY CreatedDate ASC
                ];
                if (processInstancelist != null && processInstancelist.size() > 0) {
                    for (ProcessInstance proInst: processInstancelist) {
                        Integer coountOfApproved = proInst.StepsAndWorkitems != null ? Integer.valueOf(proInst.StepsAndWorkitems.size()) : 0;
                        if (approvedStepCountMap.containsKey(previousClaimList.get(proInst.TargetObjectId).VME_External_ID__c)) {
                            Integer temp = approvedStepCountMap.get(previousClaimList.get(proInst.TargetObjectId).VME_External_ID__c);
                            approvedStepCountMap.put(previousClaimList.get(proInst.TargetObjectId).VME_External_ID__c, (temp + coountOfApproved));
                        } else {
                            approvedStepCountMap.put(previousClaimList.get(proInst.TargetObjectId).VME_External_ID__c, coountOfApproved);
                        }
                    }
                }
                for (VME_Claims__c existClaim: previousClaimList.values()) {
                    //get the id of  claim which submitted or resubmitted
                    if (existClaim.VME_Status__c == 'Submitted' || existClaim.VME_Status__c == 'Resubmitted') {
                        claimsIds.add(existClaim.Id);
                    }
                    //Map of claims with external Id as a key
                    claimWithExIdMap.put(existClaim.VME_External_ID__c, existClaim);
                    if (assetExistingClaimMap.containsKey(existClaim.VME_VIN__c)) {
                        Map < String, VME_Claims__c > tempMap = assetExistingClaimMap.get(existClaim.VME_VIN__c);
                        tempMap.put(existClaim.VME_External_ID__c, existClaim);
                        assetExistingClaimMap.put(existClaim.VME_VIN__c, tempMap);

                        //Making old claims Map with Asset Id
                    } else {
                        assetExistingClaimMap.put(existClaim.VME_VIN__c, new Map < String, VME_Claims__c > {
                            existClaim.VME_External_ID__c => existClaim
                        });

                    }

                }
                ProcessInstanceWorkitem[] piWorkItems;
                System.debug('claimsIds' + claimsIds);
                if (claimsIds != null && claimsIds.size() > 0)
                    piWorkItems = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN: claimsIds AND ProcessInstance.Status = 'Pending'];
                System.debug('piWorkItems' + piWorkItems);
                if (piWorkItems != null && piWorkItems.size() > 0) {
                    for (ProcessInstanceWorkitem wItem: piWorkItems) {
                        //Create Process Work Item Request to unlock the claim
                        Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                        pwiRequest.setAction('Removed');
                        pwiRequest.setWorkItemId(wItem.Id);
                        claimWithProcessInstanceMap.put(previousClaimList.get(wItem.ProcessInstance.TargetObjectId).VME_External_ID__c, pwiRequest);
                    }
                }
            }

        }

        if (masterWrapper.statusOfTransaction == 'MATCH ERROR' && masterWrapper.errorMsgOfTransaction != '') {
            System.debug('Inside Match Error');
            return 50000;
        }



        if (VIN_RelatedScheme_Final_Map != null && VIN_RelatedScheme_Final_Map.size() > 0) {
            System.debug('VIN_RelatedScheme_Final_Map.keySet()***' + VIN_RelatedScheme_Final_Map.keySet());
            for (Id assetObjId: VIN_RelatedScheme_Final_Map.keySet()) {
                Map < String, VME_Claims__c > newClaimMap = new Map < String, VME_Claims__c > ();
                List < VME_Claims__c > newClaimList = new List < VME_Claims__c > ();
                if (VIN_RelatedScheme_Final_Map.get(assetObjId) != null) {
                    for (VME_Schemes__c scheme: VIN_RelatedScheme_Final_Map.get(assetObjId)) {
                        VME_Claims__c tempClaim = new VME_Claims__c();
                        /*      Claim Details   */
                        tempClaim.VME_External_ID__c = scheme.Id + '_' + assetObjId; //unique external id // ""scheme sf id_vin sf id""
                        tempClaim.VME_Related_Scheme__c = scheme.Id; // Parent Scheme ID
                        tempClaim.L2_VME_Category__c = scheme.VME_Campaign__c; //Putting Related VME for Record Detail card
                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.containsKey(newAssetMap.get(assetObjId).AccountId + '_' + scheme.Id)) {
                            //putting retail based scheme id if any applicable
                            tempClaim.VME_Retailer_Based_Scheme__c = RetailBased_Scheme_Map.get(newAssetMap.get(assetObjId).AccountId + '_' + scheme.Id);
                        }
                        tempClaim.VME_VIN_Number__c = newAssetMap.get(assetObjId).VIN__c;
                        tempClaim.VME_VIN__c = assetObjId; //related Asset claim applied on
                        tempClaim.VME_Claim_Type__c = 'Retail'; // MVP all claims are retailer type
                        tempClaim.VME_Number_Of_Attachments__c = 0; // number of attachment while generate 0
                        tempClaim.VME_InActive__c = false;
                        //tempClaim.VME_Retailer_Contribution__c popuated from submit claims field.
                        tempClaim.CurrencyIsoCode = scheme.CurrencyIsoCode; // Claim Currency as per applied scheme currency
                        tempClaim.VME_Quarter__c = scheme.VME_Campaign__r.VME_Quarter__c; //Claims quarter will be related L2 VME Category quarter
                        tempClaim.VME_Status__c = 'Generated'; // initial status will be generated
                        tempClaim.VME_Country_ISO_Code__c = scheme.VME_Campaign__r.VME_Country_ISO_Code__c;
                        tempClaim.VME_Region_Market__c = scheme.VME_Campaign__r.VME_Market_Code__c;
                        //VME_Sales_Link_Selected_Schemes__c below populated customer section
                        /* Below logic for applied scheme selection on vin based */
                        if (asset_Selected_Scheme_Set_Map != null && asset_Selected_Scheme_Set_Map.containsKey(assetObjId) && asset_Selected_Scheme_Set_Map.get(assetObjId).contains(scheme.Id)) {
                            tempClaim.VME_Applied_Scheme__c = true;
                        }
                        /*     Finance Details         */
                        //VME_Claim_Submission_Date__c populated from when submitted for approval
                        //Last Date of submit claim 
                        if (dateInfoMap != null && dateInfoMap.containsKey(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Submit')) {
                            if (dateInfoMap.get(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Submit').Type__c == 'EOM') {
                                Date selectedDate = newAssetMap.get(assetObjId).VME_Retail_Date__c; //Give your date
                                Date firstDate = selectedDate.toStartOfMonth();
                                Date lastDate = firstDate.addDays(date.daysInMonth(selectedDate.year(), selectedDate.month()) - 1);
                                //System.debug(firstDate + ' **** ' + lastDate);
                                tempClaim.VME_Last_Date_of_Submissiom__c = lastDate.addDays(Integer.valueOf(dateInfoMap.get(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Submit').Days__c));
                            } else {
                                tempClaim.VME_Last_Date_of_Submissiom__c = newAssetMap.get(assetObjId).VME_Retail_Date__c.addDays(Integer.valueOf(dateInfoMap.get(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Submit').Days__c));
                            }
                        } else {
                            //this below line excexute when Date info custom setting will not have submit data by mistake
                            tempClaim.VME_Last_Date_of_Submissiom__c = newAssetMap.get(assetObjId).VME_Retail_Date__c.addDays(30);
                        }
                        //Last Date of re - submit claim 
                        if (dateInfoMap != null && dateInfoMap.containsKey(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Resubmit')) {
                            if (dateInfoMap.get(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Resubmit').Type__c == 'EOM') {
                                Date selectedDate = newAssetMap.get(assetObjId).VME_Retail_Date__c; //Give your date
                                Date firstDate = selectedDate.toStartOfMonth();
                                Date lastDate = firstDate.addDays(date.daysInMonth(selectedDate.year(), selectedDate.month()) - 1);
                                //System.debug(firstDate + ' **** ' + lastDate);
                                tempClaim.VME_Last_Resubmission_Date__c = lastDate.addDays(Integer.valueOf(dateInfoMap.get(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Resubmit').Days__c));
                            } else {
                                tempClaim.VME_Last_Resubmission_Date__c = newAssetMap.get(assetObjId).VME_Retail_Date__c.addDays(Integer.valueOf(dateInfoMap.get(userDetails.Market__c + '_' + userDetails.Country_ISO_Code__c + '_Resubmit').Days__c));
                            }
                        } else {
                            //this below line excexute when Date info custom setting will not have resubmit data by mistake
                            tempClaim.VME_Last_Resubmission_Date__c = newAssetMap.get(assetObjId).VME_Retail_Date__c.addDays(90);
                        }
                        //Below line to add Number of Rejection Resubmission Attampts // if label dosnot have any value then default 5
                        tempClaim.VME_Maximum_Attempts__c = System.Label.VME_Maximum_Attempts != null ? Integer.valueOf(System.Label.VME_Maximum_Attempts) : 5;
                        tempClaim.VME_Amount__c = scheme.VME_PU_Amount__c; //Claim Amount
                        tempClaim.VME_Approved_Amount__c = 0; //Approved Amount after approval
                        //VME_Claim_Approval_Date__c will be auto populated after approval
                        /*      Customer Details        */
                        if (Asset_OpportunityCustomer_Map != null && Asset_OpportunityCustomer_Map.containsKey(assetObjId) && Asset_OpportunityCustomer_Map.get(assetObjId).Opportunity.VME_Selected_Schemes__c != null) {
                            tempClaim.VME_Sales_Link_Selected_Schemes__c = Asset_OpportunityCustomer_Map.get(assetObjId).Opportunity.VME_Selected_Schemes__c; //selected schemes on opportunity
                        }
                        if (Asset_OpportunityCustomer_Map != null && Asset_OpportunityCustomer_Map.containsKey(assetObjId) && Asset_OpportunityCustomer_Map.get(assetObjId).Opportunity.AccountId != null) {
                            tempClaim.VME_Customer_Name__c = Asset_OpportunityCustomer_Map.get(assetObjId).Opportunity.AccountId; //VIN related 
                        }
                        tempClaim.VME_Retail_Date__c = newAssetMap.get(assetObjId).VME_Retail_Date__c;
                        tempClaim.VME_JLR_Invoice_Date__c = newAssetMap.get(assetObjId).VME_Retail_Date__c;
                        /*      Retailer Details                */
                        if (Asset_Retailer_Map != null && Asset_Retailer_Map.containsKey(newAssetMap.get(assetObjId).Retailer_Name__c)) {
                            tempClaim.VME_Retailer_Name__c = Asset_Retailer_Map.get(newAssetMap.get(assetObjId).Retailer_Name__c).Id;
                        }
                        tempClaim.VME_Sales_Executive__c = UserInfo.getUserId();
                        tempClaim.VME_Claim_Submitted_By__c = UserInfo.getUserEmail();
                        /*Retal Month Feedback format -- "Retail month" in retailer details -Change to May 19*/
                        Date rtDate = newAssetMap.get(assetObjId).VME_Retail_Date__c;
                        DateTime d = DateTime.newInstance(rtDate.year(), rtDate.month(), rtDate.day());
                        String monthName = d.format('MMM-YY'); // May'19
                        monthName = monthName.replace('-', '\'');
                        tempClaim.VME_Retail_Month__c = monthName;
                        //adding claims into insertion list
                        //Check the claim  status is  other then Approved or Settled then upsert the claims.
                        if (assetExistingClaimMap != null && !assetExistingClaimMap.isEmpty()) {
                            if (assetExistingClaimMap.containsKey(assetObjId)) {
                                if (assetExistingClaimMap.get(assetObjId).containsKey(tempClaim.VME_External_ID__c)) {
                                    if (assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Status__c != 'Approved' && assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Status__c != 'Settled') {
                                        if (assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Status__c == 'Submitted' || assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Status__c == 'Resubmitted') {
                                            System.debug('^%%%%' + approvedStepCountMap.get(tempClaim.VME_External_ID__c));
                                            if (approvedStepCountMap != null && !approvedStepCountMap.isEmpty() && approvedStepCountMap.containsKey(tempClaim.VME_External_ID__c) && approvedStepCountMap.get(tempClaim.VME_External_ID__c) >= 1) {
                                                //That means its approved by first level so no need to change anything
                                                System.debug('first level approval claim' + tempClaim.VME_External_ID__c);
                                            } else {
                                                //unlock the record and modify details with status as generated
                                                System.debug('Submitted and resubmiited' + tempClaim.VME_External_ID__c);
                                                if (claimWithProcessInstanceMap != null && !claimWithProcessInstanceMap.isEmpty() && claimWithProcessInstanceMap.containsKey(tempClaim.VME_External_ID__c) && assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Amount__c != tempClaim.VME_Amount__c) {
                                                    tempClaim.VME_Status__c = 'Generated';
                                                    pwiRequestList.add(claimWithProcessInstanceMap.get(tempClaim.VME_External_ID__c));
                                                    asset_Claims_List.add(tempClaim);
                                                    newClaimList.add(tempClaim);
                                                    System.debug('Unlocking list' + tempClaim.VME_External_ID__c);
                                                }

                                            }
                                        } else {
                                            if (assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Amount__c != tempClaim.VME_Amount__c) {
                                                System.debug('other claims' + tempClaim.VME_External_ID__c);
                                                tempClaim.VME_Status__c =assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Status__c;
                                                tempClaim.VME_Maximum_Attempts__c =assetExistingClaimMap.get(assetObjId).get(tempClaim.VME_External_ID__c).VME_Maximum_Attempts__c;
                                                newClaimList.add(tempClaim);
                                                asset_Claims_List.add(tempClaim);
                                            }
                                        }
                                    }
                                } else {
                                    newClaimList.add(tempClaim);
                                    asset_Claims_List.add(tempClaim);
                                }
                            } else {
                                newClaimList.add(tempClaim);
                                asset_Claims_List.add(tempClaim);
                            }
                        } else {
                            newClaimList.add(tempClaim);
                            asset_Claims_List.add(tempClaim);
                        }
                        newClaimMap.put(tempClaim.VME_External_ID__c, tempClaim);
                        assetNewClaimMap.put(assetObjId, newClaimMap);
                        claimStatusWithAsset.put(assetObjId, new Map < String, List < VME_Claims__c >> {
                            'TOTAL' => (newClaimMap).values(),
                            'INSERT' => newClaimList
                        });
                        //claimStatusWithAsset.put(assetObjId, new Map<String,List<VME_Claims__c >>{'INSERT'=>newClaimList});
                    }
                }
            }
        }
        // Create a savepoint while All the list is ready
        Savepoint sp = Database.setSavepoint();
        try {
            //Deletion logic for the old not existing claims
            System.debug('try block');
            Set < String > claimExtIdSet = new Set < String > ();
            System.debug('assetExistingClaimMap' + assetExistingClaimMap);
            if (assetExistingClaimMap != null && !assetExistingClaimMap.isEmpty()) {
                for (Id assetId: assetExistingClaimMap.keySet()) {
                    if (assetNewClaimMap != null && !assetNewClaimMap.isEmpty() && assetNewClaimMap.containsKey(assetId)) {
                        Set < String > tempSet = assetExistingClaimMap.get(assetId).keySet();
                        (tempSet).removeAll(assetNewClaimMap.get(assetId).keySet());
                        claimExtIdSet.addAll(tempSet);
                    } else {
                        System.debug('assetExistingClaimMap.get(assetId).keySet()' + assetExistingClaimMap.get(assetId).keySet());
                        claimExtIdSet.addAll(assetExistingClaimMap.get(assetId).keySet());
                    }
                }
            }
            System.debug('claimExtIdSet' + claimExtIdSet);
            if (claimExtIdSet != null && claimExtIdSet.size() > 0) {
                for (String claimExId: claimExtIdSet) {
                    if (claimWithExIdMap != null && !claimWithExIdMap.isEmpty() && claimWithExIdMap.containsKey(claimExId)) {
                        if (claimWithExIdMap.get(claimExId).VME_Status__c != 'Approved' && claimWithExIdMap.get(claimExId).VME_Status__c != 'Settled') {
                            if (claimWithExIdMap.get(claimExId).VME_Status__c == 'Submitted' || claimWithExIdMap.get(claimExId).VME_Status__c == 'Resubmitted') {
                                if (approvedStepCountMap != null && !approvedStepCountMap.isEmpty() && approvedStepCountMap.containsKey(claimExId) && approvedStepCountMap.get(claimExId) >= 1) { //That means its approved by first level so no need to change delete it 
                                } else {
                                    if (claimStatusWithAsset != null && claimStatusWithAsset.size() > 0 && claimStatusWithAsset.containsKey(claimWithExIdMap.get(claimExId).VME_VIN__c) && (claimStatusWithAsset.get(claimWithExIdMap.get(claimExId).VME_VIN__c).containsKey('DELETION'))) {
                                        List < VME_Claims__c > tempClaimsList = claimStatusWithAsset.get(claimWithExIdMap.get(claimExId).VME_VIN__c).get('DELETE');
                                        tempClaimsList.add(claimWithExIdMap.get(claimExId));
                                        claimStatusWithAsset.put(claimWithExIdMap.get(claimExId).VME_VIN__c, new Map < String, List < VME_Claims__c >> {
                                            'DELETE' => tempClaimsList
                                        });
                                    } else {
                                        claimStatusWithAsset.put(claimWithExIdMap.get(claimExId).VME_VIN__c, new Map < String, List < VME_Claims__c >> {
                                            'DELETE' => (new List < VME_Claims__c > {
                                                claimWithExIdMap.get(claimExId)
                                            })
                                        });
                                    }
                                    pwiRequestList.add(claimWithProcessInstanceMap.get(claimExId));
                                    deletionClaimList.add(claimWithExIdMap.get(claimExId));
                                }
                            } else {
                                if (claimStatusWithAsset != null && claimStatusWithAsset.size() > 0 && claimStatusWithAsset.containsKey(claimWithExIdMap.get(claimExId).VME_VIN__c) && (claimStatusWithAsset.get(claimWithExIdMap.get(claimExId).VME_VIN__c).containsKey('DELETION'))) {
                                    List < VME_Claims__c > tempClaimsList = claimStatusWithAsset.get(claimWithExIdMap.get(claimExId).VME_VIN__c).get('DELETE');
                                    tempClaimsList.add(claimWithExIdMap.get(claimExId));
                                    claimStatusWithAsset.put(claimWithExIdMap.get(claimExId).VME_VIN__c, new Map < String, List < VME_Claims__c >> {
                                        'DELETE' => tempClaimsList
                                    });
                                } else {
                                    claimStatusWithAsset.put(claimWithExIdMap.get(claimExId).VME_VIN__c, new Map < String, List < VME_Claims__c >> {
                                        'DELETE' => (new List < VME_Claims__c > {
                                            claimWithExIdMap.get(claimExId)
                                        })
                                    });
                                }
                                deletionClaimList.add(claimWithExIdMap.get(claimExId));
                            }
                        }
                    }
                }
            }
            //unlock the records from approval process
            System.debug('pwiRequestList' + pwiRequestList);
            List < Approval.ProcessResult > result = Approval.process(pwiRequestList, true);
            for (Approval.ProcessResult lr: result) {
                if (!lr.isSuccess()) {
                    return null;
                }
            }


            if (deletionClaimList != null && deletionClaimList.size() > 0) {
                delete deletionClaimList;
            }
            System.debug(asset_Claims_List.size() + 'List of New Claims :: ' + asset_Claims_List);
            Database.UpsertResult[] Claims_Insert_results;
            Set < id > insertedClaims = new Set < id > ();
            if (asset_Claims_List != null && asset_Claims_List.size() > 0) {
                Schema.SObjectField externalIdField = VME_Claims__c.Fields.VME_External_ID__c;
                Claims_Insert_results = Database.Upsert(asset_Claims_List, externalIdField, true);
                System.debug('Claims_Insert_results :: ' + Claims_Insert_results);

            }
            if (Claims_Insert_results != null && Claims_Insert_results.size() > 0) {

                for (Database.UpsertResult r: Claims_Insert_results) {
                    if (r.isSuccess()) {
                        insertedClaims.add(r.getId());
                    }
                }
            }
            System.debug('insertedClaims' + insertedClaims);
            if ((insertedClaims != null && insertedClaims.size() > 0) || (deletionClaimList != null && deletionClaimList.size() > 0)) {
                VME_Generate_Claim_SendEmail.sendMailtoRetailer(newAssetMap, claimStatusWithAsset, UserInfo.getUserEmail());
                Integer deletion = (deletionClaimList != null && deletionClaimList.size() > 0) ? deletionClaimList.size() : 0;
                Integer insertion = (insertedClaims != null && insertedClaims.size() > 0) ? insertedClaims.size() : 0;
                Integer updatedCount = deletion + insertion;
                return updatedCount;
            } else {
                if (assetExistingClaimMap != null && !assetExistingClaimMap.isEmpty()) {
                    return 500000;
                } else {
                    return 0;
                }
            }
        } catch (Exception e) {
            // Rollback to the previous null value
            Database.rollback(sp);
            System.debug('Claim Trigger Handler : Wohhooo !! You got a Exception in Line number ' + e.getLineNumber() + ' and surprisingly your error is ' + e.getMessage() + e.getCause());
            return null;
        }
    }

}