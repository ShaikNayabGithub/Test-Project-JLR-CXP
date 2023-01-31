({
    doInit : function(component, event, helper) {
        var action = component.get("c.getcurrentRecordData"); 
        var recordId = component.get("v.recordId");
        var baseUrl = component.get("v.baseUrl");
        var notAvailableUrl = component.get("v.notAvailableUrl");
        console.log('recordId -->  '+recordId);
        console.log('baseUrl -->  '+baseUrl);
        action.setParams({
            "recordId" : recordId,
            "baseUrl" : baseUrl,
            "notAvailableUrl" : notAvailableUrl
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var resp = a.getReturnValue();
                console.log('Resp --> '+JSON.stringify(resp));
                if(resp 
                   && resp.hasError != null 
                   && !resp.hasError){
                    if(resp.VistaOSAExteriorWrapperList){
                        component.set("v.exteriorImageList",resp.VistaOSAExteriorWrapperList);
                    }
                    if(resp.VistaOSAInteriorWrapperList){
                        component.set("v.interiorImageList",resp.VistaOSAInteriorWrapperList);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})