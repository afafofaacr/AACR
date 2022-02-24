window.onload = init();
var nominatorIds = new Array('', '');
var nominatorsDetails = new Array();
var contactId, stepId;
var ItemIsNull, IsActiveMembership;
var oldAttachments = new Array();
var attachments = new Array();
var maxFileSize = 2e+6;      	//Setting max file size to 2MB
var chunkSize = 950000;         //Maximum Javascript Remoting message size is 1,000,000 characters
var attachment;
var attachmentName;
var attachmentBody = "";
var fileSize;
var positionIndex;
var doneUploading;
var nextStepUrl;

/*
* Description: Function called on page load to get metadata and decide whether to 
                display single file attachments and validators or two depending on whther user 
                belongs to active membership
*/
function init(){
    var url = new URL(window.location.href);
    stepId = url.searchParams.get("id");
    console.log('stepId: ', stepId);
    showLoader();
    /*
    * Method : doInit
    * @stepId : Step Id of membership join / renewal process ( Steps object record Id )
    */
    var options = {
        url : "DW_JPMembershipController.doInit",
        params : [ stepId ]
    };
    callVfRemoting(options).then(
        // success function
        function(result){
            console.log( 'doInit result: ', result );
      
            if(result.isSuccess == true) {
                contactId = result.data["ContactId"];
                console.log('Returned value: ', contactId);
                ItemIsNull = result.data["ItemIsNull"];
                IsActiveMembership = result.data["IsActiveMembership"];
                nextStepUrl = result.data.nextStepUrl;
                if(ItemIsNull == false && IsActiveMembership == true){
                    //document.getElementById('attachment2').style.visibility = 'visible';
                    //Show two attachments if active membership
                    $( "#attachment2" ).show();
                    $( "#secondNominator" ).show();
                    //Pre-fill fields if found records
                    if(typeof result.data["nominatorsInfo"] != 'undefined' && result.data["nominatorsInfo"].length > 0){
                        nominatorsDetails = result.data["nominatorsInfo"];
                        for(var index=0; index<nominatorsDetails.length ; index++){
                            nominatorIds[index] = nominatorsDetails[index].nominatorId;
                            $( "#memberNo"+(index+1) ).val(nominatorsDetails[index].memberNo);
                            $( "#email"+(index+1) ).val(nominatorsDetails[index].email);
                            $( "#status"+(index+1) ).val(nominatorsDetails[index].name + ' has been verified');
                        }
                        if(nominatorsDetails.length == 2){
                            $( "#nextStepBttn" ).attr( 'disabled', false );
                        }
                    }
                    if(typeof result.data["attachments"] != 'undefined' && result.data["attachments"].length > 0){
                        oldAttachments = result.data["attachments"];
                        for(var index=0; index<oldAttachments.length ; index++){
                            //$( "#attachmentName"+(index+1) ).html(oldAttachments[index].name);
                            $( "#attachmentName"+(index+1) ).show();
                            $( "#attachmentName"+(index+1)+" .fileName" ).html( oldAttachments[index].name );
                        }
                    }
                }else if(ItemIsNull == false && IsActiveMembership == false){
                    //document.getElementById('attachment2').style.visibility = 'hidden';
                    //Show only one attachment if not active membership and hide second one
                    $( "#attachment2" ).hide();
                    $( "#secondNominator" ).hide();
                }
                hideLoader();
            } else {
                hideLoader();
                Toaster.showError( result.message, 5000 );
            }       
        },
        // error function
        function(error){
            hideLoader();
            Toaster.showError( error, 5000 );
        }
    );        
}

