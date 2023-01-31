({
	scheduleWBS : function(component, event, helper) {
		var action = component.get('c.callingBatch');
		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                if (response.getReturnValue().statusOfTransaction == 'COMPLETED') {
                	component.set("v.status",'COMPLETED');
	            }else if(response.getReturnValue().statusOfTransaction == 'FAIL'){
	            		component.set("v.status",'FAIL');
	            }else if(response.getReturnValue().statusOfTransaction == 'STARTED-PROCESSING'){
	            		component.set("v.status",'STARTED-PROCESSING');
	            }else if(response.getReturnValue().statusOfTransaction =='MARKET-UNAVAILABLE'){
	            		component.set("v.status",'MARKET-UNAVAILABLE');
	            }else if(response.getReturnValue().statusOfTransaction =='FAIL'){
	            		component.set("v.status",'ERROR');
	            }else if(response.getReturnValue().statusOfTransaction == 'INSUFFICIENT PRIVILEGES'){
	            		component.set("v.status",'INSUFFICIENT PRIVILEGES');
	            }else{
	            	component.set("v.status",'ERROR');
	            } 
	        }else{
	        	component.set("v.status",'ERROR');
	        }                  
	});
    $A.enqueueAction(action);
},
closeMe : function(component,event,helper){
	component.set("v.status",'CLOSE');
}
})