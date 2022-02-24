/**
 * Created by lauren.lezberg on 9/22/2020.
 */

({
    doInit : function(cmp, event, helper){
        var newImgTemplate = {};
        newImgTemplate.Is_Default__c = false;
        newImgTemplate.Is_Active__c = false;
        newImgTemplate.MasterLabel = '';
        newImgTemplate.Image_URL__c = '';
        newImgTemplate.Header_Text__c = '';
        newImgTemplate.Image_Text__c = '';
        newImgTemplate.Image_Link__c = '';
        cmp.set("v.newImgTemplate", newImgTemplate);
        helper.getBannerImages(cmp, event);
    },

    updateVisibility : function(cmp, event, helper){
        var action = cmp.get("c.saveImageSegments");
        action.setParams({
            "imgId" : cmp.get("v.selectedId"),
            "jsonString" : JSON.stringify(cmp.get("v.selectedSegments"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                // var data = response.getReturnValue();
                // cmp.set("v.imgs", data);
                cmp.set("v.showVisibility", false);
                cmp.set("v.selectedId", null);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "Visibility has been successfully updated."
                });
                toastEvent.fire();

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error",
                    "message": "Visibility could not be updated."
                });
                toastEvent.fire();
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error",
                    "message": "Visibility could not be updated."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    openVisibility : function(cmp, event, helper){

        var imgId = event.getSource().get("v.value");

        var action = cmp.get("c.getImageSegmentIds");
        action.setParams({
            "imgId" : imgId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                var data = response.getReturnValue();
                cmp.set("v.selectedSegments", data);
                cmp.set("v.selectedId", imgId);
                cmp.set("v.showVisibility", true);

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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

    closeVisibility : function(cmp, event, helper){
        cmp.set("v.showVisibility", false);
        cmp.set("v.selectedId", null);
    },


    updateIntervalSeconds: function(cmp, event, helper){
        var action = cmp.get("c.setBannerInterval");
        action.setParams({
            "seconds" : cmp.get("v.intervalSeconds")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                // var data = response.getReturnValue();
                // cmp.set("v.imgs", data);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "The job has been submitted successfully."
                });
                toastEvent.fire();

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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

    deleteImg : function(cmp, event, helper){
        var imgId = event.getSource().get("v.value");
        console.log("imgId: " + imgId);
        var selectedImg = {};
        var imgs = cmp.get("v.imgs");

        imgs.forEach(function(img){
            if(img.Id == imgId){
                selectedImg = img;
            }
        });

        var action = cmp.get("c.deleteBannerImage");
        action.setParams({
            "img" : selectedImg,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                var data = response.getReturnValue();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "Image has been deleted."
                });
                toastEvent.fire();

                cmp.set("v.imgs", data);

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error.",
                    "message": 'Error deleting image.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    addNewImage : function(cmp, event, helper){

        console.log("addNewimage: " + JSON.stringify(cmp.get("v.newImgTemplate")));
        var action = cmp.get("c.createBannerImage");
        action.setParams({
            "img" : cmp.get("v.newImgTemplate"),
            "jsonString" : JSON.stringify(cmp.get("v.selectedSegments"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                // var data = response.getReturnValue();
                // cmp.set("v.imgs", data);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "The job has been submitted successfully."
                });
                toastEvent.fire();

                var imgs = cmp.get("v.imgs");
                if(imgs==undefined){
                    imgs = [];
                }
                imgs.push(cmp.get("v.newImgTemplate"));

                cmp.set("v.imgs", imgs);

                cmp.set("v.modalOpen", false);

                // setTimeout(function(){
                //     this.getBannerImages(cmp, event);
                // },10000);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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

    openModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", true);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", false);
    },

    deactivateBannerImages : function(cmp, event, helper){
        var imgs = [];
        cmp.get("v.imgs").forEach(function(img){
            if(!img.Is_Default__c){
                img.Is_Active__c = false;
            } else {
                img.Is_Active__c = true;
            }
            imgs.push(img);
        });
        cmp.set("v.imgs", imgs);
        helper.deactivateAll(cmp, event);

    },

    updateImage : function(cmp, event, helper){
        var imgId = event.getSource().get("v.value");
        console.log("imgId: " + imgId);
        var selectedImg = {};
        var imgs = cmp.get("v.imgs");

        imgs.forEach(function(img){
            if(img.Id == imgId){
                selectedImg = img;
            }
        });

        cmp.set("v.imgs", imgs);

        helper.updateImage(cmp, selectedImg);
    },

    makeDefault : function(cmp, event, helper){
        var imgId = event.getSource().get("v.value");

        var oldDefault = {};
        var newidx = 0;
        var newDefault = {};
        var imgs = cmp.get("v.imgs");

        imgs.forEach(function(img, idx){
            if(img.Id == imgId){
                img.Is_Default__c = true;
                newDefault = img;
                newidx = idx;
            } else if(img.Is_Default__c){
                img.Is_Default__c = false;
                oldDefault = img;
            }

        });

        imgs[0] = newDefault;
        imgs[newidx] = oldDefault;

        cmp.set("v.imgs", imgs);

        helper.updateImage(cmp, oldDefault);
        helper.updateImage(cmp, newDefault);


    },

    activateBannerImage : function(cmp, event, helper){
        var imgId = event.getSource().get("v.value");
        console.log("imgId: " + imgId);
        var selectedImg = {};
        var imgs = cmp.get("v.imgs");

        var counter = 0;

        imgs.forEach(function(img){
            if(img.Is_Active__c){
                counter+= 1;
            }
            if(img.Id == imgId){
                if(img.Is_Active__c){
                    img.Is_Active__c = false;
                } else {
                    img.Is_Active__c = true;
                }
                selectedImg = img;
            }
        });

        console.log('counter: ' + counter);
        console.log('seleceted: ' + JSON.stringify(selectedImg));

        if(!selectedImg.Is_Active__c && counter == 1){
            //TODO: throw error, you cannot deactivate the default while its the only one active
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "warning",
                "title": "Error",
                "message": "You cannot deactivate the only active image."
            });
            toastEvent.fire();
        } else {

            cmp.set("v.imgs", imgs);

            helper.updateImage(cmp, selectedImg);
        }

    }
});