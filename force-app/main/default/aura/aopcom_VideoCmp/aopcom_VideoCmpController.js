({
	doInit : function(component, event, helper) {
        
        var name='communityPath';
        var name2='AWSUrl';
        var CommunityPath='';
        var AWSUrl='';        
        var partURL = document.URL.split('/');

        
        if(partURL[partURL.length-1]=='book-event'){            
        	setTimeout(function() {
                
        		var ca = document.cookie.split(';');
        
        		for(var i = 0; i < ca.length; i++) 
        		{
        			var c = ca[i];
            		while (c.charAt(0) == ' ') {
            			c = c.substring(1);
            		}
            		if (c.indexOf(name) == 0) {
            			CommunityPath= c.substring(name.length, c.length);
                		CommunityPath=CommunityPath.substring(1, c.length);
           			}
            		if (c.indexOf(name2) == 0){
            			AWSUrl= c.substring(name2.length, c.length);
                		AWSUrl=AWSUrl.substring(1, c.length);
            		}
        		}
        		component.set("v.CommunityUrl",CommunityPath);
 	   			component.set("v.AWSUrl",AWSUrl);      	
       		}, 2500);
        }else{
           
        	var ca = document.cookie.split(';');
        
        	for(var i = 0; i < ca.length; i++) 
        	{
        		var c = ca[i];
            	while (c.charAt(0) == ' ') {
            		c = c.substring(1);
            	}
            	if (c.indexOf(name) == 0) {
            		CommunityPath= c.substring(name.length, c.length);
                	CommunityPath=CommunityPath.substring(1, c.length);
           		}
            	if (c.indexOf(name2) == 0){
            		AWSUrl= c.substring(name2.length, c.length);
                	AWSUrl=AWSUrl.substring(1, c.length);
            	}
        	}
        	component.set("v.CommunityUrl",CommunityPath);
 	   		component.set("v.AWSUrl",AWSUrl);
        }
     
		
        var photo = component.get("v.ImageURL");       
        if(photo== "" || photo==null || photo=='abc'){   
            component.set("v.paneImage",true);            
        }
   
        /*setTimeout(function() {
        var name='communityPath';
        var name2='AWSUrl';
        var CommunityPath='';
        var AWSUrl='';
        var ca = document.cookie.split(';');
        
        for(var i = 0; i < ca.length; i++) 
        {
        	var c = ca[i];
            while (c.charAt(0) == ' ') {
            	c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
            	CommunityPath= c.substring(name.length, c.length);
                CommunityPath=CommunityPath.substring(1, c.length);
           	}
            if (c.indexOf(name2) == 0){
            	AWSUrl= c.substring(name2.length, c.length);
                AWSUrl=AWSUrl.substring(1, c.length);
            }
        }
        component.set("v.CommunityUrl",CommunityPath);
 	   	component.set("v.AWSUrl",AWSUrl);      	
       }, 1200);*/
        
       
        

	}
})