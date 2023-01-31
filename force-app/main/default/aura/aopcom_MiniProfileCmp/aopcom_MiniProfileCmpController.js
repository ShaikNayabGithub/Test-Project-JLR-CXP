({
    doInit : function(component, event, helper) {
        var result;
        var arrayRes;
        
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
                    CommunityPath=CommunityPath.substring(1, name.length);
            	}
        	}  
       
			component.set("v.CommunityUrl",CommunityPath);
            
        
        var defaultPhoto = '/'+CommunityPath+'/resource/GraphicResources/imagen_monigote.jpg';
        var action = component.get("c.getPortraitURL");
        action.setCallback(this, function(action) {
            var state = action.getState();
            if (state === "SUCCESS") {
                result=action.getReturnValue();
                arrayRes=result.split('#');
            }else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if(arrayRes[0] == ''){
                component.set("v.urlPortrait", defaultPhoto);
            }else{
                component.set("v.urlPortrait", arrayRes[0]);
            }
     
            component.set("v.name", arrayRes[1]);
            component.set("v.lname", arrayRes[2]);
            component.set("v.country", arrayRes[3]);
            component.set("v.context",arrayRes[4]);
            });
            $A.enqueueAction(action); 
        }, 1000);
		
        
        /*setTimeout(function(){
            //debugger;
            var CommunityPath=document.getElementById("CommunityUrl").innerText;  
            
        //debugger;
        var defaultPhoto = '/'+CommunityPath+'/resource/GraphicResources/imagen_monigote.jpg';
        var action = component.get("c.getPortraitURL");
        action.setCallback(this, function(action) {
            var state = action.getState();
            if (state === "SUCCESS") {
                result=action.getReturnValue();
                arrayRes=result.split('#');
            }else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if(arrayRes[0] == ''){
                component.set("v.urlPortrait", defaultPhoto);
            }else{
                component.set("v.urlPortrait", arrayRes[0]);
            }
     
            component.set("v.name", arrayRes[1]);
            component.set("v.lname", arrayRes[2]);
            component.set("v.country", arrayRes[3]);
            component.set("v.context",arrayRes[4]);
        });
        $A.enqueueAction(action); 
        }, 1000);*/
        
    }
               
})