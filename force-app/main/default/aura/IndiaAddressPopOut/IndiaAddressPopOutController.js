({
	 openPopOut: function(component, event, helper) {
    
     //var domainlabel = $A.get("$Label.c.domain")
     
    var recordIdParam = component.get("v.recordId");
       var hostname = window.location.hostname; 
   var  windowObjectReference = window.open(
    "https://"+ hostname+"/apex/NTTPCL__Address_Lookup?id="+recordIdParam,
    "IndiaAddressLookupWindowName",
    "resizable,scrollbars,status"
  );
   }
})