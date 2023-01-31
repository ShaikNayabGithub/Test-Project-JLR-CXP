({
	doInit : function(component, event, helper) {
		//debugger;
        /*setTimeout(function(){
        //debugger;
            var AWSPath=document.getElementById("AWSUrl").innerText;
       		 component.set("v.AWSUrl",AWSPath);
            }, 2500);
        setTimeout(function(){
        //debugger;
            var CommunityPath=document.getElementById("CommunityUrl").innerText;
       		 component.set("v.CommunityUrl",CommunityPath);
            }, 2500);*/
        
        setTimeout(function(){
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
       		component.set("v.AWSUrl",AWSUrl);
        	component.set("v.CommunityUrl",CommunityPath);        	
        }, 2500);
            
            
        //debugger;
        for (var i=1; i<=3;i++){
            var Image=component.get("v.Image"+i+"URL");
            var Video=component.get("v.Video"+i+"URL");
            var ImageVideo=component.get("v.VideoImage"+i)
         
            if(Video!="" && Video!=null){
                component.set("v.panevideo"+i,true);
              
                if(ImageVideo== "" || ImageVideo==null || ImageVideo=='abc'){
                    
                     component.set("v.panevideoimage"+i,true);    
                }
            }else{
                component.set("v.paneimage"+i,true);
            }
        }
	}
})