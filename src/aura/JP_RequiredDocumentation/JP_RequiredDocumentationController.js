/**
 * Created by lauren.lezberg on 6/3/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('JP_RequiredDocumentation init...');

        var action = cmp.get("c.getRequiredDocuments");
        action.setParams({
            "salesOrderId" : helper.getSalesOrderId(cmp),
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.itemName", data.itemName);
                cmp.set("v.contactId", data.contactId);
                var fileMap = {};
                var fileNames = [];
                data.attachments.forEach(function(att){
                    console.log('attachment: ' + JSON.stringify(att));
                    var fileName = att.Title.substring(0, att.Title.indexOf('.'));
                    fileNames.push(fileName);
                    fileMap[fileName] = att;
                });


                if(data.itemName=='Active Membership' || data.itemName == 'Emeritus Membership'){
                    helper.createFileInput(cmp, 'bibliography', true, 'Bibliography', 'v.fileInput1','Bibliography', fileNames.includes('Bibliography')?fileMap['Bibliography']:null);
                    helper.createFileInput(cmp, 'cv', true, 'Curriculum Vitae', 'v.fileInput2', 'CV', fileNames.includes('CV')?fileMap['CV']:null);
                } else if(data.itemName=='Associate Membership'){
                    helper.createFileInput(cmp, 'bibliography', true, 'Bibliography', 'v.fileInput1','Bibliography',fileNames.includes('Bibliography')?fileMap['Bibliography']:null);
                    helper.createFileInput(cmp, 'cv', true, 'Curriculum Vitae', 'v.fileInput2', 'CV', fileNames.includes('CV')?fileMap['CV']:null);
                }
                else if(data.itemName == 'Affiliate Membership'){
                    helper.createFileInput(cmp, 'bibliography', true, 'Bibliography', 'v.fileInput1','Bibliography', fileNames.includes('Bibliography')?fileMap['Bibliography']:null);
                    helper.createFileInput(cmp, 'cv', true, 'Curriculum Vitae', 'v.fileInput2', 'CV', fileNames.includes('CV')?fileMap['CV']:null);
                    helper.createFileInput(cmp, 'coverLetter', true, 'Cover Letter', 'v.fileInput3', 'CoverLetter', fileNames.includes('CoverLetter')?fileMap['CoverLetter']:null);
                    helper.createFileInput(cmp, 'recommendationLetter', true, 'Recommendation Letter', 'v.fileInput4', 'Recommendation', fileNames.includes('Recommendation')?fileMap['Recommendation']:null);
                }
                else if (data.itemName == 'Student Membership'){
                    helper.createFileInput(cmp, 'resume', true, 'Resume', 'v.fileInput1', 'Resume',fileNames.includes('Resume')?fileMap['Resume']:null);
                    helper.createFileInput(cmp, 'coverLetter', true, 'Cover Letter', 'v.fileInput2', 'CoverLetter', fileNames.includes('CoverLetter')?fileMap['CoverLetter']:null);
                }
            } else if (state === "INCOMPLETE") {
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

    handleNext : function(cmp, event, helper){
        console.log('JP_RequiredDocumentation handleNext...');

        if(cmp.get("v.stepId")!=null){
            if(helper.validate(cmp)) {
                var stepId = event.getParam("stepId");
                var cmpName = event.getParam("cmpName");

                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": stepId});
                navEvt.setParams({"cmpName": cmpName});
                navEvt.fire();
            }
        }
    }


})