$( document ).ready( function() {
    /*
    * Validate nominator on click of Verify Nominator button
    */
    $( ".verify-nominator" ).on( "click", function() {
        console.log('verifyNominators', $( this ).parents('.verifyNominatorBlock').find('.status'));
      
        //Reading memberNo and email values
        var nominatorNumber = $( this ).data('id');
        var memberNo = $( this ).parents('.verifyNominatorBlock').find('.memberNo'+nominatorNumber).val();
        var email = $( this ).parents('.verifyNominatorBlock').find('.email'+nominatorNumber).val();
        console.log('values ', memberNo , email, ' nominatorNumber: ', nominatorNumber);
        var btnInstance = $( this );
        showLoader();
        /*
        * Method : verifyNominators
        * @contactId : Contact Id
        * @memberNo : User added member number
        * @email : User added email
        * @nominatorIds[0] : nominator id
        */
        var checkNominator;
        if(nominatorNumber == 1){
            checkNominator = 1;
        }else if(nominatorNumber == 2){
            checkNominator = 0;
        }
        var options = {
            url : "DW_JPMembershipController.verifyNominators",
            params : [ contactId, memberNo , email, nominatorIds[checkNominator] ]
        };
        callVfRemoting(options).then(
            // success function
            function(result){
                console.log( 'verifyNominators result: ', result );

                btnInstance.parents('.verifyNominatorBlock').find('.status').val( result.message );
                if(result.isSuccess == true) {
                    console.log( result.data["NominatorID"] );                        
                    nominatorIds[nominatorNumber-1] = result.data["NominatorID"];                        
                    if(nominatorNumber == 1 && ItemIsNull == false && IsActiveMembership == true) {
                        //document.getElementById('secondNominator').style.display = 'block';
                        
                    } else {
                        //document.getElementById("nextStepBttn").disabled  = false;
                        $( "#nextStepBttn" ).attr( 'disabled', false );
                    }
                    hideLoader();
                } else {
                    nominatorIds[nominatorNumber-1] = '';
                    hideLoader();
                    $( "#nextStepBttn" ).attr( 'disabled', true );
                    Toaster.showError( result.message, 5000 );
                }       
            },
            // error function
            function(error){
                hideLoader();
                Toaster.showError( error, 5000 );
            }
        );        

    } );
    //old attachment delete
    $( '.old-attachment .btn-delete' ).on( 'click', function() {
        var parentElement = $( this ).parent( '.old-attachment' );
        var fileIdxToDelete = parentElement.data( 'fileindex' );
        console.log( "fileIdxToDelete: ", fileIdxToDelete, oldAttachments[ fileIdxToDelete ].id );
        //call back-end method to delete attachment
        if( oldAttachments[ fileIdxToDelete ] && oldAttachments[ fileIdxToDelete ].id ) {
            showLoader();
            var options = {
                url : "DW_JPMembershipController.deleteAttachment",
                params : [ contactId, oldAttachments[ fileIdxToDelete ].id ]
            };
            callVfRemoting(options).then(
                // success function
                function(result){
                    console.log( 'deleteAttachment result: ', result );
                    if( result.isSuccess ) {
                        //after file delete clear file name and hide that div to hide delete button
                        parentElement.find('.fileName').html( '' );
                        parentElement.hide();
                        //as attachment is deleted make it compulsory to upload new so disable next step button
                        $( "#nextStepBttn" ).attr( 'disabled', true );
                        hideLoader();
                    } else {
                        hideLoader();
                        Toaster.showError( result.message, 5000 );
                    }       
                },
                // error function
                function(error){
                    hideLoader();
                    Toaster.showError( error, 5000 );
                }
            );        
        }

    } );
});

/*
* Description: Validate nominator on click of Verify Nominator button
* @baseUrl : Base URL which needs to be modified ( to which extra URL params need to add )
*/
function updateQueryParamsOfURLCustom( baseUrl ) {
    //static query params to add in URL
    var queryParams = [
        {
            key : 'isjoin',
            value : getUrlParam( 'isjoin' )
        }
    ];
    _.each( queryParams, function( param ) {
        var re = new RegExp("([?&])" + param.key + "=.*?(&|$)", "i");
        var separator = baseUrl.indexOf('?') !== -1 ? "&" : "?";
        if (baseUrl.match(re)) {
            baseUrl = baseUrl.replace(re, '$1' + param.key + "=" + param.value + '$2');
        }
        else {
            if( param.value && param.value != '' && param.value != null )
                baseUrl += separator + param.key + "=" + param.value;
        }
    } ); 
    return baseUrl; 
}

