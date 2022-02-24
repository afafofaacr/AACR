/**
 * Created by afaf.awad on 4/22/2021.
 */

({
    buildSponsorsTable: function(cmp){
        cmp.set('v.sponsorColumns', [
            {label: '', type: 'button-icon', initialWidth:40, class:'slds-m-right_none', typeAttributes: { label: 'Delete', name: 'delete', iconName: 'utility:delete', title: 'Click to delete', iconAlternativeText: 'Delete'}},
            {label: '', type: 'button-icon', initialWidth:40, class:'slds-m-left_none', typeAttributes: { label: 'Edit', name: 'edit', iconName: 'utility:edit', title: 'Click to edit', iconAlternativeText: 'Edit'}},
            {label: 'Sponsor Number', fieldName: 'sponsorId', type: 'url', sortable: true,  typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Sponsor', fieldName: 'accountId', type: 'url', sortable: true, typeAttributes: {label: { fieldName: 'accountName' }, target: '_blank'}},
            {label: 'Display As', fieldName: 'Display_As__c', type: 'text', sortable: true},
            {label: 'Level', fieldName: 'Level__c', type: 'text', sortable: true}
        ]);

        let action = cmp.get("c.getSponsorInfo");
        action.setParams({
            "eventId" : cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let sponsors = response.getReturnValue();
                if(sponsors.length > 0) {
                    console.log('returned sponsors = ' + JSON.stringify(sponsors));
                    sponsors.forEach(function (row) {
                        row.accountName = row.Sponsor__r.Name;
                        row.accountId = '/' + row.Sponsor__c;
                        row.sponsorId = '/' + row.Id;
                    });
                }
                cmp.set('v.sponsorsData', sponsors);
                this.sortData(cmp,cmp.get('v.sortedBy'),cmp.get('v.sortDirection'));
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - buildSponsorTable: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - buildSponsorTable: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    },

    setFileAccessSettings: function(cmp, fileId){
        let action = cmp.get("c.setImageToPublic");
        action.setParams({
            "fileId": fileId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('file set to public..');
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: setImageToPublic');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    toggleButtons : function(cmp){

        for(let i=1;i<=3;i++) {
            if(!cmp.find("sponsorField" + i).get("v.value")){
                console.log('sponsor field is blank, disabling button '+ i);
                cmp.find("sponsorBtn"+ i).set("v.disabled", true);
            }else{
                cmp.find("sponsorBtn"+ i).set("v.disabled", false);
            }
        }

        if (cmp.find("levelCheck").get("v.value")) {
            cmp.set('v.isLevelDisabled', true)
            for (let i = 2; i <= 3; i++) {
                console.log('sponsor field is blank, disabling button '+ i);
                cmp.find("sponsorBtn" + i).set("v.disabled", true);
            }
        } else {
            cmp.set('v.isLevelDisabled', false)
        }
    },

    getImage : function (cmp){
        let action = cmp.get("c.getSponsorImages");
        action.setParams({
            "sponsorId": cmp.get("v.sponsorId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let fileId = response.getReturnValue();
                if (fileId) {
                    console.log('fileId == ' + fileId);
                    cmp.find("logoId").set("v.value", fileId);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getImages");
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    sortData: function (cmp, fieldName, sortDirection) {
        let data = cmp.get("v.sponsorsData");
        let reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.sponsorsData", data);
    },

    sortBy: function(field, reverse, primer) {
        let key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    deleteRecord: function(cmp, record){

        let action = cmp.get("c.deleteSponsorRecord");
        action.setParams({
            "sponsorId": record.Id
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    console.log('record deleted!');
                    this.buildSponsorsTable(cmp);
                }
                else{
                    console.log('could not delete record');
                }
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getImages");
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },

    editRecord: function(cmp, record){
        console.log('edit record...');
        cmp.set('v.isSponsorDisabled', false);
        cmp.set('v.sponsorFileId', '');
        cmp.set('v.sponsorId', record.Id);
        cmp.set('v.level', record.Level__c);
        cmp.find('account').set("v.value", record.Sponsor__c);
        cmp.find('displayAs').set("v.value", record.Display_As__c);
        cmp.find('logoUrl').set("v.value", record.Logo_URL__c);
        cmp.find('logoId').set("v.value", record.Logo_Image_Id__c);
        cmp.find('levelNum').set("v.value", record.Level__c);
        cmp.find('event').set("v.value", record.Event__c);
        // cmp.find('event').set("v.value", cmp.get('v.recordId'));
        // cmp.set("v.sponsorFileId", cmp.find("logoId").get("v.value"));
        // console.log('recId= ' + recId.Id);
    },

    validate : function(cmp) {
        console.log('validating fields...');
        let isValid = true;

        let validateField = auraId => {
            var field = cmp.find(auraId);
            var fieldVal = field.get("v.value");
            if (!fieldVal) {
                $A.util.addClass(field, 'slds-has-error');
                return false;
            } else {
                $A.util.removeClass(field, 'slds-has-error');
                return true;
            }

        }

        let account = validateField('account');
        let displayAs = validateField('displayAs');
        let logoImage = validateField('logoId');
        let logoURL = validateField('logoUrl');

        let file = cmp.find('fileError');
        if (!logoImage) {
            console.log('logoid errored');
            $A.util.removeClass(file, 'slds-hide');
            $A.util.addClass(file, 'slds-show');
        } else {
            $A.util.removeClass(file, 'slds-show');
            $A.util.addClass(file, 'slds-hide');
        }

        if(!account || !logoImage || !displayAs || !logoURL){
            isValid = false;
        }

        return isValid;
    },

    // loadEditForm: function(cmp) {
    //     console.log('sponsorId = ' + cmp.get('v.sponsorId'));
    //         // cmp.find('levelNum').set("v.value", cmp.get('v.level'));
    //         if (cmp.get('v.sponsorId')) {
    //             console.log('sponsor ID exists');
    //             cmp.find('event').set("v.value", cmp.get('v.recordId'));
    //             cmp.set("v.sponsorFileId", cmp.find("logoId").get("v.value"));
    //             // console.log('displayAs ' + cmp.find('displayAs').get("v.value"));
    //         }
    // },




});