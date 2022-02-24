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

var app = angular.module('nominationsApp', [ 'toastr', 'Remoting','cp.ngConfirm' ]);  

app.controller( 'nominationsController', function ( $scope, Remoting, toastr, $timeout, $ngConfirm ) { 
	var self = this;
	$scope.pageData = {
		meta : {},
		showLoader : false,
		nominators : [],
        totalAttachments : 1,
        totalNominators : 1,
        attachments : [],
        maxFileSize : 2e+6, //Setting max file size to 2MB
        chunkSize : 950000, //Maximum Javascript Remoting message size is 1,000,000 characters
        doneUploading : false,
        positionIndex : 0 
	};
	self.defaultNominator = {
		nominatorId: '',
		status : '',
		memberNo : '',
		email : '',
		isVerified : false
	};
    self.defaultAttachment = {
        id: '',
        name : '',
        body : ''
    };
	self.displayLoader = function() {
		$scope.pageData.showLoader = true;		
	}
	self.hideLoader = function() {
		$scope.pageData.showLoader = false;
    }
	self.getUrlParameter = function( name ) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)' , "i" );
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
	}

	$scope.stepId = self.getUrlParameter( 'Id' );

	self.addDefaultNominators = function( howManyToAdd ) {
		for( var i = 0; i < howManyToAdd; i++ ) {
			$scope.pageData.nominators.push( angular.copy( self.defaultNominator ) );
		}
	}
    
	self.addDefaultAttachments = function( howManyToAdd ) {
		for( var i = 0; i < howManyToAdd; i++ ) {
			$scope.pageData.attachments.push( angular.copy( self.defaultAttachment ) );
		}
	}

    self.manageAttachments = function() {
    	console.log( 'att len',$scope.pageData.attachments.length, 'total len',$scope.pageData.totalAttachments );
    	if( $scope.pageData.attachments.length < $scope.pageData.totalAttachments ){
    		self.addDefaultAttachments( $scope.pageData.totalAttachments - $scope.pageData.attachments.length );
    	} else if( $scope.pageData.attachments.length > $scope.pageData.totalAttachments ) {
    		var toRemoveCnt = $scope.pageData.attachments.length - $scope.pageData.totalAttachments;
    		$scope.pageData.attachments.splice( -toRemoveCnt );
    	}
    }

	self.getPageMetaDataCallback = function( pageMetaData ) {
		console.log()
		$scope.pageData.meta = pageMetaData;
		if( angular.isDefined( $scope.pageData.meta.nominatorsInfo ) ) {
			$scope.pageData.nominators = $scope.pageData.meta.nominatorsInfo;
		}		
		if( !$scope.pageData.meta.ItemIsNull && $scope.pageData.meta.IsActiveMembership ) {
			$scope.pageData.totalNominators = 2;
		}
        if( angular.isDefined( $scope.pageData.meta.totalAttachmentCount ) ) {
            $scope.pageData.totalAttachments = $scope.pageData.meta.totalAttachmentCount;            
        }
        if( $scope.pageData.nominators.length < $scope.pageData.totalNominators ) {
			self.addDefaultNominators( $scope.pageData.totalNominators - $scope.pageData.nominators.length );
		}
        if( angular.isDefined( $scope.pageData.meta.attachments ) && $scope.pageData.meta.attachments.length ) {
            $scope.pageData.attachments = $scope.pageData.meta.attachments;
        }
        /*if( $scope.pageData.attachments.length < $scope.pageData.totalAttachments ){
            self.addDefaultAttachments( $scope.pageData.totalAttachments - $scope.pageData.attachments.length );
        }*/
        if( $scope.pageData.attachments.length != $scope.pageData.totalAttachments ) {
        	self.manageAttachments();
        }
	}

	$scope.getPageMetaData = function() {
		if( $scope.stepId != null ) {
			//self.displayLoader();
			$scope.pageData.showLoader = true;
			Remoting.doInit( $scope.stepId ).then( function( result ) {
				console.log( 'doInit result: ', result );
				if( result.isSuccess ) {
					self.getPageMetaDataCallback( result.data );
                    $scope.pageData.showLoader = false;
				} else {
					$scope.pageData.showLoader = false;
					toastr.error( result.message, 'Error' );
				}
			}, function( error ) {
				$scope.pageData.showLoader = false;
				toastr.error( error, 'Error' );
			} );
		} else {
			$scope.pageData.showLoader = false;
			toastr.error( 'Please provide id in URL' );
		}
	}

	$scope.verifyNominator = function( nominator, idx ) {
		if( nominator.email == '' && nominator.memberNo == '' ) {
			toastr.error( 'Please fill email or member number' );
		} else {
			var existingNominatorIds = [];
			_.each( $scope.pageData.nominators, function( nom, innerIdx ) {
				console.log( 'nom: ',nom, 'innerIdx', innerIdx, 'idx', idx );
				if( innerIdx != idx ) {
					if( nom.nominatorId != '' ) {
						existingNominatorIds.push( nom.nominatorId );
					}
				}
			});
			console.log( 'existingNominatorIds:',existingNominatorIds, $scope.pageData.meta.ContactId, nominator.memberNo , nominator.email );
            $scope.pageData.showLoader = true;
			Remoting.verifyNominators( $scope.pageData.meta.ContactId, nominator.memberNo , nominator.email, existingNominatorIds ).then( function( result ) {
				console.log( 'verifyNominators result: ', result );
				if( result.isSuccess ) {
					$scope.pageData.nominators[ idx ] = result.data.nominator;	
                    $scope.pageData.showLoader = false;
				} else {
					var nom = angular.copy( self.defaultNominator );
					nom.status = result.message;
					console.log( 'nom',nom );
					$scope.pageData.nominators[ idx ] = nom;
					$scope.pageData.showLoader = false;
					console.log( 'toastr', toastr, result.message );
					toastr.error( result.message, 'Error' );
				}
			}, function( error ) {
                $scope.pageData.nominators[ idx ] = angular.copy( self.defaultNominator );
				$scope.pageData.showLoader = false;				
				toastr.error( error, 'Error' );
			} );
		}
	}
    $scope.deleteAttachment = function( attachmentId, listIdx ) {
    	$ngConfirm({
            title: 'Confirm!',
            content: 'Do you want to delete this file?',
            buttons: {
                yes: {
                    btnClass: "btn-blue",
                    action : function() {
                    	$timeout( function() {
	                    	$scope.pageData.showLoader = true;
		        			Remoting.deleteAttachment( $scope.pageData.meta.ContactId, attachmentId ).then( function( result ) {
			            		console.log( 'deleteAttachment result: ', result );
			            		if( result.isSuccess ) {
			            			//if new file added by replacing old then add to upload		            			
			            			$scope.pageData.attachments[ listIdx ] = angular.copy( self.defaultAttachment );		            			
			            			$scope.pageData.showLoader = false;
			            		} else {
			                		$scope.pageData.showLoader = false;
			                		toastr.error( result.message, 'Error' );
			            		}
			        		}, function( error ) {
			            		$scope.pageData.showLoader = false;				
			            		toastr.error( error, 'Error' );
			        		} );
			        	}, 100);
                    }
                },
                No: {
                    action : function() {  
                    	return true;
                    }
                }
            },
        });
    }
    self.addFileToUpload = function( e, fileIdx ) {
    	var file = e.files[0];  
    	if( angular.isDefined( file ) ) {
	        if( file.size <= $scope.pageData.maxFileSize ) {
	            console.log('file type: ' , file.type);
	            //restrict file types
	            if(file.type == 'application/zip' || file.type == 'zip' || file.type == 'exe'){
	                toastr.error( "Restricted file type: " + file.type, '' );
	            }else{
	                //chunk file upload in case of bigger files
	                var attachmentName = file.name;
	                var attachmentBody = '';
	                console.log('Size in bytes: ', file.size);
	                var fileReader = new FileReader();
	                fileReader.onloadend = function(e) {
	                    var attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
	                    positionIndex=0;
	                    //console.log("Total Attachment Length: " + fileSize);
	                    $scope.pageData.doneUploading = false;
	                    //if( fileSize <= positionIndex + $scope.pageData.chunkSize ) {
	                    if( file.size <= $scope.pageData.positionIndex + $scope.pageData.chunkSize ) {
	                        attachmentBody = attachment.substring( $scope.pageData.positionIndex );
	                        $scope.pageData.doneUploading = true;
	                    } else {
	                        attachmentBody = attachment.substring( $scope.pageData.positionIndex, 
	                        $scope.pageData.positionIndex + $scope.pageData.chunkSize);
	                    }
	                    
                    	$scope.pageData.attachments[ fileIdx ] = { id: '', name : attachmentName, body : attachmentBody };
                    	$scope.$apply();
	                    console.log( 'attachments: ',$scope.pageData.attachments );
	                    console.log("Uploading " + attachmentBody.length );
	                }
	                fileReader.onerror = function(e) {
	                    toastr.error( "There was an error reading the file.  Please try again.", '' );
	                }
	                fileReader.onabort = function(e) {
	                    toastr.error( "There was an error reading the file.  Please try again.", '' );
	                }
	                
	                fileReader.readAsBinaryString(file);  //Read the body of the file
	            }
	        }else {
	            toastr.error( "File must be under 2 MB in size.  Your file is too large.  Please try again.", '' );
	        }
    	} else {
    		$scope.pageData.attachments[ fileIdx ] = angular.copy( self.defaultAttachment );
    		$scope.$apply();
    	}
    }
	$scope.uploadFile = function( e ) {
		console.log( 'files: ',e, e.files, $( e ).data( 'idx' ) );
		var fileIdx = $( e ).data( 'idx' );		
		self.addFileToUpload( e, fileIdx );		
	}
	self.isDataValid = function() {
		var isValid = true;
		//validate attachments
		var notUploadedAttachment = _.findWhere( $scope.pageData.attachments, { id : '', body : '' } );
		console.log( 'notUploadedAttachment',notUploadedAttachment );
		if( angular.isDefined( notUploadedAttachment ) ) {
			isValid = false;
		} else { //validate nominators
			var notVerifiedNominator = _.findWhere( $scope.pageData.nominators, { isVerified : false } );
			console.log( 'notVerifiedNominator',notVerifiedNominator, angular.isDefined( notVerifiedNominator ) );
			if( angular.isDefined( notVerifiedNominator ) ) {
				isValid = false;
			}
		}
		return isValid;
	}
	/*
	* Description: Validate nominator on click of Verify Nominator button
	* @baseUrl : Base URL which needs to be modified ( to which extra URL params need to add )
	*/
	/*function updateQueryParamsOfURLCustom( baseUrl ) {
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
	}*/
	$scope.nextStep = function() {
		console.log( 'isValid', self.isDataValid() );
		if( self.isDataValid() ) {
			var newAttachments = _.filter( $scope.pageData.attachments, function( attachment ) {
				return attachment.id == '' && attachment.body != '';
			} );
			var oldAttachmentIds = _.filter( $scope.pageData.attachments, function( attachment ) {
				return attachment.id != '';
			} ).map( function( attachment ) { return attachment.id; } );
			console.log( 'newAttachments: ', newAttachments, 'nominators', $scope.pageData.nominators, 'oldAttachmentIds', oldAttachmentIds );
			var nominatorIds = $scope.pageData.nominators.map( function( nom ) { return nom.nominatorId; } );			
			console.log( 'nominatorIds: ', nominatorIds );
			if( nominatorIds.length && $scope.pageData.attachments.length ) {
				$scope.pageData.showLoader = true;
				//remove hashKey from list
				newAttachments = JSON.parse( angular.toJson( newAttachments ) );
		        Remoting.nextStep( $scope.pageData.meta.ContactId, $scope.stepId, newAttachments, nominatorIds, oldAttachmentIds ).then( 
		        	function( result ) {
			            console.log( 'nextStep result: ', result );
			            if( result.isSuccess ) {
			            	//window.location.href = updateQueryParamsOfURLCustom( $scope.pageData.meta.nextStepUrl );
			            	window.location.href = updateQueryParamsOfURL( $scope.pageData.meta.nextStepUrl, true );
			            } else {
			                $scope.pageData.showLoader = false;
			                toastr.error( result.message, 'Error' );
			            }
			        }, function( error ) {
			            $scope.pageData.showLoader = false;				
			            toastr.error( error, 'Error' );
			        } 
			    );
		 	} else {
		 		toastr.error( 'Please fill all required data', 'Error' );
		 	}
		} else {
			toastr.error( 'Please fill all required data', 'Error' );
		}
		console.log( 'attachments',$scope.pageData.attachments );
	}
} );

/*
*  Toast messages configuration
*/
app.config( function( toastrConfig ) {
    angular.extend( toastrConfig, {
        maxOpened: 1,
        preventOpenDuplicates: true
    });
});