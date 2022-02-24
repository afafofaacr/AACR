// Remoting Factory
angular.module('Remoting', []).factory('Remoting', function($q, $rootScope) {
    function __invokeRemoteAction(rArgs) {
        var deferred = $q.defer();        
        rArgs.push(function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else if (event.type == "exception") {
                deferred.reject(event);
            }
        });        
        rArgs.push(__Remoting.rConfig);
        console.log( "Remoting Args:",rArgs );
        Visualforce.remoting.Manager.invokeAction.apply(Visualforce.remoting.Manager, rArgs);
        return deferred.promise;
    };
    
    var __defaultRemotingConfig = { buffer: false, escape: false, timeout: 120000 };
    var __pageId = Object.keys(Visualforce.remoting.Manager.providers)[0];

    var __actions = [];
    _.each( Object.keys(Visualforce.remoting.Manager.providers[__pageId].actions), function( __controllerName ) {
        var remotingMethods = Visualforce.remoting.Manager.providers[__pageId]['actions'][__controllerName].ms;
        //add controller name to all remoting methods of individual controller
        remotingMethods = _.map( remotingMethods, function( element ) { return _.extend( {}, element, { controllerName : __controllerName } ); } );
        __actions = __actions.concat(  remotingMethods );        
    } );
    console.log( 'remoting actions: ', __actions );

    var __Remoting = {
        pageId: __pageId,
        actions: __actions,
        rConfig: __defaultRemotingConfig,
        setupRemotingConfig: function (config) {
            this.rConfig = (typeof(config) == 'object') ? config : __defaultRemotingConfig;
        }
    };
    
    for (var i = 0; i < __Remoting.actions.length; i++) {
        var rmContext = { rMethod: __Remoting.actions[i].controllerName + "." + __Remoting.actions[i].name };
        __Remoting[__Remoting.actions[i].name] = function () {
            var rArgs = [];
            for (var j = 0; j < arguments.length; j++) {
                rArgs.push(arguments[j]);
            }
            rArgs.unshift(this.rMethod);
            return __invokeRemoteAction(rArgs);
        }.bind(rmContext);
    }
    
    return __Remoting;
});

var app = angular.module( 'subscriptionsApp', [ 'toastr', 'Remoting', 'ngSanitize' ] );  

app.controller( 'subscriptionsController', function ( $scope, Remoting, toastr ) { 
	var self = this;
	$scope.pageData = {
        showLoader : false,
        contactData : {},
        badge : {},
        journals : [],
        workingGroups : [],
        showRenewPopup : false,
        showJournalAddrModal : false,
        renewJoinprocessUrl : '',
        updatedContactData : {}
    };

    self.getSubscriptionDetailsCallback = function( pageData ) {
        $scope.pageData.contactData = pageData.Contact;
        $scope.pageData.updatedContactData = angular.copy( $scope.pageData.contactData );
        //$scope.pageData.contactData.membershipStatus = '1-YR Suspended'
        $scope.pageData.badge = pageData.Badge;
        $scope.pageData.membershipSubscription = pageData.Individual_Membership_Subscription;
        //$scope.pageData.membershipSubscription.daysToLapse = -1;
        $scope.pageData.journals = pageData.Journal_Subscription;
        $scope.pageData.workingGroups = pageData.Working_Groups_Subscription;
        $scope.pageData.renewJoinprocessUrl = pageData.Join_Process_URL;
    }

    /*
    * Description: Function to get all required contact and subscription data at page load
    */
    $scope.getSubscriptionDetails = function() {
        $scope.pageData.showLoader = true;
        Remoting.getSubscriptionDetails().then( function( result ) {
            console.log( "getSubscriptionDetails result: ", result );
            if( result.isSuccess ) {
                self.getSubscriptionDetailsCallback( result.data );
                $scope.pageData.showLoader = false;
            } else {
                $scope.pageData.showLoader = false;
                toastr.error( result.message, 'Error' );
            }            
        }, function( error ) {
            $scope.pageData.showLoader = false;
            toastr.error( error, 'Error' );
        } );        
    }

    $scope.renewSubscriptionPlan = function() {
        console.log( "call renewSubscriptionPlan" );
        $scope.pageData.showLoader = true;
        Remoting.renewSubscriptionPlan().then( function( result ) {
            console.log( "renewSubscriptionPlan result: ", result );
            if( result.isSuccess ) {
                toastr.success( result.message, '' );
                window.location.href = result.data.joinProcessURL;
            } else {
                $scope.pageData.showLoader = false;
                toastr.error( result.message, 'Error' );
            }            
        }, function( error ) {
            $scope.pageData.showLoader = false;
            toastr.error( error, 'Error' );
        } );
    }
    $scope.validateJournalsAddrAndProceed = function( isFormValid ) {
        console.log( "in validateJournalsAddrAndProceed", isFormValid );
        if( isFormValid ) {            
            $scope.pageData.showLoader = true;
            Remoting.updateContactsJournalAddr( $scope.pageData.contactData ).then( function( result ) {
                console.log( "updateContactsJournalAddr result: ", result );
                $scope.pageData.showLoader = false;
                if( result.isSuccess ) {
                    toastr.success( result.message, '' );
                    $scope.pageData.updatedContactData = angular.copy( $scope.pageData.contactData );
                    $scope.pageData.showJournalAddrModal = false;
                } else {                    
                    toastr.error( result.message, 'Error' );
                }            
            }, function( error ) {
                $scope.pageData.showLoader = false;
                toastr.error( error, 'Error' );
            } );
        } else {
            toastr.error( 'Please fill all required fields', '' );
        }
    }

    $scope.cancelAddressUpdate = function() {
        $scope.pageData.showJournalAddrModal = false;
        $scope.pageData.contactData = angular.copy( $scope.pageData.updatedContactData );
    }    
} );