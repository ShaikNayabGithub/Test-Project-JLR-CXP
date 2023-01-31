({
    doinit : function(component, event, helper) {

        var days=NoofDays();
        console.log(days);
        component.set('v.days',days);
        //Get PdiQuota object data
        var action = component.get('c.fetchPdiQuota');
        //component.find("YearMonth").set("v.value", getCurrentMonYear);
        var getCurrentMonYr=getCurrentMonYear();
        console.log('getCurrentMonYear'+getCurrentMonYr);
        
        let selectedValue = component.find('YearMonth').get('v.value'); 
        var stringSelectedValue =  String(selectedValue)
        var c=stringSelectedValue.slice(0,4);
        var e=stringSelectedValue.slice(5);
        //console.log('value of year'+selectedValue.getFullYear());
        //console.log('value of month'+c);
        //console.log('year selected by user'+ c + 'year' + e) ;
        //console.log('year selected by user'+ String(selectedValue)) ;
        var f = ("JanFebMarAprMayJunJulAugSepOctNovDec".indexOf(e) / 3 + 1 );
        //console.log('year selected by user'+ c + 'month' + f) ;
        console.log('selectedValue'+selectedValue) ;
        if (selectedValue == null){ 
        var d = new Date();
        f = d.getMonth()+1;
        c = d.getFullYear();
        component.set('v.CurrentMonthYr', getCurrentMonYr); 
        }else{
        let selectedValue = component.find('YearMonth').get('v.value'); 
        component.set('v.CurrentMonthYr', selectedValue);
        }
        //component.find("YearMonth").set("v.value", c+'-'+f);
        //component.set('v.YearSelected',c+'-'+f);
        


        console.log('default data year'+ c + 'month' + f) ;
        action.setParams({ Year: c, Month : f });
        //action.setParams({ recordTypeName: component.get("v.targetType") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                console.log("allValues--->>> " + allValues);
                component.set('v.pdiData', allValues);
                helper.calculateTotals(component);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });

        var actionacalendar = component.get('c.GetDays');
        //actionacalendar.setParams({ Year: d.getFullYear(), Month : d.getMonth()+1 });
        actionacalendar.setParams({ Year: c, Month : f });
        actionacalendar.setCallback(this, function(response){
            var state = response.getState();
            console.log('calendardays'+ state);
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result data from new class'+ result);
                //component.set('v.getDaysHolidayWrapper',result);
                //console.log('result data from new class' , JSON.parse((result))  );
                console.log(result);

                var calendarValues = result.finalMap_1;
                var holidaylist = result.holiday;
                var pdiViewPermissionLocal = result.pdiViewPermission;
                //toggling the value as this variable is used to enable/diable Save button based on the permission
                if (pdiViewPermissionLocal == false){
                    pdiViewPermissionLocal = true;
                }
                else if(pdiViewPermissionLocal == true){
                    pdiViewPermissionLocal = false;
                }
                component.set('v.pdiViewPermissionCheck', pdiViewPermissionLocal);
                console.log(calendarValues ) ;
                console.log( holidaylist ) ;
                var calendarvaluesLocal=[];
                for (let key in calendarValues) {
                    calendarvaluesLocal.push({value:calendarValues[key], key:key});
                  //  console.log("Values--->>> " + calendarValues[key]);
                   // console.log("Key--->>> " + key);
                 }
                component.set('v.calendarValuesMonth', calendarvaluesLocal);
                component.set('v.DaysInMonth', calendarvaluesLocal.length);
                component.set('v.holidaylist', holidaylist);
                console.log("calendardata--->>> " + calendarvaluesLocal);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });
 
        var actionMonthYear = component.get('c.GetYearMonth')
        actionMonthYear.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var yearMonthPickList = response.getReturnValue();
              
               component.set('v.yearMonthPickList', yearMonthPickList); //added this line 
                console.log('yearMonthPickList'+ yearMonthPickList);
                helper.resetPDIQuotaHeader(component);
                
        }
    });

        $A.enqueueAction(action);
        $A.enqueueAction(actionacalendar);
        $A.enqueueAction(actionMonthYear);
        function  getCurrentMonYear(){
             var DateObj = new Date();
             var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
             var year=DateObj.getFullYear();
             console.log('year'+year)
             var month=months[DateObj.getMonth()];
             console.log('month'+month)
            return  year+'-'+month;
         };
        function   NoofDays(){ 
            var days=[];
            for(var i=1;i<=31;i++){
            days.push('num'+i);
            }
            return days;
        };
       

       
   
    },
    onchange:function(component, event, helper){
        let selectedValue = component.find('YearMonth').get('v.value'); 
        component.set('v.CurrentMonthYr', selectedValue);
       
    },
    showCon : function(component, event, helper){
        component.set("v.show",true);
        var idx = event.target.getAttribute('data-index');
        console.log('idx---->>> ' + idx);
        var rowRecord = component.get("v.pdiData")[idx];
        console.log('rowRecord---->>> ' + JSON.stringify(rowRecord));
        var action = component.get('c.fetchCon');
        action.setParams({recordId : rowRecord.Id});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                console.log("allValues--->>> " + JSON.stringify(allValues));
                component.set('v.conData', allValues);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    saveRecords: function(component, event, helper) {
        var button = event.getSource();
        button.set("v.disabled", true);
        var PdiData ;
        var action = component.get("c.saveTargetRecords");
        //console.log('i am here just before setparams');
        //console.log(component.get("v.pdiData"));
        action.setParams({ PdiData: JSON.stringify(component.get("v.pdiData")) });
        //console.log(PdiData);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log("state" + state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                //console.log("getreturnvalue" + response.getReturnValue());
                if (response.getReturnValue() == "Success") {
                    toastEvent.setParams({
                        title: "Success!",
                        type: "success",
                        message: $A.get("$Label.c.LC_COOP_The_Record_Has_Been_Updated_Successfully")
                   //message : "The record has been updated successfully."
                    });
                } else {
                    toastEvent.setParams({
                        title: "Error!",
                        type: "error",
                        message: response.getReturnValue()
                    });
                }
                toastEvent.fire();
                $A.get('e.force:refreshView').fire(); 
                button.set("v.disabled", false);
            }
        });
        $A.enqueueAction(action);
    },
    
	calcTotals: function(component, event, helper) {
        var totaltest = component.get("v.totalDay1");
        console.log('total after manual entry' + totaltest);
		helper.calculateTotals(component);
	},

    capacityPercentage: function(component, event, helper) {
		helper.calculateTotalsHelper(component);
        helper.calculateTotals(component);
	},
    //this function may not be required and to be deleted. It is updated in above function by using helper function
    capacityPercentageTemp: function(component, event, helper) {
        var result1;
        var result2;
        var result3;
        var result4;
        var result5;
        var result6;
        var result7;
        var result8;
        var result9;
        var result10;
        var result11;
        var result12;
        var result13;
        var result14;
        var result15;
        var result16;
        var result17;
        var result18;
        var result19;
        var result20;
        var result21;
        var result22;
        var result23;
        var result24;
        var result25;
        var result26;
        var result27;
        var result28;
        var result29;
        var result30;
        var result31;
        
        //var Keyname = v.this.Id
        let Keyname1 = component.find("PercentageID");
       console.log('keyname'+Keyname1[0].get("v.value") + 'size of keyname1' + Keyname1.length);
        var arraymap = component.get("v.pdiData");
        var num1 = component.get("v.num1");
        var num2 = component.get("v.num2");
        var num3 = component.get("v.num3");
        var num4 = component.get("v.num4");
        var num5 = component.get("v.num5");
        var num6 = component.get("v.num6");
        var num7 = component.get("v.num7");
        var num8 = component.get("v.num8");
        var num9 = component.get("v.num9");
        var num10 = component.get("v.num10");
        var num11 = component.get("v.num11");
        var num12 = component.get("v.num12");
        var num13 = component.get("v.num13");
        var num14 = component.get("v.num14");
        var num15 = component.get("v.num15");
        var num16 = component.get("v.num16");
        var num17 = component.get("v.num17");
        var num18 = component.get("v.num18");
        var num19 = component.get("v.num19");
        var num20 = component.get("v.num20");
        var num21 = component.get("v.num21");
        var num22 = component.get("v.num22");
        var num23 = component.get("v.num23");
        var num24 = component.get("v.num24");
        var num25 = component.get("v.num25");
        var num26 = component.get("v.num26");
        var num27 = component.get("v.num27");
        var num28 = component.get("v.num28");
        var num29 = component.get("v.num29");
        var num30 = component.get("v.num30");
        var num31 = component.get("v.num31");
        



        console.log('number 1' + num1);
        
        for (var i =0; i < Keyname1.length; i++ ){
            var percentageRow = Keyname1[i].get("v.value");
            console.log ('inside for loop keyname'+ Keyname1[i].get("v.value"));
            var tempNewAllocationValue ;
            console.log('percentagerow' + percentageRow)
            //var num2 = component.get("v.num2");
            //console.log('number 1' + num2);

            //console.log('arramay' + arraymap);
            if((num1 || percentageRow) != 0 ){
            result1 = (num1*percentageRow)/100;
            if (isNaN((num1*percentageRow))) {
                result1 =0;
             }
            arraymap[i].Allocation_Day_1__c = result1;}

            if((num2 || percentageRow)  != 0 ){
                result2 = (num2*percentageRow)/100;
                if (isNaN((num2*percentageRow))) {
                     result2 =0;
                  }
            //result2 = if(isNaN((num2*percentageRow)/100,0), result2 =0) ; 
            arraymap[i].Allocation_Day_2__c = result2;}

            if((num3 || percentageRow) != 0 ){
                result3 = (num3*percentageRow)/100;
                if (isNaN((num3*percentageRow))) {
                    result3 =0;
                  }
            
            arraymap[i].Allocation_Day_3__c = result3;}

            if((num4 || percentageRow) != 0 ){
            result4 = (num4*percentageRow)/100;
            if (isNaN((num4*percentageRow))) {
                result4 =0;
             }
            arraymap[i].Allocation_Day_4__c = result4;}

            if((num5 || percentageRow) != 0 ){
            result5 = (num5*percentageRow)/100;
            if (isNaN((num5*percentageRow))) {
                result5 =0;
             }
            arraymap[i].Allocation_Day_5__c = result5;}

            if((num6 || percentageRow) != 0 ){
            result6 = (num6*percentageRow)/100;
            if (isNaN((num6*percentageRow))) {
                result6 =0;
             }
            arraymap[i].Allocation_Day_6__c = result6;}

            if((num7 || percentageRow) != 0 ){
            result7 = (num7*percentageRow)/100;
            if (isNaN((num7*percentageRow))) {
                result7 =0;
             }
            arraymap[i].Allocation_Day_7__c = result7;}

            if((num8 || percentageRow) != 0 ){
            result8 = (num8*percentageRow)/100;
            if (isNaN((num8*percentageRow))) {
                result8 =0;
             } 
            arraymap[i].Allocation_Day_8__c = result8;
            }

            if((num9 || percentageRow) != 0 ){
            result9 = (num9*percentageRow)/100;
            if (isNaN((num9*percentageRow))) {
                result9 =0;
             }
            arraymap[i].Allocation_Day_9__c = result9;
            }

            if((num10 || percentageRow) != 0 ){
            result10 = (num10*percentageRow)/100;
            if (isNaN((num10*percentageRow))) {
                result10 =0;
             }
            arraymap[i].Allocation_Day_10__c = result10;
            }

            if((num11 || percentageRow) != 0 ){
            result11 = (num11*percentageRow)/100;
            if (isNaN((num11*percentageRow))) {
                result11 =0;
             }
            arraymap[i].Allocation_Day_11__c = result11;}

            if((num12 || percentageRow) != 0 ){
            result12 = (num12*percentageRow)/100;
            if (isNaN((num12*percentageRow))) {
                result12 =0;
             }
            arraymap[i].Allocation_Day_12__c = result12;}

            if((num13 || percentageRow) != 0 ){
            result13 = (num13*percentageRow)/100;
            if (isNaN((num13*percentageRow))) {
                result13 =0;
             }
            arraymap[i].Allocation_Day_13__c = result13;}

            if((num14 || percentageRow) != 0 ){
            result14 = (num14*percentageRow)/100;
            if (isNaN((num14*percentageRow))) {
                result14 =0;
             }
            arraymap[i].Allocation_Day_14__c = result14;}

            if((num15 || percentageRow) != 0 ){
            result15 = (num15*percentageRow)/100;
            if (isNaN((num15*percentageRow))) {
                result15 =0;
             }
            arraymap[i].Allocation_Day_15__c = result15;}

            if((num16 || percentageRow) != 0 ){
            result16 = (num16*percentageRow)/100;
            if (isNaN((num16*percentageRow))) {
                result16 =0;
             }
            arraymap[i].Allocation_Day_16__c = result16;}

            if((num17 || percentageRow) != 0 ){
            result17 = (num17*percentageRow)/100;
            if (isNaN((num17*percentageRow))) {
                result17 =0;
             }
            arraymap[i].Allocation_Day_17__c = result17;}

            if((num18 || percentageRow) != 0 ){
            result18 = (num18*percentageRow)/100;
            if (isNaN((num18*percentageRow))) {
                result18 =0;
             }
            arraymap[i].Allocation_Day_18__c = result18;}

            if((num19 || percentageRow) != 0 ){
            result19 = (num19*percentageRow)/100;
            if (isNaN((num19*percentageRow))) {
                result19 =0;
             }
            arraymap[i].Allocation_Day_19__c = result19;}

            if((num20 || percentageRow) != 0 ){
            result20 = (num20*percentageRow)/100;
            if (isNaN((num20*percentageRow))) {
                result20 =0;
             }
            arraymap[i].Allocation_Day_20__c = result20;}

            if((num21 || percentageRow) != 0 ){
            result21 = (num21*percentageRow)/100;
            if (isNaN((num21*percentageRow))) {
                result21 =0;
             }
            arraymap[i].Allocation_Day_21__c = result21;}

            if((num22 || percentageRow) != 0 ){
            result22 = (num22*percentageRow)/100;
            if (isNaN((num22*percentageRow))) {
                result22 =0;
             }
            arraymap[i].Allocation_Day_22__c = result22;}

            if((num23 || percentageRow) != 0 ){
            result23 = (num23*percentageRow)/100;
            if (isNaN((num23*percentageRow))) {
                result23 =0;
             }
            arraymap[i].Allocation_Day_23__c = result23;}

            if((num24 || percentageRow) != 0 ){
            result24 = (num24*percentageRow)/100;
            if (isNaN((num24*percentageRow))) {
                result24 =0;
             }
            arraymap[i].Allocation_Day_24__c = result24;}

            if((num25 || percentageRow) != 0 ){
            result25 = (num25*percentageRow)/100;
            if (isNaN((num25*percentageRow))) {
                result25 =0;
             }
            arraymap[i].Allocation_Day_25__c = result25;}

            if((num26 || percentageRow) != 0 ){
            result26 = (num26*percentageRow)/100;
            if (isNaN((num26*percentageRow))) {
                result26 =0;
             }
            arraymap[i].Allocation_Day_26__c = result26;}

            if((num27 || percentageRow) != 0 ){
            result27 = (num27*percentageRow)/100;
            if (isNaN((num27*percentageRow))) {
                result27 =0;
             }
            arraymap[i].Allocation_Day_27__c = result27;}

            if((num28 || percentageRow) != 0 ){
            result28 = (num28*percentageRow)/100;
            if (isNaN((num28*percentageRow))) {
                result28 =0;
             }
            arraymap[i].Allocation_Day_28__c = result28;}

            if((num29 || percentageRow) != 0 ){
            result29 = (num29*percentageRow)/100;
            if (isNaN((num29*percentageRow))) {
                result29 =0;
             }
            arraymap[i].Allocation_Day_29__c = result29;}

            if((num30 || percentageRow) != 0 ){
            result30 = (num30*percentageRow)/100;
            if (isNaN((num30*percentageRow))) {
                result30 =0;
             }
            arraymap[i].Allocation_Day_30__c = result30;}  

            if((num31 || percentageRow) != 0 ){
                result31 = (num31*percentageRow)/100;
                if (isNaN((num31*percentageRow))) {
                    result31 =0;
                 }
             arraymap[i].Allocation_Day_31__c = result31;}              
            
            console.log('result@@'+result1);
            console.log('arraymap 1st field' + arraymap[0].Allocation_Day_1__c);
            tempNewAllocationValue = arraymap[i];
            ///tempNewAllocationValue.Allocation_Day_1__c = result;   
           
            };
              
        component.set("v.pdiData", arraymap);
        helper.calculateTotals(component);
   
}



})