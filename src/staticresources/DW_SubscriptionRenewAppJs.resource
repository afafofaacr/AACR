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

var app = angular.module( 'subscriptionRenewApp', [ 'toastr', 'Remoting', 'ngSanitize' ] );  

app.controller( 'subscriptionRenewController', function ( $scope, Remoting, toastr ) { 
	var self = this;
	$scope.pageData = {
        showLoader : false,
        item : {},
        renewProcessUrl : ''
    };

    function getUrlParam( name, url ) {
        if (!url) url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        return results == null ? null : results[1];
    }

    /*
    * Description: 
    */
    $scope.getRenewItem = function() {
        $scope.pageData.showLoader = true;
        var salesOrderId = getUrlParam( 'salesOrder' );
        if( salesOrderId != '' ) {
            Remoting.getRenewItem( salesOrderId ).then( function( result ) {
                console.log( "getRenewItem result: ", result );
                if( result.isSuccess ) {
                    $scope.pageData.showLoader = false;
                    $scope.pageData.Item = result.data.item;
                    $scope.pageData.renewProcessUrl = result.data.joinProcessURL;
                } else {
                    $scope.pageData.showLoader = false;
                    toastr.error( result.message, 'Error' );
                }            
            }, function( error ) {
                $scope.pageData.showLoader = false;
                toastr.error( error, 'Error' );
            } );
        } else {
            toastr.error( 'Sales order id not provided', 'Error' );
        }        
    }  
    $scope.goToRenewProcesss = function() {
        window.location.href = $scope.pageData.renewProcessUrl;
    }
    $scope.closeRenew = function() {
        window.location.href = '/DW_Custom_Profile';
    }
} );