/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin 		05/08/2021			CXPD-1434: Prevent submit when Add Corporate SP
*											is selected and Corporate Account SP is not selected
* 
*/
({
    searchHandler : function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }

            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchRecords(component, searchString);
            }), 1000);
            component.set("v.inputSearchFunction", inputTimer);
        } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
        console.log('searchString --> '+searchString);
        var updateEvent = component.getEvent("updateExpense");
        updateEvent.setParams({ "serviceplanid": "" });
        updateEvent.setParams({ "offerId": "" });
        updateEvent.setParams({ "corpId": "" });
        updateEvent.setParams({ "corpName": "" });
        updateEvent.fire();
        
    },
     closeModal:function(component,event,helper){    
        component.set("v.showModal",false);    
       
    },
       optionClickHandlerConfirmed:function(component,event,helper){    
        component.set("v.showModal",false); 
            const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
           var offerMap = component.get("v.offerMap");
           console.log('selectedId'+selectedId);
           console.log('selectedId'+ offerMap[selectedId]);
        var updateEvent = component.getEvent("updateExpense");
        updateEvent.setParams({ "serviceplanid": selectedId });
        updateEvent.setParams({ "offerId": offerMap[selectedId] });
        updateEvent.setParams({ "corpName": selectedValue});
        updateEvent.fire();
       
    },

    optionClickHandler : function (component, event, helper) {
        //here
      //  component.set("v.showModal", true);
        //
         
      
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
         const serviceselectedValue = event.target.closest('li').dataset.service;
        component.set("v.inputValue", selectedValue);
        console.log('inputValue  '+ component.get("v.inputValue"));
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
           var offerMap = component.get("v.offerMap");
        var offerId = '';
        var serviceID = '';
        var corpId = '';
        offerMap.forEach(element => {
            if(element.key == selectedId){
             offerId = element.value;
            serviceID = element.service;
            corpId = element.key;
        }
        });
        console.log(offerId);
        var updateEvent = component.getEvent("updateExpense");
        updateEvent.setParams({ "serviceplanid": serviceID });
        updateEvent.setParams({ "offerId":offerId });
        updateEvent.setParams({ "corpId":corpId });
        updateEvent.setParams({ "corpName":component.get("v.inputValue") });
        updateEvent.fire();
           
        
        
    },

    clearOption : function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
        console.log('clearOption --> ');
        //1.0
        var updateEvent = component.getEvent("updateExpense");
        updateEvent.setParams({ "serviceplanid": "" });
        updateEvent.setParams({ "offerId": "" });
        updateEvent.setParams({ "corpId": "" });
        updateEvent.setParams({ "corpName": "" });
        updateEvent.fire();
    },
})