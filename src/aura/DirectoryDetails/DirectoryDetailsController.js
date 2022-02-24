/**
 * Created by lauren.lezberg on 6/5/2019.
 */
({
    getWorkingGroups : function(cmp, event, helper){
        var action = cmp.get("c.getContactWorkingGroups");
        action.setParams({
            "contactId": cmp.get("v.Contact").Id
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            cmp.set("v.workingGroups", result);
        });
        $A.enqueueAction(action);
    },

    emailMember : function(cmp, event, helper){
        var parent = cmp.get("v.parent");
        parent.set("v.emailModalOpen", true);
        var contacts = parent.get("v.Contacts");
        contacts.forEach(function(contact){
           if(contact.Id == cmp.get("v.Contact").Id){
               parent.find("emailModal").set("v.emailAddr", contact.Email); 
           }
        });

        cmp.set("v.isOpen", false);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.isOpen", false);
    },
})