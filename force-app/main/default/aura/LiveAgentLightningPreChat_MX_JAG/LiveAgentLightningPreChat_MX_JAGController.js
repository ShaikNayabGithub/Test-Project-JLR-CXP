({
	onInit: function(cmp, evt, hlp) {
        // Get pre-chat fields defined in setup using the prechatAPI component
		var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        // Get pre-chat field types and attributes to be rendered
        var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(prechatFields);

        
        // Make asynchronous Aura call to create pre-chat field components
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldComponents", components);
                }
            }
        );
        
        // Hidden Fields e.g. Opt in
        const prechatHiddenFieldComponentsArray = [];
		prechatHiddenFieldComponentsArray.push(["ui:inputText", {
                "aura:id": "prechatField",
                required: true,
                label: "Opt In",
                disabled: false,
                maxlength: 2,
                class: "LA_Opt_In__c slds-style-inputtext",
                value: "LY"            
        }]);
   
        
        // Make asynchronous Aura call to create pre-chat hidden fields
        $A.createComponents(
            prechatHiddenFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldHiddenComponents", components);
                }
            }
        );		
    },
    
    startButtonClick: function(cmp, evt, hlp) {
  
        JLRChat.prechat.submit(cmp, evt, hlp);
        
    },
    
    tabButtonClick: function(cmp, evt, hlp) {
        const index = evt.target.getAttribute('data-index');
        JLRChat.tabs.activate(index);
    },
    
    tabButtonPressed: function(cmp, evt, hlp) {
        evt.preventDefault();
        const index = evt.target.getAttribute('data-index');        
        
        JLRChat.tabs.activatedByKey(evt, index);
    },    

    accordionButtonPressed: function(cmp, evt, hlp) {
        evt.preventDefault();
		JLRChat.accordion.onKeyPress(evt);        
    },

    accordionButtonClick: function(cmp, evt, hlp) {
	    JLRChat.accordion.onClick(evt);
    },

    agreedClick: function(cmp, evt, hlp) {
	    JLRChat.disclaimer.onJAgree(cmp, evt, hlp);
    },
    
    disAgreedClick: function(cmp, evt, hlp) {
	    JLRChat.disclaimer.onJDisAgree(cmp, evt, hlp);
    },    
    
    scriptsLoaded: function() {
        
    }
});