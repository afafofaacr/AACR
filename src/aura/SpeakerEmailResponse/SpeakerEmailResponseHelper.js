/**
 * Created by lauren.lezberg on 2/14/2020.
 */
({

    getSpeakerId : function(cmp){ 
        var name ='speakerId';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            return results[1];
        }

        return false;
    },

    getResponse : function(cmp){
        var name ='response';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            if(results[1] == '1'){
                return true;
            } else {
                return false;
            }
        }

        return false;
    },

    createModal : function(cmp, widget){
        console.log("Creating Component...");
        $A.createComponent(
            "c:DisclosureModal",
            {
                "Widget": widget
            },
            function(pdfViewer, status, errorMessage){
                if (status === "SUCCESS") {
                    var modal = cmp.get("v.disclosureModal");
                    modal.push(pdfViewer);
                    cmp.set("v.disclosureModal", modal);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }
    
})