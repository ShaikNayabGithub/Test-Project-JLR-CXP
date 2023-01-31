({
myAction : function(component, event, helper) {

},
modelAdjust :function(component, event, helper){
var evt = $A.get("e.force:navigateToComponent");      
evt.setParams({
componentDef:"c:VME_Model_Adjustment",
});

evt.fire();
},
categoryAdjust : function(component, event, helper){
var evt = $A.get("e.force:navigateToComponent");      
evt.setParams({
componentDef:"c:VME_Category_Adjustment",
});

evt.fire();
}
})