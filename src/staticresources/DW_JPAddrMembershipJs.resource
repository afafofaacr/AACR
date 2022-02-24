/* 
    TASK: CONTACT DATA VALIDATION AND SUBMISSION FUNCTIONALITY 
    AUTHOR: AJIT (DW)           
*/
// Validate Contact Data on navigation to next step
function validateData() {
    // Remove all error messages
    FormValidator.hideAllErrors();
    
    var isValid = true;
    
    // Email Regex Pattern
    var emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
    //validate salutation field
    var salutationField = $("select[data-api-name='Salutation']");
    if (salutationField.val() == '') {
        FormValidator.showError(salutationField, "Please select salutation");
        isValid = false;
    }   
    // Validate FirstName
    var firstNameField = $("input[data-api-name='FirstName']");
    if (firstNameField.val() == '') {
        FormValidator.showError(firstNameField, "Please enter valid First Name");
        isValid = false;
    }   
    
    // Validate LastName
    var lastNameField = $("input[data-api-name='LastName']");
    if (lastNameField.val() == '') {
        FormValidator.showError(lastNameField, "Please enter valid Last Name");
        isValid = false;
    }   
  
    // Validate Degree Held Field
    var degreesHeld = $("select[data-api-name='Degrees_Held__c']").val();
    if (degreesHeld == null || degreesHeld.length == 0) {
        var errMsg = "Please select education degree (at least 1)";
        var field = $("select[data-api-name='Degrees_Held__c']");
        if (field.parents(".multiSelectPicklistTable").has(".err-msg").length > 0) {
            field.parents(".multiSelectPicklistTable").find(".err-msg").html(errMsg).removeClass("hide");
        } else {
            field.parents(".multiSelectPicklistTable").append("<span class='err-msg'>" + errMsg + "</span>");
        }
        isValid = false;
    }
    
    // Validate Email
    //var emailType = $("select[data-api-name='OrderApi__Preferred_Email_Type__c']").val();
    var emailType = $( 'input[name=primaryemail]:checked' ).val();
    if (emailType != "") {                     
        if (emailType == 'Work') {
            var workEmailField = $("input[data-api-name='OrderApi__Work_Email__c']");
            if (workEmailField.val() == '' || !emailRegex.test(workEmailField.val())) {
                FormValidator.showError(workEmailField, "Please enter valid Work Email Address");
                isValid = false;
            }
        }
        
        if (emailType == 'Personal') {
            var personalEmailField = $("input[data-api-name='OrderApi__Personal_Email__c']");
            if (personalEmailField.val() == '' || !emailRegex.test(personalEmailField.val())) {
                FormValidator.showError(personalEmailField, "Please enter valid Personal Email Address");
                isValid = false;
            }
        } 
    } else {
        var personalEmailField = $("input[data-api-name='OrderApi__Personal_Email__c']");
        FormValidator.showError(personalEmailField, "Please select any primary email : Work or Personal");
        isValid = false;
    }               
    
    // Validate Birthdate
    var birthDateField = $("input[data-api-name='Birthdate']");
    if (birthDateField.val() == '') {
        FormValidator.showError(birthDateField, "Please enter valid Birth date");
        isValid = false;
    }
    
    // Validate Race
    var raceField = $("select[data-api-name='Race__c']");
    if (raceField.val() == '') {
        FormValidator.showError(raceField, "Select valid race");
        isValid = false;
    }

    //validate gender
    var genderField = $("select[data-api-name='Gender__c']");
    if ( genderField.val() == '' ) {
        FormValidator.showError( genderField, "Select valid gender");
        isValid = false;
    }

    // Validate Address Fields
    //var addressType = $("select[data-api-name='Preferred_Address__c']").val();
    var addressType = $( 'input[name=preferredaddress]:checked' ).val();
    console.log( 'addressType: ', addressType );
    if (addressType == 'Business') {
        var mailingCountryCodeField = $("select[data-api-name='MailingCountryCode']");
        if ( mailingCountryCodeField.val() == '' ) {
            FormValidator.showError( mailingCountryCodeField, "Select any country" );
            isValid = false;
        } else { //make state compulsory if country is USA
            var selectedCountry = mailingCountryCodeField.val();
            if( selectedCountry == 'US' ) {
                var mailingStateCodeField = $("select[data-api-name='MailingStateCode']");
                if ( mailingStateCodeField.val() == '' ) {
                    FormValidator.showError( mailingStateCodeField, "Select any state" );
                    isValid = false;
                }
            }                     
        }
    }
    
    if (addressType == 'Home') {
        var otherCountryCodeField = $("select[data-api-name='OtherCountryCode']");
        console.log( 'otherCountryCodeField val: ', otherCountryCodeField.val() );
        if (otherCountryCodeField.val() == '') {
            FormValidator.showError(otherCountryCodeField, "Select any country");
            isValid = false;
        } else { //make state compulsory if country is USA
            var selectedCountry = otherCountryCodeField.val();
            if( selectedCountry == 'US' ) {
                var otherStateCodeField = $("select[data-api-name='OtherStateCode']");
                if ( otherStateCodeField.val() == '' ) {
                    FormValidator.showError( otherStateCodeField, "Select any state" );
                    isValid = false;
                }
            }                     
        }
    }
    //validate institution / company field
    //if affiliated with institution / company and not filled account then through error
    var affiliatedWithSelf = $( '.affiliated-with input' ).val();
    console.log( 'affiliatedWithSelf: ',isAssociatedWithSelf, typeof isAssociatedWithSelf, 'input val: ',$( ".ui-autocomplete-input" ).val() );
    //if( !affiliatedWithSelf && $( "#institutionLookup_hiddenDiv input[type=hidden]" ).val() == '' ) {
    if( isAssociatedWithSelf == 'false' && $( ".ui-autocomplete-input" ).val() == '' ) {
        FormValidator.showError( $( ".autocomplete-field" ), "Please enter valid Institution/Company");
        isValid = false;
    }

    //Validate phone fields
    var phoneType = $("select[data-api-name='OrderApi__Preferred_Phone_Type__c']").val();
    if ( phoneType == 'Home' ) {
        var phoneField = $("input[data-api-name='HomePhone']");
        if (phoneField.val() == '') {
            FormValidator.showError(phoneField, "Enter valid home phone");
            isValid = false;
        }
    }
    if ( phoneType == 'Mobile' ) {
        var phoneField = $("input[data-api-name='MobilePhone']");
        if (phoneField.val() == '') {
            FormValidator.showError(phoneField, "Enter valid mobile phone");
            isValid = false;
        }
    }
    if ( phoneType == 'Work' ) {
        var phoneField = $("input[data-api-name='OrderApi__Work_Phone__c']");
        if (phoneField.val() == '') {
            FormValidator.showError(phoneField, "Enter valid work phone");
            isValid = false;
        }
    }
    
    //Birthdate field validation
    var birthdateField = $(".birthDate");
    console.log( 'birthDate val: ',birthdateField.val(), 'isValidDate: ', isValidDate( birthdateField.val() ) );
    if( !isValidDate( birthdateField.val() ) ) {
        FormValidator.showError(birthdateField, "Enter valid birthdate(mm/dd/yyyy). Maximum year can be 13 years before current");
        isValid = false;
    }

    if( !isValid ) {
        Toaster.showWarning("Please fill all required fields with valid data", 5000);
    }
    return isValid;
}
/*
* Description: Function called on change of "affiliated with" radio button change 
                to populate hidden account id field
* @isAssociatedWithSelfOption : current radio button value ( Boolean - is associated with self or institution )
*/
function affiliatedWithChange( isAssociatedWithSelfOption ) {
    isAssociatedWithSelf = isAssociatedWithSelfOption;
    if( isAssociatedWithSelf == 'true' ) {
        $( '.institutionLookup-wrap' ).hide();   
        //$( ".institution-autocomplete" ).attr( 'readonly', true );                     
        //reset value to previous one
        $( "#institutionLookup_hiddenDiv input[type=hidden]" ).val( currentAccountId );
        $( '.autocomplete-field' ).val( currentAccountName );                    
    } else {
        $( '.institutionLookup-wrap' ).show();
        //$( ".institution-autocomplete" ).attr( 'readonly', false );      
        if( currentAccountName != '' ) {
            if( currentAccountName.indexOf( 'Household' ) !== -1 ) {
                $( '.autocomplete-field' ).val( '' );
                $( "#institutionLookup_hiddenDiv input[type=hidden]" ).val( '' );
            } else {
                $( "#institutionLookup_hiddenDiv input[type=hidden]" ).val( currentAccountId );
                $( '.autocomplete-field' ).val( currentAccountName ); 
            }
        }
    }
}

