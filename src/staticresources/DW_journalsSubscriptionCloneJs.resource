var pageData = {};
var templateJournals;
var formatedJournals;
var isJoinProcess;
var salesOrderLIsToDelete = [];
var previousDeclinedJournal = '';
/*
* Description : Function to group journals ( type : print online and online only )
*               in one object and get it's price
* @journals : All journals to be formatted
*/
function groupJournalsInRequiredFormat( journals ) {
    var formatedJournals = [];
    //get all journals with type "Print & Online"
    var filteredJournals = _.filter( journals, function( journal ) {
        //console.log( "journal.type: " );
        return journal.type == 'Print & Online';
        //return true;
    } );
    console.log( 'filteredJournals: ', filteredJournals );
    //find same journal with type "Online Only"
    _.each( filteredJournals, function( journal ) {
        var journalName = journal.name;
        var nameArr = journalName.split( "-" );
        if( nameArr.length > 0 ) {
            var mainName = nameArr[0];
            mainName = mainName.trim();
            var compareName = mainName+' - Online';
            var sameOnlineJournal = _.findWhere( journals, { name : compareName, type : 'Online Only' } );
            if( typeof sameOnlineJournal != 'undefined' ) {
                var newJournalObj = {};
                newJournalObj[ 'printOnlineId' ] = journal.Id;
                newJournalObj[ 'onlineId' ] = sameOnlineJournal.Id;
                newJournalObj[ 'displayName' ] = mainName;
                if( journal.price == 0 ) {
                    newJournalObj[ 'printOnlinePrice' ] = 'Free';
                } else {
                    newJournalObj[ 'printOnlinePrice' ] = journal.price;
                }
                if(sameOnlineJournal.price == 0) {
                    newJournalObj[ 'onlinePrice' ] = 'Free';
                } else {
                    newJournalObj[ 'onlinePrice' ] = sameOnlineJournal.price;
                }
                //add
                newJournalObj[ 'printJrHideInJoin' ] = false;
                newJournalObj[ 'printJrDefaultSelectedInJoin' ] = false;
                newJournalObj[ 'onlineJrHideInJoin' ] = false;
                newJournalObj[ 'onlineJrDefaultSelectedInJoin' ] = false;
                if( journal.hideInJoin ) {
                    newJournalObj.printJrHideInJoin = true;
                }
                if( journal.defaultSelectedInJoin ) {
                    newJournalObj.printJrDefaultSelectedInJoin = true;
                }
                if( sameOnlineJournal.hideInJoin ) {
                    newJournalObj.onlineJrHideInJoin = true;
                }
                if( sameOnlineJournal.defaultSelectedInJoin ) {
                    newJournalObj.onlineJrDefaultSelectedInJoin = true;
                }
                formatedJournals.push( newJournalObj );
            }
        }
    } );    
    return formatedJournals;
}
/*
* Description : Function to filter complimentary journals with type "Both"
*               to be displayed in picklist 
* @journals : All journals to be filtered
*/
function filterComplimentaryJournals( journals ) {
    var filteredJournals = _.where( journals, { type : "Both" } );
    if( typeof filteredJournals != 'undefined' ) {
        return filteredJournals;
    } else {
        return journals;
    }
}
/*
* Description : Callback function called after getting page metadata
*               to display journals template on page 
* @journalsData : Page metadata
*/
function getJournalsCallback( journalsData ) {
    pageData = journalsData;
    //undescore template to display data on page
    var tmpl = _.template( templateJournals );
    formatedJournals = groupJournalsInRequiredFormat( pageData.Items.Journal_Subscriptions );
    console.log( 'formatedJournals: ', formatedJournals );
    var complimentaryJournals = filterComplimentaryJournals( pageData.Items.Complimentary_Journals );
    console.log( "Filtered complimentaryJournals:", complimentaryJournals );
    $("#journals_wrap").html( tmpl( { journals: formatedJournals, complementoryJournals : complimentaryJournals, isJoinProcess : isJoinProcess } ) );
    console.log( 'isJoinProcess: ',isJoinProcess );

    //keep selected complementary journal in picklist
    var oldSelectdComplementaryJournals = pageData.Items.Previous_Complimentary_Journals;
    console.log( 'oldSelectdComplementaryJournals: ', oldSelectdComplementaryJournals );

    if( oldSelectdComplementaryJournals && oldSelectdComplementaryJournals.length  ) {
        var oldSelectdComplementaryJournal = oldSelectdComplementaryJournals[ 0 ];
        console.log( 'oldSelectdComplementaryJournal: ', oldSelectdComplementaryJournal );
        var jrArr = oldSelectdComplementaryJournal.protalLabel.split( "-" );
        if( jrArr.length ) {
            var selectedComplementaryJournalName = jrArr[ 0 ].trim();
            $( '.selectComplJournal' ).val( selectedComplementaryJournalName ); 
        }   
        //keep selected complimentary journal filter type ( Online Only / Online & Print ) if added previously         
        var jrType = oldSelectdComplementaryJournal.type;  
        if( jrType ) {
            if( jrType == 'Online Only' ) {
                $( 'input[name=filterOnlineOnly]' ).prop( 'checked',true );
            } else if( jrType == 'Print & Online' ) {
                $( 'input[name=filterOnlineNPrint]' ).prop( 'checked',true );
            }
        }
    }

    //keep selected previously added additional journals
    var oldSelectdAdditionalJournals = pageData.Items.Previous_Journal_Subscriptions;
    if( oldSelectdAdditionalJournals && oldSelectdAdditionalJournals.length ) {
        _.each( oldSelectdAdditionalJournals, function( journal ) {
            $( 'input[data-id="'+journal.Id+'"]' ).prop( "checked", true );
        } );
    } 
    
    //keep isJournalAddrSameAsPreferedAddr checkbox checked depending on previous contact field value
    if( pageData.Contact ) {
        if( pageData.Contact.Is_Journal_Addr_Same_As_Preferred_Addr__c ) {
            $( '.isJournalAddrSameAsPreferedAddr' ).prop( 'checked', true );
        } 
        //only show update journal address link if Is_Journal_Addr_Same_As_Preferred_Addr__c checkbox is unchecked
        if( !pageData.Contact.Is_Journal_Addr_Same_As_Preferred_Addr__c || 
            typeof pageData.Contact.Is_Journal_Addr_Same_As_Preferred_Addr__c == 'undefined' ) {
            $( ".update-address" ).show();
        }   else {
            $( ".update-address" ).hide();
        }    
    }

    //After underscore template loads, bind required events to it's elements
    bindEvents();
    
    //keep checked "Decline Complimentary Journal" if saved previously
    /*if( typeof pageData.Is_Complimentary_Journal_Declined != 'undefined' && 
        pageData.Is_Complimentary_Journal_Declined ) {*/
    if( pageData.Items && pageData.Items.Previous_Declined_Journal && pageData.Items.Previous_Declined_Journal.length ) {
        previousDeclinedJournal = pageData.Items.Previous_Declined_Journal[ 0 ];
        if( previousDeclinedJournal.salesOrderLineItemId && previousDeclinedJournal.salesOrderLineItemId != '' ) {
            $( '.decline-complimentary' ).prop( 'checked', true );
            //check for additional journals visibility and whether to keep complimentary journal editable
            $( '.decline-complimentary' ).trigger( 'change' ); 
        }        
    }
    
    //if membership type is active then onl display complimentary journal components ( select list, filter checkboxes and decline checkbox )
    console.log( 'pageData.membership_type: ',pageData.membership_type );
    if( typeof pageData.membership_type != 'undefined' && pageData.membership_type != 'Active Membership' ) {
        console.log( "innn" );
        $( '.declinecheck-wrap' ).hide();
        $( '.filters-check' ).hide();   
        $( '.selectComplJournal' ).hide();
    }
    
}

