({
        afterScriptsLoadedCall : function(component, event, helper){
            //console.log('Simple browser zoom detect with jquery loading complete');
        },
        getFiltersData: function(component, event, helper){
                //console.log('Compoent Handler Called');
                helper.check_and_set_ResolutionHelper(component, event, helper);
                helper.check_and_set_ResolutionChanger(component, event, helper);
                //calling helper to get Filters Data
                helper.getFiltersDatahelper(component, event, helper);
        },
        filterChangeRequest: function(component, event, helper){
                var mapOfFiltersSelected =  JSON.parse(JSON.stringify(component.get("v.map_Of_Filters_Selected")));
                console.log(mapOfFiltersSelected);
                var counter = 0;
                for (var key in mapOfFiltersSelected) {
                        if (mapOfFiltersSelected[key].indexOf("Select_") > -1){
                                counter++;
                        }                        
                }
                if (mapOfFiltersSelected["Fiscal_Year"].indexOf("Select_") > -1){
                        helper.showToast(component, event, helper,'Value Required!!','Please select Fiscal Year!!','error','info_alt');
                        return;
                }
                if (mapOfFiltersSelected["Quarter"].indexOf("Select_") > -1){
                        helper.showToast(component, event, helper,'Value Required!!','Please select Quarter!!','error','info_alt');
                        return;
                }
                if (mapOfFiltersSelected["Region"].indexOf("Select_") > -1){
                        helper.showToast(component, event, helper,'Value Required!!','Please select Region!!','error','info_alt');
                        return;
                }
                if (mapOfFiltersSelected["Country"].indexOf("Select_") > -1){
                        helper.showToast(component, event, helper,'Value Required!!','Please select Country!!','error','info_alt');
                        return;
                }

                if (counter == 6) {
                        helper.showToast(component, event, helper,'No Result Found!!','Please select at least one filter option !!','error','info_alt');
                        return;
                }
                //console.log(JSON.parse(JSON.stringify(component.get("v.map_Of_Filters"))));
                helper.getMasterQMSPdateHelper(component, event, helper, JSON.parse(JSON.stringify(component.get("v.map_Of_Filters_Selected"))));
        },
        // function automatic called by aura:waiting event  
        showSpinner: function(component, event, helper) {
                // make Spinner attribute true for displaying loading spinner 
                component.set("v.spinner", true);
        },
        // function automatic called by aura:doneWaiting event 
        hideSpinner: function(component, event, helper) {
                // make Spinner attribute to false for hiding loading spinner    
                component.set("v.spinner", false);
        },
        navigateToRecord: function(component, event, helper) {
                var clickedRecordId = event.target.getAttribute('data-index');
                //console.log(clickedRecordId);
                var navEvent = $A.get("e.force:navigateToSObject");
                if (navEvent) {
                        navEvent.setParams({
                                recordId: clickedRecordId,
                                slideDevName: "detail"
                        });
                        navEvent.fire();
                } else {}
        },
        onCapacityChange: function(component, event, helper) {
                helper.showSpinnerC(component,event,helper);
                // This will contain the string of the "value" attribute of the selected option
                //console.log('Record_per_Page  ' + component.get("v.defaultRpp"));
                var selectedOptionValue = component.get("v.defaultRpp");
                var pageNumberCapacity = parseInt(selectedOptionValue);
                component.set("v.pageSize",pageNumberCapacity);
                component.set("v.currentPageNumber",1);
                helper.generateMasterPageDataList(component, event, helper);
        },
        resetFilter : function(component, event, helper){
                var masterPageData = [];
                var storeResponse = component.get("v.userInfo");
                // set current user information on userInfo attribute
                component.set("v.map_Of_Filters_Selected.Fiscal_Year", "Select_Fiscal Year");
                component.set("v.map_Of_Filters_Selected.Quarter", "Select_Quarter");
                if(storeResponse.Market__c != '' && storeResponse.Market__c != null && storeResponse.Market__c != undefined){
                                component.set("v.map_Of_Filters_Selected.Region", storeResponse.Market__c);
                                component.set("v.disableRegionField",true);
                }else{
                        component.set("v.map_Of_Filters_Selected.Region","Select_Region");
                }
            	if(storeResponse.Country_ISO_Code__c != '' && storeResponse.Country_ISO_Code__c != null && storeResponse.Country_ISO_Code__c != undefined){
                                component.set("v.map_Of_Filters_Selected.Country", storeResponse.Country_ISO_Code__c);
                                component.set("v.makeCountryDisabled",true);
                }else{
                        component.set("v.map_Of_Filters_Selected.Country","Select_Country");
                }
                component.set("v.map_Of_Filters_Selected.Brand", "Select_Brand");
                component.set("v.brandDisabledDependentFld", true);
                component.set("v.map_Of_Filters_Selected.Model", "Select_Model");
                component.set("v.map_Of_Filters_Selected.Category", "Select_Category");
                component.set("v.map_Of_Filters_Selected.VME_Type", "Select_VME-Type");
                component.set("v.defaultRpp",5);
                component.set("v.showResults", false);
                component.set("v.MasterPageDataList", masterPageData);
        },
        onFirst: function(component, event, helper) {
                helper.showSpinnerC(component,event,helper);
                component.set("v.currentPageNumber", 1);
                helper.generateMasterPageDataList(component, event, helper);
        },
        onNext: function(component, event, helper) {
                helper.showSpinnerC(component,event,helper);
                var pageNumber = component.get("v.currentPageNumber");
                component.set("v.currentPageNumber", pageNumber + 1);
                helper.generateMasterPageDataList(component, event, helper);
        },
        onPrev: function(component, event, helper) {
                helper.showSpinnerC(component,event,helper);
                var pageNumber = component.get("v.currentPageNumber");
                component.set("v.currentPageNumber", pageNumber - 1);
                helper.generateMasterPageDataList(component, event, helper);
        },
        onLast: function(component, event, helper) {
                helper.showSpinnerC(component,event,helper);
                component.set("v.currentPageNumber", component.get("v.totalPages"));
                helper.generateMasterPageDataList(component, event, helper);
        },
        processMe : function(component, event, helper) {
                helper.showSpinnerC(component,event,helper);
                component.set("v.currentPageNumber", parseInt(event.target.name));
                helper.generateMasterPageDataList(component, event, helper);
        },
        RegionChangeRequest : function(component, event, helper){
                var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
                var dependentCountryFieldMap = component.get("v.dependentCountryFieldMap");
                component.set("v.map_Of_Filters_Selected.Country","Select_Country");

                if (controllerValueKey != 'Select_Region') {
                        var ListOfDependentFields = dependentCountryFieldMap[controllerValueKey];
                    	console.log(ListOfDependentFields);
                        if (ListOfDependentFields!= null && ListOfDependentFields!= undefined && ListOfDependentFields.length > 0) {
                                component.set("v.makeCountryDisabled", false);
                                helper.fetchDepValues(component, ListOfDependentFields);
                        } else {
                            	var dependentFields = [];
                            	dependentFields.push({
                                        label: 'All',
                                        value: 'All_Country'
                                });
                                component.set("v.makeCountryDisabled", true);
                                component.set("v.map_Of_Filters.Country", dependentFields);
                            	component.set("v.map_Of_Filters_Selected.Country","All_Country");
                        }
                } else {
                        //component.set("v.makeCountryDisabled", ['Select_Country']);
                        component.set("v.makeCountryDisabled", true);
                }

        },
        BrandChangeRequest : function(component, event, helper){
                var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
                var dependentModelFieldMap = component.get("v.dependentModelFieldMap");
                component.set("v.map_Of_Filters_Selected.Model","Select_Model");
                //console.log('var1', 'var2');
               // console.log(dependentModelFieldMap, controllerValueKey);
                if (controllerValueKey != 'Select_Brand') {
                        var ListOfDependentFields = dependentModelFieldMap[controllerValueKey];
                        if (ListOfDependentFields.length > 0) {
                                component.set("v.brandDisabledDependentFld", false);
                                helper.fetchModelDepValues(component, ListOfDependentFields);
                        } else {
                                component.set("v.brandDisabledDependentFld", true);
                                component.set("v.BrandDependingValues", ['Select_Model']);
                        }
                } else {
                        component.set("v.BrandDependingValues", ['Select_Model']);
                        component.set("v.brandDisabledDependentFld", true);
                }
        },
        showRetailer : function(component, event, helper){

                /*var  listofRetailer = event.currentTarget.getAttribute("data-id");
                console.log(event.currentTarget);data-id="{!SCHEME_Master.Id}" 
                console.log(event.target);
                console.log(JSON.stringify(event.target.getAttribute("data-id")));
                console.log(JSON.stringify(event.currentTarget.getAttribute("data-id")));
                console.log(event.srcElement.id); id="{!SCHEME_Master.Id}"*/
                var selectedItem = event.currentTarget;
                var schemeId = selectedItem.dataset.record;
                //console.log(schemeId);
                helper.getRetailer(component, event, helper, schemeId);
        },
        showBundle : function(component, event, helper){
                var selectedItem = event.currentTarget;
                var schemeId = selectedItem.dataset.record;
                //console.log(schemeId);
                helper.getBundle(component, event, helper, schemeId);
        },
        handleRangeChange : function(component, event, helper){
                // This will contain the string of the "value" attribute of the selected option
                var val = component.get("v.value");
                //console.log("You selected: "+ val);

                var high = component.get("v.highResolution");
                high = high.substring(1, 2);
                high = high+val;
                var normal = component.get("v.resolution");
                normal = normal.substring(1, 2);
                normal = normal+val;
                //console.log(val,high,normal);

                if (window.devicePixelRatio != 0) {
                        component.set("v.resolution", val+"rem");
                        component.set("v.highResolution", val+"rem");
                }               
        },
        getBrandWiseReport : function(component, event, helper){
                var brand = component.get("v.map_Of_Filters_Selected.Brand");
                if(brand == "Select_Brand"){
                        helper.showToast(component, event, helper, 'Please select brand to get your results !!!', 'Value Required!', 'warning', 'info_alt');
                        return;
                }
                //helper.showBrandWisePlannerHelper(component, event, helper);
                helper.getBrandWisePlannerHelper(component, event, helper);
        }
})