/*
* Description: Function to remove additional options from given picklist
* @selectApiName : API name of select field
* @optionValuesToRemove : List of options to remove from select list
*/
function removeAdditionalSelectOptions( selectApiName, optionValuesToRemove ) {
    if( $('select[data-api-name="'+selectApiName+'"]').length ) {
        for( cnt = 0; cnt < optionValuesToRemove.length; cnt++ ) {
            var optionElm = $( 'select[data-api-name="'+selectApiName+'"] option[value="'+optionValuesToRemove[ cnt ]+'"]' );
            if( optionElm.length ) {
                optionElm.remove();
            }
        }               
    }
}

/*
* Description: Function to create new account from autocomplete "New Institution / Company" option
*/
function saveNewAccount() {
    console.log( "in saveNewAccount" );
    var accountName = $('#accountName').val();
    console.log( "in saveNewAccount accountName", accountName );
    if( accountName.trim() != '' ) {
        showLoader();
        /*
        * Method : saveAccount
        * @!isJoinProcess : At server side referred isRenewal membership process
        * @salesOrderId : Sales Order Id
        * @stepId : Current step Id of membership join / renewal process ( from Steps object ) 
        */
        var options = {
            url : "DW_JPMembershipCtrl.saveAccount",
            params : [ accountName ] 
        };
        callVfRemoting(options).then(
            // success function
            function(result){
                console.log( 'saveAccount result: ', result );
                if( result.isSuccess && result.data && result.data.Id ) {
                    console.log( "in", $( ".autocomplete-field" ).length, $( ".autocomplete-field" ).val()  );
                    $( "#institutionLookup_hiddenDiv input[type=hidden]" ).val( result.data.Id );
                    $( ".autocomplete-field" ).val( result.data.Name );
                    hideLoader();
                    Toaster.showSuccess( result.message , 5000 );
                    $('#accountName').val( '' ); //clear form
                    hideModal(); //hide modal
                } else {
                    hideLoader();
                    Toaster.showError( result.message , 5000 );
                }          
            },
            // error function
            function(error){
                hideLoader();
                Toaster.showError( error, 5000 );
            }
        );
    } else {
        Toaster.showError( 'Please enter account name' , 5000 );
    }
}

