({
    showResult : function(component, event, helper) {
        var selectedValue= component.get("v.selectedValue");
        if(selectedValue != ''){
            var totalList = component.get("v.totalList");
            var resultList = [];
            var x;
            for (x in totalList) {            
                if(totalList[x].toLowerCase().indexOf(selectedValue.toLowerCase()) > -1) resultList.push(totalList[x]);
            }
            component.set("v.resultList",resultList);
            component.set("v.showOptions",true);  
        }else{            
            component.set("v.showOptions",false); 
        }
    },
    SelectValue: function(component, event, helper) {
        component.set("v.selectedValue",event.currentTarget.getAttribute("value"));
        component.set("v.showOptions",false); 
        var PassSelectedValueEvent = $A.get("e.c:PassSelectedValue");
        PassSelectedValueEvent.setParams({"selectedValue": event.currentTarget.getAttribute("value")});
        PassSelectedValueEvent.fire(); 
    },
})