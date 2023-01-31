({
	doInit : function(component, event, helper) {
		
        setTimeout(function(){
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
   		}, 2000);
        
        /*setTimeout(function(){
         
            var AWSPath=document.getElementById("AWSUrl").innerText;
       		 component.set("v.AWSUrl",AWSPath);
            }, 2000);*/
        
	}
})