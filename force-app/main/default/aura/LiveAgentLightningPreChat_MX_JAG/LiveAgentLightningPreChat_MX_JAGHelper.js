({
    /**
     * Create an array in the format $A.createComponents expects.
     *
     * Example:
     * [["componentType", {attributeName: "attributeValue", ...}]]
     *
     * @param prechatFields - Array of prechat field Objects.
     * @returns Array that can be passed to $A.createComponents
     */
    getPrechatFieldAttributesArray: function (prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        // For each field, prepare the type and attributes to pass to $A.createComponents.
        prechatFields.forEach(function (field) {
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
        
            
            if (field.label == 'Opt In') {
                var componentInfoArray = ["ui:" + componentName];
                var attributes         = {
                    "aura:id": "prechatField",
                    required : field.required,
                    label    : field.label,
                    disabled : field.readOnly,
                    maxlength: field.maxLength,
                    class    : field.className,
                    value    : "GB"
                };
            } else {
                var componentInfoArray = ["ui:" + componentName];
                var attributes         = {
                    "aura:id": "prechatField",
                    required : field.required,
                    label    : field.label,
                    disabled : field.readOnly,
                    maxlength: field.maxLength,
                    class    : field.className,
                    value    : field.value
                };
                // Special handling for options for an input:select (picklist) component.
                if (field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
            }
            // Append the attributes Object containing the required attributes to render this prechat field.            
            componentInfoArray.push(attributes);
            // Append this componentInfoArray to the fieldAttributesArray.
            if (field.label != 'Opt In' && field.label != 'Country ISO Code' ) {
                prechatFieldsInfoArray.push(componentInfoArray);
            }
        });
        return prechatFieldsInfoArray;
    }
,


    getHiddenPrechatFieldAttributesArray: function (consent) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        // For each field, prepare the type and attributes to pass to $A.createComponents.
        var input                  = consent;
        var componentName          = "inputText";

        var componentInfoArray = ["ui:" + componentName];
        var attributes         = {
            "aura:id": "prechatField",
            required : true,
            label    : "Opt In",
            disabled : false,
            maxlength: 2,
            class    : "LA_Opt_In__c slds-style-inputtext",
            value    : input
        };
        // Append the attributes Object containing the required attributes to render this prechat field.            
        componentInfoArray.push(attributes);
        // Append this componentInfoArray to the fieldAttributesArray.

        prechatFieldsInfoArray.push(componentInfoArray);

        return prechatFieldsInfoArray;
    }
});