var pageData;
/*
* Description : Callback function called after getting page metadata
*               to display optional items template on page 
* @workingGroupsData : Page metadata
*/
function getOptionalItemsCallback( optionalItemsData ) {
    console.log( "in getOptionalItemsCallback", optionalItemsData.Items.Merchandise );
    pageData = optionalItemsData;
    var templateOptionalItems = $("#optionalItems_template").html();
    var tmpl = _.template( templateOptionalItems );
    console.log( 'tmpl: ', tmpl );
    var isJoinProcess = getUrlParam( 'isjoin' );
    isJoinProcess = ( isJoinProcess == null || isJoinProcess == 'true' ) ? true : false;
    $("#optionalItems_wrap").html( tmpl( { optionalItems: pageData.Items.Merchandise, isJoinProcess : isJoinProcess } ) );
}

$( document ).ready( function() {
    console.log( "in document ready" );
    var stepId = getUrlParam( 'id' );
    showLoader();
    //on page load get all optional items
    /*
    * Method : getOptionalItems
    * @stepId : Current step Id of membership join / renewal process ( from Steps object ) 
    */
    var options = {
        url : "DW_ECRMController.getOptionalItems",
        params : [ stepId ],
    };
    callVfRemoting(options).then(
        // success function
        function(result){
            console.log( 'getOptionalItems result: ', result );
            if( result.isSuccess ) {
                //using underscore template to display journals list  
                getOptionalItemsCallback( result.data );          
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

    /*
    * Navigation to next step and saving data to back-end 
    * Sales order line items are been created for given sales order id 
    * with item class as "Merchandise" for selected optional items
    */
    $( '.next-step' ).on( 'click', function() {        
        //get all optional items which are checked
        var optionalItemsToSend = [];
        $('.oi-check:checkbox:checked').each( function( optionalItem ) {
            /*
            * get optional item of selected optional items 
            * from either old selected or all optional items list
            */ 
            var optionalItemId = $( this ).data( 'id' );
            console.log( 'optionalItemId: ', optionalItemId );
            var originalOptionalItemObj = _.findWhere( pageData.Items.Merchandise, { Id : optionalItemId } );
            console.log( 'originalOptionalItemObj: ',originalOptionalItemObj );
            if( typeof originalOptionalItemObj != 'undefined' ) {
                optionalItemsToSend.push( originalOptionalItemObj );
            }
            console.log( 'optionalItemsToSend: ', optionalItemsToSend );
        });
        //proceed only when any optional item is selected
        if( optionalItemsToSend.length ) {
            var salesOrderId = getUrlParam('salesorder');
            console.log( 'salesOrderId: ', salesOrderId );
            //proceed only when sales order id is provided in URL
            if( salesOrderId ) {
                showLoader();
                /*
                * Method : createSalesOrderLines
                * @salesOrderId : Sales Order Id
                * @optionalItemsToSend : list of optional items to be saved as sales order line items at back-end
                * @Optional Items : type of item ( Journals, Working Groups, Optional Items )
                * @salesOrderLIsToDelete : [] - blank as no need to display previous subscribed optional items as selected as per requirement
                * @isJournalAddrSameAsPreferedAddr : Boolean - false ( only used in case of Journals Item )
                * @stepId : step Id
                */
                var options = {
                    url : "DW_ECRMController.createSalesOrderLines",
                    params : [ salesOrderId, optionalItemsToSend, 'Optional Items', [], false, stepId ]
                };
                callVfRemoting(options).then(
                    // success function
                    function(result){
                        console.log( 'createSalesOrderLines result: ', result );                        
                        if( result.isSuccess ) {
                            Toaster.showSuccess( result.message, 5000 );
                            if( pageData.Step_URLs && pageData.Step_URLs.Next_Step_URL ) {
                                window.location.href = pageData.Step_URLs.Next_Step_URL;
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
        } else { //allow to navigate to next step even when no optional items selected            
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
                            window.location.href = pageData.Step_URLs.Next_Step_URL;
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
    } );

    //Previous step navigation
    $( '.prev-step' ).on( 'click', function() {
        if( pageData.Step_URLs && pageData.Step_URLs.Previous_Step_URL ) {
            //add required extra query params in URL - method in commonFunctions Js
            window.location.href = updateQueryParamsOfURL( pageData.Step_URLs.Previous_Step_URL, true );
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
} );