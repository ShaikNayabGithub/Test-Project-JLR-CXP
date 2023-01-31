({
        check_and_set_ResolutionChanger: function(component, event, helper) {
                window.addEventListener('resize', $A.getCallback(function() {
                        if (window.devicePixelRatio != 1) {
                                component.set("v.showSlider",true);
                                //call this helper when user chnage screen size using zoom in / out
                                helper.check_Window_Frame_Resize(component, event, helper);
                        } else {
                                //call this helper when user chnage screen size
                                helper.check_and_set_ResolutionHelper(component, event, helper);
                        }
                }));
        },
        check_and_set_ResolutionHelper: function(component, event, helper) {
                //console.log('Available Resolution : ', window.screen.availHeight, window.screen.availWidth);
                //console.log('Changing Resolution : ', window.outerHeight, window.outerWidth);
                var heightAvailable = window.screen.availHeight;
                var widthAvailable = window.screen.availWidth;
                if (window.devicePixelRatio == 1){
                        component.set("v.showSlider",true);
                }
                //console.log(heightAvailable, widthAvailable);
                /*component.set("v.value",heightAvailable);
                component.set("v.min", heightAvailable);
                component.set("v.max", widthAvailable);*/
                if (heightAvailable > 700 && heightAvailable < 768) {
                        component.set("v.value", 16);
                        component.set("v.resolution", "16rem");
                        component.set("v.highResolution", "16rem");
                        /*var cmpTarget = component.find('card_Header_Planner');
                        $A.util.removeClass(cmpTarget, 'container-outer');
                        $A.util.removeClass(cmpTarget, 'container-outer800');
                        $A.util.removeClass(cmpTarget, 'container-outer900');
                        $A.util.addClass(cmpTarget, 'container-outer700');
                        console.log('container-outer700');*/
                } else if (heightAvailable > 786 && heightAvailable < 850) {
                        component.set("v.value", 24);
                        component.set("v.resolution", "24rem");
                        component.set("v.highResolution", "24rem");
                        /*var cmpTarget = component.find('card_Header_Planner');
                        $A.util.removeClass(cmpTarget, 'container-outer');
                        $A.util.removeClass(cmpTarget, 'container-outer700');
                        $A.util.removeClass(cmpTarget, 'container-outer900');
                        $A.util.addClass(cmpTarget, 'container-outer800');
                        console.log('container-outer800');*/
                } else if (heightAvailable > 850 && heightAvailable < 950) {
                        component.set("v.value", 28);
                        component.set("v.resolution", "28rem");
                        component.set("v.highResolution", "28rem");
                        /*var cmpTarget = component.find('card_Header_Planner');
                        $A.util.removeClass(cmpTarget, 'container-outer');
                        $A.util.removeClass(cmpTarget, 'container-outer700');
                        $A.util.removeClass(cmpTarget, 'container-outer800');
                        $A.util.addClass(cmpTarget, 'container-outer900');
                        console.log('container-outer900');*/
                } else if (heightAvailable > 950 && heightAvailable < 1080) {
                        component.set("v.value", 32);
                        component.set("v.resolution", "32rem");
                        component.set("v.highResolution", "32rem");
                        /*var cmpTarget = component.find('card_Header_Planner');
                        $A.util.removeClass(cmpTarget, 'container-outer');
                        $A.util.removeClass(cmpTarget, 'container-outer700');
                        $A.util.removeClass(cmpTarget, 'container-outer800');
                        $A.util.removeClass(cmpTarget, 'container-outer900');
                        $A.util.addClass(cmpTarget, 'container-outer1000');
                        console.log('container-outer1000');*/
                }
        },
        check_Window_Frame_Resize: function(component, event, helper) {
                var width  = Number(window.getComputedStyle(document.getElementById("card_Header_Planner_Id"),null).getPropertyValue("width").replace("px", "")).toFixed();
                var height = Number(window.getComputedStyle(document.getElementById("card_Header_Planner_Id"),null).getPropertyValue("height").replace("px", "")).toFixed();
                var zoomR = width/height; 
                //console.log(width, height, zoomR, parseFloat(window.devicePixelRatio, 10).toFixed(2),window.devicePixelRatio);
                var zoom = window.screen.availWidth / window.screen.availHeight;
                //console.log(window.screen.availWidth, window.screen.availHeight, zoom);
                //console.log(Math.round(zoom) * window.devicePixelRatio, Math.round(zoomR) * window.devicePixelRatio);
                //document.getElementById("framesize").innerHTML = "Result Size: <span>" + width + " x " + height + "</span>";
        },
        getFiltersDatahelper: function(component, event, helper) {
                var mapOfFilter = JSON.parse(JSON.stringify(component.get("v.map_Of_Filters_Selected")));
                //calling apex conttroller to get picklist values
                var action = component.get("c.getFiltersValues");
                //setting up the call back
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        //console.info(response.getState());
                        if (state === "SUCCESS") {
                                //console.info(response.getReturnValue());
                                for (var key in response.getReturnValue()) {
                                        //console.log(response.getReturnValue()[key]);
                                        helper.convertMapIntoPicklistArrayHelper(component, event, helper, key, response.getReturnValue()[key]);
                                }
                        } else if (state === "ERROR") {} else {}
                });
                $A.enqueueAction(action);
                //Getting Market and Country Mapping Picklist
                var action = component.get("c.getRegion_Market_Map");
                action.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                                //store the return response from server (map<string,List<string>>)  
                                var StoreResponse = response.getReturnValue();
                                //console.log(response.getReturnValue());
                                component.set("v.dependentCountryFieldMap", StoreResponse);
                                var listOfkeys = [];
                                var ControllerField = [];
                                for (var singlekey in StoreResponse) {
                                        listOfkeys.push(singlekey);
                                }
                                if (listOfkeys != undefined && listOfkeys.length > 0) {
                                        ControllerField.push({
                                                label: 'Select Region',
                                                value: 'Select_Region'
                                        });
                                }
                                for (var i = 0; i < listOfkeys.length; i++) {
                                        var ele = {
                                                'label': listOfkeys[i],
                                                'value': listOfkeys[i]
                                        };
                                        ControllerField.push(ele);
                                }
                                //console.log(ControllerField, StoreResponse);
                                component.set("v.map_Of_Filters.Region", ControllerField);
                        } else {
                                alert('Something is not right. Please contact Admin!!');
                        }
                });
                $A.enqueueAction(action);
                //Getting Brand and Model Dependent picklist values  
                var action = component.get("c.getBrand_Model_Map");
                action.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                                //store the return response from server (map<string,List<string>>)  
                                var StoreResponse = response.getReturnValue();
                                //console.log(response.getReturnValue());
                                component.set("v.dependentModelFieldMap", StoreResponse);
                                var listOfkeys = [];
                                var ControllerField = [];
                                for (var singlekey in StoreResponse) {
                                        listOfkeys.push(singlekey);
                                }
                                if (listOfkeys != undefined && listOfkeys.length > 0) {
                                        ControllerField.push({
                                                label: 'Select Brand',
                                                value: 'Select_Brand'
                                        });
                                }
                                for (var i = 0; i < listOfkeys.length; i++) {
                                        var ele = {
                                                'label': listOfkeys[i],
                                                'value': listOfkeys[i]
                                        };
                                        ControllerField.push(ele);
                                }
                                //console.log(ControllerField, StoreResponse);
                                component.set("v.map_Of_Filters.Brand", ControllerField);
                                component.set("v.map_Of_Filters.Model", [{
                                        label: 'Select Model ',
                                        value: 'Select_Model'
                                }]);
                                component.set("v.map_Of_Filters_Selected.Model", 'Select_Model');
                        } else {
                                alert('Something is not right. Please contact Admin..');
                        }
                });
                $A.enqueueAction(action);
                //get the current logged in user Details
                var action = component.get("c.fetchUser");
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                                //console.log(response.getReturnValue());
                                var storeResponse = response.getReturnValue();
                                // set current user information on userInfo attribute
                                component.set("v.userInfo", storeResponse);
                                //put the deafult country value if the user field is filled.
                                if (storeResponse.Country_ISO_Code__c != '' && storeResponse.Country_ISO_Code__c != null && storeResponse.Country_ISO_Code__c != undefined) {
                                        component.set("v.map_Of_Filters_Selected.Country", storeResponse.Country_ISO_Code__c);
                                        component.set("v.makeCountryDisabled", true);
                                } else {
                                        component.set("v.map_Of_Filters.Country", ['Select_Country']);
                                        component.set("v.makeCountryDisabled", false);
                                }
                                //put the deafult Region / market value if the user field is filled.
                                if (storeResponse.Market__c != '' && storeResponse.Market__c != null && storeResponse.Market__c != undefined) {
                                        component.set("v.map_Of_Filters_Selected.Region", storeResponse.Market__c);
                                        var dependentCountryFieldMap = component.get("v.dependentCountryFieldMap");
                                        var ListOfDependentFields = dependentCountryFieldMap[storeResponse.Market__c];
                                        this.fetchDepValues(component, ListOfDependentFields);
                                } else {
                                        component.set("v.disableRegionField", false);
                                    	component.set("v.makeCountryDisabled", true);
                                }
                        }
                });
                $A.enqueueAction(action);

                var Fiscal_Year_Data = this.getMeTheCurrentYearNQuarter(component, event, helper);
                //console.log(Fiscal_Year_Data);    
                component.set("v.map_Of_Filters_Selected.Fiscal_Year", Fiscal_Year_Data.currentFY);
                component.set("v.map_Of_Filters_Selected.Quarter", Fiscal_Year_Data.currentQ);
        },
        getMeTheCurrentYearNQuarter : function(component, event, helper){
                //creating hard code quarter array
                var quarterArray = [[1, 'Q1'], [2, 'Q2'],[3, 'Q3'], [4, 'Q4']];
                // Use the regular Map constructor to transform a 2D key-value Array into a map
                var quraterMap = new Map(quarterArray);
                //get current date
                var today = new Date();
                //get current month
                var curMonth = today.getMonth();
                var quarterMonth = today.getMonth() + 1;
                var quarterNumber =  (Math.ceil(quarterMonth / 3));
                var fiscalYr = 0;
                if (curMonth > 3) { //
                        fiscalYr = (today.getFullYear() + 1).toString();
                } else {
                        fiscalYr = today.getFullYear().toString();
                }

                var Fiscal_Year_Data = {
                        pastQ : quraterMap.get(quarterNumber-1),
                        pastFY : Number(fiscalYr) - 1,
                        currentFY: fiscalYr,
                        currentQ : quraterMap.get(quarterNumber),
                        proposeFY : Number(fiscalYr) +1,
                        proposeQ : quraterMap.get(quarterNumber+1)
                }

                return Fiscal_Year_Data;
        },
        convertMapIntoPicklistArrayHelper: function(component, event, helper, pickListType, pickListMap) {
                //console.log(pickListType);
                var arrayOfMapKeys = [];
                arrayOfMapKeys.push({
                        label: 'Select ' + pickListType.replace("_", " "),
                        value: 'Select_' + pickListType
                });
                if (pickListType != 'Fiscal_Year' && pickListType != "Category") {
                        arrayOfMapKeys.push({
                                label: 'All ',
                                value: 'All_' + pickListType
                        });
                }
                for (var keyValues in pickListMap) {
                        var ele = {
                                'label': keyValues,
                                'value': pickListMap[keyValues]
                        };
                        arrayOfMapKeys.push(ele);
                }
                component.set('v.map_Of_Filters[' + pickListType + ']', arrayOfMapKeys);
        },
        //Method to get Master Data from SFDC
        getMasterQMSPdateHelper: function(component, event, helper, mapOfFiltersSelected) {
                if (window.devicePixelRatio != 1)
                        component.set("v.showSlider",true);
                //calling apex conttroller to get picklist values
                var action = component.get("c.getMasterQMSPData");
                //set parameter for sending to controller
                action.setParams({
                        selectedFilterValues: mapOfFiltersSelected,
                        userISOCode: component.get("v.userInfo").DefaultCurrencyIsoCode
                });
                //setting up the call back
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.info(response.getState());
                        if (state === "SUCCESS") {
                                console.info(response.getReturnValue());
                                if (response.getReturnValue().statusOfTransaction == "SUCCESS" && response.getReturnValue().QMSP_Wrapper_List.length > 0) {
                                        component.set("v.MasterDataList", response.getReturnValue().QMSP_Wrapper_List);
                                        component.set("v.TotalRecords", response.getReturnValue().QMSP_Wrapper_List.length);
                                        component.set("v.BrandWisePlannerMap", response.getReturnValue().BrandWisePlanner_Wrapper_List);
                                        //component.set("v.showResults", true);
                                        console.log('Response Time: ' + ((new Date().getTime()) - requestInitiatedTime));
                                        component.set("v.totalPages", Math.ceil(response.getReturnValue().QMSP_Wrapper_List.length / component.get("v.pageSize")));
                                        component.set("v.currentPageNumber", 1);
                                        this.generateMasterPageDataList(component, event, helper);
                                } else if (response.getReturnValue().statusOfTransaction == 'NO-FILTER') {
                                        component.set("v.showResults", false);
                                } else {
                                        component.set("v.showResults", false);
                                        this.showToast(component, event, helper, 'Selected filters are not yielding results!!', 'Please refine your filters options !!', 'warning', 'info_alt');
                                        return;
                                }
                        } else if (state === "ERROR") {
                                component.set("v.showResults", false);
                        } else {
                                component.set("v.showResults", false);
                        }
                });
                var requestInitiatedTime = new Date().getTime();
                $A.enqueueAction(action);
        },
        //generate Master data with Pagination List
        generateMasterPageDataList: function(component, event, helper) {
                var masterPageData = [];
                var pageNumber = component.get("v.currentPageNumber"); //1
                var pageSize = component.get("v.pageSize"); //5
                var masterData = component.get("v.MasterDataList");
                component.set("v.totalPages", Math.ceil(masterData.length / pageSize));
                var x = (pageNumber - 1) * pageSize; //1-1 *5 / 2-1*5 / 3-1*5
                //setting the first record cursor on current page
                component.set("v.RecordStart", x + 1);
                var endRecord = x;
                //creating data-table data
                for (; x < (pageNumber) * pageSize; x++) {
                        if (masterData[x]) {
                                endRecord++;
                                masterPageData.push(masterData[x]);
                        }
                }
                //setting the last record cursor on current page
                component.set("v.RecordEnd", endRecord);
                component.set("v.MasterPageDataList", masterPageData);
                this.generatePageNumberList(component, event, helper, pageNumber);
        },
        generatePageNumberList: function(component, event, helper, pageNumber) {
                var pageNumber = parseInt(pageNumber);
                var pageList = [];
                var totalPages = component.get("v.totalPages");
                //console.log(pageNumber, totalPages);
                if (totalPages > 1) {
                        if (totalPages <= 10) {
                                var counter = 2;
                                for (; counter < (totalPages); counter++) {
                                        pageList.push(counter);
                                }
                        } else {
                                if (pageNumber < 5) {
                                        pageList.push(2, 3, 4, 5, 6);
                                } else {
                                        if (pageNumber > (totalPages - 5)) {
                                                pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                                        } else {
                                                pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                                        }
                                }
                        }
                }
                //console.log('pageList :: ', pageList);
                //console.log('totalPages :: ', totalPages);
                //console.log('pageNumber :: ', pageNumber);
                setTimeout(function(){
                        helper.hideSpinnerC(component,event,helper);
                }, 500);
                
                component.set("v.pageList", pageList);
                component.set("v.showResults", true);
        },
        showSpinnerC: function (component, event, helper) {
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
        },
        hideSpinnerC: function (component, event, helper) {
            var spinner = component.find("mySpinner");
            $A.util.addClass(spinner, "slds-hide mySpinnerCss");
        },
        showToast: function(component, event, helper, titleVal, msg, typeVal, icon) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        title: titleVal,
                        message: msg,
                        messageTemplate: msg,
                        duration: '3000',
                        key: icon,
                        type: typeVal,
                        mode: 'dismissible'
                });
                toastEvent.fire();
        },
        fetchDepValues: function(component, ListOfDependentFields) {
                // create a empty array var for store dependent picklist values for controller field  
                var dependentFields = [];
                dependentFields.push({
                        label: 'Select Country ',
                        value: 'Select_Country'
                });
            	if(ListOfDependentFields.length>1)
                    dependentFields.push({
                            label: 'All',
                            value: 'All_Country'
                    });
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                        var ele = {
                                'label': ListOfDependentFields[i],
                                'value': ListOfDependentFields[i]
                        };
                        dependentFields.push(ele);
                }
                //console.log(ListOfDependentFields, dependentFields);
                // set the dependentFields variable values to store(dependent picklist field) on lightning:select
                component.set("v.map_Of_Filters.Country", dependentFields);
        },
        fetchModelDepValues: function(component, ListOfDependentFields) {
                // create a empty array var for store dependent picklist values for controller field  
                var dependentFields = [];
                dependentFields.push({
                        label: 'Select Model ',
                        value: 'Select_Model'
                });
                dependentFields.push({
                        label: 'All ',
                        value: 'All_Model'
                });
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                        var ele = {
                                'label': ListOfDependentFields[i],
                                'value': ListOfDependentFields[i]
                        };
                        dependentFields.push(ele);
                }
                //console.log(ListOfDependentFields, dependentFields);
                // set the dependentFields variable values to store(dependent picklist field) on lightning:select
                component.set("v.map_Of_Filters.Model", dependentFields);
        },
        getRetailer : function(component, event, helper, schemeId) {

                //calling apex conttroller to get picklist values
                var action = component.get("c.getMyRetailerScheme");
                //setting calling parameter
                action.setParams({ baseSchemeId : schemeId });
                //setting up the call back
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.info(response.getState());
                        if (state === "SUCCESS"){
                                console.info(response.getReturnValue());
                                this.showRetailerHelper(component, event, helper, response.getReturnValue());
                        } else if (state === "ERROR") {} else {}
                });
                $A.enqueueAction(action);

        },
        showRetailerHelper: function(component, event, helper, dealerList) {
                $A.createComponent("c:VME_ShowPlannerRetailer", {
                        "dealerList": dealerList,
                        "isOpenComp": true,
                }, function(msgBox) {
                        if (component.isValid()) {
                                var targetCmp = component.find('ModalDialogPlaceholderPlanner');
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                        }
                });
                this.hideSpinnerC(component, event, helper);
        },
        getBundle : function(component, event, helper, schemeId) {

                //calling apex conttroller to get picklist values
                var action = component.get("c.getMyBundlingScheme");
                //setting calling parameter
                action.setParams({ baseSchemeId : schemeId });
                //setting up the call back
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.info(response.getState());
                        if (state === "SUCCESS"){
                                console.info(response.getReturnValue());
                                this.showBundleHelper(component, event, helper, response.getReturnValue());
                        } else if (state === "ERROR") {} else {}
                });
                $A.enqueueAction(action);

        },
        showBundleHelper: function(component, event, helper, dealerList) {
                $A.createComponent("c:VME_ShowBundleAssetDerivativeModel", {
                        "dealerList": dealerList,
                        "isOpenComp": true,
                }, function(msgBox) {
                        if (component.isValid()) {
                                var targetCmp = component.find('ModalDialogPlaceholderBundlePlanner');
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                        }
                });
                this.hideSpinnerC(component, event, helper);
        },
        getBrandWisePlannerHelper : function(component, event, helper) {
                var BrandWisePlannerNew = JSON.parse(JSON.stringify(component.get("v.BrandWisePlannerMap")));
                //console.log(BrandWisePlannerNew);
                var Fiscal_Year_Data = this.getMeTheCurrentYearNQuarter(component, event, helper);
                var selectedQuarter = component.get("v.map_Of_Filters_Selected.Quarter");
                var qKey = selectedQuarter+"_"+component.get("v.map_Of_Filters_Selected.Brand");
                var currentQData = BrandWisePlannerNew[qKey];
                //console.log(Fiscal_Year_Data, selectedQuarter, qKey);
                if (currentQData != null && currentQData != undefined) {
                        if(selectedQuarter == "All_Quarter")
                                currentQData.Quarter = "All Quarter";
                    	  currentQData.Market = component.get("v.map_Of_Filters_Selected.Region");
                        this.showBrandWisePlannerHelper(component, event, helper, currentQData);
                } else {
                        helper.showToast(component, event, helper, 'No Result found for selected Brand & Quarter', 'Please run planner to get results!!', 'error', 'info_alt');
                        return;
                }
        },
        showBrandWisePlannerHelper: function(component, event, helper, currentQData) {
                $A.createComponent("c:VME_BrandWiseQuarterPlanner", {
                        "brandWiseMap": currentQData,
                        "userDetails": component.get("v.userInfo"),
                        "isOpenComp": true,
                }, function(msgBox) {
                        if (component.isValid()) {
                                var targetCmp = component.find('ModalBrandWiseQuarterPlanner');
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                        }
                });
                this.hideSpinnerC(component, event, helper);
        }
})