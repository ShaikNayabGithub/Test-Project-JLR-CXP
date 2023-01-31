public class VME_ClaimReversalCtrl {
    public static Asset assetDetails = new Asset();

    @AuraEnabled
    public static processDetails getAssetDetails(String assetId) {
        processDetails transDetails = new processDetails();
        boolean errorConfirm = false;
        try {
            assetDetails = [SELECT Id, Manufacture_Year__c,Name, VME_Retail_Date__c,VME_Market_Arrival_Date__c, toLabel(VME_TypeOfSale_Code_L2__c) VME_TypeOfSale_Code_L2, Sale_Type_Code__c, VME_TypeOfSale_Code_L2__c, Derivative__c, Model__c, Retailer_Name__c, AccountId, Derivative__r.VME_GST__c, VIN__c, VME_Channel_Type__c FROM Asset where Id =: assetId limit 1];
            Map < Id, Integer > approvedStepCountMap = new Map < Id, Integer > ();
            if (assetDetails.VME_Retail_Date__c == null) {
                transDetails.icon = 'utility:warning';
                transDetails.variantDetails = 'warning';
                transDetails.message = 'Please fill the Retail Date to generate the claims.';
                errorConfirm = true;
                transDetails.confirmation = false;
                return transDetails;
            }
            //check if opportunity is present or not for this VIN
            System.debug('assetId' + assetDetails.Id);
            List < OpportunityLineItem > lineItems = [SELECT Id, Asset__c, OpportunityId FROM OpportunityLineItem where Asset__c =: assetDetails.Id];
            if (lineItems==null || lineItems.isEmpty()) {
                transDetails.icon = 'utility:warning';
                transDetails.variantDetails = 'warning';
                transDetails.message = 'Please attach  VIN with an opportunity generate the claims.';
                errorConfirm = true;
                transDetails.confirmation = false;
                return transDetails;
            }

            if (assetDetails.Sale_Type_Code__c == null || assetDetails.VME_TypeOfSale_Code_L2__c == null || assetDetails.VME_Channel_Type__c == null) {
                transDetails.icon = 'utility:warning';
                transDetails.variantDetails = 'warning';
                transDetails.message = 'Please fill the Sale Type Code/Channel Type/Type of Sale Code - L2 to generate the claims.';
                errorConfirm = true;
                transDetails.confirmation = false;
                return transDetails;
            }
            Map < Id, VME_Claims__c > claimsMap = new Map < Id, VME_Claims__c > ([Select id, VME_Status__c, VME_Last_Date_of_Submissiom__c, VME_Last_Resubmission_Date__c from VME_Claims__c where VME_VIN__c =: assetId]);
            System.debug(claimsMap);
            if (claimsMap == null || claimsMap.isEmpty()) {
                transDetails.icon = 'utility:forward';
                transDetails.variantDetails = 'Continue';
                transDetails.message = 'CONFIRMATION';
                errorConfirm = false;
                transDetails.confirmation = true;
                transDetails.selectedAsset = assetDetails;
                return transDetails;
            }

            if (assetDetails.VME_Retail_Date__c != null && claimsMap != null && claimsMap.size() > 0 && !claimsMap.isEmpty()) {
               /*Map < Id, ProcessDefinition > processDefinationMap = new Map < Id, ProcessDefinition > ([SELECT Id, Name, State, Type FROM ProcessDefinition WHERE Name LIKE 'VME_Claim_Level%'
                    AND Name LIKE '%_Approval_Process'
                ]);
                List < ProcessInstance > processInstancelist = [SELECT Id, ProcessDefinitionId, TargetObjectId,CreatedDate, Status, (SELECT Id, comments, StepStatus FROM StepsAndWorkitems where StepStatus =: 'Approved') FROM ProcessInstance where TargetObjectId IN: claimsMap.keySet() AND Status = 'Pending'
                    AND ProcessDefinitionId IN: processDefinationMap.keySet() ORDER BY CreatedDate ASC
                ];
                if (processInstancelist != null && processInstancelist.size() > 0) {
                    for (ProcessInstance proInst: processInstancelist) {
                        Integer coountOfApproved = proInst.StepsAndWorkitems != null ? Integer.valueOf(proInst.StepsAndWorkitems.size()) : 0;
                        if (approvedStepCountMap.containsKey(proInst.TargetObjectId)) {
                            Integer temp = approvedStepCountMap.get(proInst.TargetObjectId);
                            approvedStepCountMap.put(proInst.TargetObjectId, (temp + coountOfApproved));
                        } else {
                            approvedStepCountMap.put(proInst.TargetObjectId, coountOfApproved);
                        }
                    }
                }*/
            
                //Map of TargetObjectId and Approved Instance

                for (VME_Claims__c vmeClaim: claimsMap.values()) {
                    //This needs to be delete after discussion with Rachit and sumit
                 /*   if (vmeClaim.VME_Status__c == 'Settled' || vmeClaim.VME_Status__c == 'Approved' || vmeClaim.VME_Status__c == 'Expired' || vmeClaim.VME_Status__c == 'Rejected -Non claimable') {
                        transDetails.icon = 'utility:error';
                        transDetails.variantDetails = 'error';
                        transDetails.message = 'Claims cannot be regenerated as one or more of existing claims has been ' + vmeClaim.VME_Status__c + '.';
                        errorConfirm = true;
                        break;
                    }*/

                    if ((vmeClaim.VME_Status__c == 'Generated' || vmeClaim.VME_Status__c == 'Submitted') && vmeClaim.VME_Last_Date_of_Submissiom__c != null && vmeClaim.VME_Last_Date_of_Submissiom__c < Date.Today()) {
                        transDetails.icon = 'utility:date_time';
                        transDetails.variantDetails = 'error';
                        transDetails.message = 'Claims  cannot be regenerated as claims last submission date has expired.';
                        errorConfirm = true;
                        break;
                    }
                    if ((vmeClaim.VME_Status__c == 'Recalled' || vmeClaim.VME_Status__c == 'Rejected' || vmeClaim.VME_Status__c == 'Resubmitted') && vmeClaim.VME_Last_Resubmission_Date__c != null && vmeClaim.VME_Last_Resubmission_Date__c < Date.Today()) {
                        transDetails.icon = 'utility:date_time';
                        transDetails.variantDetails = 'error';
                        transDetails.message = 'Claims  cannot be regenerated as claims last resubmission date has expired.';
                        errorConfirm = true;
                        break;
                    } //discussion
                  /*  if (vmeClaim.VME_Status__c == 'Submitted' || vmeClaim.VME_Status__c == 'Resubmitted') {
                        if (approvedStepCountMap != null && !approvedStepCountMap.isEmpty() && approvedStepCountMap.containsKey(vmeClaim.Id) && approvedStepCountMap.get(vmeClaim.Id) >= 1) {
                            transDetails.icon = 'utility:approval';
                            transDetails.variantDetails = 'success';
                            transDetails.message = 'Claims cannot be regenerated as one or more of existing claims is in approval process.';
                            errorConfirm = true;
                            break;
                        }
                    }*/
                }
            }
        }
        Catch(Exception e) {
            transDetails.icon = 'utility:close';
            transDetails.variantDetails = 'error';
            transDetails.message = e.getMessage();
            errorConfirm = true;
        }
        System.debug(errorConfirm);
        if (errorConfirm == true) {
            transDetails.confirmation = false;
        } else {
            transDetails.icon = 'utility:forward';
            transDetails.variantDetails = 'Continue';
            transDetails.message = 'CONFIRMATION';
            transDetails.confirmation = true;
            transDetails.selectedAsset = assetDetails;
        }
        return transDetails;
    }
   
 
    @AuraEnabled
    public static processDetails regenerateAllClaims(Asset assetObj) {
        return startGenerationProcess(assetObj);
    }

   public static processDetails startGenerationProcess(Asset assetObj) {
       Savepoint sp = Database.setSavepoint();
       
        List < Asset > newAssetList = new List < Asset > ();
        Map < Id, Asset > newAssetMap = new Map < Id, Asset > ();
        List < Asset > oldAssetList = new List < Asset > ();
        Map < Id, Asset > oldAssetMap = new Map < Id, Asset > ();
        processDetails resultedProcessDetails = new processDetails();
        
        Asset newAssetold = assetObj.clone(true, true, true, false);
        newAssetold.VME_Retail_Date__c = null;
        oldAssetList.add(newAssetold);
        oldAssetMap.put(newAssetold.Id, newAssetold);
        Asset newAsset = assetObj.clone(true, true, true, false);
        newAsset.VME_Retail_Date__c = assetObj.VME_Retail_Date__c;
        newAssetList.add(newAsset);
        newAssetMap.put(newAsset.Id, newAsset);

        VME_Generate_Claims_Trigger_Handler handler = new VME_Generate_Claims_Trigger_Handler();
        Integer result = handler.regenerateClaims(newAssetMap, oldAssetMap, newAssetList, oldAssetList, assetObj.VME_Retail_Date__c);
        if (result > 0 && result != 50000 && result != 500000) {
            resultedProcessDetails.icon = 'action:approval';
            resultedProcessDetails.variantDetails = 'success';
            resultedProcessDetails.message = 'Claims are regenerated successfully.';
            resultedProcessDetails.confirmation = false;
        } else if (result == 0) {
            resultedProcessDetails.icon = 'utility:warning';
            resultedProcessDetails.variantDetails = 'warning';
            resultedProcessDetails.message = 'Your selection doesn\'t  yielding any claim generation.Please change and try again.';
            resultedProcessDetails.confirmation = false;
        } else if (result == 50000) {
            resultedProcessDetails.icon = 'utility:warning';
            resultedProcessDetails.variantDetails = 'warning';
            resultedProcessDetails.message = 'Your selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset\'s Sale Type Code, Please try again.';
            resultedProcessDetails.confirmation = false;
        }else if (result == 500000) {
            resultedProcessDetails.icon = 'utility:warning';
            resultedProcessDetails.variantDetails = 'warning';
            resultedProcessDetails.message = 'There is no update required on the claims.';
            resultedProcessDetails.confirmation = false;
        } 
         else {
            Database.rollback(sp);
            resultedProcessDetails.icon = 'action:close';
            resultedProcessDetails.variantDetails = 'error';
            resultedProcessDetails.message = 'There is some error in the claim regeneration process.Please try again.';
            resultedProcessDetails.confirmation = false;
        }

        return resultedProcessDetails;
    
   
}

@AuraEnabled
public static String loggedInFormat() {
    return VME_Utility_Class.getUserDateTimeFormat();
}
public Class processDetails {
    @AuraEnabled public String icon;
    @AuraEnabled public String message;
    @AuraEnabled public String variantDetails;
    @AuraEnabled public boolean confirmation;
    @AuraEnabled public Asset selectedAsset;
}
}