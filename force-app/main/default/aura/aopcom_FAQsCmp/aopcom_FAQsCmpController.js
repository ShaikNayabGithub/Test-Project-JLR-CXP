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
        //Obtener total de elementos
        var total = 0;
        for (var i=1;i<=25;i++){
            if(component.get("v.titleQuestion" + i) != ''){
                total++;
            }else{
                break;
            }
        }
        
      component.set("v.pages",Math.ceil(total/5));       
 	  component.set("v.AWSUrl",AWSUrl);   
      
    },
    
    pageChange: function(component, event, helper) {
        
        var page = component.get("v.page");
        var pages = component.get("v.pages");
        var direction = event.getParam("direction");
        page = direction === "previous" ? (page - 1) : (page + 1);
        component.set("v.page",page);   
        if(pages == page){
            component.set("v.final",true);
        }else{
            component.set("v.final",false);
        }
        if(page == 1){
            component.set("v.inicio",true);
        }  else{
            component.set("v.inicio",false);
        }         
        
	},
    
    previousPage : function(component, event, helper) {        
        var myEvent = $A.get("e.c:EventPaginator");
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire(); 
        
	},
    
	nextPage : function(component, event, helper) {
        var myEvent = $A.get("e.c:EventPaginator");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire();   
        
        


	}
})