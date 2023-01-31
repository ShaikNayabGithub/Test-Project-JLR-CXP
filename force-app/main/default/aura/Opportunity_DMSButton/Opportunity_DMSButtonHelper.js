/**
 * Created by lbrindle on 03/07/2018.
 */
({
    toastThis : function(message, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title || "Error:",
            "message": message,
            "type": type,
            "mode": "sticky"
        });
        toastEvent.fire();
    }
})