$( document ).ready( function() {
    templateJournals = $("#journals_template").html();
    isJoinProcess = getUrlParam( 'isjoin' );
    isJoinProcess = ( isJoinProcess == 'true' || isJoinProcess == null ) ? true : false;
    var salesOrderId = getUrlParam( 'salesorder' );
    var stepId = getUrlParam( 'id' );
    
    showLoader();
    //on page load get all journals and page metadata
    /*
    * Method : getJournals
    * @!isJoinProcess : At server side referred isRenewal membership process
    * @salesOrderId : Sales Order Id
    * @stepId : Current step Id of membership join / renewal process ( from Steps object ) 
    */
    var options = {
        url : "DW_ECRMControllerClone.getJournals",
        params : [ !isJoinProcess, salesOrderId, stepId ] //isRenewal : is dues process or join process
    };
    callVfRemoting(options).then(
        // success function
        function(result){
            console.log( 'getJournals result: ', result );
            if( result.isSuccess ) {
                //using underscore template to display journals list  
                getJournalsCallback( result.data );          
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

    //Keep either of the filter checkbox checked ( "Online Only" or "Onlien & Print" )
    $( ".filterJournals" ).on( 'change', function() {
        var sourceInput = $( this ).attr( 'name' );
        var onlineChecked = false;
        var printOnlineChecked = false;
        if( sourceInput == 'filterOnlineOnly' ) {
            if( $( this ).prop( 'checked' ) ) {
                //make "online and print filter" checkbox uncheck
                $( 'input[name=filterOnlineNPrint]' ).prop('checked', false);
                onlineChecked = true;
            }
        } else {
            if( $( this ).prop( 'checked' ) ) {
                //make online only filter checkbox uncheck
                $( 'input[name=filterOnlineOnly]' ).prop('checked', false);
                printOnlineChecked = true;
            }
        }
        /*
        * Allow to select additional journals only when any complimentary is selected 
        * and it's type checkbox is checked
        */
        checkAdditionalJournalsVisibility();
    } );

    /*
    * If complimentary journal is declined then make complimentary
    * journals picklist and filter checkboxes disabled
    */
    $( ".decline-complimentary" ).on( "change", function() {
        if( $( this ).prop( 'checked' ) ) {
            //if selected complimentary journal is added in sales order line item then add it in delete list
            var complimentoryJournalToFind = $( '.selectComplJournal' ).val();
            if( $( 'input[name=filterOnlineOnly]' ).prop( 'checked' ) ) {
                complimentoryJournalToFind += ' - Online';
            } else if( $( 'input[name=filterOnlineNPrint]' ).prop( 'checked' ) ) {
                complimentoryJournalToFind += ' - Print';
            } 
            var complementaryJournalObj = _.findWhere( pageData.Items.Previous_Complimentary_Journals, { protalLabel : complimentoryJournalToFind } );
            if( typeof complementaryJournalObj != 'undefined' ) { 
                var isAlreadyAdded = _.findWhere( salesOrderLIsToDelete ,{ Id : complementaryJournalObj.Id  } );
                if( typeof isAlreadyAdded == 'undefined' ) {
                    salesOrderLIsToDelete.push( complementaryJournalObj );            
                }
            }
            //disable complimentary journal selection and filter checkboxes
            $( '.selectComplJournal' ).val( '' ).attr( 'disabled', true );
            $( '.filterJournals' ).attr( { 'checked': false, 'disabled' : true } );
            //make additional journal editable which was selected as complimentary
            $( '.journalTypeChange' ).attr( 'disabled', false );  
            $( '.subscription-journals tr' ).removeClass( 'non-editable' );            
        } else {
            //enable complimentary journal selection and filter checkboxes
            $( '.selectComplJournal' ).attr( 'disabled', false );
            $( '.filterJournals' ).attr( 'disabled', false  );
            /*
            * Check if sales order line item already created for "Declined Complimentary Journal" item.
            * If created and "Decline Complimentary Journal" checkbox is unchecked then add in delete list
            * to delete sales order line item
            */
            if( previousDeclinedJournal.salesOrderLineItemId && previousDeclinedJournal.salesOrderLineItemId != '' ) {
                var isDeclinedJournalAddedInDeleteList = _.findWhere( salesOrderLIsToDelete, { Id: previousDeclinedJournal.Id } );
                if( typeof isDeclinedJournalAddedInDeleteList == 'undefined' ) {
                    salesOrderLIsToDelete.push( previousDeclinedJournal );
                }
            }
        }
        /*
        * If complimentary journal is declined then allow user to select 
        * additional journals without selection of complimentary journal
        */
        checkAdditionalJournalsVisibility();
    } );

    /*
    * Navigation to next step and saving data to back-end 
    * Sales order line items are been created for given sales order id 
    * with item class as "Jornals Subscription" for additional journals and
    * with item class as "Complimentary Journal" for complimentary journal
    */
    $( ".next-step" ).on( "click", function() {
        var selectedComplementaryJournal = $( '.selectComplJournal' ).val();
        if( ( $( '.decline-complimentary' ).prop( 'checked' ) ) ||
            ( ( $( 'input[name=filterOnlineOnly]' ).prop( 'checked' ) 
                || $( 'input[name=filterOnlineNPrint]' ).prop( 'checked' ) ) 
                && selectedComplementaryJournal != '' ) || 
           		( typeof pageData.membership_type != 'undefined' && pageData.membership_type != 'Active Membership' ) ) {
            //make complimentary journal selection or decline compulsory only when membership type is "Active Membership"
            if( pageData.membership_type == 'Active Membership' && selectedComplementaryJournal == '' 
               && !$( '.decline-complimentary' ).prop( 'checked' ) ) { 
                Toaster.showError( 'Please select any complimentary journaland filter checkbox or decline complimentary journal', 5000 );
            } else {
                //get all checked journals to be sent at back-end
                console.log( "checked journals: ", $('.journalTypeChange:checkbox:checked') );
                var journalsToSend = [];
                $('.journalTypeChange:checkbox:checked').each( function( journal ) {
                    var journalName = $( this ).data( 'name' );
                    var journalId = $( this ).data( 'id' );
                    console.log( 'journalName: ', journalName, 'journalId: ', journalId );
                    if( journalId ) {
                        var oldSelectdAdditionalJournals = pageData.Items.Previous_Journal_Subscriptions;
                        var originalJournalObj = _.findWhere( oldSelectdAdditionalJournals, { Id : journalId } );
                        if( typeof originalJournalObj == 'undefined' )
                            var originalJournalObj = _.findWhere( pageData.Items['Journal_Subscriptions'], { Id : journalId } );
                    }
                    console.log( 'originalJournalObj: ',originalJournalObj );
                    if( typeof originalJournalObj != 'undefined' ) {
                        journalsToSend.push( originalJournalObj );
                    }               
                });
                //add complimentory journal in list ( find complimentary journal with selectd filter type in original list )
                var complimentoryJournalToFind = selectedComplementaryJournal;
                if( $( 'input[name=filterOnlineOnly]' ).prop( 'checked' ) ) {
                    complimentoryJournalToFind += ' - Online';
                } else if( $( 'input[name=filterOnlineNPrint]' ).prop( 'checked' ) ) {
                    complimentoryJournalToFind += ' - Print';
                } 
                console.log( 'complimentoryJournalToFind: ',complimentoryJournalToFind );
                var complementaryJournalObj = _.findWhere( pageData.Items.Previous_Complimentary_Journals, { protalLabel : complimentoryJournalToFind } );
                console.log( 'isfound in old selected: ',complementaryJournalObj );
                if( typeof complementaryJournalObj == 'undefined' ) {
                    complementaryJournalObj = _.findWhere( pageData.Items.Complimentary_Journals, { protalLabel : complimentoryJournalToFind } );                
                    console.log( 'isfound in complimentary jr: ',complementaryJournalObj );
                }
                if( typeof complementaryJournalObj != 'undefined' ) {
                    journalsToSend.push( complementaryJournalObj );
                }
                //check if complementory journal is changed in dues process and if changed then add in delete list
                var oldSelectdComplementaryJournals = pageData.Items.Previous_Complimentary_Journals;
                if( oldSelectdComplementaryJournals && oldSelectdComplementaryJournals.length ) {
                    var oldSelectdComplementaryJournal = oldSelectdComplementaryJournals[ 0 ];
                    if( oldSelectdComplementaryJournal.protalLabel != complimentoryJournalToFind ) {
                        var isAlreadyAdded = _.findWhere( salesOrderLIsToDelete, { Id: oldSelectdComplementaryJournal.Id } );
                        if( typeof isAlreadyAdded == 'undefined'  ) {
                            salesOrderLIsToDelete.push( oldSelectdComplementaryJournal );
                        }                    
                    }
                }
                var isComplimentaryJournalDeclined = $( '.decline-complimentary' ).prop( 'checked' );
                /*
                * Check if sales order line item already created for "Declined Complimentary Journal" item.
                * If not created and "Decline Complimentary Journal" checkbox is checked then add in journalsToSend list
                * for creation of sales order line item 
                */
                if( isComplimentaryJournalDeclined ) {
                    console.log( 'previousDeclinedJournal:', previousDeclinedJournal, typeof previousDeclinedJournal.salesOrderLineItemId, previousDeclinedJournal.salesOrderLineItemId );
                    if( typeof previousDeclinedJournal.salesOrderLineItemId == 'undefined' || 
                        ( previousDeclinedJournal.salesOrderLineItemId && previousDeclinedJournal.salesOrderLineItemId == '' ) ) {
                        var isDeclinedJournalAdded = _.findWhere( journalsToSend, { Id: previousDeclinedJournal.Id } );
                        console.log( 'isDeclinedJournalAdded: ', isDeclinedJournalAdded );
                        if( typeof isDeclinedJournalAdded == 'undefined' ) {
                            journalsToSend.push( previousDeclinedJournal );
                        }
                    }
                }
                console.log( 'journalsToSend: ', journalsToSend, 'salesOrderLIsToDelete',salesOrderLIsToDelete );
                //return false;
                //proceed only when any journals are selected
                if( journalsToSend.length || salesOrderLIsToDelete.length ) {                
                    var salesOrderId = getUrlParam('salesorder');
                    console.log( 'salesOrderId: ', salesOrderId );
                    //proceed only when sales order id is present in URL
                    if( salesOrderId ) {
                        
                        //check journal address
                        var isJournalAddrSameAsPreferedAddr = $( ".isJournalAddrSameAsPreferedAddr" ).prop( 'checked' );
                        console.log( 'isJournalAddrSameAsPreferedAddr: ', isJournalAddrSameAsPreferedAddr, typeof isJournalAddrSameAsPreferedAddr );                    
                        if( !isJournalAddrSameAsPreferedAddr ) {
                            //show popup of journal address to update if address is not valid
                            console.log( 'isJournalsAddrValid: ',isJournalsAddrValid() );
                            if( !isJournalsAddrValid() )  {
                                showAddressModal();
                                Toaster.showError( 'Please fill journals address', 5000 );
                                return false;
                            }
                        }
                        
                        showLoader();                    
                        /*
                        * Method : createSalesOrderLines
                        * @salesOrderId : Sales Order Id
                        * @journalsToSend : list of journals to be saved as sales order line items at back-end
                        * @Journals : type of item ( Journals, Working Groups, Optional Items )
                        * @isJournalAddrSameAsPreferedAddr : Boolean - Whether to send journals to same address as user's preferred address
                        * @stepId : step id
                        */
                        var options = {
                            url : "DW_ECRMControllerClone.createSalesOrderLines",
                            params : [ salesOrderId, journalsToSend, 'Journals', salesOrderLIsToDelete, isJournalAddrSameAsPreferedAddr, stepId ]
                        };
                        callVfRemoting(options).then(
                            // success function
                            function(result){
                                console.log( 'createSalesOrderLines result: ', result );
                                if( result.isSuccess ) {
                                    Toaster.showSuccess( result.message, 5000 );
                                    if( pageData.Step_URLs && pageData.Step_URLs.Next_Step_URL ) {
                                        //add required extra query params in URL - method in commonFunctions Js
                                        var linkToNavigate = updateQueryParamsOfURL( pageData.Step_URLs.Next_Step_URL, true );
                                        window.location.href = linkToNavigate;
                                    } else {
                                        console.log( 'Issue in getting next step URL' );
                                    } 
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
                    } else {
                        Toaster.showError( 'Sales order id not provided', 5000 );
                    }
                } else {
                    //Toaster.showError( 'Please select any journal', 5000 );
                    //allow user to go further even if no journal selected and decline complimentary journal is checked
                    showLoader();
                    //update last accessed step of contact in junction object for progress bar functionality
                    var options = {
                        url : "DW_ECRMControllerClone.updateContactLastAccessedStep",
                        params : [ stepId ]
                    };
                    callVfRemoting(options).then(
                        // success function
                        function(result){
                            console.log( 'updateContactLastAccessedStep result: ', result );                        
                            if( result.isSuccess ) {
                                //navigate to next step
                                if( pageData.Step_URLs && pageData.Step_URLs.Next_Step_URL ) {
                                    //add required extra query params in URL - method in commonFunctions Js
                                    window.location.href = updateQueryParamsOfURL( pageData.Step_URLs.Next_Step_URL, true );
                                } else {
                                    console.log( 'Issue in getting next step URL' );
                                } 
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
            
        } else { 
            var errorMsg = ''
            if( selectedComplementaryJournal == '' ) {
                errorMsg = 'Please select any complimentary journal';
            } else {
                errorMsg = 'Please select online only or Print and Online type for selected complimentary journal';
            }
            Toaster.showError( errorMsg, 5000 );
        }
    } );

    //Navigation to previous step 
    $( '.prev-step' ).on( 'click', function() {
        if( pageData.Step_URLs && pageData.Step_URLs.Previous_Step_URL ) {
            //window.location.href = pageData.Step_URLs.Previous_Step_URL; 
            //add required extra query params in URL - method in commonFunctions Js
            window.location.href = updateQueryParamsOfURL( pageData.Step_URLs.Previous_Step_URL, true );
        } else {
            console.log( 'Issue in getting previous step URL' );
        }       
    } );

    //Cancel step navigation
    $( '.cancel-step' ).on( 'click', function() {
        if( pageData.Step_URLs && pageData.Step_URLs.Cancel_Step_URL ) {
            window.location.href = pageData.Step_URLs.Cancel_Step_URL;
        } else {
            console.log( 'Issue in getting cancel URL' );
        } 
    } );
} );

/*
* Function to make same additional journal non-editable  
* which is selected as complimentary journal in select list
*/
function makeAdditionaJournalNonEditable() {
    var selectedComplementaryJournalName = $( '.selectComplJournal' ).val();
    if( selectedComplementaryJournalName && selectedComplementaryJournalName != '' ) {
        $( '.journalTypeChange' ).attr( 'disabled', false );  
        $( '.subscription-journals tr' ).removeClass( 'non-editable' );  //to maintain different style to non-editable class        
        $( 'input[data-name="'+selectedComplementaryJournalName+'"]' ).attr( 'disabled', true );
        $( 'input[data-name="'+selectedComplementaryJournalName+'"]' ).parents('tr').addClass( 'non-editable' );
    }
}

/*
* Function to hide or show additional journals table depending on 
* whether complimentary journal is selected or declined
* If complimentary is not declined then show additional journals 
* only when complimentary journal is selected and any filter checkbox is checked.
* If complimentary journal is declined then display additional journals
*/
function checkAdditionalJournalsVisibility() {
    if( typeof pageData.membership_type != 'undefined' && pageData.membership_type != 'Active Membership' )  {
		$( '.subscription-journals' ).show();
        $( '.btnDiv' ).show(); 
    } else {
        if( $( '.decline-complimentary' ).prop( 'checked' ) ) {
            $( '.subscription-journals' ).show();
            $( '.btnDiv' ).show();
        } else {
            if( $('.selectComplJournal').val() == '' 
                || ( !$( 'input[name=filterOnlineOnly]' ).prop( 'checked' ) 
                    && !$( 'input[name=filterOnlineNPrint]' ).prop( 'checked' ) ) ) {
                $( '.subscription-journals' ).hide();
                $( '.btnDiv' ).hide();
            } else {
                $( '.subscription-journals' ).show();
                $( '.btnDiv' ).show();
            }
        }    
    }    
}
/*
* Function to add journal in delete list if unchecked ( and already have sales order line item id )
*/
function addSalesOrderLiInDeleteList( journalId ) {
    var oldSelectdAdditionalJournals = pageData.Items.Previous_Journal_Subscriptions;
    var journal = _.findWhere( oldSelectdAdditionalJournals, { Id : journalId } );
    if( typeof journal != 'undefined' && journal.salesOrderLineItemId 
        && journal.salesOrderLineItemId != '' ) {
        var isAlreadyAdded = _.findWhere( salesOrderLIsToDelete, { Id: journal.Id } );
        if( typeof isAlreadyAdded == 'undefined'  ) {
           salesOrderLIsToDelete.push( journal );
        }         
    }      
}

//Function to bind dyanmic template events after it loads ( using underscore js )
function bindEvents() {
    //keep same additional journal as that of selected complementory journal, non-editable
    makeAdditionaJournalNonEditable();
    //if no complementary journal is selected or no filter is selected then hide below table and buttons
    checkAdditionalJournalsVisibility();
    //made same additional journal non-editable which is selected as complementary and make it grey
    $('.selectComplJournal').on( 'change', function() {      
        //made all additional journals editable and only one non-editable
        makeAdditionaJournalNonEditable();
        var selectedComplementaryJournalName = $( this ).val();
        //if selected complimentary journal is already added in additional journals then remove additional journal and add in delete list 
        $( 'input[data-name="'+selectedComplementaryJournalName+'"]' ).each( function( idx, elm ) {
            console.log( 'elm: ',elm, $( this ).prop( 'checked' ) );
            if( $( this ).prop( 'checked' ) ) {                    
                var jrId = $( this ).data('id');
                console.log( 'jrId: ', jrId );
                if( jrId ) {
                    console.log( "in jrId" );
                    var additionalJrObj = _.findWhere( pageData.Items.Previous_Journal_Subscriptions, { Id : jrId } );
                    console.log( "additionalJrObj", additionalJrObj, typeof additionalJrObj );
                    if( typeof additionalJrObj != 'undefined' ) {
                         console.log( "additionalJrObj.salesOrderLineItemId", additionalJrObj.salesOrderLineItemId );
                        if( additionalJrObj.salesOrderLineItemId && additionalJrObj.salesOrderLineItemId != '' ) {
                            var isAlreadyAddedInDeleteList = _.findWhere( salesOrderLIsToDelete, { Id : additionalJrObj.Id } );
                            console.log( "isAlreadyAddedInDeleteList: ", isAlreadyAddedInDeleteList, typeof isAlreadyAddedInDeleteList );
                            if( typeof isAlreadyAddedInDeleteList == 'undefined' ) {
                                salesOrderLIsToDelete.push( additionalJrObj );
                            }                                
                        }
                    }
                }
                $( this ).prop( 'checked', false );
                console.log( 'salesOrderLIsToDelete: ', salesOrderLIsToDelete );
            }
        } );
        //make additional journals and buttons visible only when any complimentary journal and type checkbox is checked
        // or decline journal is checked
        checkAdditionalJournalsVisibility();
    } );

    //Function to handle individual journal checkbox change
    $( ".journalTypeChange" ).on( 'change', function() {
        var journalId = $( this ).data('id');
        if( $( this ).prop('checked') ) {
            if( $( this ).attr('name') == 'printAndOnline' ) {
                $( this ).parents('tr').find( 'input[name=onlineOnly]' ).prop( 'checked', false );
                //check if we need to delete it from back-end
                addSalesOrderLiInDeleteList( $( this ).parents('tr').find( 'input[name=onlineOnly]' ).data( 'id' ) );
            }
            else {
                $( this ).parents('tr').find( 'input[name=printAndOnline]' ).prop( 'checked', false );
                //check if we need to delete it from back-end
                addSalesOrderLiInDeleteList( $( this ).parents('tr').find( 'input[name=printAndOnline]' ).data( 'id' ) );
            }
        } else {
            //if unchecked and alreay have salesOrderLineItemId and not present in delete array then add
            addSalesOrderLiInDeleteList( journalId );                 
        }
    } );

    //Function to open address modal on click of "update journals address"
    $( ".update-address" ).on( "click", function() {
        showAddressModal();
    } );
    //only show update journal address link if isJournalAddrSameAsPreferedAddr checbox is unchecked
    $( '.isJournalAddrSameAsPreferedAddr' ).on( "change", function() {
        if( $( this ).prop( 'checked' ) ) {
            $( '.update-address' ).hide();
        } else {
            $( '.update-address' ).show();
        }
    } );
}

function showAddressModal() {
    $( ".journalAddressModal" ).addClass( "show" );
}

/*
* Function to hide journals address modal
*/
function hideAddressModal() {
    $( ".journalAddressModal" ).removeClass( "show" );
}   

function cancelAddressUpdate() {
    //reset values if cancelled
    $( ".journalAddressModal .form-field" ).each( function( idx, elm ) {
        $( this ).val( $( this ).data('value') );
    } );
    hideAddressModal();
}

function isJournalsAddrValid() {
    FormValidator.hideAllErrors();    
    var isValid = true;
    var addrStreet = $("textarea[data-api-name='Journal_Street__c']");
    if( addrStreet.val() == '' ) {
        FormValidator.showError( addrStreet, "Please enter street" );
        isValid = false;
    }   
    var addrCountry = $("input[data-api-name='Journal_Country__c']");
    if( addrCountry.val() == '' ) {
        FormValidator.showError( addrCountry, "Please enter country" );
        isValid = false;
    }

    var addrState = $("input[data-api-name='Journal_State_Province__c']");
    if (addrState.val() == '') {
        FormValidator.showError( addrState, "Please enter state" );
        isValid = false;
    }  

    var addrCity = $("input[data-api-name='Journal_City__c']");
    if( addrCity.val() == '' ) {
        FormValidator.showError( addrCity, "Please enter city" );
        isValid = false;
    } 
    return isValid; 
}

function validateJournalsAddrAndProceed() {
    var isValid = isJournalsAddrValid();    
    if( isValid ) {
        showLoader();
        updateContactsJournalAddr();
    }   
}