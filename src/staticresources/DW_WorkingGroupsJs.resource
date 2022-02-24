var pageData;
var isJoinProcess;
var salesOrderLIsToDelete = [];
var isPricedWorkingGroupSelected = false;
var pageType = getUrlParam( 'type' ); 
console.log( "pageType: ", pageType );
/*
* Description : Callback function called after getting page metadata
*               to display working groups template on page 
* @workingGroupsData : Page metadata
*/
function getWorkingGroupsCallback( workingGroupsData ) {
    pageData = workingGroupsData;
    console.log( "in getWorkingGroupsCallback", pageData.Items.Working_Groups );
    var templateWorkingGroups = $("#workingGroups_template").html();
    //undescore js template to display data on page
    var tmpl = _.template( templateWorkingGroups );
    console.log( 'tmpl: ', tmpl );
    var currentContactsGender = 'Male';
    if( pageData.Contact && pageData.Contact.Gender__c ) {
        currentContactsGender = pageData.Contact.Gender__c;
    }
    var isModifyPage = ( getUrlParam( 'type' ) != null ) ? true : false;    
    
    $("#workingGroups_wrap").html( tmpl( { workingGroups: pageData.Items.Working_Groups, 
                                          currentContactsGender : currentContactsGender, isModifyPage : isModifyPage, 
                                          isJoinProcess: isJoinProcess } ) );
    //Keep selected previously subscribed working groups
    console.log( 'isJoinProcess: ',isJoinProcess );
    var oldSelectedWgs = workingGroupsData.Items.Previous_Working_Groups;
    if( oldSelectedWgs ) {
        _.each( oldSelectedWgs, function( wg ) {
            $( 'input[data-id="'+wg.Id+'"]' ).prop( 'checked', true );
            if( wg.price > 0 ) {
                isPricedWorkingGroupSelected = true;
            }
        } );
    }
    checkVisibilityOfButtons();
    //After underscore template loads, bind required events to it's elements
    bindEvents();
}
function checkVisibilityOfButtons() { 
    if( pageType == null && pageType != 'modify' ) {
        $( ".saveAndClose" ).hide();
        $( ".next-step.navigate" ).show();
    } else {
        if( !isPricedWorkingGroupSelected ) { //if all working groups with price 0 are added then show save and close 
            $( ".saveAndClose" ).show();
            $( ".next-step.navigate" ).hide();
        } else {
            $( ".saveAndClose" ).hide();
            $( ".next-step.navigate" ).show();
        }
    }
}
function bindEvents() {
    $( '.wg-check' ).on( 'change', function() {
        /*
        * If working group is unchecked and alreay have salesOrderLineItemId
        * and not present in delete array then add it in delete list
        */
        console.log( 'check change ',$( this ).prop( 'checked' ) );
        if( !$( this ).prop( 'checked' ) ) {
            console.log( 'in uncheck' );
            var workingGroupId = $( this ).data( 'id' );
            var oldSelectedWgs = pageData.Items.Previous_Working_Groups;
            var wg = _.findWhere( oldSelectedWgs, { Id : workingGroupId } );
            if( typeof wg != 'undefined' && wg.salesOrderLineItemId 
                && wg.salesOrderLineItemId != '' ) {
                salesOrderLIsToDelete.push( wg );
            }            
        }
        isPricedWorkingGroupSelected = false;
        $('.wg-check:checkbox:checked').each( function( workingGroup ) {
            if( $( this ).data( 'price' ) > 0 ) {
                isPricedWorkingGroupSelected = true;
            }
        });
        if( pageType != null && pageType == 'modify' ) {
            checkVisibilityOfButtons();
        }
    } );

    /*
    * Navigation to next step and saving data to back-end 
    * Sales order line items are been created for given sales order id 
    * with item class as "Working Groups" for selected working groups
    */
    $( '.next-step' ).on( 'click', function() {        
        var workingGroupsToSend = [];
        var isPricedWgSelected = false;
        //get all working groups which are checked
        $('.wg-check:checkbox:checked').each( function( workingGroup ) {
            var workingGroupId = $( this ).data( 'id' );
            console.log( 'workingGroupId: ', workingGroupId );
            /*
            * get working group object of selected working group 
            * from either old selected or all working groups list
            */ 
            var oldSelectdWgs = pageData.Items.Previous_Working_Groups;
            var originalWorkingGroupObj = _.findWhere( oldSelectdWgs, { Id : workingGroupId } );
            if( typeof originalWorkingGroupObj == 'undefined' )            
                originalWorkingGroupObj = _.findWhere( pageData.Items.Working_Groups, { Id : workingGroupId } );
            console.log( 'originalWorkingGroupObj: ',originalWorkingGroupObj );
            if( typeof originalWorkingGroupObj != 'undefined' ) {
                workingGroupsToSend.push( originalWorkingGroupObj );
                /*if any of the working group having price greater than 0 is selected then 
                allow navigate to cart page in case of modify groups else close the page*/
                if( originalWorkingGroupObj.price > 0 ) {
                    isPricedWgSelected = true;
                }
            }
            console.log( 'workingGroupsToSend: ', workingGroupsToSend );
        });
        var salesOrderId = getUrlParam('salesorder');            
        if( salesOrderId == null ) {
            if( typeof pageData.SalesOrder_Id != 'undefined' )  {
                salesOrderId = pageData.SalesOrder_Id
            }
        }
        console.log( 'salesOrderId: ', salesOrderId );
        //proceed only when any working group is selected
        if( workingGroupsToSend.length || salesOrderLIsToDelete.length ) {
            //proceed only when sales order id is provided in URL
            if( salesOrderId && salesOrderId != null ) {
                showLoader();
                /*
                * Method : createSalesOrderLines
                * @salesOrderId : Sales Order Id
                * @workingGroupsToSend : list of working groups to be saved as sales order line items at back-end
                * @Working Groups : type of item ( Journals, Working Groups, Optional Items )
                * @salesOrderLIsToDelete : list of sales order line items to delete ( which are unchecked )
                * @isJournalAddrSameAsPreferedAddr : Boolean - false ( only used in case of Journals Item )
                * @stepId : step Id
                */
                var options = {
                    url : "DW_ECRMController.createSalesOrderLines",
                    params : [ salesOrderId, workingGroupsToSend, 'Working Groups', salesOrderLIsToDelete, false, stepId ]
                };
                callVfRemoting(options).then(
                    // success function
                    function(result){
                        console.log( 'createSalesOrderLines result: ', result );                        
                        if( result.isSuccess ) {
                            Toaster.showSuccess( result.message, 5000 );
                            console.log( 'typeParam: ',getUrlParam( 'type' ) );
                            if( getUrlParam( 'type' ) != null && getUrlParam( 'type' ) == 'modify' && !isPricedWgSelected ) {
                                console.log( "in if" );
                                self.close(); //close window
                            } else {
                                if( pageData.Step_URLs && pageData.Step_URLs.Next_Step_URL ) {
                                    //add required extra query params in URL - method in commonFunctions Js
                                    window.location.href = updateQueryParamsOfURL( pageData.Step_URLs.Next_Step_URL, true );
                                } else {
                                    console.log( 'Issue in getting next step URL' );
                                } 
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
            //Toaster.showError( 'Please select any working group', 5000 );
            //proceed only when sales order id is provided in URL
            if( salesOrderId && salesOrderId != null ) {
                showLoader();
                //update last accessed step of contact in junction object for progress bar functionality
                var options = {
                    url : "DW_ECRMController.updateContactLastAccessedStep",
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
    } );

    //Previous step navigation
    $( '.prev-step' ).on( 'click', function() {
        if( pageData.Step_URLs && pageData.Step_URLs.Previous_Step_URL ) {
            //add required extra query params in URL - method in commonFunctions Js
            window.location.href = updateQueryParamsOfURL( pageData.Step_URLs.Previous_Step_URL, true ); ;
        } else {
            console.log( 'Issue in getting prev step URL' );
        } 
    } );

    //Cancel step navigation
    $( '.cancel-step' ).on( 'click', function() {
        if( pageData.Step_URLs && pageData.Step_URLs.Cancel_Step_URL ) {
            //add required extra query params in URL - method in commonFunctions Js
            window.location.href = updateQueryParamsOfURL( pageData.Step_URLs.Cancel_Step_URL, false );
        } else {
            console.log( 'Issue in getting cancel URL' );
        } 
    } );
}

$( document ).ready( function() {
    isJoinProcess = getUrlParam( 'isjoin' );
    var salesOrderId = getUrlParam( 'salesorder' );
    var stepId = getUrlParam( 'id' );
    isJoinProcess = ( isJoinProcess == 'true' || isJoinProcess == null ) ? true : false;
    showLoader();
    //on page load get all working groups and page metadata
    /*
    * Method: getWorkingGroups
    * @!isJoinProcess : At server side referred isRenewal membership process
    * @salesOrderId : Sales Order Id
    * @stepId : Current step Id of membership join / renewal process ( from Steps object ) 
    */
    var options = {
        url : "DW_ECRMController.getWorkingGroups",
        params : [ !isJoinProcess, salesOrderId, stepId, pageType ],
    };
    callVfRemoting(options).then(
        // success function
        function(result){
            console.log( 'getWorkingGroups result: ', result );
            if( result.isSuccess ) {
                getWorkingGroupsCallback( result.data );          
                hideLoader();
            } else {
                hideLoader();
                Toaster.showError( result.message, 5000 );
            }            
        },
        // error function
        function( error ){
            hideLoader();
            Toaster.showError( error, 5000 );
        }
    );   

    
} );