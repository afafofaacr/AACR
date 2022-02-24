/**
 * Created by lauren.lezberg on 2/28/2019.
 */
({

    /**
     * @purpose Validates nominators and files based on membership type
     * @param cmp
     * @returns {boolean}
     */
    validate : function(cmp){
        console.log('JP_Nominators validate...');

        var isValid = true;
        var itemName = cmp.get("v.itemName");
        if(itemName!='Student Membership') {
            var nom1 = cmp.get("v.nominator1");
            if ($A.util.isEmpty(nom1)) {
                $A.util.addClass(cmp.find("nominator1"), 'customError');
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find("nominator1"), 'customError');
            }

            if (nom1.isVerified == false || nom1.isVerified == '' || nom1.isVerified == undefined) {
                $A.util.addClass(cmp.find("nominator1"), 'customError');
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find("nominator1"), 'customError');
            }

            if(itemName=='Active Membership') {
                var nom2 = cmp.get("v.nominator2");
                if ($A.util.isEmpty(nom2)) {
                    $A.util.addClass(cmp.find("nominator2"), 'customError');
                    isValid = false;
                } else {
                    $A.util.removeClass(cmp.find("nominator2"), 'customError');
                }
                if (nom2.isVerified == false || nom2.isVerified == '' || nom2.isVerified == undefined) {
                    $A.util.addClass(cmp.find("nominator2"), 'customError');
                    isValid = false;
                } else {
                    $A.util.removeClass(cmp.find("nominator2"), 'customError');
                }
            }
        } else {
            //STUDENT MEMBERSHIP
            if(cmp.find("nominatorType").get("v.value") == '' || cmp.find("nominatorType").get("v.value") == null){
                $A.util.addClass(cmp.find('nominatorType'), 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find('nominatorType'), 'slds-has-error');
            }

            if(cmp.find("nominatorName").get("v.value") == '' || cmp.find("nominatorName").get("v.value") == null){
                $A.util.addClass(cmp.find('nominatorName'), 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find('nominatorName'), 'slds-has-error');
            }


            if(cmp.find("nominatorTitle").get("v.value") == '' || cmp.find("nominatorTitle").get("v.value") == null){
                $A.util.addClass(cmp.find('nominatorTitle'), 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find('nominatorTitle'), 'slds-has-error');
            }
        }


        if(cmp.find("requiredDocumentation").get("v.fileInput1")[0]!=undefined && cmp.find("requiredDocumentation").get("v.fileInput1")[0]!=null){
            if(cmp.find("requiredDocumentation").get("v.fileInput1")[0].get("v.fileId")== null || cmp.find("requiredDocumentation").get("v.fileInput1")[0].get("v.fileId")== undefined){
                $A.util.addClass(cmp.find("requiredDocumentation").get("v.fileInput1")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }

        if(cmp.find("requiredDocumentation").get("v.fileInput2")[0]!=undefined && cmp.find("requiredDocumentation").get("v.fileInput2")[0]!=null){
            if(cmp.find("requiredDocumentation").get("v.fileInput2")[0].get("v.fileId")==null || cmp.find("requiredDocumentation").get("v.fileInput2")[0].get("v.fileId")==undefined){
                $A.util.addClass(cmp.find("requiredDocumentation").get("v.fileInput2")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }

        if(cmp.find("requiredDocumentation").get("v.fileInput3")[0]!=undefined && cmp.find("requiredDocumentation").get("v.fileInput3")[0]!=null){
            if(cmp.find("requiredDocumentation").get("v.fileInput3")[0].get("v.fileId")==null || cmp.find("requiredDocumentation").get("v.fileInput3")[0].get("v.fileId")==undefined){
                $A.util.addClass(cmp.find("requiredDocumentation").get("v.fileInput3")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }

        if(cmp.find("requiredDocumentation").get("v.fileInput4")[0]!=undefined && cmp.find("requiredDocumentation").get("v.fileInput4")[0]!=null){
            if(cmp.find("requiredDocumentation").get("v.fileInput4")[0].get("v.fileId")==null || cmp.find("requiredDocumentation").get("v.fileInput4")[0].get("v.fileId")==undefined){
                $A.util.addClass(cmp.find("requiredDocumentation").get("v.fileInput4")[0].find("fileInput"), 'customError');
                isValid = false;
            }
        }


        return isValid;
    },
    

    /**
     * @purpose Retrieves salesOrder id parameter from URL
     * @param cmp
     * @returns {string}
     */
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