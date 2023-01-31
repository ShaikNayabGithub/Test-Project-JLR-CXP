({
    getAssets: function(component, event, helper) {
        var vinNum = component.find("searchVIN").get("v.value");
        var retStart = component.find("retailStartDate").get("v.value");
        var retEnd = component.find("retailEndDate").get("v.value");
        var custName = component.find("custName").get("v.value");
        var custPhone = component.find("custPhone").get("v.value");
        var cusClaim = component.find("searchClaim").get("v.value"); 
        var action = component.get('c.get_Assets');
        action.setParams({
            startDate: retStart,
            endDate: retEnd,
            vin: vinNum,
            customerName: custName,
            customerPhone: custPhone,
            cusclaimStatus: cusClaim
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                if (response.getReturnValue().statusOfTransaction == 'SUCCESS' || response.getReturnValue().statusOfTransaction == 'NO-FILTER') {
                    component.set("v.resultList", response.getReturnValue().Asset_Wrapper_List);
                    component.set("v.listOfAssets", response.getReturnValue().Asset_Wrapper_List);
                    var assetList = response.getReturnValue().Asset_Wrapper_List;
                    console.log(response.getReturnValue().Asset_Wrapper_List);
                    for (var i = 0; i < assetList.length; i++) {
                        var eachAssetClaim = assetList[i].allClaims;
                        for (var j = 0; j < eachAssetClaim.length; j++) {
                            var eachEveList = eachAssetClaim[j].uploadEvidence;
                            var upList = [];
                            for (var k in eachEveList) {
                                upList.push({
                                    value: eachEveList[k],
                                    key: k
                                });
                            }
                            eachAssetClaim[j].uploadEvidence = upList;
                        }
                        assetList[i].allClaims = eachAssetClaim;
                    }
                    component.set("v.totalPages", Math.ceil(response.getReturnValue().Asset_Wrapper_List.length / component.get("v.pageSize")));
                    component.set("v.currentPageNumber",1);
                    this.generateMasterPageDataList(component,event,helper);
                    component.set("v.paginationList", response.getReturnValue());
                    component.set("v.blockSubmit",true);
                    component.set("v.isClaimForApprovalList",[]);
                    
                    //console.log(assetList);
                } else if (response.getReturnValue().statusOfTransaction == 'ERROR') {
                    console.log(response.getReturnValue().errorMsgOfTransaction);
                    this.raiseToast("Something went wrong!!", "Please contact your administrator for further assistance.", "error", "pester");
                } else if (response.getReturnValue().statusOfTransaction == 'NO-VIN') {
                    this.raiseToast("No Result Found !!", "Your filter does not yield results. Please refine your filter.", "warning", "pester");
                    component.set("v.resultList", response.getReturnValue().Asset_Wrapper_List);
                    component.set("v.listOfAssets", response.getReturnValue().Asset_Wrapper_List);
                    var assetList = response.getReturnValue().Asset_Wrapper_List;
                    for (var i = 0; i < assetList.length; i++) {
                        var eachAssetClaim = assetList[i].allClaims;
                        for (var j = 0; j < eachAssetClaim.length; j++) {
                            var eachEveList = eachAssetClaim[j].uploadEvidence;
                            var upList = [];
                            for (var k in eachEveList) {
                                upList.push({
                                    value: eachEveList[k],
                                    key: k
                                });
                            }
                            eachAssetClaim[j].uploadEvidence = upList;
                        }
                        assetList[i].allClaims = eachAssetClaim;
                    }
                    this.generateMasterPageDataList(component,event,helper);
                    component.set("v.paginationList", response.getReturnValue());
                    component.set("v.blockSubmit",true);
                    component.set("v.isClaimForApprovalList",[]);
                    //console.log(assetList);
                }
            }
        });
        $A.enqueueAction(action);
    },
    get_Claims_Of_Asset: function(component, event, helper, assetRec) {
        var assetList = component.get('v.MasterPageDataList');
        var displayClaims = [];
        for (var i = 0; i < assetList.length; i++) {
            var assetwithClaim = assetList[i];
            var assetrecord = assetList[i].asset;
            if (assetrecord.Id == assetRec.Id) {
                if (assetwithClaim.financeUser == true) {
                    component.set("v.blockSubmit", false);
                    component.set("v.financeUser",true);
                } else {
                    component.set("v.blockSubmit", true);
                    component.set("v.financeUser",false);
                }
                var claims = assetwithClaim.allClaims;
                for (var j = 0; j < claims.length; j++) {
                    if (claims[j].claims.VME_InActive__c == false) {
                        claims[j].bottonlabel = 'Edit';
                        claims[j].bottonvariant = 'brand';
                        displayClaims.push(claims[j]);
                    }
                    //console.log(displayClaims);
                }
            }
        }
        if (displayClaims.length > 0) {
            component.set('v.searchlistOfClaims', JSON.parse(JSON.stringify(displayClaims)));
            component.set("v.statusOfClaims", JSON.parse(JSON.stringify(displayClaims)));
            component.set('v.searchModal', true);
            console.log(component.get('v.searchlistOfClaims'));
        } else {
            this.raiseToast("Sorry", "There are no claims for the selected VIN", "error", "pester");
        }
        //component.find('select').set('v.value', 'Generated');
        component.find('select').set('v.value', 'All');
        var clmStatus = [];
        for (var i = 0; i < displayClaims.length; i++) {
            clmStatus.push(displayClaims[i].claims.VME_Status__c);
        }
        if(component.find('select').get('v.value')== 'All'){
            component.set("v.isNoClaims", false); 
        }else{
            if (clmStatus.includes('Generated')) {
                component.set("v.isNoClaims", false);
            } else {
                component.set("v.isNoClaims", true);
            }
        }
        
        
    },
    editClaim: function(component, event, helper) {
        var get_claim_to_Edit = JSON.parse(JSON.stringify(component.get("v.searchlistOfClaims")));
        var firstWrp = event.getSource().get('v.name');
        //console.log(firstWrp);
        if(firstWrp.isselected == true){
            this.raiseToast("ERROR", "Unable to Edit while selected for submission", "error", "pester");
            component.set("v.blockSubmit",true); 
            var isClaimForApproval=component.get("v.isClaimForApprovalList");
            for (var i = 0; i < get_claim_to_Edit.length; i++) {
                var claim = get_claim_to_Edit[i].claims;
                if (get_claim_to_Edit[i].claims.Id == firstWrp.claims.Id) {
                    get_claim_to_Edit[i].isselected = false;
                    isClaimForApproval.pop();
                }
            }
            component.set('v.searchlistOfClaims', get_claim_to_Edit);
            component.set("v.isClaimForApprovalList",isClaimForApproval);
        }else{
            if (event.getSource().get("v.label") == 'Edit') {
                var initialclaim = event.getSource().get('v.tabindex');
                component.set("v.ClaimAmount", initialclaim);
                event.getSource().set("v.label", 'Save');
                event.getSource().set("v.variant", "success");
                component.set("v.isEditingMode", true);
                var subComments = firstWrp.claims.VME_Submitter_Comments__c;
                var claimAmnt = firstWrp.claims.VME_Amount__c;
                var isSchemeAvailable = firstWrp.claims.VME_Applied_Scheme__c;
                component.set("v.initiallyclaimed",claimAmnt);
                component.set("v.initialComment", subComments);
                component.set("v.initialIsScheme", isSchemeAvailable);
                for (var i = 0; i < get_claim_to_Edit.length; i++) {
                    var claim = get_claim_to_Edit[i].claims;
                    if (get_claim_to_Edit[i].claims.Id == firstWrp.claims.Id) {
                        get_claim_to_Edit[i].isEditable = false;
                        get_claim_to_Edit[i].isUploadable = true;
                        get_claim_to_Edit[i].isDeletable = true;
                        get_claim_to_Edit[i].bottonlabel = 'Save';
                        get_claim_to_Edit[i].bottonvariant = 'success';
                    }
                }
                try {
                    component.set("v.searchlistOfClaims", get_claim_to_Edit);
                } catch (err) {
                    console.log(err.message);
                }
            } else {
                var claimId = event.getSource().get("v.value");
                var sc = firstWrp.submitterComments;
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                console.log(today);
                console.log(firstWrp.claims.VME_Applied_Scheme__c);
                console.log(firstWrp.claims.VME_Last_Date_of_Submissiom__c);
                if (firstWrp.claims.VME_Retailer_Contribution__c >= 0 && (firstWrp.claims.VME_Retailer_Contribution__c.length<18 || firstWrp.claims.VME_Retailer_Contribution__c>=0) && (firstWrp.claims.VME_Amount__c >=0 && firstWrp.claims.VME_Amount__c<=firstWrp.claims.VME_Related_Scheme__r.VME_PU_Amount__c && firstWrp.claims.VME_Amount__c !='')) {
                    if(firstWrp.claims.VME_Retailer_Contribution__c == ''){
                        firstWrp.claims.VME_Retailer_Contribution__c = 0;
                    }
                    console.log(firstWrp.claims.VME_Applied_Scheme__c);
                    var action = component.get('c.save_Edited_Claim');
                    firstWrp.isUploadable = false;
                    firstWrp.isDeletable = false;
                    action.setParams({
                        editClaimId: claimId,
                        editClaimAmount: firstWrp.claims.VME_Retailer_Contribution__c,
                        subComments:firstWrp.claims.VME_Submitter_Comments__c,
                        editAmountClaimed:firstWrp.claims.VME_Amount__c,
                        editedScheme:firstWrp.claims.VME_Applied_Scheme__c
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            this.raiseToast("Success", "Update Successful", "success", "pester");
                            for (var i = 0; i < get_claim_to_Edit.length; i++) {
                                get_claim_to_Edit[i].isEditable = true;
                                get_claim_to_Edit[i].isDeletable = false;
                                get_claim_to_Edit[i].bottonlabel = 'Edit';
                                get_claim_to_Edit[i].bottonvariant = 'brand';
                                if (get_claim_to_Edit[i].claims.Id == firstWrp.claims.Id) {
                                    get_claim_to_Edit[i].submitterComments = firstWrp.claims.VME_Submitter_Comments__c;
                                }
                            }
                            component.set("v.isEditingMode", false);
                            component.set('v.searchlistOfClaims', get_claim_to_Edit);
                        } else {
                            this.raiseToast("Something went wrong!!", "An error occured during updating record.", "error", "dismissable");
                            for (var i = 0; i < get_claim_to_Edit.length; i++) {
                                get_claim_to_Edit[i].isEditable = true;
                                get_claim_to_Edit[i].bottonlabel = 'Edit';
                                get_claim_to_Edit[i].bottonvariant = 'brand';
                                if (get_claim_to_Edit[i].claims.Id == firstWrp.claims.Id) {
                                    get_claim_to_Edit[i].submitterComments = firstWrp.claims.VME_Submitter_Comments__c;
                                    get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c = component.get("v.ClaimAmount");
                                    get_claim_to_Edit[i].claims.VME_Amount__c = component.get("v.initiallyclaimed");
                                }
                            }
                            component.set('v.searchlistOfClaims', get_claim_to_Edit);
                        }
                    });
                    $A.enqueueAction(action);
                }else if(firstWrp.claims.VME_Retailer_Contribution__c.length>=18){
                    this.raiseToast("ERROR!!", "Too long Non-Claimable amount", "error", "dismissable");
                }else if(firstWrp.claims.VME_Amount__c ==''){
                    this.raiseToast("ERROR!!", "Please enter Claimed Amount", "error", "dismissable");
                    firstWrp.isUploadable = false;
                    firstWrp.isDeletable = false;
                    for (var i = 0; i < get_claim_to_Edit.length; i++) {
                        get_claim_to_Edit[i].isEditable = true;
                        if (get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c == firstWrp.claims.VME_Retailer_Contribution__c) {
                            get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c = component.get("v.ClaimAmount");
                            get_claim_to_Edit[i].submitterComments = component.get("v.initialComment");
                            get_claim_to_Edit[i].claims.VME_Amount__c = component.get("v.initiallyclaimed");
                            get_claim_to_Edit[i].bottonlabel = 'Edit';
                            get_claim_to_Edit[i].bottonvariant = 'brand';
                        }
                    }
                }else if(firstWrp.claims.VME_Amount__c>firstWrp.claims.VME_Related_Scheme__r.VME_PU_Amount__c){
                    this.raiseToast("ERROR!!", "Claim Amount is more than scheme amount", "error", "dismissable");
                    firstWrp.isUploadable = false;
                    firstWrp.isDeletable = false;
                    for (var i = 0; i < get_claim_to_Edit.length; i++) {
                        get_claim_to_Edit[i].isEditable = true;
                        if (get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c == firstWrp.claims.VME_Retailer_Contribution__c) {
                            get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c = component.get("v.ClaimAmount");
                            get_claim_to_Edit[i].submitterComments = component.get("v.initialComment");
                            get_claim_to_Edit[i].claims.VME_Amount__c = component.get("v.initiallyclaimed");
                            get_claim_to_Edit[i].bottonlabel = 'Edit';
                            get_claim_to_Edit[i].bottonvariant = 'brand';
                        }
                    }
                    //component.set('v.searchlistOfClaims', get_claim_to_Edit);
                }else {
                    this.raiseToast("ERROR!!", "Enter valid Amount to be Claimed.", "error", "dismissable");
                    firstWrp.isUploadable = false;
                    firstWrp.isDeletable = false;
                    for (var i = 0; i < get_claim_to_Edit.length; i++) {
                        get_claim_to_Edit[i].isEditable = true;
                        if (get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c == firstWrp.claims.VME_Retailer_Contribution__c) {
                            get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c = component.get("v.ClaimAmount");
                            get_claim_to_Edit[i].submitterComments = component.get("v.initialComment");
                            get_claim_to_Edit[i].claims.VME_Amount__c = component.get("v.initiallyclaimed");
                            get_claim_to_Edit[i].bottonlabel = 'Edit';
                            get_claim_to_Edit[i].bottonvariant = 'brand';
                        }
                    }
                    component.set('v.searchlistOfClaims', get_claim_to_Edit);
                }
            }
        }
    },
    cancel_editing_claim: function(component, event, helper){
        var get_claim_to_Edit = JSON.parse(JSON.stringify(component.get('v.searchlistOfClaims')));
        var cancelId = event.getSource().get("v.value");
        for (var i = 0; i < get_claim_to_Edit.length; i++) {
            var clm = get_claim_to_Edit[i].claims;
            if (clm.Id == cancelId) {
                clm.VME_Retailer_Contribution__c = component.get("v.ClaimAmount");
                clm.VME_Applied_Scheme__c = component.get("v.initialIsScheme");
            }
            get_claim_to_Edit[i].isEditable = true;
            get_claim_to_Edit[i].isDeletable = false;
            get_claim_to_Edit[i].bottonlabel = 'Edit';
            get_claim_to_Edit[i].bottonvariant = 'brand';
            get_claim_to_Edit[i].claims.VME_Retailer_Contribution__c = component.get("v.ClaimAmount");
            get_claim_to_Edit[i].claims.VME_Submitter_Comments__c = component.get("v.initialComment");
            get_claim_to_Edit[i].claims.VME_Amount__c = component.get("v.initiallyclaimed");
        }
        component.set('v.searchlistOfClaims', get_claim_to_Edit);
        component.set("v.isEditingMode", false);
    },
    get_Claims_With_Selected_Status:function(component, event, helper){
        var clmStatus = [];
        component.set("v.searchlistOfClaims", component.get("v.searchlistOfClaims"));
        var listLen = component.get("v.searchlistOfClaims");
        var selectedst = component.get("v.selectedstatus");
        console.log(selectedst);
        for (var i = 0; i < listLen.length; i++) {
            clmStatus.push(listLen[i].claims.VME_Status__c);
        }
        if (clmStatus.includes(selectedst)) {
            component.set("v.isNoClaims", false);
        } else {
            component.set("v.isNoClaims", true);
        }         
    },
    submit_Claims: function(component, event, helper) {
        var check = event.getSource().get("v.checked");
        var ListtoSubmit = component.get('v.submitClaims');
        //console.log(ListtoSubmit);
        try {
            var id = event.getSource().get("v.value");
            //console.log(JSON.parse(JSON.stringify(id)));
        } catch (err) {
            console.log(err.message);
        }
        if (check == true) {
            component.set("v.blockSubmit", false);
            ListtoSubmit.push(id);
        } else {
            ListtoSubmit.splice(ListtoSubmit.indexOf(id), 1);
        }
        if (ListtoSubmit.length <= 0) {
            component.set("v.blockSubmit", true);
        }
        component.set('v.submitClaims', JSON.parse(JSON.stringify(ListtoSubmit)));
    },
    claim_Submission:function(component, event, helper){
        var allclaimList = component.get("v.searchlistOfClaims");
        var submitClaimLst = component.get("v.submitClaims");
        var claimComment = [];
        var documents=[];
        if (allclaimList.length > 0) {
            for (var i = 0; i < allclaimList.length; i++) {
                if (allclaimList[i].isselected == true && (allclaimList[i].claims.VME_Status__c == 'Generated' || allclaimList[i].claims.VME_Status__c == 'Rejected' ||  allclaimList[i].claims.VME_Status__c == 'Recalled')) {
                    claimComment.push(allclaimList[i].claims.Id);
                    documents.push(allclaimList[i].documents);
                }
            }
        }
        if($A.util.isEmpty(claimComment)){
            this.raiseToast("Warning", "Please select atleast one claim for submission", "warning", "dismissable"); 
        }else{
            var action = component.get('c.submitForApproval');
            action.setParams({
                claimCom: claimComment
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue().statusOfTransaction == 'SENTFORAPPROVAL') {
                        component.set("v.Spinner", false);
                        try {
                            for (var i = 0; i < allclaimList.length; i++) {
                                if (allclaimList[i].isselected == true) {
                                    if(allclaimList[i].claims.VME_Maximum_Attempts__c==5 && (allclaimList[i].claims.VME_Status__c=='Generated'||allclaimList[i].claims.VME_Status__c=='Recalled')){
                                        allclaimList[i].claims.VME_Status__c = 'Submitted';
                                    }else if(allclaimList[i].claims.VME_Maximum_Attempts__c<5 && (allclaimList[i].claims.VME_Status__c=='Rejected'||allclaimList[i].claims.VME_Status__c=='Recalled')){
                                        allclaimList[i].claims.VME_Status__c = 'Resubmitted';
                                    }
                                    allclaimList[i].documents=documents[i];
                                }
                            }
                            component.set('v.searchlistOfClaims', JSON.parse(JSON.stringify(allclaimList)));
                            component.set('v.statusOfClaims', JSON.parse(JSON.stringify(allclaimList)));
                            this.raiseToast("SUCCESS", "Claims Successfully submitted", "success", "dismissable");       
                            var submit = component.set("v.isClaimForApprovalList",[]);
                            component.set("v.blockSubmit",true); 
                            
                        }catch (err) {
                            console.log(err.message);
                        }
                        component.set("v.submitClaims", []);
                    }else{
                        this.raiseToast("Unable to Submit Claims!!", "You have crossed the Submission dates/Submission limit exceeded.", "error", "dismissable");       
                        console.log(response.getReturnValue().errorMsgOfTransaction);
                    }
                }else{
                    this.raiseToast("Something went wrong!!", "An error occured during submission for approval.Please contact administrator", "error", "dismissable");
                }
            });
            $A.enqueueAction(action);
        }
    },
    recallClaim: function(component, event, helper){
        var rec_To_Recall = event.getSource().get('v.value');
        var allclaimList = component.get("v.searchlistOfClaims");
        var documents=[];
        if (allclaimList.length > 0) {
            for (var i = 0; i < allclaimList.length; i++) {
                documents.push(allclaimList[i].documents);
            }
        }
        var action = component.get('c.recallOnSubmit');
        action.setParams({
            recordId: rec_To_Recall
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    for (var i = 0; i < allclaimList.length; i++) {
                        if (allclaimList[i].claims.Id == rec_To_Recall) {
                            allclaimList[i].documents=documents[i];
                            allclaimList[i].claims.VME_Status__c = 'Recalled';
                            allclaimList[i].isselected=false;
                        }
                    }
                    component.set('v.searchlistOfClaims', JSON.parse(JSON.stringify(allclaimList)));
                    component.set('v.statusOfClaims', JSON.parse(JSON.stringify(allclaimList)));
                    this.raiseToast("SUCCESS", "Claim Successfully recalled", "success", "dismissable");       
                    var submit = component.set("v.isClaimForApprovalList",[]);
                    component.set("v.blockSubmit",true); 
                    
                }catch (err) {
                    console.log(err.message);
                }
                component.set("v.submitClaims", []);
            }
        });
        $A.enqueueAction(action);
    },
    delete_Claim: function(component, event, helper) {
        //var delRec = event.getSource().get("v.value");
        var delRec = component.get("v.claimtobedeleted");
        //console.log('Rec to be deleted' + delRec);
        var assetList = component.get("v.resultList");
        var action = component.get('c.delete_Claim_Record');
        action.setParams({
            rec_To_Delete: delRec
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                this.raiseToast("Success", "Successfully deleted the record!", "success", "pester");
                component.set("v.isClaimDelete", false);
                var claimList = component.get("v.searchlistOfClaims");
                for (var i = 0; i < claimList.length; i++) {
                    var eachClaim = claimList[i].claims;
                    //console.log(eachClaim);
                    if (eachClaim.Id == delRec) {
                        //console.log(claimList);
                        try {
                            claimList.splice(i, 1);
                            eachClaim.VME_InActive__c = true;
                        } catch (err) {
                            //console.log(err.message);
                        }
                    }
                }
                //console.log(claimList);
                if (claimList.length > 0) {
                    component.set("v.searchlistOfClaims", claimList);
                } else {
                    this.raiseToast("Success", "Successfully deleted the record!", "success", "pester");
                    component.set("v.searchModal", false);
                }
            } else {
                this.raiseToast("Sorry", "Unable to delete!", "error", "dismissable");
            }
        });
        $A.enqueueAction(action);
    },
    successful_Upload: function(component, event, helper) {
        this.raiseToast("SUCCESS!", "Files Uploaded successfully.", "success", "pester");
    },
    isSchemeEditable: function(component, event, helper){
        var lastSubmission = event.getSource().get('v.name');
        var val = event.getSource().get('v.value');
        console.log(val);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        console.log(today);
        console.log(lastSubmission);
        if(val==true && today>lastSubmission){
            this.raiseToast("Sorry", "You have crossed the submission date", "error", "dismissable");
            event.getSource().set('v.value',false);
        }
    },
    updateClaims: function(component, event, helper, claimRec, lbl) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        if (lbl != 'Others') {
            this.renameUpload(component, event, helper, lbl, documentId);
        }
        var AssetClaimList = JSON.parse(JSON.stringify(component.get('v.searchlistOfClaims')));
        for (var i = 0; i < AssetClaimList.length; i++) {
            if (AssetClaimList[i].claims.Id == claimRec) {
                AssetClaimList[i].uploadCount = AssetClaimList[i].uploadCount + 1;
                var existingDocs = AssetClaimList[i].uploadEvidence;
                var fileNametrim = fileName.split('.').slice(0, -1).join('.');
                for (var k in existingDocs) {
                    if (existingDocs[k].key === lbl) {
                        existingDocs[k].value = documentId;
                        if (lbl != 'Others') {
                            existingDocs[k].key = lbl;
                        } else {
                            existingDocs[k].key = fileNametrim;
                            break;
                        }
                    }
                }
            }
        }
        component.set('v.searchlistOfClaims', AssetClaimList);
    },
    renameUpload: function(component, event, helper, fileName, DocumentIdValue) {
        var action = component.get('c.rename_Document');
        action.setParams({
            DocIdToUpdate: DocumentIdValue,
            newDocName: fileName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var AssetClaimList = JSON.parse(JSON.stringify(component.get('v.searchlistOfClaims')));
                for (var i = 0; i < AssetClaimList.length; i++) {
                    var existingDocs = AssetClaimList[i].uploadEvidence;
                    for (var k in existingDocs) {
                        if (existingDocs[k].value === DocumentIdValue) {
                            //console.log('insideee');
                            existingDocs[k].key = fileName;
                        }
                    }
                }
                component.set('v.searchlistOfClaims', AssetClaimList);
            } else {
                this.raiseToast("SORRY", "Something went wrong while Updating...", "error", "pester");
            }
        });
        $A.enqueueAction(action);
    },
    delDoc: function(component, event, helper, deleteDoc) {
        var action = component.get('c.delete_Document');
        action.setParams({
            DocumentIdValue: deleteDoc
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var AssetClaimList = JSON.parse(JSON.stringify(component.get('v.searchlistOfClaims')));
                for (var i = 0; i < AssetClaimList.length; i++) {
                    var existingDocs = AssetClaimList[i].uploadEvidence;
                    var documentsList = AssetClaimList[i].documents;
                    //console.log(existingDocs);
                    var documentsListTrimed = [];
                    for(var trm in documentsList){
                        var elementTrim = documentsList[trm].trim();
                        documentsListTrimed.push(elementTrim);
                    }
                    for (var k in existingDocs) {
                        if (existingDocs[k].value === deleteDoc) {
                            //console.log('insideee');
                            existingDocs[k].value = '';
                            //console.log(existingDocs[k].key);
                            
                            if(!documentsListTrimed.includes(existingDocs[k].key)){
                                existingDocs[k].key = 'Others';
                            }
                            
                            AssetClaimList[i].uploadCount = AssetClaimList[i].uploadCount - 1;
                        }
                    }
                }
                component.set('v.searchlistOfClaims', AssetClaimList);
            } else {
                this.raiseToast("SORRY! Unable to delete", "Something went wrong...", "error", "pester");
            }
        });
        
        $A.enqueueAction(action);
    },
    raiseToast: function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    generateMasterPageDataList: function(component, event, helper) {
        var masterPageData = [];
        var pageNumber = component.get("v.currentPageNumber"); //1
        var pageSize = component.get("v.pageSize"); //5
        var masterData = component.get("v.resultList");
        component.set("v.totalPages", Math.ceil(masterData.length / pageSize));
        var x = (pageNumber - 1) * pageSize; //1-1 *5 / 2-1*5 / 3-1*5
        //setting the first record cursor on current page
        component.set("v.RecordStart", x + 1);
        var endRecord = x;
        //creating data-table data
        for (; x < (pageNumber) * pageSize; x++) {
            if (masterData[x]) {
                endRecord++;
                masterPageData.push(masterData[x]);
            }
        }
        //setting the last record cursor on current page
        component.set("v.RecordEnd", endRecord);
        component.set("v.MasterPageDataList", masterPageData);
        this.generatePageNumberList(component, event, helper, pageNumber);
    },
    generatePageNumberList: function(component, event, helper, pageNumber) {
        var pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if (totalPages > 1) {
            if (totalPages <= 10) {
                var counter = 2;
                for (; counter < (totalPages); counter++) {
                    pageList.push(counter);
                }
            } else {
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > (totalPages - 5)) {
                        pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                    } else {
                        pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                    }
                }
            }
        }
        setTimeout(function(){
            helper.hideSpinner(component,event,helper);
        }, 500);
        
        component.set("v.pageList", pageList);
        component.set("v.showResults", true);
    },
})