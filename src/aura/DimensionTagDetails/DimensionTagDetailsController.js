/**
 * Created by afaf.awad on 6/7/2021.
 */

({
    doInit: function(cmp,event,helper){
        let myPageRef = cmp.get("v.pageReference");
        let dimTagId = myPageRef.state.c__dimTagId;
        let objectName = myPageRef.state.c__objectName;
        console.log('doInit TagDetails...' + JSON.stringify(dimTagId));
        cmp.set("v.dimTagId", dimTagId);
        helper.getDetails(cmp,dimTagId);

    },

    goToSubTab : function(cmp, event, helper) {
        console.log('goToSubTab...');
        let action = event.getParam('action');
        let row = event.getParam('row');
        let object = cmp.get('v.DimTag').Object__c.toLowerCase();
        let workspaceAPI = cmp.find("workspace");

        console.log('row = ' + JSON.stringify(row));
        console.log('action = ' + JSON.stringify(action));
        //Open respective tab based on which column button was pushed: TagName or ConvertedTag?
        if(action.label.fieldName == 'deleteIcon'){
            //do nothing
        }else if(action.label.fieldName == 'tagName') {
            workspaceAPI.openTab({
                pageReference: {
                    "type": "standard__recordPage",
                    "attributes": {
                        recordId: row.link,
                        objectApiName: object,
                        actionName: "view",
                    }
                },
                focus: true
            }).catch(function (error) {
                console.log(error);
            });
        }else{
                workspaceAPI.openTab({
                    pageReference: {
                        "type": "standard__component",
                        "attributes": {
                            "componentName": "c__DimensionTagDetails" ,
                        },
                        "state": {
                            "c__dimTagId" : row.convertedTag.Id,
                            "c__objectName" : row.convertedTag.Object__c
                        }
                    },
                    focus: true
                }).then(function(response) {
                    console.log(response);
                    workspaceAPI.setTabLabel({
                        tabId: response,
                        label: ' ' + row.convertedTag.Label + ' Details'
                    });
                    workspaceAPI.setTabIcon({
                        tabId: response,
                        icon: "action:new_task",
                        iconAlt: "Tag List Details"
                    });
                }).catch(function(error) {
                    console.log('Error opening new tab: ' + error);
                });

            }
    },

    callActionCmp : function(cmp,event,helper){
        let cmpName = event.getSource().getLocalId();
        cmp.set("v.actionCmp", []);

        $A.createComponent(
            "c:DimensionTag" + cmpName,
            {
                "DimTag": cmp.get('v.DimTag'),
                "aura:id": 'actionCmp'
            },
            function (actionCmp, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var cmpInput = cmp.get("v.actionCmp");
                    cmpInput.push(actionCmp);
                    cmp.set("v.actionCmp", cmpInput);
                } else if (status === "INCOMPLETE") {
                    console.log("Could not create component: No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Could not create component: Error - " + errorMessage);
                }
            });
    },

    handleDimTagEvent : function(cmp,event,helper){
        let action = event.getParam('action');

        if(action == 'destroy') {
            cmp.find("actionCmp").destroy();
            helper.getDetails(cmp, cmp.get('v.DimTag').Id);
        }else if(action == 'refresh'){
            helper.getDetails(cmp, cmp.get('v.DimTag').Id);
        }
    },

    exportData : function(cmp,event,helper){
            cmp.set('v.processing', true);
            let exportType = event.getSource().getLocalId();
            let detailsData = cmp.get('v.detailsData');
            let ids = [];
            detailsData.forEach(function (row){
                ids.push(row.Object_Lookup__r.Id);
            });
            console.log('ids == ' + JSON.stringify(ids));
            helper.getDetailsToExport(cmp, JSON.stringify(ids), exportType);
    },

    handleSort : function (cmp,event,helper){
        let fieldName = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        console.log('fieldName to Sort : ' + fieldName);
        console.log('sortedDirection = ' + sortDirection);
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },

    handleHeaderAction: function (cmp, event, helper) {
        // Retrieves the name of the selected filter
        let actionName = event.getParam('action').name;
        let colDef = event.getParam('columnDefinition');
        console.log('ColDef = ' + JSON.stringify(colDef));
        let columns = cmp.get('v.columns');
        let idx = columns.indexOf(colDef);
        // Update the column definition with the updated actions data
        let actions = columns[idx].actions;
        actions.forEach(function (action) {
            action.checked = action.name === actionName;
        });
        console.log('coldef.name == ' + colDef.name);

        if(colDef.label == 'Delete Requested'){
            console.log('Inside If statement..');
            cmp.set('v.flagFilter', actionName);
            let cTag = cmp.get('v.cTagFilter');
            helper.filterData(cmp,actionName, cTag);
        }else{
            cmp.set('v.cTagFilter', actionName);
            let flag = cmp.get('v.flagFilter');
            console.log('flag == ' + flag);
            helper.filterData(cmp,flag, actionName);
        }

        cmp.set('v.columns', columns);
    },

    handleNext : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        helper.getDetails(component, component.get('v.dimTagId'));
    },

    handlePrev : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        helper.getDetails(component, component.get('v.dimTagId'));
    },

});