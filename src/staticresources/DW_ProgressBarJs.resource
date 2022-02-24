var progressBarSteps = [];
var templateProgressBar;
var stepId = '';

function getParamFromURL( name, url ) {
    if (!url) url = location.href;
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    name = name.toLowerCase();
    var regexS = "[\\?&]"+name+"=([^&#]*)";
    var regex = new RegExp( regexS, "i" );
    var results = regex.exec( url );
    return results == null ? null : results[1];
}

function showStepsLoader() {
    $( ".loader-stepBG" ).show();
}

function hideStepsLoader() {
    $( ".loader-stepBG" ).hide();
}

function displayProgressBarTemplate( progressBarData ) {
    console.log( "in display template pageNamesWithSO: ", pageNamesWithSO, 'soId: ',soId );
    var tmpl = _.template( templateProgressBar );
    $("#progressbar-stepslist").html( tmpl( { steps: progressBarSteps, lastAccessdStepOrder : progressBarData.lastAccessdStepOrder,
                                             currentStepId : stepId, pageNamesWithSO : pageNamesWithSO, soId : soId } ) );
}
function isLocalstorageSupported() {
    if( typeof localStorage !== "undefined" ) {
      return true;
    }
    else {
        return false;
    }
}
function getProgressBarNextSteps( progressBarData ) {
    //console.log('in getProgressBarNextSteps');
    if( typeof progressBarData.step.nextStepId != 'undefined' && progressBarData.step.nextStepId != '' 
       && progressBarData.step.nextStepId != null ) {
        getProgressBarStep( progressBarData.step.nextStepId, false );
        //console.log( "in call recursive method" );
    } else {
        console.log( "in last step" );
        //if localstorage is supported then store all steps in localstorage for caching
        if( isLocalstorageSupported() ) {       
            var cachedData = localStorage.getItem( "ECRM_JoinProcessSteps" );
            //console.log( 'cachedJoinProcessSteps: ', cachedData );
            var dataToCach = {
                joinProcessId : progressBarData.joinProcessId,
                contactId : progressBarData.contactId,
                steps : progressBarSteps,
                dataSavedTimeStamp : getCurrentTimeStamp()
            }                       
            if( cachedData != null ) {     
                cachedData = JSON.parse( cachedData );
                //console.log( 'cachedData after parse', cachedData );
                cachedData.push( dataToCach );
                dataToCach = cachedData;
                //console.log( 'dataToCach', dataToCach );
            }  else {
                dataToCach = [ dataToCach ];
            } 
            //console.log( "localstorageSupported and store data ", JSON.stringify( dataToCach ) ); 
            try {
                localStorage.setItem( "ECRM_JoinProcessSteps", JSON.stringify( dataToCach ) );            
            } catch( exp ) {
                //console.log( "Exception occured while storing data to localstorage : ", exp );
                if ( exp.code == 22 ) { //QUOTA_EXCEEDED_ERR
                    localStorage.clear(); //clear localstorage if storage limit exceeds
                }
            }
        }
        //display progress bar template once done with fetching all steps or getting them from cache
        displayProgressBarTemplate( progressBarData );        
        hideStepsLoader();
    }
}

function getCurrentTimeStamp() {
    if (!Date.now) {
        return new Date().getTime();
    } else {
        return Date.now();
    }
}

