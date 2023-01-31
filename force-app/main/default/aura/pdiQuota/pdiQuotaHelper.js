({
	calculateTotals: function(component) {
		var totalDay1 = 0;
		var totalDay2 = 0;
		var totalDay3 = 0;
		var totalDay4 = 0;
		var totalDay5 = 0;
		var totalDay6 = 0;
		var totalDay7 = 0;
		var totalDay8 = 0;
		var totalDay9 = 0;
		var totalDay10 = 0;
		var totalDay11 = 0;
		var totalDay12 = 0;
		var totalDay13 = 0;
		var totalDay14 = 0;
		var totalDay15 = 0;
		var totalDay16 = 0;
		var totalDay17 = 0;
		var totalDay18 = 0;
		var totalDay19 = 0;
		var totalDay20 = 0;
		var totalDay21 = 0;
		var totalDay22 = 0;
		var totalDay23 = 0;
		var totalDay24 = 0;
		var totalDay25 = 0;
		var totalDay26 = 0;
		var totalDay27 = 0;
		var totalDay28 = 0;
		var totalDay29 = 0;
		var totalDay30 = 0;
		var totalDay31 = 0;
		var totalTotal = 0;
		var lineTotalHelper=[] ;
		var arraymap = component.get("v.pdiData");
//		console.log("i am here in helper class before arraymap");
		//console.log(arraymap);
		//console.log(arraymap[1]);
        //console.log("complete arraymap");
		for (var i = 0; i < arraymap.length; i++) {
			var fld = arraymap[i];
			//console.log("field");
			//console.log(fld);
			
			totalDay1 = totalDay1 + parseInt((fld.Allocation_Day_1__c = fld.Allocation_Day_1__c == null ? 0 : fld.Allocation_Day_1__c),10);
			totalDay2 = totalDay2 + parseInt((fld.Allocation_Day_2__c = fld.Allocation_Day_2__c == null ? 0 : fld.Allocation_Day_2__c),10);		
			//console.log(totalDay2);
			totalDay3 = totalDay3 + parseInt((fld.Allocation_Day_3__c = fld.Allocation_Day_3__c == null ? 0 : fld.Allocation_Day_3__c),10);
			totalDay4 = totalDay4 + parseInt((fld.Allocation_Day_4__c = fld.Allocation_Day_4__c == null ? 0 : fld.Allocation_Day_4__c),10);
			totalDay5 = totalDay5 + parseInt((fld.Allocation_Day_5__c = fld.Allocation_Day_5__c == null ? 0 : fld.Allocation_Day_5__c),10);
			totalDay6 = totalDay6 + parseInt((fld.Allocation_Day_6__c = fld.Allocation_Day_6__c == null ? 0 : fld.Allocation_Day_6__c),10);
			totalDay7 = totalDay7 + parseInt((fld.Allocation_Day_7__c = fld.Allocation_Day_7__c == null ? 0 : fld.Allocation_Day_7__c),10);
			totalDay8 = totalDay8 + parseInt((fld.Allocation_Day_8__c = fld.Allocation_Day_8__c == null ? 0 : fld.Allocation_Day_8__c),10);
			totalDay9 = totalDay9 + parseInt((fld.Allocation_Day_9__c = fld.Allocation_Day_9__c == null ? 0 : fld.Allocation_Day_9__c),10);
			totalDay10 = totalDay10 + parseInt((fld.Allocation_Day_10__c = fld.Allocation_Day_10__c == null ? 0 : fld.Allocation_Day_10__c),10);
			totalDay11 = totalDay11 + parseInt((fld.Allocation_Day_11__c = fld.Allocation_Day_11__c == null ? 0 : fld.Allocation_Day_11__c),10);
			totalDay12 = totalDay12 + parseInt((fld.Allocation_Day_12__c = fld.Allocation_Day_12__c == null ? 0 : fld.Allocation_Day_12__c),10);
			totalDay13 = totalDay13 + parseInt((fld.Allocation_Day_13__c = fld.Allocation_Day_13__c == null ? 0 : fld.Allocation_Day_13__c),10);
			totalDay14 = totalDay14 + parseInt((fld.Allocation_Day_14__c = fld.Allocation_Day_14__c == null ? 0 : fld.Allocation_Day_14__c),10);
			totalDay15 = totalDay15 + parseInt((fld.Allocation_Day_15__c = fld.Allocation_Day_15__c == null ? 0 : fld.Allocation_Day_15__c),10);
			totalDay16 = totalDay16 + parseInt((fld.Allocation_Day_16__c = fld.Allocation_Day_16__c == null ? 0 : fld.Allocation_Day_16__c),10);
			totalDay17 = totalDay17 + parseInt((fld.Allocation_Day_17__c = fld.Allocation_Day_17__c == null ? 0 : fld.Allocation_Day_17__c),10);
			totalDay18 = totalDay18 + parseInt((fld.Allocation_Day_18__c = fld.Allocation_Day_18__c == null ? 0 : fld.Allocation_Day_18__c),10);
			totalDay19 = totalDay19 + parseInt((fld.Allocation_Day_19__c = fld.Allocation_Day_19__c == null ? 0 : fld.Allocation_Day_19__c),10);
			totalDay20 = totalDay20 + parseInt((fld.Allocation_Day_20__c = fld.Allocation_Day_20__c == null ? 0 : fld.Allocation_Day_20__c),10);
			totalDay21 = totalDay21 + parseInt((fld.Allocation_Day_21__c = fld.Allocation_Day_21__c == null ? 0 : fld.Allocation_Day_21__c),10);
			totalDay22 = totalDay22 + parseInt((fld.Allocation_Day_22__c = fld.Allocation_Day_22__c == null ? 0 : fld.Allocation_Day_22__c),10);
			totalDay23 = totalDay23 + parseInt((fld.Allocation_Day_23__c = fld.Allocation_Day_23__c == null ? 0 : fld.Allocation_Day_23__c),10);
			totalDay24 = totalDay24 + parseInt((fld.Allocation_Day_24__c = fld.Allocation_Day_24__c == null ? 0 : fld.Allocation_Day_24__c),10);
			totalDay25 = totalDay25 + parseInt((fld.Allocation_Day_25__c = fld.Allocation_Day_25__c == null ? 0 : fld.Allocation_Day_25__c),10);
			totalDay26 = totalDay26 + parseInt((fld.Allocation_Day_26__c = fld.Allocation_Day_26__c == null ? 0 : fld.Allocation_Day_26__c),10);
			totalDay27 = totalDay27 + parseInt((fld.Allocation_Day_27__c = fld.Allocation_Day_27__c == null ? 0 : fld.Allocation_Day_27__c),10);
			totalDay28 = totalDay28 + parseInt((fld.Allocation_Day_28__c = fld.Allocation_Day_28__c == null ? 0 : fld.Allocation_Day_28__c),10);
			totalDay29 = totalDay29 + parseInt((fld.Allocation_Day_29__c = fld.Allocation_Day_29__c == null ? 0 : fld.Allocation_Day_29__c),10);
			totalDay30 = totalDay30 + parseInt((fld.Allocation_Day_30__c = fld.Allocation_Day_30__c == null ? 0 : fld.Allocation_Day_30__c),10);
			totalDay31 = totalDay31 + parseInt((fld.Allocation_Day_31__c = fld.Allocation_Day_31__c == null ? 0 : fld.Allocation_Day_31__c),10);
			
			
			lineTotalHelper[i]= parseInt((fld.Allocation_Day_1__c = fld.Allocation_Day_1__c == null ? 0 : fld.Allocation_Day_1__c),10) +
								parseInt((fld.Allocation_Day_2__c = fld.Allocation_Day_2__c == null ? 0 : fld.Allocation_Day_2__c),10)+
								parseInt((fld.Allocation_Day_3__c = fld.Allocation_Day_3__c == null ? 0 : fld.Allocation_Day_3__c),10)+
								parseInt((fld.Allocation_Day_4__c = fld.Allocation_Day_4__c == null ? 0 : fld.Allocation_Day_4__c),10)+
								parseInt((fld.Allocation_Day_5__c = fld.Allocation_Day_5__c == null ? 0 : fld.Allocation_Day_5__c),10)+
								parseInt((fld.Allocation_Day_6__c = fld.Allocation_Day_6__c == null ? 0 : fld.Allocation_Day_6__c),10)+
								parseInt((fld.Allocation_Day_7__c = fld.Allocation_Day_7__c == null ? 0 : fld.Allocation_Day_7__c),10)+
								parseInt((fld.Allocation_Day_8__c = fld.Allocation_Day_8__c == null ? 0 : fld.Allocation_Day_8__c),10)+
								parseInt((fld.Allocation_Day_9__c = fld.Allocation_Day_9__c == null ? 0 : fld.Allocation_Day_9__c),10)+
								parseInt((fld.Allocation_Day_10__c = fld.Allocation_Day_10__c == null ? 0 : fld.Allocation_Day_10__c),10)+
								parseInt((fld.Allocation_Day_11__c = fld.Allocation_Day_11__c == null ? 0 : fld.Allocation_Day_11__c),10)+
								parseInt((fld.Allocation_Day_12__c = fld.Allocation_Day_12__c == null ? 0 : fld.Allocation_Day_12__c),10)+
								parseInt((fld.Allocation_Day_13__c = fld.Allocation_Day_13__c == null ? 0 : fld.Allocation_Day_13__c),10)+
								parseInt((fld.Allocation_Day_14__c = fld.Allocation_Day_14__c == null ? 0 : fld.Allocation_Day_14__c),10)+
								parseInt((fld.Allocation_Day_15__c = fld.Allocation_Day_15__c == null ? 0 : fld.Allocation_Day_15__c),10)+
								parseInt((fld.Allocation_Day_16__c = fld.Allocation_Day_16__c == null ? 0 : fld.Allocation_Day_16__c),10)+
								parseInt((fld.Allocation_Day_17__c = fld.Allocation_Day_17__c == null ? 0 : fld.Allocation_Day_17__c),10)+
								parseInt((fld.Allocation_Day_18__c = fld.Allocation_Day_18__c == null ? 0 : fld.Allocation_Day_18__c),10)+
								parseInt((fld.Allocation_Day_19__c = fld.Allocation_Day_19__c == null ? 0 : fld.Allocation_Day_19__c),10)+
								parseInt((fld.Allocation_Day_20__c = fld.Allocation_Day_20__c == null ? 0 : fld.Allocation_Day_20__c),10)+
								parseInt((fld.Allocation_Day_21__c = fld.Allocation_Day_21__c == null ? 0 : fld.Allocation_Day_21__c),10)+
								parseInt((fld.Allocation_Day_22__c = fld.Allocation_Day_22__c == null ? 0 : fld.Allocation_Day_22__c),10)+
								parseInt((fld.Allocation_Day_23__c = fld.Allocation_Day_23__c == null ? 0 : fld.Allocation_Day_23__c),10)+
								parseInt((fld.Allocation_Day_24__c = fld.Allocation_Day_24__c == null ? 0 : fld.Allocation_Day_24__c),10)+
								parseInt((fld.Allocation_Day_25__c = fld.Allocation_Day_25__c == null ? 0 : fld.Allocation_Day_25__c),10)+
								parseInt((fld.Allocation_Day_26__c = fld.Allocation_Day_26__c == null ? 0 : fld.Allocation_Day_26__c),10)+
								parseInt((fld.Allocation_Day_27__c = fld.Allocation_Day_27__c == null ? 0 : fld.Allocation_Day_27__c),10)+
								parseInt((fld.Allocation_Day_28__c = fld.Allocation_Day_28__c == null ? 0 : fld.Allocation_Day_28__c),10)+
								parseInt((fld.Allocation_Day_29__c = fld.Allocation_Day_29__c == null ? 0 : fld.Allocation_Day_29__c),10)+
								parseInt((fld.Allocation_Day_30__c = fld.Allocation_Day_30__c == null ? 0 : fld.Allocation_Day_30__c),10)+
								parseInt((fld.Allocation_Day_31__c = fld.Allocation_Day_31__c == null ? 0 : fld.Allocation_Day_31__c),10)	;

			console.log('line total is'+lineTotalHelper[i]);
			arraymap[i].lineTotal = lineTotalHelper[i]

		}
        
		totalTotal =
			totalTotal +
			totalDay1 +
			totalDay2 +
			totalDay3 +
			totalDay4 +
			totalDay5 +
			totalDay6 +
			totalDay7 +
			totalDay8 +
			totalDay9 +
			totalDay10 +
			totalDay11 +
			totalDay12 +
			totalDay13 +
			totalDay14 +
			totalDay15 +
			totalDay16 +
			totalDay17 +
			totalDay18 +
			totalDay19 +
			totalDay20 +
			totalDay21 +
			totalDay22 +
			totalDay23 +
			totalDay24 +
			totalDay25 +
			totalDay26 +
			totalDay27 +
			totalDay28 +
			totalDay29 +
			totalDay30 +
			totalDay31 			;

        
			component.set("v.pdiData", arraymap);
			component.set("v.totalDay1", totalDay1);
			component.set("v.totalDay2", totalDay2);
			component.set("v.totalDay3", totalDay3);
			component.set("v.totalDay4", totalDay4);
			component.set("v.totalDay5", totalDay5);
			component.set("v.totalDay6", totalDay6);
			component.set("v.totalDay7", totalDay7);
			component.set("v.totalDay8", totalDay8);
			component.set("v.totalDay9", totalDay9);
			component.set("v.totalDay10", totalDay10);
			component.set("v.totalDay11", totalDay11);
			component.set("v.totalDay12", totalDay12);
			component.set("v.totalDay13", totalDay13);
			component.set("v.totalDay14", totalDay14);
			component.set("v.totalDay15", totalDay15);
			component.set("v.totalDay16", totalDay16);
			component.set("v.totalDay17", totalDay17);
			component.set("v.totalDay18", totalDay18);
			component.set("v.totalDay19", totalDay19);
			component.set("v.totalDay20", totalDay20);
			component.set("v.totalDay21", totalDay21);
			component.set("v.totalDay22", totalDay22);
			component.set("v.totalDay23", totalDay23);
			component.set("v.totalDay24", totalDay24);
			component.set("v.totalDay25", totalDay25);
			component.set("v.totalDay26", totalDay26);
			component.set("v.totalDay27", totalDay27);
			component.set("v.totalDay28", totalDay28);
			component.set("v.totalDay29", totalDay29);
			component.set("v.totalDay30", totalDay30);
			component.set("v.totalDay31", totalDay31);
			component.set("v.totalTotal", totalTotal); 
			//component.set("v.lineTotal",lineTotalHelper);
			//console.log('value from linetotal in object' + JSON.stringify((component.get("v.pdiData"))));
			console.log('totalTotalloca'+totalTotal);
			console.log('totalTotalObject'+ component.get("v.totalTotal") );
		},

		getCurrentMonth:function(component) {
		},

		resetPDIQuotaHeader: function(component) {
			component.set("v.num1", '');
			component.set("v.num2", '');
			component.set("v.num3", '');
			component.set("v.num4", '');
			component.set("v.num5", '');
			component.set("v.num6", '');
			component.set("v.num7", '');
			component.set("v.num8", '');
			component.set("v.num9", '');
			component.set("v.num10", '');
			component.set("v.num11", '');
			component.set("v.num12", '');
			component.set("v.num13", '');
			component.set("v.num14", '');
			component.set("v.num15", '');
			component.set("v.num16", '');
			component.set("v.num17", '');
			component.set("v.num18", '');
			component.set("v.num19", '');
			component.set("v.num20", '');
			component.set("v.num21", '');
			component.set("v.num22", '');
			component.set("v.num23", '');
			component.set("v.num24", '');
			component.set("v.num25", '');
			component.set("v.num26", '');
			component.set("v.num27", '');
			component.set("v.num28", '');
			component.set("v.num29", '');
			component.set("v.num30", '');
			component.set("v.num31", '');

		},

		calculateTotalsHelper:function(component) {
			console.log('iam inside dummy function');
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

		console.log('iam inside dummy function 2');
		//console.log('keyname'+Keyname1);
		 //  console.log('keyname'+Keyname1[0].get("v.value") + 'size of keyname1' + Keyname1.length);
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
			let Keyname1 = component.find("PercentageID");
			//debugger;
			//this code is added to fix a problem where the page loads for the first time and that month has only 1 record then 
			//keyname1 throws undefined and it is due to keyname1 will not come as list. However if the page is moved to other months 
			//with more number of records and come back to current month with one record, it returns list
			if (!Array.isArray(Keyname1)){
				console.log('isarray'+ Keyname1.get("v.value"));
				var percentageRow = Keyname1.get("v.value");
				var tempNewAllocationValue ;
				console.log('percentagerow' + percentageRow)

				if((num1 || percentageRow) != 0 ){
				result1 = (num1*percentageRow)/100;
				if (isNaN((num1*percentageRow))) {
					result1 =0;
				 }
				arraymap[0].Allocation_Day_1__c = result1;}
	
				if((num2 || percentageRow)  != 0 ){
					result2 = (num2*percentageRow)/100;
					if (isNaN((num2*percentageRow))) {
						 result2 =0;
					  }
				//result2 = if(isNaN((num2*percentageRow)/100,0), result2 =0) ; 
				arraymap[0].Allocation_Day_2__c = result2;}
	
				if((num3 || percentageRow) != 0 ){
					result3 = (num3*percentageRow)/100;
					if (isNaN((num3*percentageRow))) {
						result3 =0;
					  }
				
				arraymap[0].Allocation_Day_3__c = result3;}
	
				if((num4 || percentageRow) != 0 ){
				result4 = (num4*percentageRow)/100;
				if (isNaN((num4*percentageRow))) {
					result4 =0;
				 }
				arraymap[0].Allocation_Day_4__c = result4;}
	
				if((num5 || percentageRow) != 0 ){
				result5 = (num5*percentageRow)/100;
				if (isNaN((num5*percentageRow))) {
					result5 =0;
				 }
				arraymap[0].Allocation_Day_5__c = result5;}
	
				if((num6 || percentageRow) != 0 ){
				result6 = (num6*percentageRow)/100;
				if (isNaN((num6*percentageRow))) {
					result6 =0;
				 }
				arraymap[0].Allocation_Day_6__c = result6;}
	
				if((num7 || percentageRow) != 0 ){
				result7 = (num7*percentageRow)/100;
				if (isNaN((num7*percentageRow))) {
					result7 =0;
				 }
				arraymap[0].Allocation_Day_7__c = result7;}
	
				if((num8 || percentageRow) != 0 ){
				result8 = (num8*percentageRow)/100;
				if (isNaN((num8*percentageRow))) {
					result8 =0;
				 } 
				arraymap[0].Allocation_Day_8__c = result8;
				}
	
				if((num9 || percentageRow) != 0 ){
				result9 = (num9*percentageRow)/100;
				if (isNaN((num9*percentageRow))) {
					result9 =0;
				 }
				arraymap[0].Allocation_Day_9__c = result9;
				}
	
				if((num10 || percentageRow) != 0 ){
				result10 = (num10*percentageRow)/100;
				if (isNaN((num10*percentageRow))) {
					result10 =0;
				 }
				arraymap[0].Allocation_Day_10__c = result10;
				}
	
				if((num11 || percentageRow) != 0 ){
				result11 = (num11*percentageRow)/100;
				if (isNaN((num11*percentageRow))) {
					result11 =0;
				 }
				arraymap[0].Allocation_Day_11__c = result11;}
	
				if((num12 || percentageRow) != 0 ){
				result12 = (num12*percentageRow)/100;
				if (isNaN((num12*percentageRow))) {
					result12 =0;
				 }
				arraymap[0].Allocation_Day_12__c = result12;}
	
				if((num13 || percentageRow) != 0 ){
				result13 = (num13*percentageRow)/100;
				if (isNaN((num13*percentageRow))) {
					result13 =0;
				 }
				arraymap[0].Allocation_Day_13__c = result13;}
	
				if((num14 || percentageRow) != 0 ){
				result14 = (num14*percentageRow)/100;
				if (isNaN((num14*percentageRow))) {
					result14 =0;
				 }
				arraymap[0].Allocation_Day_14__c = result14;}
	
				if((num15 || percentageRow) != 0 ){
				result15 = (num15*percentageRow)/100;
				if (isNaN((num15*percentageRow))) {
					result15 =0;
				 }
				arraymap[0].Allocation_Day_15__c = result15;}
	
				if((num16 || percentageRow) != 0 ){
				result16 = (num16*percentageRow)/100;
				if (isNaN((num16*percentageRow))) {
					result16 =0;
				 }
				arraymap[0].Allocation_Day_16__c = result16;}
	
				if((num17 || percentageRow) != 0 ){
				result17 = (num17*percentageRow)/100;
				if (isNaN((num17*percentageRow))) {
					result17 =0;
				 }
				arraymap[0].Allocation_Day_17__c = result17;}
	
				if((num18 || percentageRow) != 0 ){
				result18 = (num18*percentageRow)/100;
				if (isNaN((num18*percentageRow))) {
					result18 =0;
				 }
				arraymap[0].Allocation_Day_18__c = result18;}
	
				if((num19 || percentageRow) != 0 ){
				result19 = (num19*percentageRow)/100;
				if (isNaN((num19*percentageRow))) {
					result19 =0;
				 }
				arraymap[0].Allocation_Day_19__c = result19;}
	
				if((num20 || percentageRow) != 0 ){
				result20 = (num20*percentageRow)/100;
				if (isNaN((num20*percentageRow))) {
					result20 =0;
				 }
				arraymap[0].Allocation_Day_20__c = result20;}
	
				if((num21 || percentageRow) != 0 ){
				result21 = (num21*percentageRow)/100;
				if (isNaN((num21*percentageRow))) {
					result21 =0;
				 }
				arraymap[0].Allocation_Day_21__c = result21;}
	
				if((num22 || percentageRow) != 0 ){
				result22 = (num22*percentageRow)/100;
				if (isNaN((num22*percentageRow))) {
					result22 =0;
				 }
				arraymap[0].Allocation_Day_22__c = result22;}
	
				if((num23 || percentageRow) != 0 ){
				result23 = (num23*percentageRow)/100;
				if (isNaN((num23*percentageRow))) {
					result23 =0;
				 }
				arraymap[0].Allocation_Day_23__c = result23;}
	
				if((num24 || percentageRow) != 0 ){
				result24 = (num24*percentageRow)/100;
				if (isNaN((num24*percentageRow))) {
					result24 =0;
				 }
				arraymap[0].Allocation_Day_24__c = result24;}
	
				if((num25 || percentageRow) != 0 ){
				result25 = (num25*percentageRow)/100;
				if (isNaN((num25*percentageRow))) {
					result25 =0;
				 }
				arraymap[0].Allocation_Day_25__c = result25;}
	
				if((num26 || percentageRow) != 0 ){
				result26 = (num26*percentageRow)/100;
				if (isNaN((num26*percentageRow))) {
					result26 =0;
				 }
				arraymap[0].Allocation_Day_26__c = result26;}
	
				if((num27 || percentageRow) != 0 ){
				result27 = (num27*percentageRow)/100;
				if (isNaN((num27*percentageRow))) {
					result27 =0;
				 }
				arraymap[0].Allocation_Day_27__c = result27;}
	
				if((num28 || percentageRow) != 0 ){
				result28 = (num28*percentageRow)/100;
				if (isNaN((num28*percentageRow))) {
					result28 =0;
				 }
				arraymap[0].Allocation_Day_28__c = result28;}
	
				if((num29 || percentageRow) != 0 ){
				result29 = (num29*percentageRow)/100;
				if (isNaN((num29*percentageRow))) {
					result29 =0;
				 }
				arraymap[0].Allocation_Day_29__c = result29;}
	
				if((num30 || percentageRow) != 0 ){
				result30 = (num30*percentageRow)/100;
				if (isNaN((num30*percentageRow))) {
					result30 =0;
				 }
				arraymap[0].Allocation_Day_30__c = result30;}  
	
				if((num31 || percentageRow) != 0 ){
					result31 = (num31*percentageRow)/100;
					if (isNaN((num31*percentageRow))) {
						result31 =0;
					 }
				 arraymap[0].Allocation_Day_31__c = result31;}              
				
				console.log('result@@'+result1);
				console.log('arraymap 1st field' + arraymap[0].Allocation_Day_1__c);
				tempNewAllocationValue = arraymap[0];
				///tempNewAllocationValue.Allocation_Day_1__c = result; 

			}
			else{
				console.log('length is '+Keyname1.length);
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
			   
				}
			};
				  
			component.set("v.pdiData", arraymap);
		}

});