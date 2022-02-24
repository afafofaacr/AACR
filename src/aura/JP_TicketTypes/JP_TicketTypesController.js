/**
 * Created by lauren.lezberg on 11/11/2019.
 */
({
    doInit : function(cmp, event, helper){
        // console.log('doInit...');
        var action = cmp.get("c.getTicketTypes");
        action.setParams({
            "eventId" : helper.getEventId(cmp, event)
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.allSegments", data.userSegments);

                var selectedIds = [];
                var selectedSegments = [];
                
                if(data.ticketTypes!=null) {
                    data.ticketTypes.forEach(function (type) {
                        if (type.EBPrice != null && type.EBDate != null) {
                            type.EB = true;
                        }
                        if (type.ODPrice != null && type.ODDate != null) {
                            type.OD = true;
                        }
                        selectedSegments.push(type);
                        selectedIds.push(type.Id);
                    });
                }

                cmp.set("v.selectedSegments",selectedSegments);

                var availableSegments = [];
                if(selectedIds.length>0){
                    data.userSegments.forEach(function(segment){
                        if(!selectedIds.includes(segment.Id)) {
                            availableSegments.push(segment);
                        }
                    });
                } else {
                    availableSegments = data.userSegments;
                }

                cmp.set("v.availableSegments", availableSegments);

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:getTicketTypes');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    selectUserSegment : function(cmp, event, helper){
        var selectedSegmentId = event.getSource().get("v.value");
        var availableSegments = cmp.get("v.availableSegments");
        var selectedSegment = {};
        var selectedIdx = 0;

        //find selected segment from available segments
        availableSegments.forEach(function(segment, idx){

            if(segment.Id == selectedSegmentId){
                selectedSegment = segment;
                selectedIdx = idx;
            }
        });
        availableSegments.splice( selectedIdx ,1);

        //remove selected segment from available list
        cmp.set("v.availableSegments", availableSegments);

        //create new selected segment obj
        var newSegment = {};
        newSegment.Id = selectedSegment.Id;
        newSegment.Name = selectedSegment.Name;
        newSegment.Price = 0.0;
        newSegment.Priority = 0;
        newSegment.EBPrice = null;
        newSegment.EBDate = null;
        newSegment.DietPreferences = null;
        
        //add to selected segment list
        var selectedSegments = cmp.get("v.selectedSegments");
        selectedSegments.push(newSegment);
        cmp.set("v.selectedSegments", selectedSegments);

        //save old segments
        helper.saveTicketTypes(cmp, event, false);

    },

    removeUserSegment : function(cmp, event, helper){
        var selectedSegmentId = event.getSource().get("v.value");
        //console.log('selectedSegmentId: ' + selectedSegmentId);

        var allSegments = cmp.get("v.allSegments");
        var selectedSegment = {};
        var selectedIdx = 0;

        //find selected segment from available segments
        allSegments.forEach(function(segment){
            if(segment.Id == selectedSegmentId){
                selectedSegment = segment;
            }
        });

        var availableSegments = cmp.get("v.availableSegments");
        availableSegments.push(selectedSegment);
        cmp.set("v.availableSegments", availableSegments);

        var selectedSegments = cmp.get("v.selectedSegments");
        selectedSegments.forEach(function(segment, idx){
            if(segment.Id == selectedSegmentId){
                selectedIdx = idx;
            }
        });
        selectedSegments.splice( selectedIdx,1);

        //remove selected segment from available list
        cmp.set("v.selectedSegments", selectedSegments.sort());

        //save old segments
        helper.saveTicketTypes(cmp, event, false);

    },

    createEvent : function(cmp, event, helper){
        helper.saveTicketTypes(cmp, event, true); 
    },

    onStepChange:function(cmp, event, helper){
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");
        
        helper.saveTicketTypes(cmp, event, false);

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();
    }
})