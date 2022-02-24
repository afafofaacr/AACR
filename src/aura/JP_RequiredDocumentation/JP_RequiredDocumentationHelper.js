/**
 * Created by lauren.lezberg on 6/3/2019.
 */
({
    createFileInput : function(cmp, inputId, required, label, attributeName, fileNameOverride, file){
        console.log('JP_RequiredDocumentation createFileInput...');

        $A.createComponent(
            "c:JP_FileUpload",
            {
                "aura:id": inputId,
                "inputLabel": label,
                "required": required,
                "fileName" : file!=null?file.Title:fileNameOverride,
                "fileNameOverride" : fileNameOverride,
                "fileId" : file!=null?file.Id:null,
                "contentDocumentId" : file!=null?file.ContentDocumentId:null,
                "uploadDate" : file!=null?file.LastModifiedDate:null,
                "fileCategory" : 'JoinProcess - ' + fileNameOverride,
                "recordId" : cmp.get("v.contactId")
            },
            function(fileCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var fileInput = cmp.get(attributeName);
                    fileInput.push(fileCmp);
                    cmp.set(attributeName, fileInput);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },

    validate : function(cmp){
        console.log('JP_RequiredDocumentation validate...');

        var isValid = true;

        if(cmp.get("v.fileInput1")[0]!=undefined && cmp.get("v.fileInput1")[0]!=null && cmp.get("v.fileInput1")[0]!={}){
            if(cmp.get("v.fileInput1")[0].get("v.fileId")== null){
                $A.util.addClass(cmp.get("v.fileInput1")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }

        if(cmp.get("v.fileInput2")[0]!=undefined && cmp.get("v.fileInput2")[0]!=null){
            if(cmp.get("v.fileInput2")[0].get("v.fileId")==null){
                $A.util.addClass(cmp.get("v.fileInput2")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }

        if(cmp.get("v.fileInput3")[0]!=undefined && cmp.get("v.fileInput3")[0]!=null){
            if(cmp.get("v.fileInput3")[0].get("v.fileId")==null){
                $A.util.addClass(cmp.get("v.fileInput3")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }

        if(cmp.get("v.fileInput4")[0]!=undefined && cmp.get("v.fileInput4")[0]!=null){
            if(cmp.get("v.fileInput4")[0].get("v.fileId")==null){
                $A.util.addClass(cmp.get("v.fileInput4")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }


        return isValid;
    },

    getSalesOrderId : function(cmp){
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId=results[1];
        return SOId;
    },

})