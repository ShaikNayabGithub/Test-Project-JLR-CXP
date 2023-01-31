({
	doInit : function(component, event, helper) {
    if($A.get("{!$Label.c.VME_Show_Configure_Btn}")==="true"){
      component.set('v.showConfigure', true);
     }else{
      component.set('v.showConfigure', false);
     }
   
          var parentCamp = JSON.parse(JSON.stringify(component.get("v.parentVMECampaign")));
      helper.getRecordTypeIdParSch(component, event, helper);
      var showConfigure=component.get("v.showConfigure");
    if( component.get("v.containBaseScheme")==true &&( parentCamp.RecordType.Name =='Tactical' || parentCamp.RecordType.Name =='Regular')) {
        helper.showToast(component, event, helper,'Already Base L3 Campaign is existed!', 'Please create ModelWise or DerivativeWise L3 Campaign.', 'warning', 'info_alt');
                     
    }
    var catSubCatLabel = $A.get("{!$Label.c.Error_Message_Record_greater_than_Limit}");
    var catSubCatList = catSubCatLabel.split(',');
    for (var i = 0; i < catSubCatList.length; i++) {
      if(parentCamp.VME_External_ID__c.includes(catSubCatList[i])){
        component.set('v.TradeIn', true);
        component.set("v.schemeApplicable",'ModelWise'); 
        component.set("v.discreationaryVME",true); 
        break;
      }
    }
    if(parentCamp.VME_External_ID__c.includes('-OFB-')){
      component.set('v.OFBCheck', true);
      component.set("v.schemeApplicable",'ModelWise'); 
      component.set("v.discreationaryVME",true); 
    }
      var day = 60 * 60 * 24 * 1000;
      var todayDate =new Date();
      var  tomorrow =  $A.localizationService.formatDate(new Date(todayDate.getFullYear(),todayDate.getMonth(),todayDate.getDate()).getTime() + day, "YYYY-MM-DD");

     var parStartDate = new Date(parentCamp.VME_Start_Date__c);
      
      if(((todayDate.getTime() + day)>parStartDate.getTime()) && !showConfigure){
          component.set("v.minDate",tomorrow); 
      }else{
        component.set("v.minDate",parentCamp.VME_Start_Date__c); 
      }

        component.set("v.maxDate",parentCamp.VME_End_Date__c); 
      
      if((component.get("v.parameterName")==$A.get("{!$Label.c.Revise_VME_Parameter}") || component.get("v.parameterName")==$A.get("{!$Label.c.Modify_VME_Parameter}"))  ){
            var revisedScheme = JSON.parse(JSON.stringify(component.get("v.revisedScheme")));
       var action = component.get("c.getBundeling");
                action.setParams({
                "scheme": revisedScheme,
                "model" :parentCamp.VME_Model__c
            });
        action.setCallback(this, function(response) {
            var result =response.getReturnValue();
            if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
                   if(revisedScheme.VME_Scheme_Type__c =='Others' && result==1){
          component.set("v.schemeApplicable",'ModelWise'); 
          component.set("v.discreationaryVME",true); 
         }
          if(revisedScheme.VME_Scheme_Type__c =='Others' && result==2){
          component.set("v.schemeApplicable",'DerivativeWise'); 
          component.set("v.discreationaryVME",true); 
         }
         if(revisedScheme.VME_Scheme_Type__c =='Others' && result==0){
          component.set("v.schemeApplicable",'DerivativeWise'); 
          component.set("v.discreationaryVME",false); 
         }
            if(revisedScheme.VME_Scheme_Type__c =='Base'){
          component.set("v.schemeApplicable",'ModelWise'); 
          component.set("v.discreationaryVME",true); 
         }
            if(component.get("v.parameterName")==$A.get("{!$Label.c.Modify_VME_Parameter}")){
                 component.set("v.schemeId",revisedScheme.Id);  
            }
            if(parentCamp.RecordType.Name !='Tactical' && parentCamp.RecordType.Name !='Regular' &&   component.get('v.TradeIn')==false &&  component.get('v.OFBCheck')==false){
              component.set("v.schemeApplicable",'DerivativeWise'); 
              component.set("v.discreationaryVME",true);
               component.set("v.isOpenComp",true); 
          }
          if( component.get('v.TradeIn')==true){
            component.set('v.TradeIn', true);
            component.set("v.schemeApplicable",'ModelWise'); 
            component.set("v.discreationaryVME",true); 
          }
          if(component.get('v.OFBCheck')==true){
            component.set('v.OFBCheck', true);
            component.set("v.schemeApplicable",'ModelWise'); 
            component.set("v.discreationaryVME",true); 
          }
            helper.convertAmountValue(component, event, helper,revisedScheme.CurrencyIsoCode);
            }else{
                   helper.showToast(component, event, helper, 'Something went wrong!!!', 'Please  contact administrator.', 'error', 'info_alt');
      
            }
        });
        $A.enqueueAction(action);
     
        }
        if(parentCamp.RecordType.Name !='Tactical' && parentCamp.RecordType.Name !='Regular'  &&   component.get('v.TradeIn')==false &&  component.get('v.OFBCheck')==false){
          component.set("v.schemeApplicable",'DerivativeWise'); 
          component.set("v.discreationaryVME",true);
           component.set("v.isOpenComp",true); 
      }
      
	},


	closeConfirmModel: function(component, event, helper) {
   if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
       helper.refreshCategoryPage(component, event, helper);
       }
       if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
       helper.refreshAdjustmentPage(component, event, helper);
     }
        },
        handleSubmit: function(component, event, helper) {
          var showConfigure=component.get("v.showConfigure");
                event.preventDefault();
                var fields = event.getParam("fields");
                var error = false;
              var recTypeId =   component.get("v.recordTypeId");
              fields["RecordTypeId"]=recTypeId;
                if (fields["VME_Start_Date__c"] === "" || fields["VME_End_Date__c"] === "" || fields["VME_JLR_Share__c"] === "" || fields["VME_PU_Amount__c"] === "" ||  fields["VME_Volume__c"] === "" || fields["VME_Start_Date__c"] === null || fields["VME_End_Date__c"] === null || fields["VME_JLR_Share__c"] === null || fields["VME_PU_Amount__c"] === null || fields["VME_Volume__c"] === null) {
                        helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill all the required fields', 'error', 'info_alt');
                        error = true;
                }
                if ( Number(fields["VME_PU_Amount__c"]) < 1 || Number(fields["VME_Volume__c"]) <1 ) {
                        helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'The P/U Amount and Volume should not be less than 1.', 'error', 'info_alt');
                        error = true;
                }
                 if (Number(fields["VME_JLR_Share__c"]) < 0) {
                        helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'The JLR share should not be less than zero.', 'error', 'info_alt');
                        error = true;
                }
                  if (Number(fields["VME_JLR_Share__c"])>100) {
                        helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'The JLR share should not be greater than 100.', 'error', 'info_alt');
                        error = true;
                }
                var ParentCamp = JSON.parse(JSON.stringify(component.get("v.parentVMECampaign")));
                if (ParentCamp.VME_Start_Date__c > fields["VME_Start_Date__c"] || ParentCamp.VME_End_Date__c < fields["VME_End_Date__c"] || ParentCamp.VME_End_Date__c < fields["VME_Start_Date__c"] || ParentCamp.VME_Start_Date__c > fields["VME_End_Date__c"]) {
                        helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'The Start Date and End Date should be in between the ' + ParentCamp.VME_Start_Date__c + ' and ' + ParentCamp.VME_End_Date__c + ' of VME Campaign.', 'error', 'info_alt');
                        error = true;
                }
                if (fields["VME_Start_Date__c"]>fields["VME_End_Date__c"]  ) {
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'The Start Date should be less than the  End Date ', 'error', 'info_alt');
                        error = true; 
                }
                  if ((fields["VME_Market_Arrival_Start_Date__c"]!=null && fields["VME_Market_Arrival_Start_Date__c"]!="" && (fields["VME_Market_Arrival_End_Date__c"]==null || fields["VME_Market_Arrival_End_Date__c"]=="" )) || ((fields["VME_Market_Arrival_Start_Date__c"]==null || fields["VME_Market_Arrival_Start_Date__c"]=="") && fields["VME_Market_Arrival_End_Date__c"]!=null && fields["VME_Market_Arrival_End_Date__c"]!="" )) {
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill Market Arrival Start Date and  Market Arrival End Date correctly. ', 'error', 'info_alt');
                        error = true; 
                }
               if(fields["VME_Market_Arrival_Start_Date__c"]>fields["VME_Market_Arrival_End_Date__c"]) {
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Market Arrival Start Date should be less than  Market Arrival End Date ', 'error', 'info_alt');
                        error = true; 
                }
                if ((fields["VME_Manufacturing_Start_Date__c"]!=null && fields["VME_Manufacturing_Start_Date__c"]!="" && (fields["VME_Manufacturing_End_Date__c"]==null || fields["VME_Manufacturing_End_Date__c"]=="" )) || ((fields["VME_Manufacturing_Start_Date__c"]==null || fields["VME_Manufacturing_Start_Date__c"]=="") && fields["VME_Manufacturing_End_Date__c"]!=null && fields["VME_Manufacturing_End_Date__c"]!="" )) {
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill Manufacturing  Start Date or  Manufacturing  End Date correctly. ', 'error', 'info_alt');
                        error = true; 
                }
                  if ( fields["VME_Manufacturing_Start_Date__c"]>fields["VME_Manufacturing_End_Date__c"]) {
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Manufacturing Start Date should be less than  Manufacturing End Date. ', 'error', 'info_alt');
                        error = true; 
                }
                if((fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null ) && component.get("v.containBaseScheme")==true && component.get("v.schemeApplicable")=='ModelWise'   &&   component.get('v.TradeIn')==false  &&  component.get('v.OFBCheck')== false){
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Base L3 Campaign is already existed.Please fill the L3 Description.', 'error', 'info_alt');
                        error = true; 
                }
                  if((fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null )  && component.get("v.schemeApplicable")=='DerivativeWise' ){
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill the L3 Description.', 'error', 'info_alt');
                        error = true; 
                }
                 if( fields["VME_Trade_In__c"]  !=null && fields["VME_Trade_In__c"]  !="" && component.get('v.TradeIn') ==true   && (fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null ) && component.get("v.schemeApplicable")=='ModelWise' ){
                   helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill the L3 Description.', 'error', 'info_alt');
                        error = true; 
                }
                if(( fields["VME_Segment__c"]  !=null || fields["VME_Segment__c"]  !="") && ( fields["VME_Sub_Division__c"]  !=null || fields["VME_Sub_Division__c"]  !="") && component.get('v.OFBCheck') ==true   && (fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null ) && component.get("v.schemeApplicable")=='ModelWise' ){
                  helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill the L3 Description.', 'error', 'info_alt');
                       error = true; 
               }
               if( ((fields["VME_Segment__c"]  ==null || fields["VME_Segment__c"]  =="") &&  (fields["VME_Sub_Division__c"]  ==null || fields["VME_Sub_Division__c"]  =="") )&& component.get('v.OFBCheck') ==true  && component.get("v.schemeApplicable")=='ModelWise' ){
                helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill the Segment/Sub-Division values.', 'error', 'info_alt');
                     error = true; 
             }
                if( (fields["VME_Trade_In__c"]  ==null || fields["VME_Trade_In__c"]  =="") && component.get('v.TradeIn') ==true  && component.get("v.schemeApplicable")=='ModelWise' ){
                  helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill the TradeIn Value.', 'error', 'info_alt');
                       error = true; 
               }
             if(((fields["VME_Manufacturing_Start_Date__c"]!=null && fields["VME_Manufacturing_Start_Date__c"]!="" &&  fields["VME_Manufacturing_End_Date__c"]!=null && fields["VME_Manufacturing_End_Date__c"]!="") || (fields["VME_Market_Arrival_Start_Date__c"]!=null && fields["VME_Market_Arrival_Start_Date__c"]!="" && fields["VME_Market_Arrival_End_Date__c"]!=null && fields["VME_Market_Arrival_End_Date__c"]!="")) && (fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null ) && component.get("v.schemeApplicable")=='ModelWise' ){
                 helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'You are creating a modelWise L3 Campaign.Please fill the L3 Description.', 'error', 'info_alt');
                       error = true; 
              }
                  var day = 60 * 60 * 24 * 1000;
                 var todayDate =new Date();
                 var  tomorrow =  $A.localizationService.formatDate(new Date(todayDate.getFullYear(),todayDate.getMonth(),todayDate.getDate()).getTime() + day, "YYYY-MM-DD");
                    if ((fields["VME_Start_Date__c"]<tomorrow || fields["VME_End_Date__c"]<tomorrow ) && !(showConfigure)) {
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Start Date and End Date should be greater than today.', 'error', 'info_alt');
                        error = true; 

              }
                 if(component.get("v.parameterName")==$A.get("{!$Label.c.Revise_VME_Parameter}") || component.get("v.parameterName")==$A.get("{!$Label.c.Modify_VME_Parameter}") ){

                var revisedScheme = JSON.parse(JSON.stringify(component.get("v.revisedScheme")));
                fields["VME_Scheme_Type__c"] =revisedScheme.VME_Scheme_Type__c;
                  var conversionRate =    component.get("v.conversionRate");
                  fields["VME_PU_Amount__c"] = fields["VME_PU_Amount__c"]  * conversionRate;
                  if( fields["VME_Scheme_Type__c"] =='Others' && (fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null ) && component.get("v.schemeApplicable")=='ModelWise' && component.get('v.TradeIn') ==false && component.get('v.OFBCheck') ==false){
                     helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill L3 Description.', 'error', 'info_alt');
                        error = true; 
                  }
  
              }
              if(!error){
                 if((fields["VME_Level_3_Description__c"] === "" || fields["VME_Level_3_Description__c"] === null ) && component.get("v.schemeApplicable")=='ModelWise' && component.get('v.TradeIn') ==false && component.get('v.OFBCheck') ==false){
                //Take confirmation for creating base scheme
                     error = true;    
                     Swal.fire({
                      title: "Are you sure?",
                     text: "Do you want to create a Base L3 VME Campaign, click OK .",
                  showCancelButton: true,
                  cancelButtonColor: '#d33'
                })
                .then((result) => {
                  if (result.value) {
                         fields["VME_Scheme_Type__c"] ='Base';
                     helper.saveNewScheme(component, event, helper);
                  } else {
                          error = true;    
                  }
                });
                                
                     
                }
              }
                if (!error) {
                  if(component.get("v.schemeApplicable")=='ModelWise' && component.get('v.TradeIn') ==false && component.get('v.OFBCheck') ==false && (ParentCamp.RecordType.Name=='Tactical' || ParentCamp.RecordType.Name=='Regular') && ((fields["VME_Manufacturing_Start_Date__c"] ==null || fields["VME_Manufacturing_Start_Date__c"] =="") && (fields["VME_Manufacturing_End_Date__c"]==null || fields["VME_Manufacturing_End_Date__c"]=="" )) && ((fields["VME_Market_Arrival_Start_Date__c"]==null || fields["VME_Market_Arrival_Start_Date__c"]=="") && (fields["VME_Market_Arrival_End_Date__c"]==null || fields["VME_Market_Arrival_End_Date__c"]=="") )) 
                  {     
                    Swal.fire({
                            title: "Do you want to Continue?",
                        text: "It seems you didn't filled Manufacturing Date/MarketArrival Date.Please fill dates or select the retailers from Retailer Mix. ",
                        type: "warning",
                   showCancelButton: true,
                   confirmButtonColor:'#3085d6',
                   cancelButtonColor:  '#d33',
                   confirmButtonText: 'Select Retailers',
                    })
                    .then((result) => {
                        if (result.value) {
                          if(component.get("v.parameterName")==$A.get("{!$Label.c.Revise_VME_Parameter}")){
                            helper.endScheme(component, event, helper);
                       }
                       if(component.get("v.parameterName")==$A.get("{!$Label.c.New_VME_Parameter}") ){
                        fields["VME_Scheme_Type__c"] ='Others';
                          helper.saveNewScheme(component, event, helper);
                       }
                       if(component.get("v.parameterName")==$A.get("{!$Label.c.Modify_VME_Parameter}")){
                        helper.saveNewScheme(component, event, helper);
                      }
         
                        } else {
                          
                        }
                    });
                         }else{
                          if(component.get("v.parameterName")==$A.get("{!$Label.c.Revise_VME_Parameter}")){
                            helper.endScheme(component, event, helper);
                       }
                       if(component.get("v.parameterName")==$A.get("{!$Label.c.New_VME_Parameter}") ){
                        fields["VME_Scheme_Type__c"] ='Others';
                          helper.saveNewScheme(component, event, helper);
                       }
                       if(component.get("v.parameterName")==$A.get("{!$Label.c.Modify_VME_Parameter}")){
                        helper.saveNewScheme(component, event, helper);
                      }
         
                         }
                     
            
                }
        },


        handleSuccess: function(component, event, helper) {
                var record = event.getParam("response");
           if( (record.fields.VME_Level_3_Description__c.value===null || record.fields.VME_Level_3_Description__c.value=='') && record.fields.VME_Scheme_Type__c.value=='Base' && component.get("v.schemeApplicable")=='ModelWise' ){
              helper.showToast(component, event, helper, 'Base L3 VME Campaign is created successfully.', 'Record is  created.', 'success', 'info_alt');
                      if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                  helper.refreshCategoryPage(component, event, helper);
                    }
                   if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                            helper.refreshAdjustmentPage(component, event, helper);
                 }
                       
                }else if( (record.fields.VME_Level_3_Description__c.value !=null  &&  record.fields.VME_Level_3_Description__c.value !='') && record.fields.VME_Scheme_Type__c.value=='Others' && component.get("v.schemeApplicable")=='ModelWise' && ((component.get('v.TradeIn') ==true && record.fields.VME_Trade_In__c.value!=null) || (component.get('v.OFBCheck') ==true &&  record.fields.VME_Segment__c.value!=null &&  record.fields.VME_Sub_Division__c.value!=null) )){
                 // helper.showToast(component, event, helper, 'L3 VME Campaign is created successfully.', 'Record is  created.', 'success', 'info_alt');
                 helper.callNextScreenOnSave(component, event, helper,record.id,filters,record.fields.VME_Trade_In__c.value, record.fields.VME_Segment__c.value, record.fields.VME_Sub_Division__c.value);                    
                    } else{
                  var filters =false;
                  if((record.fields.VME_Manufacturing_Start_Date__c.value!=null &&  record.fields.VME_Manufacturing_Start_Date__c.value!='') || (record.fields.VME_Market_Arrival_Start_Date__c.value!=null && record.fields.VME_Market_Arrival_Start_Date__c.value!='') && component.get('v.TradeIn') ==false && component.get('v.OFBCheck') ==false){
                      filters=true;
                    }
              helper.callNextScreenOnSave(component, event, helper,record.id,filters,record.fields.VME_Trade_In__c.value, record.fields.VME_Segment__c.value, record.fields.VME_Sub_Division__c.value);
          }
          
        },


        handleError: function(component, event, helper) {
                helper.showToast(component, event, helper, 'Something went wrong!!!', 'Please scroll up to check the error or contact administrator.', 'error', 'info_alt');
        },

   
      handlerefreshCmpEvt :function(component,event,helper){
        component.set("v.Spinner", false);
       component.set("v.isOpenComp", false);
        },
            showSpinnerApex: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinnerApex : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }

})