/*
* Description: Generalized function to upload attachment
* @fieldName : field name ( of input type file ) to get it's uploaded file details
* @number : Index of attachments list to be sent at back-end when user will navigate to next step
*/
function uploadFile(fieldName, number) {
    console.log('field name: ', fieldName);
    var file = document.getElementById(fieldName).files[0];
    console.log(file);
    if(file != undefined) {
        if(file.size <= maxFileSize) {
            console.log('file type: ' , file.type);
            //restrict file types
            if(file.type == 'application/zip' || file.type == 'zip' || file.type == 'exe'){
                Toaster.showError( "Restricted file type: " + file.type, 5000 );
            }else{
                //chunk file upload in case of bigger files
                attachmentName = file.name;
                console.log('Size in bytes: ', file.size);
                var fileReader = new FileReader();
                fileReader.onloadend = function(e) {
                    attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                    positionIndex=0;
                    console.log("Total Attachment Length: " + fileSize);
                    doneUploading = false;
                    if( fileSize <= positionIndex + chunkSize ) {
                        attachmentBody = attachment.substring(positionIndex);
                        doneUploading = true;
                    } else {
                        attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
                    }
                    attachments[number] = { name : attachmentName, body : attachmentBody};
                    console.log("Uploading " + attachmentBody.length );
                }
                fileReader.onerror = function(e) {
                    Toaster.showError( "There was an error reading the file.  Please try again.", 5000 );
                }
                fileReader.onabort = function(e) {
                    Toaster.showError( "There was an error reading the file.  Please try again.", 5000 );
                }
                
                fileReader.readAsBinaryString(file);  //Read the body of the file
            }
        }else {
            Toaster.showError( "File must be under 2 MB in size.  Your file is too large.  Please try again.", 5000 );
        }
    }else {
        Toaster.showError( "Please select a file", 5000 );
    }
}

/*
* Description: Function called on navigation to next step.
                Attachments are uploaded to contact and
                Relationship records are for applicant and nominee contacts
*/
function nextStep(){
    console.log( 'next step : ', nominatorIds );
    if( ItemIsNull == false && IsActiveMembership == false && attachments.length == 0 && oldAttachments.length == 0 ) {
        Toaster.showError( "Please upload a file", 5000 );
    } else if( ItemIsNull == false && IsActiveMembership == true && attachments.length < 2 && oldAttachments.length < 2) {
        Toaster.showError( "Please upload two files", 5000 );
    } else{
        console.log( 'attachmentBody : ', attachmentBody, ' Name: ', attachmentName );
        showLoader();
        /*
        * Method : nextStep
        * @contactId : Current user contact Id
        * @stepId : Step Id of membership join / renewal process ( Steps object record Id )
        * @attachments : List of attachments to upload
        * @nominatorIds : Nominator Ids ( contact ids )
        */
        var options = {
            url : "DW_JPMembershipController.nextStep",
            params : [ contactId, stepId, attachments, nominatorIds, oldAttachments ]
        };
        callVfRemoting(options).then(
            // success function
            function(result){
                console.log( 'nextStep result: ', result );
          
                if(result.isSuccess == true) {
                    window.location.href = updateQueryParamsOfURLCustom( nextStepUrl );
                    //hideLoader();
                } else {
                    hideLoader();
                    Toaster.showError( result.message, 5000 );
                }       
            },
            // error function
            function(error){
                hideLoader();
                Toaster.showError( error, 5000 );
            }
        );                
    }
}