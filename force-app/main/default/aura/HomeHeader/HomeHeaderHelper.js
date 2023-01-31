({
    gotoView : function(urlString) {
        var urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({"url": urlString});
        if(urlString != null && urlString != '' && urlString != '#'){
    		urlEvent.fire();
        }
    }
})