/**
 * Created by afaf.awad on 10/7/2021.
 */

({
    updateLists : function(cmp, dragValue, clientY) {
        let fieldList = cmp.get('v.fieldOptions');
        let dropList = cmp.get('v.dropFields');
        let dragIdx = dropList.findIndex(bl => bl.dragId == dragValue) == -1 ? dropList.length : dropList.findIndex(bl => bl.dragId == dragValue);
        let matchedField = dropList.find(d => d.dragId == dragValue); //if there is a matched value do not add to droplist (avoiding duplicates)

        // console.log('dropList == ' + JSON.stringify(dropList));
        console.log('dragIdx == ' + dragIdx);
        console.log('dragValue == ' + dragValue);
        console.log('clientY == ' + clientY);

        for (let i = 0; i < fieldList.length; i++) {
            if (fieldList[i].dragId == dragValue && !matchedField) {
                dropList.push(fieldList[i]);
                console.log('field being added == ' + JSON.stringify(fieldList[i]));

                //splice field from field options if it's a unique field. Need to call parent to find appropriate list
                // to splice, because body fields are broken out into 3 sections.
                if (fieldList[i].isUnique__c) {
                    this.callDragDropEvent(cmp, fieldList[i]);
                }
            }
        }
        console.log('calling sorting method...');
        console.log('dropList after fieldList loop= ' + JSON.stringify(dropList));
        // cmp.set('v.dropFields', dropList); //set droplist to setup for sorting list
        console.log('calling sorting method...');
        cmp.set('v.dropFields', this.sortList(cmp,dragValue,dragIdx, clientY, dropList));

    },

    sortList : function(cmp, dragValue, dragIdx, clientY, dropList){
        console.log('in sort list................');
        // console.log('sortList dropList = ' + JSON.stringify(dropList));

        let arraymove = (arr, fromIndex, toIndex) => {
            var element = arr[fromIndex];
            console.log('element from Array == ' + JSON.stringify(element));
            arr.splice(fromIndex, 1);
            // console.log('arr from Index = ' + JSON.stringify(arr.length));
            arr.splice(toIndex, 0, element);
            // console.log('arr to Index = ' + JSON.stringify(arr.length));
            return arr;
        }

        let sortStaticFields = arr => {
            if(cmp.get('v.dragCategory') == 'Footer') {
                let currentIndex = arr.findIndex(a => a.API_Name__c == 'FooterButton');
                arraymove(arr, currentIndex, arr.length - 1);

                currentIndex = arr.findIndex(a => a.API_Name__c == 'FooterCaptcha');
                arraymove(arr, currentIndex, arr.length - 2);
            }
            return arr;
        }

        if (dropList.length > 2) {
            console.log('calling getDragAfterElement...');
            let afterElement = this.getDragAfterElement(cmp, dragValue, clientY);
            console.log('afterElement = ' + JSON.stringify(afterElement));

            if (afterElement != null) {
                // console.log('droplist before afterElement == ' + JSON.stringify(dropList));
                let toIndex = dropList.findIndex(df => df.dragId == afterElement.element);
                console.log('toIndex == ' + toIndex);
                toIndex = toIndex < 0 ? dropList.length - 1 : toIndex;
                //call event and send element that needs to be removed from appropriate list, array = array[dragIdx].fieldCategory
                console.log('dragIndex = ' + dragIdx + ' and toIndex = ' + toIndex);
                dropList = arraymove(dropList, dragIdx, toIndex); //put the element in the right order of array.
                dropList = sortStaticFields(dropList); // THIS IS ONLY FOR STATIC FIELDS THAT SHOULD NOT MOVE FROM THEIR DEFAULT POSITION.
                // console.log('bodyFieldSet FINAL == ' + JSON.stringify(dropFieldSet));
            }
        }
        
        console.log('setting drop List after sort');
        return dropList;
    },

    getDragAfterElement : function (cmp,dragValue, y) {
        let draggableElements = cmp.find('dragSort');

        for (let i = 0; i < draggableElements.length; i++) {
            if(draggableElements[i].getElement() == null) {
                draggableElements.splice(i, 1);
            }
        }

        // console.log('draggableElements == ' + draggableElements.length);
        return draggableElements.reduce((closest, child) => {
            // console.log('child == ' + child.getElement());
            // console.log('closest == ' + JSON.stringify(closest));
            if(child.getElement() == null){ return null;}
            // console.log('child name == ' + JSON.stringify(child.getElement().title));
            const box = child.getElement().getBoundingClientRect();
            const offset = y - box.top - box.height / 2;
            // console.log('box== ' + JSON.stringify(box));
            // console.log('offset == ' + offset);
            // console.log('closest.offset == ' + closest.offset);
            if (offset < 0 && offset > closest.offset) {
                console.log('return on reduce = ' + JSON.stringify({ offset: offset, element: child.getElement().id}) );
                return { offset: offset, element: child.getElement().id};
            } else {
                console.log(('returning closest == ' + JSON.stringify(closest)));
                return closest;
            }
        }, { offset: Number.NEGATIVE_INFINITY });

    },

    callDragDropEvent : function (cmp, element){
        var appEvent = $A.get("e.c:WF_AppEvent");
        appEvent.setParams({
            'fieldElement' : element,
        });
        appEvent.fire();
    },

    deleteRecord : function(cmp,record){
        console.log('deleting record...' + record);
        let action = cmp.get("c.deleteSQRecord");
        action.setParams({
            sqId: record,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {

                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: deleteRecord');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - deleteRecord: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in deleteRecord");
                }
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    }


});