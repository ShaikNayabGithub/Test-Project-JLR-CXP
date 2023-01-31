({
	calculateTotals : function(component) {
        var totalApr = 0;
        var totalMay = 0;
        var totalJun = 0;
        var totalJul = 0;
        var totalAug = 0;
        var totalSep = 0;
        var totalOct = 0;
        var totalNov = 0;
        var totalDec = 0;
        var totalJan = 0;
        var totalFeb = 0;
        var totalMar = 0;
    	var totalTotal = 0;
        var arraymap = component.get('v.targetRecords');
        for(var i=0; i<arraymap.length; i++){
            var fld = arraymap[i].salesTarget;
            totalApr = totalApr + parseInt(fld.April_Target__c, 10);
            totalMay = totalMay + parseInt(fld.May_Target__c, 10);
            totalJun = totalJun + parseInt(fld.June_Target__c, 10);
            totalJul = totalJul + parseInt(fld.July_Target__c, 10);
            totalAug = totalAug + parseInt(fld.August_Target__c, 10);
            totalSep = totalSep + parseInt(fld.September_Target__c, 10);
            totalOct = totalOct + parseInt(fld.October_Target__c, 10);
            totalNov = totalNov + parseInt(fld.November_Target__c, 10);
            totalDec = totalDec + parseInt(fld.December_Target__c, 10);
            totalJan = totalJan + parseInt(fld.January_Target__c, 10);
            totalFeb = totalFeb + parseInt(fld.February_Target__c, 10);
            totalMar = totalMar + parseInt(fld.March_Target__c, 10);
            arraymap[i].salesTotal = parseInt(fld.April_Target__c, 10) + parseInt(fld.May_Target__c, 10) + parseInt(fld.June_Target__c, 10) + parseInt(fld.July_Target__c, 10) + parseInt(fld.August_Target__c, 10) + parseInt(fld.September_Target__c, 10) + parseInt(fld.October_Target__c, 10) + parseInt(fld.November_Target__c, 10) + parseInt(fld.December_Target__c, 10) + parseInt(fld.January_Target__c, 10) + parseInt(fld.February_Target__c, 10) + parseInt(fld.March_Target__c, 10);
        }
        totalTotal = totalTotal + totalApr + totalMay + totalJun + totalJul + totalAug + totalSep + totalOct + totalNov + totalDec + totalJan + totalFeb + totalMar;
        component.set('v.targetRecords', arraymap);
        component.set('v.totalApr', totalApr);
        component.set('v.totalMay', totalMay);
        component.set('v.totalJun', totalJun);
        component.set('v.totalJul', totalJul);
        component.set('v.totalAug', totalAug);
        component.set('v.totalSep', totalSep);
        component.set('v.totalOct', totalOct);
        component.set('v.totalNov', totalNov);
        component.set('v.totalDec', totalDec);
        component.set('v.totalJan', totalJan);
        component.set('v.totalFeb', totalFeb);
        component.set('v.totalMar', totalMar);
        component.set('v.totalTotal', totalTotal);
    }
})