function checkWhetherToclearCachedData( progressBarData ) {
    //console.log( 'in checkWhetherToclearCachedData' );
    var cachedJoinProcessSteps = localStorage.getItem( "ECRM_JoinProcessSteps" );
    //console.log( 'cachedJoinProcessSteps: ', cachedJoinProcessSteps );
    if( cachedJoinProcessSteps != null ) {
        //console.log( 'cachedJoinProcessSteps not null' );
        var cachedData = JSON.parse( cachedJoinProcessSteps );
        //console.log( 'cachedData: ', cachedData );
        //var requiredCachedData = _.findWhere( cachedData, { joinProcessId : progressBarData.joinProcessId, contactId : progressBarData.contactId } );
        var requiredCachedData = _.find( cachedData, { joinProcessId : progressBarData.joinProcessId, 
            contactId : progressBarData.contactId } );
        //console.log( 'requiredCachedData',requiredCachedData );
        if( typeof requiredCachedData != 'undefined' ) {
            var currenTimeStamp = getCurrentTimeStamp();
            var dataSavedTimeStamp = requiredCachedData.dataSavedTimeStamp;
            var timeDifference = currenTimeStamp - dataSavedTimeStamp;
            var hoursDifference = Math.floor( timeDifference / 1000 / 60 / 60 );
            var minutesDifference = Math.floor(timeDifference/1000/60);
            //console.log('minutesDifference',minutesDifference);
            //console.log( 'hoursDifference', hoursDifference );
            if( hoursDifference > 24 ) {
            //if( minutesDifference > 1 ) { //for testing
                //console.log( 'in hoursDifference exceed' );
                var cachedDataIdx = _.findIndex( cachedData, { joinProcessId : progressBarData.joinProcessId, 
                                                                contactId : progressBarData.contactId } );
                //console.log( 'cachedDataIdx', cachedDataIdx );
                cachedData.splice( cachedDataIdx, 1 ); 
                //console.log( 'cachedData after delete', cachedData );
                if( cachedData.length > 0 ) {
                    localStorage.setItem( "ECRM_JoinProcessSteps", JSON.stringify( cachedData ) );
                } else {
                    localStorage.removeItem( "ECRM_JoinProcessSteps" );
                }
            }
        }
    }
}

function getProgressBarDetailsCallback( progressBarData, isFirstStep ) {    
    progressBarSteps.push( progressBarData.step );
    //console.log( 'progressBarSteps1:',progressBarSteps );
    //check if steps are cached in localstorage. If cached then do not query at back-end
    if( isLocalstorageSupported() ) {
        //console.log( 'in localstorage supported' );
        if( isFirstStep ) {
            /* 
            * If cached data is stored for more than 24hrs then clear it so that if any
            * configuration is changed at back-end then new data will be fetched instead of cached one 
            */
            checkWhetherToclearCachedData( progressBarData );
        }
        //if( !isFirstStep ) {
            //console.log( 'in not first step' );
            //get steps from cache and populate the template
            var cachedJoinProcessSteps = localStorage.getItem( "ECRM_JoinProcessSteps" );
            //console.log( 'cachedJoinProcessSteps: ', cachedJoinProcessSteps );
            if( cachedJoinProcessSteps != null ) {
                //console.log( 'cachedJoinProcessSteps not null' );
                var cachedData = JSON.parse( cachedJoinProcessSteps );
                //console.log( 'cachedData: ', cachedData );
                //var requiredCachedData = _.findWhere( cachedData, { joinProcessId : progressBarData.joinProcessId, contactId : progressBarData.contactId } );
                var requiredCachedData = _.find( cachedData, { joinProcessId : progressBarData.joinProcessId, 
                    contactId : progressBarData.contactId } );
                //console.log( 'requiredCachedData',requiredCachedData );
                if( typeof requiredCachedData != 'undefined' ) {
                    progressBarSteps = requiredCachedData.steps;
                    //console.log( 'progressBarSteps: ', progressBarSteps, 'progressBarData: ', progressBarData );
                    displayProgressBarTemplate( progressBarData );
                    hideStepsLoader();
                } else {
                    //console.log( 'requiredCachedData not found' );
                    getProgressBarNextSteps( progressBarData );
                }                
            } else {
                //console.log( 'cachedJoinProcessSteps null' );
                getProgressBarNextSteps( progressBarData );
            }
        /*} else {
            console.log( 'in first step' );
            getProgressBarNextSteps( progressBarData );
        }*/
    } else {
        //console.log( 'in localstorage not supported' );
        getProgressBarNextSteps( progressBarData );        
    }
}
function getProgressBarStep( stepId, isFirstStep ) {
    var options = {
        url : "DW_ProgressBarCtrl.getProgressBarDetails",
        params : [ stepId, isFirstStep ]
    };
    callVfRemoting(options).then(
        // success function
        function(result){
            console.log( 'getProgressBarDetails result: ', result );
            if( result.isSuccess ) {
                getProgressBarDetailsCallback( result.data, isFirstStep );
            } else {
                Toaster.showError( result.message, 5000 );
            }            
        },
        // error function
        function(error){
            Toaster.showError( error, 5000 );
            console.log( 'error: ', error );
        }
    );
}
$( document ).ready( function() {
    templateProgressBar = $("#progressbar_template").html();     
});
$( window ).on( 'load', function() {
    stepId = getParamFromURL('Id');
    //console.log( 'stepId: ', stepId );
    if( stepId != null ) {
        showStepsLoader();            
        getProgressBarStep( stepId, true );
    }
});