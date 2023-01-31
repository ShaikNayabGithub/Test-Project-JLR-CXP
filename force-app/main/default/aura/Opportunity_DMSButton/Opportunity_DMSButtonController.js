/**
 * Created by lbrindle on 03/07/2018.
 */
({
        sendToDMS: function(component, event, helper) {
            // Create the action
            var oppId = component.get("v.recordId");
            if(oppId == null || oppId == ''){
                oppId = component.get("v.communityRecordId");
            }
            var action = component.get("c.SendToDMS");
            action.setParams({
                "opportunityId": oppId
            });

            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    //alert("From server: " + response.getReturnValue());
                    var dmsResponse = response.getReturnValue();

                    //component.set("v.expenses", response.getReturnValue());

                    if(dmsResponse.IsSuccess){
                        helper.toastThis(dmsResponse.SuccessMessage,'Ok','Success');
                    }else{
                        helper.toastThis(dmsResponse.ErrorMessage,'Not Ok','Error');
                    }

                }
                else {
                    console.log("Failed with state: " + state);
                    console.log(response);
                    helper.toastThis(state,'Error','Error');
                }
            });
            // Send action off to be executed
            $A.enqueueAction(action);
        }
    }

)