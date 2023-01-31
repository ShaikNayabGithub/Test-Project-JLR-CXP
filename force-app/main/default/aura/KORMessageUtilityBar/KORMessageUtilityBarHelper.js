({
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: message,
            title : title,
            type : type,
        });
        toastEvent.fire();
    },
    getRecord : function(component, recordId) {
        this.showSpinner(component);
        var action = component.get("c.getRecord");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === "SUCCESS") {
                if (returnVal.PersonMobilePhone) {
                    component.set('v.record', returnVal);
                    component.set('v.toNumber', returnVal.PersonMobilePhone);
                } else {
                    this.showToast('주의', '휴대폰 번호가 존재하지 않습니다.', 'warning');
                }
            } else {
                this.showToast('실패', '고객 정보를 불러올 수 없습니다.', 'error');
            }
            this.hideSpinner(component);
            
        });
        $A.enqueueAction(action);

    },
    resetInput : function(component) {
        component.set('v.toNumber', '');
        component.set('v.content', '');
        component.set('v.record', '');
    },
    minimizeUtility : function(component) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },
    showSpinner: function(component) {
        // make Spinner attribute true for displaying loading spinner 
        // component.set("v.spinner", true); 
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component){
        // make Spinner attribute to false for hiding loading spinner    
        // component.set("v.spinner", false);
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    openConfirm: function(component, helper, content, toNumber, recordId) {
        this.LightningConfirm.open({
            message: '확인 버튼을 누르면 문자가 발송되며, 발송된 문자는 취소할 수 없습니다.',
            theme: 'warning',
            label: '주의',
        }).then(function(result) {
            if (result) helper.sendMessage(component, content, toNumber, recordId);
            // if (result) this.showSpinner(component);
        });
    },
    sendMessage: function(component, content, toNumber, recordId) {
        this.showSpinner(component);
        var action = component.get("c.sendSMSbyId");
        action.setParams({
            "recordId": recordId,
            "toNumber": toNumber,
            "content": content
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var utilityAPI = component.find("utilitybar");
            if (state === "SUCCESS") {
                utilityAPI.minimizeUtility();
                this.showToast('성공', '메시지 발송을 성공하였습니다.', 'success');
            } else {
                var errors = response.getError();
                var errorMessage = errors[0].message;
                this.showToast('실패', errorMessage, 'error');
            }
            this.hideSpinner(component);
            this.resetInput(component);
            this.minimizeUtility(component);
        });
        $A.enqueueAction(action);
    }


})