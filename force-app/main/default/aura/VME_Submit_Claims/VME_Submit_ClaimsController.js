({
    loadData: function(component, event, helper) {
        //get all the claims on page load
        helper.getAssets(component, event, helper);
    },
    get_Claims_Asset: function(component, event, helper) {
        
        component.set("v.isCalltogetClaims", true);
        helper.getAssets(component, event, helper);
        var assetRec = event.getSource().get("v.value");
        component.set('v.claimOfthisAsset', assetRec.VIN__c);
        helper.get_Claims_Of_Asset(component, event, helper, assetRec);
    },
    submit_Claim: function(component, event, helper) {
        
        helper.submit_Claims(component, event, helper);
    },
    submit_All_Claims: function(component, event, helper) {
        
        helper.claim_Submission(component,event,helper);
    },
    edit_Claim: function(component, event, helper) {
        
        helper.editClaim(component, event, helper);
    },
    cancelEditingClaim: function(component, event, helper) {
        
        helper.cancel_editing_claim(component, event, helper);
    },
    filterSearch: function(component, event, helper) {
        
        //Filter the claim record based on the VIN entered on search
        var vinNum = component.find("searchVIN").get("v.value");
        var retStart = component.find("retailStartDate").get("v.value");
        var retEnd = component.find("retailEndDate").get("v.value");
        var custName = component.find("custName").get("v.value");
        var custPhone = component.find("custPhone").get("v.value");
        var clmStatus = component.find("searchClaim").get("v.value");
        var regexp = /[0-9]{10}/;
        var regalpha = /[a-zA-Z]*/;
        console.log(retStart, retEnd);
        if ((vinNum == '' || vinNum == null) && (retStart == '' || retStart == null) && (retEnd == '' || retEnd == null) && (custName == '' || custName == null) && (custPhone == '' || custPhone == null) && (clmStatus == '' || clmStatus == null)) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Value Required!!",
                "message": "Please select at least one filter to get prefer results !!",
                "type": "error",
                "mode": "dimissible",
                "duration": '6000'
            });
            toastEvent.fire();
            helper.getAssets(component, event, helper);
        }else if(custPhone!="" && custPhone!= null && custPhone.length != 10){
            helper.raiseToast("Invalid Mobile Number", "You have to enter a 10-digit mobile number!", "error", "dimissible");
        }else if((custPhone!="" && custPhone!= null && custPhone!='') && !regexp.test(custPhone)){
                helper.raiseToast("Invalid Mobile Number", "You have entered a invalid mobile number!", "error", "dimissible");            
        }else if((retStart!="" && retStart!= null) && (retEnd== null || retEnd== "")){
            helper.raiseToast("Required Field", "End Date is mandetory!", "error", "dimissible");
        }else if((retEnd!="" && retEnd!= null )&&( retStart== null || retStart== "")){
            helper.raiseToast("Required Field", "Start Date is mandetory!", "error", "dimissible");
        }else if(retEnd < retStart){
            helper.raiseToast("Valid Date", "Start Date can't be greater than End Date!", "error", "dimissible");
        }else{
            helper.getAssets(component, event, helper);
            component.set('v.message', 'Enter VIN number');
            //var el = component.find("custPhone");
            //$A.util.removeClass(el, "slds-has-error"); // remove red border
            //$A.util.addClass(el, "hide-error-message");
        }
    },
    resetSearch: function(component, event, helper) {
        component.find('searchVIN').set("v.value", "");
        component.find('retailStartDate').set("v.value", "");
        component.find('retailEndDate').set("v.value", "");
        component.find('custName').set("v.value", "");
        component.find('custPhone').set("v.value",null);
        component.set("v.selectedCS", "");
        helper.getAssets(component, event, helper);
    },
    get_All_Assets: function(component, event, helper) {
        
        //upon cancelling the search get all the claims
        var allAsets = component.get("v.resultList");
        component.set("v.listOfAssets", allAsets);
        component.find('searchVIN').set("v.value", "");
        component.find('retailStartDate').set("v.value", "");
        component.find('retailEndDate').set("v.value", "");
    },
    close: function(component, event, helper) {
        
        //component.set("v.Spinner", false);
        helper.getAssets(component, event, helper);
        component.set("v.searchModal", false);
        component.set("v.blockSubmit", true);
        component.set('v.submitClaims', []);
    },
    closeDelete: function(component, event, helper) {
        
        component.set('v.isClaimDelete', false);
    },
    handleUploadFinished: function(component, event, helper) {
        
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var lbl = event.getSource().get('v.label');
        helper.successful_Upload(component, event, helper);
        var claimRec = component.get('v.uploadRecId');
        helper.updateClaims(component, event, helper, claimRec, lbl);
    },
    confirmDelete: function(component, event, helper) {
        
        component.set("v.claimtobedeleted", event.getSource().get("v.value"));
        component.set("v.isClaimDelete", true);
    },
    deleteClaim: function(component, event, helper) {
        
        helper.delete_Claim(component, event, helper);
    },
    countFiles: function(component, event, helper) {
        
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        //console.log(id_str);
        component.set('v.uploadRecId', id_str);
    },
    handleSectionToggle: function(cmp, event) {
        
        //Used to open and close the Accordian
        var openSections = event.getParam('openSections');
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    displayUploadedFiles: function(component, event, helper) {
        
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        //console.log(id_str);
    },
    onDoubleCLickDelete: function(component, event, helper) {
        
        var deleteDoc = event.getSource().get("v.alternativeText");
        component.set('v.fileToDelete', deleteDoc);
        component.set("v.isModalOpen", true);
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner
        component.set("v.Spinner", true);
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function(component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    closeMe: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    confirm: function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
        var deleteDoc = component.get('v.fileToDelete');
        helper.delDoc(component, event, helper, deleteDoc);
    },
    onChangeSelectedStatus: function(component, event, helper) {
        
        helper.get_Claims_With_Selected_Status(component,event,helper);
    },
    isSchemeEdit: function(component, event, helper){
        helper.isSchemeEditable(component,event,helper);
    },
    checkboxSelect: function(component, event, helper) {
        var isslected = event.getSource().get('v.checked');
        var selectedRec = event.getSource().get("v.value");
        var allclaimList = component.get("v.searchlistOfClaims");
        var isClaimForApproval=component.get("v.isClaimForApprovalList");
        if (allclaimList.length > 0) {
            for (var i = 0; i < allclaimList.length; i++) {
                //console.log(allclaimList[i].claims.Id);
                if (allclaimList[i].claims.Id == selectedRec) {
                    if (isslected == true) {
                        allclaimList[i].isselected = true;
                        //console.log('in2');
                        isClaimForApproval.push(allclaimList[i]);
                        //console.log(isClaimForApproval);
                    } else {
                        allclaimList[i].isselected = false;
                        isClaimForApproval.pop();
                    }
                }
                if(allclaimList[i].isEditable==false){
                    allclaimList[i].isselected = false;
                    helper.raiseToast("ERROR!!", "Please SAVE/CANCEL editing the claim", "error", "pester");
                    isClaimForApproval.pop();
                }
            }
        }
        component.set("v.isClaimForApprovalList",isClaimForApproval);
        var submit = component.get("v.isClaimForApprovalList");
        console.log(submit.length);
        if(submit.length==0||submit.length==undefined){
            component.set("v.blockSubmit",true); 
        }else{
            if(component.get("v.financeUser")==true){
                component.set("v.blockSubmit",false);
            }
        }
        component.set("v.searchlistOfClaims", allclaimList);
    },
    create_claim: function(component, event, helper) {
        var LOOKUP = 'LOOKUP';
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "VME_Claims__c",
            "navigationLocation": LOOKUP,
            "panelOnDestroyCallback": function() {
                helper.getAssets(component, event, helper);
            }
        });
        createRecordEvent.fire();
    },
    recallForApproval:function(component, event, helper){
        
        helper.recallClaim(component,event,helper);
    },
    onCapacityChange: function(component, event, helper) {
        
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = component.get("v.defaultRpp");
        var pageNumberCapacity = parseInt(selectedOptionValue);
        component.set("v.pageSize",pageNumberCapacity);
        component.set("v.currentPageNumber",1);
        helper.generateMasterPageDataList(component, event, helper);
    },
    onFirst: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.generateMasterPageDataList(component, event, helper);
    },
    onNext: function(component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.generateMasterPageDataList(component, event, helper);
    },
    onPrev: function(component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.generateMasterPageDataList(component, event, helper);
    },
    onLast: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.generateMasterPageDataList(component, event, helper);
    },
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.generateMasterPageDataList(component, event, helper);
    },
    openVIN : function(component, event, helper){
        helper.openVINdetail(component,event,helper);
    }
})