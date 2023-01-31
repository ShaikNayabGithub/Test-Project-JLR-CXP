({
	doInit : function(component, event, helper) {
                
        var name='AWSUrl';        
        var AWSUrl='';
        var ca = document.cookie.split(';');
        
        for(var i = 0; i < ca.length; i++) 
        {
        	var c = ca[i];
          	while (c.charAt(0) == ' ') {
            	c = c.substring(1);
          	}                   
            if (c.indexOf(name) == 0){
            	AWSUrl= c.substring(name.length, c.length);
                AWSUrl=AWSUrl.substring(1, c.length);
            }
        }           
 	   	component.set("v.AWSUrl",AWSUrl);
        
        /*setTimeout(function(){
            var AWSPath=document.getElementById("AWSUrl").innerText;
       		 component.set("v.AWSUrl",AWSPath);
            }, 1000);*/
        //debugger;
        /*for (var i=1; i<=7;i++){
            var Image=component.get("v.Image"+i);
            var Title=component.get("v.Title"+i);
            var Description=component.get("v.Description"+i);
            if((Image!="" && Image!=null) || (Title!= "" && Title!=null) || (Description!="" && Description!=null))
                component.set("v.pane"+i,true);
        }*/
        
        var action = component.get("c.bringEventFeatures");
        action.setCallback(this, function(action) {
            if (action.getState() === "ERROR") {
                alert("Server Error: " + action.getError()[0].message);
            } else {
                
                ret = action.getReturnValue();
                if(ret != ""){
                    if(ret.indexOf("Smart Cone")>-1){
                        component.set("v.pane1",true);
                    }
                    if(ret.indexOf("Demonstration laps")>-1){
                        component.set("v.pane2",true);
                    }
                    if(ret.indexOf("Guided Laps")>-1){
                        component.set("v.pane3",true);
                    }
                    if(ret.indexOf("Dynamic driving activities")>-1){
                        component.set("v.pane4",true);
                    }
                    if(ret.indexOf("Spa")>-1){
                        component.set("v.pane5",true);
                    }
                    if(ret.indexOf("Golf")>-1){
                        component.set("v.pane6",true);
                    }
                    if(ret.indexOf("Road Drive")>-1){
                        component.set("v.pane7",true);
                    }
                    
                }  
        	}
        });
        $A.enqueueAction(action);
        
	}
})