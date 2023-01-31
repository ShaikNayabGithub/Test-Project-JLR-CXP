({
	doInit : function(component, event, helper) {
		var result;
        var arrayRes = null;
        
        var action = component.get("c.getLocation");
        action.setCallback(this, function(action) {
            
            if (action.getState() === "ERROR") {
                alert("Server Error: " + action.getError()[0].message);
            } else {
                result = action.getReturnValue();  
            	if(result != null)
                	arrayRes=result.split('#');
                
            }
            if(arrayRes != null){
            	if(arrayRes[0] != null)
            		component.set("v.location", arrayRes[0]);
            	if(arrayRes[1] != null)
            		var arrayTime=arrayRes[1].split(" ");
            	if(arrayTime != null && arrayTime[1] != null)
            		var arrayDate=arrayTime[1].split(":");            
            	if(arrayTime != null && arrayTime[0] !=null)
            		component.set("v.date", arrayTime[0]);
            	if(arrayDate != null && arrayDate[0] != null && arrayDate[1] != null)
            		component.set("v.time", arrayDate[0]+":"+arrayDate[1]);
            }
        });
        $A.enqueueAction(action);
    
    	setTimeout(function(){
        var CommunityPath=document.getElementById("CommunityUrl").innerText;
        component.set("v.CommunityUrl",CommunityPath);  
        }, 2000);
        
        setTimeout(function(){
            var AWSPath=document.getElementById("AWSUrl").innerText;
       		 component.set("v.AWSUrl",AWSPath);                   
            }, 2000);
        }
})