// Validates that the input string is a valid date formatted as "mm/dd/yyyy"
function isValidDate( dateString )
{
    // First check for the pattern
    if( !/^\d{1,2}\/\d{1,2}\/\d{4}$/.test( dateString ) )
        return false;

    // Parse the date parts to integers
    var parts = dateString.split("/");
    var day = parseInt(parts[1], 10);
    var month = parseInt(parts[0], 10);
    var year = parseInt(parts[2], 10);

    // Check the ranges of month and year
    if(year < 1000 || year > 3000 || month == 0 || month > 12)
        return false;

    //custom requirement : date year must not be less than 13 years from current year
    var currentDate = new Date();
    var currentYear = currentDate.getFullYear();
    console.log( 'min year: ', currentYear - 13 );
    if( year > (currentYear - 13) ) {
        return false;
    }
    var monthLength = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

    // Adjust for leap years
    if(year % 400 == 0 || (year % 100 != 0 && year % 4 == 0))
        monthLength[1] = 29;

    // Check the range of the day
    return day > 0 && day <= monthLength[month - 1];
};
/*
* Initialize datepicker for "Birthdate" field
*/
$( window ).on( "load", function() {
    $( ".birthDate" ).attr( { placeholder : "mm/dd/yyyy"}, { title : "mm/dd/yyyy" }, { maxlength : "10" } );
    $( ".birthDate" ).datepicker(
       {
         defaultDate: "+1w",
         changeMonth: true,
         changeYear: true,
         numberOfMonths: 1,
         dateFormat: "mm/dd/yy",
         altFormat: "yy-mm-dd",
         maxDate: '-13Y',
         yearRange: "-80:-13",
    });
} );

