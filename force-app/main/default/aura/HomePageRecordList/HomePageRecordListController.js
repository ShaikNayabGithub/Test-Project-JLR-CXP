({
    doInit: function(component, event, helper) {
        helper.getRecordshelper(component, event, helper);
        helper.getSalesManager(component, event, helper);
        helper.getSalesExecutive(component, event, helper);
        var labelName = component.get("v.labelName");
        if(labelName){
        var labelReference = $A.getReference("$Label.c." + labelName);
        component.set("v.tableName",labelReference);
        }
    },
    navigateToRecord: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ recordId: event.currentTarget.getAttribute("id") });
        navEvt.fire();
    },
    
    handleApplicationEvent: function(component, event, helper) {
        console.log("entered" + event.getParam("tabName"));
        component.set("v.tableName", event.getParam("tabName"));
        component.set("v.iconName", event.getParam("iconName"));
        //var message = event.getParam("message");
        /*	component.set("v.sObjectName", "Opportunity");
		component.set("v.ListViewName", "MyOpportunities");
        
        
        component.set("v.body" , []);
        $A.createComponent(
            "lightning:listView",
            {
                "objectApiName" : event.getParam("sObjectName"),
                "listName" : event.getParam("ListViewName"),
                "rows": 10,
                "showActionBar":false,
                "enableInlineEdit":true,
                "showRowLevelActions":"true"
            },
            function(newListView, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newListView);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
            }
        );*/
    },
    showModal: function(component, event, helper) {
        var x = component.get("v.NavigatetoNewOppPage");
        if (!x) {
            component.set("v.showModal", true);
        } else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ url: "/new-opportunity" }); // Pass your community URL
            urlEvent.fire();
        }
    },
    closeModal: function(component, event, helper) {
        component.set("v.showModal", false);
    },
    showSpinner: function(component, event, helper) {
        component.set("v.showSpinner", true);
    },
    hideSpinner: function(component, event, helper) {
        component.set("v.showSpinner", false);
    }
});