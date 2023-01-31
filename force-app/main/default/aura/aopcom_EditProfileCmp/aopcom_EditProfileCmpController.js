({
	doInit : function(component, event, helper) {

           /* setTimeout(function(){       
           var CommunityPath=document.getElementById("CommunityUrl").innerText;
            component.set("v.CommunityUrl",CommunityPath);            
            }, 2500);*/
        
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
        
        //Workaround in order to delete lightning base css styles
        var allLinks = document.getElementsByTagName('link');
        var badLink;        
                
        for (var i = 0; i < allLinks.length; i++) {
            thisLinkUrl=allLinks[i].href;
            var badName='/app.css';
            if (thisLinkUrl.substring( thisLinkUrl.length - badName.length, thisLinkUrl.length ) === badName) {
                badLink = allLinks[i];
                badLink.parentNode.removeChild(badLink);
                 }               
        }
        
               
        //init code        
            
        
        var result;
        var arrayRes;
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
            if(arrayRes.length >0){
            //component.set("v.urlPortrait"),arrayRes[0];
                     		 
                component.set("v.firstName", arrayRes[0]);           
                component.set("v.lastName", arrayRes[1]);          
                component.set("v.emailAddress", arrayRes[2]); 
                component.set("v.landlineNumber", arrayRes[3]);            
                component.set("v.mobileNumber", arrayRes[4]);                              
                component.set("v.street", arrayRes[5]);       
                component.set("v.town", arrayRes[6]);      
                component.set("v.state", arrayRes[7]);                  
                component.set("v.postcode", arrayRes[8]);
                component.set("v.contactId", arrayRes[9]);
                component.set("v.Context", arrayRes[11]);
          
                if(arrayRes[12] == 'null' || arrayRes[12] == ""){
                component.set("v.urlPortrait", defaultPhoto);
                } else{
                component.set("v.urlPortrait", arrayRes[12]);
                }               
                
			} 
         });
         $A.enqueueAction(action); 
  
    },
 
    
    sendImage : function(component,event,helper){
        event.stopPropagation();
        event.preventDefault();
        var files = document.getElementById('files').files[0];
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        console.log(files);
        helper.readFile(component, helper, files);
        document.getElementById("image").src = files;       
        },
        

    	sendInformation : function(component, event, helper) {
          //debugger;
            var firstname=component.find("firstName").get("v.value");		
    		var lastname=component.find("lastName").get("v.value");        
            var emailaddress=component.find("emailaddress").get("v.value");		
    		var landline=component.find("landlineNumber").get("v.value");
   			var mobilenumber=component.find("mobileNumber").get("v.value");
            var street=component.find("street").get("v.value");		
    		var town=component.find("town").get("v.value");
   			var state=component.find("state").get("v.value");
            var postcode=component.find("postcode").get("v.value");
            var portraitURL=document.getElementById("image").src;
    		var error = false;
        
       
        component.set("v.lname", false);
        component.set("v.eaddress", false);
        component.set("v.eaddress2", false);


        		if(lastname == null || lastname ==''){
            		error=true;   
            		component.set("v.lname", true);
        		}   

        		if(emailaddress == null || emailaddress ==''){
            		error=true;   
            		component.set("v.eaddress", true);
                }else {
                	   var patt =new RegExp(".+@.+\.[a-zA-Z]+");
                       var str= emailaddress;
                       var res= patt.test(str);
                           if (!res){
                           error=true;
                           component.set("v.eaddress2",true);
                           }
                }

    		if (!error) { var action2 = component.get("c.sendData");
    		
    		action2.setParams({   
                "firstnameIn" : firstname,
                "lastnameIn": lastname,          
                "emailaddressIn" : emailaddress,
                "landlineIn": landline,           
                "mobilenumberIn" : mobilenumber,
                "streetIn" : street,
                "townIn": town, 
                "stateIn" : state,  
                "postcodeIn" : postcode,
                "portraitURL" : portraitURL,
          
            });
			
                         
           action2.setCallback(this, function(action) {
                   });
                         
         		window.location.href=window.location.href
                   $A.enqueueAction(action2);
			 }
   			   
    }
    
})