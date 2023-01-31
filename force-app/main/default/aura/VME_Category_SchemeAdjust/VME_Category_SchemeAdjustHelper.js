({
     getUserCurrency :function(component,event,helper){
           this.showSpinner(component,event,helper);
               var action =component.get("c.getUserDefaultCurrency");
                 action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                       this.hideSpinner(component,event,helper);
                    component.set("v.userCurrency",response.getReturnValue());
                }
                    });
            $A.enqueueAction(action);        
    },
	splitSchemeRecord : function(component, event, helper) {
	 var tempObj =component.get("v.tempVMESchemeObj");
          this.showSpinner(component,event,helper);
		  var action =component.get("c.saveSplitSchemeRecord");
            action.setParams({ schemeToSplit : component.get('v.VMESchemeObj'), 
            	currentScheme : tempObj

        });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                       this.hideSpinner(component,event,helper);
                    var result = response.getReturnValue();
                
                    if(result==null){
                        this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"),'L3 VME Campaign is not ended.Please Contact Administrator!','error','info_alt');
                    }else{
                    	this.showToast(component, event, helper,$A.get("{!$Label.c.VME_savedSuccessfully}"),$A.get("{!$Label.c.VME_recordSaved}"),'success','info_alt');
					
						 var cmpEvent = component.getEvent("adjustVariantEvt"); 
						cmpEvent.setParams({"openAdjustModel" : true,
					        "updateVMECampWrapperList" : result 
					     });
                          this.hideSpinner(component,event,helper);
						cmpEvent.fire(); 
						 component.set("v.isOpenSchemeComponent", false);

                }
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }

            });
            $A.enqueueAction(action);

	},
showToast : function(component, event, helper,titleVal,msg,typeVal,icon) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titleVal,
            message:msg,
            messageTemplate: msg,
            duration:' 5000',
            key: icon,
            type: typeVal,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
      showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }

})