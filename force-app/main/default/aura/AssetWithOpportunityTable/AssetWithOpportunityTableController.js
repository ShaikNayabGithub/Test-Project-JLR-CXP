({
    doInit : function(component, event, helper) {
        component.set('v.oppWithProdColumns', [
            {label: 'Asset Name',initialWidth: 150, fieldName: 'assetId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'assetName' },wrapText: true, target: '_blank'}},
            {label: 'Account Name',initialWidth: 250, fieldName: 'accountId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'accountName' }, target: '_blank'}},
            {label: 'Opportunity Name',initialWidth: 250, fieldName: 'oppId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'oppName' }, target: '_blank'}},
            {label: 'Product Name',initialWidth: 250, fieldName: 'productId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'}},
            {label: 'Created Date', initialWidth: 150,fieldName: 'createdDate', type: 'date',wrapText: true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},   
            {label: 'Last Modified Date',initialWidth: 150, fieldName: 'lastModifieddate', type: 'date',wrapText: true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},   
            {label: 'Order Number', initialWidth: 100,fieldName: 'orderNumber', type: 'Text',wrapText: true},
            {label: 'Country ISO Code',initialWidth: 100, fieldName: 'countryIsoCode', type: 'Text',wrapText: true},
            {label: 'Dealer Code',initialWidth: 100, fieldName: 'dealerCode', type: 'Text',wrapText: true},
            {label: 'Vista Status',initialWidth: 100, fieldName: 'vistaStatus', type: 'Text',wrapText: true},
            {label: 'Model', fieldName: 'model',initialWidth: 180, type: 'Text',wrapText: true},
            {label: 'Product status',initialWidth: 100, fieldName: 'active', type: 'boolean',wrapText: true},
            {label: 'Common Sales Type',initialWidth: 100, fieldName: 'commonSalesType', type: 'Text',wrapText: true},
            {label: 'Region', fieldName: 'region',initialWidth: 100, type: 'Text',wrapText: true},
            {label: 'Retailer Name',initialWidth: 150, fieldName: 'retailerId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'retailerName' }, target: '_blank'}}
        ]);
        component.set('v.oppWithoutProdColumns', [
            {label: 'Asset Name',initialWidth: 150, fieldName: 'assetId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'assetName' }, target: '_blank'}},
            {label: 'Account Name',initialWidth: 150, fieldName: 'accountId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'accountName' }, target: '_blank'}},
            {label: 'Created Date',initialWidth: 150, fieldName: 'createdDate', type: 'date',wrapText: true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},   
            {label: 'Last Modified Date',initialWidth: 150, fieldName: 'lastModifieddate', type: 'date',wrapText: true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},   
            {label: 'Order Number',initialWidth: 100, fieldName: 'orderNumber', type: 'Text',wrapText: true},
            {label: 'Country ISO Code',initialWidth: 100, fieldName: 'countryIsoCode', type: 'Text',wrapText: true},
            {label: 'Dealer Code',initialWidth: 100, fieldName: 'dealerCode', type: 'Text',wrapText: true},
            {label: 'Vista Status',initialWidth: 100, fieldName: 'vistaStatus', type: 'Text',wrapText: true},
            {label: 'Model', fieldName: 'model',initialWidth: 100, type: 'Text',wrapText: true},
            {label: 'Common Sales Type',initialWidth: 100, fieldName: 'commonSalesType', type: 'Text',wrapText: true},
            {label: 'Region', fieldName: 'region',initialWidth: 150, type: 'Text',wrapText: true},
            {label: 'Retailer Name',initialWidth: 150, fieldName: 'retailerId', type: 'url',wrapText: true,
             typeAttributes: {label: { fieldName: 'retailerName' }, target: '_blank'}}
        ]);
        helper.getAssetStatus(component);
    },
    handleSalesTypeQuickChange: function (component, event) {
        console.log('handleSalesTypeQuickChange --> '+event.getParam('value'));
        var selectedsalesType= component.get("v.selectedsalesType");
        console.log('selectedsalesType --> '+selectedsalesType);
        if(selectedsalesType == 'SalesTypes'){ 
            var commonQuickSalesTypesList = component.get("v.commonQuickSalesTypesList");
            console.log('commonQuickSalesTypesList -->'+commonQuickSalesTypesList);
            var commonSalesType = ["Employee - Dealer/Importer",
                                   "Employee - JLR",
                                   "Fleet of 1-4 vehicles",
                                   "Fleet of 100+ vehicles",
                                   "Fleet of 25-100 vehicles",
                                   "Leasing Company",
                                   "Rental with Buy Back",
                                   "Government",
                                   "Embassy",
                                   "Pre-Order",
                                   "Private Individual",
                                   "Private Lease",
                                   "Affinity",
                                   "Fleet of 1-24 vehicles",
                                   "Fleet of 5-24 Vehicles",
                                   "Dealer Based Rental",
                                   "Tax Free Sales"];
            component.set("v.selectedCommonSalesType", commonSalesType);            
            console.log('22 -->'+component.get("v.selectedCommonSalesType"));
        }else if(selectedsalesType){
            var commonSalesType = [];
            component.set("v.selectedCommonSalesType", commonSalesType);
        }
    },
    handleRegionChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedRegion = event.getParam("value");
        component.set("v.selectedRegion",selectedRegion);
        console.log("Option selected with value: '" + selectedRegion + "'");
    },
    handleStatusChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedStatus",selectedOptionValue);
        console.log("Option selected with value: '" + selectedOptionValue + "'");
    },
    handleYearChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedyear",selectedOptionValue);
        console.log("Option selected with value: '" + selectedOptionValue + "'");
    },
    handleSearch: function (component, event, helper) {
        helper.handleAssetSearchHelper(component, event, helper);
    },
    clearSearch: function (component, event, helper) {
        window.location.reload();
    },
    handleTabSelect: function (component, event, helper) {
        var tabId = event.getParam('id');
        console.log('tabId --> '+tabId);
        component.set("v.currentPageNumber", 1);
        var currentPageNumber = component.get("v.currentPageNumber");
        if(tabId == 'AssetWtpp'){
            var assetWithOppList = component.get("v.assetWithOppList");
            helper.renderPage(component,currentPageNumber,assetWithOppList);
        }else if(tabId == 'AssetWoOpp'){
            var assetWithOutOppList = component.get("v.assetWithOutOppList");
            helper.renderPage(component,currentPageNumber,assetWithOutOppList);
        }
        component.set("v.selectedTabId",tabId);
    },
    firstPage: function(component, event, helper) {
        component.set("v.showFirst",true);
        component.set("v.showLast",false);
        component.set("v.currentPageNumber", 1);
        var currentPageNumber = component.get("v.currentPageNumber");
        var tabId = component.get("v.selectedTabId");
        if(tabId == 'AssetWtpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOppList"));
        } else if(tabId == 'AssetWoOpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOutOppList"));
        }
        
    },
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
        var currentPageNumber = component.get("v.currentPageNumber");
        if(currentPageNumber == 1){
            component.set("v.showFirst",true);
            component.set("v.showLast",false);
        }   else{
            component.set("v.showFirst",false);
            component.set("v.showLast",false);
        }
        var tabId = component.get("v.selectedTabId");
        if(tabId == 'AssetWtpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOppList"));
        } else if(tabId == 'AssetWoOpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOutOppList"));
        }
    },
    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
        var currentPageNumber = component.get("v.currentPageNumber");
        var maxPageNumber = component.get("v.maxPageNumber");
        if(currentPageNumber == maxPageNumber){
            component.set("v.showFirst",false);
            component.set("v.showLast",true);
        }else{
            component.set("v.showFirst",false);
            component.set("v.showLast",false);
        }
        var tabId = component.get("v.selectedTabId");
        console.log('tabId --> '+tabId);
        console.log('currentPageNumber --> '+currentPageNumber);
        if(tabId == 'AssetWtpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOppList"));
        } else if(tabId == 'AssetWoOpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOutOppList"));
        }
    },
    lastPage: function(component, event, helper) {
        component.set("v.showFirst",false);
        component.set("v.showLast",true);
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
        var currentPageNumber = component.get("v.currentPageNumber");
        var tabId = component.get("v.selectedTabId");
        if(tabId == 'AssetWtpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOppList"));
        } else if(tabId == 'AssetWoOpp'){
            helper.renderPage(component,currentPageNumber,component.get("v.assetWithOutOppList"));
        }   
    }
    
})