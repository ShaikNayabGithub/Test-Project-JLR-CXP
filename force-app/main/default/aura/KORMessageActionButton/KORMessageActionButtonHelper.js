({
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'pester',
            message: message,
            title : title,
            type : type,
            duration : 3000
        });
        toastEvent.fire();
    },
    showSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component){
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
        });
    },
    sendMessage: function (component, content, toNumber, recordId) {
        this.showSpinner(component);
        var action = component.get("c.sendSMSbyId");
        action.setParams({
            "recordId": recordId,
            "toNumber": toNumber,
            "content": content
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('성공', '메시지 발송을 성공하였습니다.', 'success');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                this.showToast('실패', '메시지 발송에 실패하였습니다.', 'error');
                var errors = response.getError();
                
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    }
});