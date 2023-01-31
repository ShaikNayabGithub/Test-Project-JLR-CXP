({
    cancel : function (component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },
    sendMessage : function(component, event, helper) {
        
        var content = component.get("v.content");
        var toNumber = component.get("v.toNumber");
        var recordId = component.get("v.record") ? component.get("v.record").Id : '';
        var validity = component.find("messagebox").get("v.validity");
        // console.log(validity.valid); //returns true
        component.find("messagebox").reportValidity();
        if (!toNumber || !recordId) {
            helper.showToast('실패', '수신 번호가 없습니다.', 'error');
            helper.hideSpinner(component);
            return
        } else if (!content) {
            helper.showToast('실패', '메시지를 입력해 주세요.', 'error');
            helper.hideSpinner(component);
            return
        }  else if (content.length > 2000) {
            helper.showToast('실패', '메시지는 최대 2,000자를 넘을 수 없습니다.', 'error');
            helper.hideSpinner(component);
            return
        }
        helper.openConfirm(component, helper, content, toNumber, recordId);


    },
    changePhoneNumber : function(component, event, helper) {
        var newRecordId = component.get("v.recordId");
        helper.getRecord(component, newRecordId);
    }
    


    
});