$( document ).ready( function() {
    //if affiliated with institution / company then only keep autocomplete field editable 
    console.log( 'isAssociatedWithSelf: ', isAssociatedWithSelf, typeof isAssociatedWithSelf );
    if( isAssociatedWithSelf == 'true' ) {
        //$( '.institution-autocomplete' ).attr( 'readonly', true );
        $( '.institutionLookup-wrap' ).hide();   
    } 
    //only set account name if it does not contain household keyword
    if( currentAccountName != '' ) {
        if( currentAccountName.indexOf( 'Household' ) !== -1 && isAssociatedWithSelf == 'false' ) {
            $( '.autocomplete-field' ).val( '' );
            $( "#institutionLookup_hiddenDiv input[type=hidden]" ).val( '' );
        }
    }
    //remove additional options of Preferred Email Type picklist                
    /*removeAdditionalSelectOptions( 'OrderApi__Preferred_Email_Type__c', [ 'Other', 'Assistant' ] );*/
    //remove additional options of Preferred Phone Type picklist
    removeAdditionalSelectOptions( 'OrderApi__Preferred_Phone_Type__c', [ 'Other', 'Assistant' ] );

    /*
    * On change of primary email radio button populate hidden 
    * actual picklist value of contact field ( OrderApi__Preferred_Email_Type__c )
    */
    $( '.radio-primaryemail' ).on( 'change', function() {
        updateContactField( 'OrderApi__Preferred_Email_Type__c', $( this ).val() ); //call action function from page
    } );

    /*
    * On change of primary address radio button populate hidden 
    * actual picklist value of contact field ( Preferred_Address__c )
    */
    $( '.radio-preferredaddress' ).on( 'change', function() {
        updateContactField( 'Preferred_Address__c', $( this ).val() ); //call action function from page
    } );

    //If got preferredEmailType from server then keep it's respective radio button selected
    console.log( 'preferredEmailType: ', preferredEmailType );
    if( preferredEmailType != '' ) {
        $( '.radio-primaryemail[value="'+preferredEmailType+'"]' ).prop( 'checked', true );
    }
     //If got preferredAddressType from server then keep it's respective radio button selected
    if( preferredAddressType != '' ) {
        $( '.radio-preferredaddress[value="'+preferredAddressType+'"]' ).prop( 'checked', true );
        //depending on primary address selection keep red asterisk visble / hidden
        if( preferredAddressType == 'Business' ) {
            $( '.redaster.MailingCountryCode' ).show();
            if( $( 'select[data-api-name="MailingCountryCode"]' ).val() == 'US' ) {
                $( '.redaster.MailingStateCode' ).show();
            }
        } else if( preferredAddressType == 'Home' ) {
            $( '.redaster.OtherCountryCode' ).show();
            if( $( 'select[data-api-name="OtherCountryCode"]' ).val() == 'US' ) {
                $( '.redaster.OtherStateCode' ).show();
            }
        }
    }
    //keep state field asterisk visible/hidden
    $( '.select-country' ).on( 'change', function() {
        var addressType = $( 'input[name=preferredaddress]:checked' ).val();
        console.log( 'countryVal: ',$( this ).val(), 'addressType',addressType );
        if( addressType == 'Business' ) {
            if( $( 'select[data-api-name="MailingCountryCode"]' ).val() == 'US' ) {
                $( '.redaster.MailingStateCode' ).show();
            } else {
                $( '.redaster.MailingStateCode' ).hide();
            }
        } else if( addressType == 'Home' ) {
            if( $( 'select[data-api-name="OtherCountryCode"]' ).val() == 'US' ) {
                $( '.redaster.OtherStateCode' ).show();
            } else {
                $( '.redaster.OtherStateCode' ).hide();
            }
        }
    } );
    $( '.radio-preferredaddress' ).on( 'change', function() {
        var addressType = $( this ).val();
        console.log( 'countryVal: ',$( this ).val(), 'addressType',addressType );
        if( addressType == 'Business' ) {
            $( '.redaster.MailingCountryCode' ).show();
            $( '.redaster.OtherCountryCode' ).hide();
            var MailingCountryCode = $( 'select[data-api-name="MailingCountryCode"]' ).val();
            
            if( MailingCountryCode == 'US' ) {
                $( '.redaster.MailingStateCode' ).show();
            } else {
                $( '.redaster.MailingStateCode' ).hide();
            }
            $( '.redaster.OtherStateCode' ).hide();
        } else if( addressType == 'Home' ) {
            $( '.redaster.OtherCountryCode' ).show();
            $( '.redaster.MailingCountryCode' ).hide();
            var OtherCountryCode = $( 'select[data-api-name="OtherCountryCode"]' ).val();
            if( OtherCountryCode == 'US' ) {
                $( '.redaster.OtherStateCode' ).show();
            } else {
                $( '.redaster.OtherStateCode' ).hide();
            }
            $( '.redaster.MailingStateCode' ).hide();
        }
    } );
    //on page load keep asterisk phone field visible / hidden depending on primary selection
    var currentPrimaryPhone = $( "select[data-api-name='OrderApi__Preferred_Phone_Type__c']" ).val();
    console.log( "currentPrimaryPhone: ", currentPrimaryPhone );
    if( currentPrimaryPhone != '' ) {
        $( '.redaster.phone.'+currentPrimaryPhone ).show();
    }
    //on page load keep asterisk email field visible / hidden depending on primary selection
    var currentPrimaryEmail = $( "input[name='primaryemail']:checked" ).val();
    if( currentPrimaryEmail != '' ) {
        $( '.redaster.email.'+currentPrimaryEmail ).show();
    }
    //on change of primary email keep asterisk of respective field visible / hidden
    $( ".radio-primaryemail" ).on( "change", function() {
        var currentPrimaryEmail = $( this ).val();
        $( '.redaster.email' ).hide();
        $( '.redaster.email.'+currentPrimaryEmail ).show();
    } );
    //
    $( "select[data-api-name='OrderApi__Preferred_Phone_Type__c']" ).on( "change", function() {
        var currentPrimaryPhone = $( this ).val();
        $( '.redaster.phone' ).hide();
        $( '.redaster.phone.'+currentPrimaryPhone ).show();
    } );
} );