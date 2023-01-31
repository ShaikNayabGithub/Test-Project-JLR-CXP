({
	doInit : function(component, event, helper) {
		
        /*setTimeout(function(){
            //debugger;
            var CommunityPath=document.getElementById("CommunityUrl").innerText;
       		 component.set("v.CommunityUrl",CommunityPath);
        }, 1000);*/
        
        setTimeout(function(){
        	
            var name='communityPath';
        	var CommunityPath='';
        	var ca = document.cookie.split(';');
    		for(var i = 0; i < ca.length; i++) {
        		var c = ca[i];
        		while (c.charAt(0) == ' ') {
            		c = c.substring(1);
                }
                if (c.indexOf(name) == 0) {
                    CommunityPath= c.substring(name.length, c.length);
                    CommunityPath=CommunityPath.substring(1, CommunityPath.length); //substring(1, name.length); EVERIS OLD 
            }
        }      
			component.set("v.CommunityUrl",CommunityPath);
        }, 1000);
        
        var result;
        var arrayRes = null;
        
        var serverAction = component.get("c.getLocation");
        serverAction.setCallback(this, function(action) {
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
                if(arrayRes[2] != null)                
            		component.set("v.googleMapsUrl", arrayRes[2]);
            }
        });
        $A.enqueueAction(serverAction);
	}
})