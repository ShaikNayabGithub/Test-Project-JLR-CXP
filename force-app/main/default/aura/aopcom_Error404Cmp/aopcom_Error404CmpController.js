({
	doInit : function(component, event, helper) {
		/*setTimeout(function(){
            //debugger;
            var CommunityPath=document.getElementById("CommunityUrl").innerText;
       		 component.set("v.CommunityUrl",CommunityPath);
		}, 1000);*/
        
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

	}
})