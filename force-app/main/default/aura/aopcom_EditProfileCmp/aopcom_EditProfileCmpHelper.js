({
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
  			return alert('Image file not supported');
		}
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            component.set("v.urlPortrait", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
            $('#image').attr('src', reader.result); 
            
        };
        reader.readAsDataURL(file);
        console.log(reader);
	},
    
    upload: function(component, file, base64Data) {
        var action = component.get("c.saveAttachment"); 
        var res;
        action.setParams({
            parentId: component.get("v.contactId"),
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type
        });
        action.setCallback(this, function(a) {
            
            

        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action); 
    }

})