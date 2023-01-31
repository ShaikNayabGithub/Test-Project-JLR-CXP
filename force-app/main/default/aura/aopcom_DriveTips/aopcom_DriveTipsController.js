({
	doInit : function(component, event, helper) {
		setTimeout(function(){
            var AWSPath=document.getElementById("AWSUrl").innerText;
       		 component.set("v.AWSUrl",AWSPath);
            }, 1000);
	}
})