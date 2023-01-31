({
    doInit : function(component, event, helper){
        helper.fetchAllNotes(component, event, helper);
    },
    showCreateRecord:function(component, event, helper){
        var newCandidate = {'sobjectType': 'ContentNote',
                            'Title': '',
                            'Content': ''
                           };
        component.set("v.note",newCandidate);
        component.set("v.showNewModal",true);
    },
    
    create : function(component, event, helper) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        var NewNote = component.get("v.note");
        if(NewNote.Title != null && NewNote.Title !='')
        {
            //Calling the Apex Function
            var action = component.get("c.createRecord");
            //Setting the Apex Parameter
            action.setParams({
                nt : NewNote,
                PrentId : component.get("v.recordId")
            });
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                //check if result is successfull
                if(state == "SUCCESS"){
                    //Reset Form
                    var newCandidate = {'sobjectType': 'ContentNote',
                                        'Title': '',
                                        'Content': ''
                                       };
                    //resetting the Values in the form
                    component.set("v.note",newCandidate);
                    helper.fetchAllNotes(component, event, helper);
                } else if(state == "ERROR"){
                    alert('Error in calling server side action');
                }
            });
            component.set("v.showNewModal",false);
            //adds the server-side action to the queue        
            $A.enqueueAction(action);
        }
    },
    
    closeModel : function (component, event, helper) {
        component.set("v.showNewModal",false); 
    },
    
    showEditNote: function (component, event, helper) {
        var indexId=event.target.id;
        const allNotes=component.get("v.ListOfNotes");
        let selectedNote=allNotes[indexId];
        let note=component.get("v.note");
        note=selectedNote.objNote;
        note.Content=selectedNote.Content;
        component.set("v.note",note);
        component.set("v.showNewModal",true); 
    },
    
    Delete: function (component, event, helper) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        var action = component.get("c.deleteNote"); 
        action.setParams({
            nt: component.get("v.note")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.fetchAllNotes(component, event, helper);
            }
            else if(state === "ERROR"){
                console.log('A problem occurred: ' + JSON.stringify(response.error));
            }
        });
        component.set("v.showNewModal",false);
        $A.enqueueAction(action);
    }
})