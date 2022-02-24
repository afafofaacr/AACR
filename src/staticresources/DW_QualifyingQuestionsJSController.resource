/* 
	Name: DW_QualifyingQuestionsJSController - v1.0
    
    External Resources:
		1 - Moment.js - https://momentjs.com/         
        2 - Bootstrap (currently v3.3.7) - https://getbootstrap.com/    
    	3 - Bootstrap 3 Datepicker v4 - https://eonasdan.github.io/bootstrap-datetimepicker/    
    	4 - angular-eonasdan-datetimepicker (AngularJS Directive) - https://github.com/atais/angular-eonasdan-datetimepicker
    
    Author: Ajit
    
    CreatedDate: 07/31/2018
    
    LastModifiedDate: 07/31/2018
    
    Conventions Used:
    1 - DTO's & Classes are CamelCase (U)
    2 - Methods & Variables are camelCase (L)
    3 - Internal/Private/Non-exposed methods & variables are prefixed with __ (double underscore)
    4 - For ng-controller "Controller as" syntax is used. "$scope" is exposed as "vm".
    5 - In ViewModel ($scope or vm) Some Methods & Variables prefixed with __ (double undersocre)
    	are used as overloaded methods to their counterpart methods and are private, non-exposed methods
        In short such methods and variable are not available for Two-way bindings.
*/

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


// dw-month-year-picker
angular.module('dwMonthYearPicker', []).directive('dwMonthYearPicker', function ($filter) {
    return {
        restrict: 'E',     
        
        scope: {			
            date: '=?',
            selectedDate: '=?'
        },
        
        templateUrl: '/directive/dw-monthyearpicker.html',
        
        controller: ['$scope', function ($scope) {
            $scope.day = null;
			//$scope.month = null;
			//$scope.year = null;
			
            // Create Month Map            
            $scope.monthMap = [ { Name: 'Month', Month: '' },{ Name: 'Jan', Month: 0 }, { Name: 'Feb', Month: 1 }, { Name: 'Mar', Month: 2 },
                               { Name: 'Apr', Month: 3 }, { Name: 'May', Month: 4 }, { Name: 'Jun', Month: 5 }, 
                               { Name: 'Jul', Month: 6 }, { Name: 'Aug', Month: 7 }, { Name: 'Sept', Month: 8 },
                               { Name: 'Oct', Month: 9 }, { Name: 'Nov', Month: 10 }, { Name: 'Dec', Month: 11 }];
			$scope.month = $scope.monthMap[ 0 ];
			// Create Year Map			
			var startYear = 1950;
            $scope.yearMap = [];
			for (var i = 0; i < 100; i++) {
				startYear = startYear + 1;
                $scope.yearMap.push({ Name: startYear, Year: startYear });
			}
            $scope.yearMap.unshift( { Name: 'Year', Year: '' } );
            $scope.year = $scope.yearMap[ 0 ];
            $scope.$watch('date', function(date) {
                if (typeof($scope.date) != 'undefined' && $scope.date != '') {
                    $scope.day = moment($scope.date);
                } else {
					$scope.day = moment();
				}
                if (typeof($scope.date) != 'undefined' && $scope.date != '') {
                    $scope.month = _.find($scope.monthMap, { Month: $scope.day.month()});
                    $scope.year = _.find($scope.yearMap, { Year: $scope.day.year()});   
                }             
            });
            
            $scope.updateDate = function () {
                //if( $scope.month != null && $scope.year != null ) {
                console.log( "in update date", $scope.month.Month, $scope.year.Year );
                if( $scope.month.Month != '' && $scope.year.Year != '' ) {
                    console.log( "in date format" );
                    $scope.date = moment({ day: 1, month: $scope.month.Month, year: $scope.year.Year }).format("YYYY-MM-DD");
                    console.log('date',$scope.date);
                } else {
                    if( $scope.month.Month == '' && $scope.year.Year == '' ) {
                        $scope.date = '';
                    }
                }
            }
        }]
    };
});


// dw-dual-multi-select Directive
angular.module('dwDualMultiSelect', []).directive('dwDualMultiSelect', function ($filter) {
    return {
        restrict: 'E',     
        
        scope: {			
            orderProperty: '=?',
            rawItems: '=',
            selectedItems: '='
        },
        
        templateUrl: '/directive/dw-dualmultiselect.html',
        
        controller: ['$scope', function ($scope) {            
            // Set default Order Property
            $scope.orderProperty = (typeof($scope.orderProperty) == 'undefined') ? 'Name' : $scope.orderProperty;
            
            // If rawItems is supplied then split it among items and selectedItems
            $scope.$watch('rawItems', function(rawItems) {
                if (typeof($scope.rawItems) != 'undefined') {
                    var items = [], selectedItems = [];
                    _.each($scope.rawItems, function (rawItem) {
                        if (rawItem.IsSelected) {
                            selectedItems.push(rawItem)
                        } else {
                            items.push(rawItem);
                        }
                    });   
                    $scope.items = items;
                    $scope.selectedItems = selectedItems;
                }
            });
            
            $scope.prepareToMove = function (item) {                
                item.IsReadyToMove = !item.IsReadyToMove;
            };
            
            $scope.transfer = function (from, to) {
                var itemsToMove = _.remove(from, function(item) {
                    return item.IsReadyToMove == true;
                });
                
                _.each(itemsToMove, function (item) {
                    item.IsReadyToMove = false;
                    to.push(item);
                });
            };
        }]
    };
});


// DWQualifyingQuestionsApp - Angular JS App
var DWQualifyingQuestionsApp = angular.module('DWQualifyingQuestionsApp', ["ngToast", "Remoting", "dwDualMultiSelect", "dwMonthYearPicker", 'cp.ngConfirm']);


// On Education edit button click we need to open that in fixed edit view on top 
// of Education List so we need to scroll up to it and highlight editable eduction 
// record for that we are using $anchorScroll to scroll to desired location on page
// Set extra offset of 10 pixcel for $anchorScroll
DWQualifyingQuestionsApp.run(['$anchorScroll', function($anchorScroll) {
  	$anchorScroll.yOffset = 120;
}]);

DWQualifyingQuestionsApp.directive('integerOnly', function(){
    return {
        require: 'ngModel',
        link: function(scope, element, attrs, modelCtrl) {
            modelCtrl.$parsers.push(function (inputValue) {
                var transformedInput = inputValue ? inputValue.replace(/[^0-9]/g,'') : null;
                if (transformedInput!=inputValue) {
                    modelCtrl.$setViewValue(transformedInput);
                    modelCtrl.$render();
                }
                return transformedInput;
            });
        }
    };
});

// Main Controller, Injector and Definition
DWQualifyingQuestionsApp.controller('DWQualifyingQuestionsController', DWQualifyingQuestionsController);
DWQualifyingQuestionsController.$inject = ['$q', '$filter', '$timeout', '$scope', 'ngToast', 'Remoting', '$location', '$document', '$window', '$anchorScroll', '$ngConfirm'];
function DWQualifyingQuestionsController($q, $filter, $timeout, $scope, ngToast, Remoting, $location, $document, $window, $anchorScroll, $ngConfirm) {
    var vm = this;    
    
    // GENERAL VARIABLES
    vm.stepId = __getUrlParameter("id") || "";
    vm.stepOrder = __getUrlParameter("order") || "";
    vm.page = {
        loader: false,
        isInitMetaLoading: false,
        notFound: false
    };
    var defaultContact = { 
        Id: '',
        Major_Focus__c: '',
        Organ_Sites__c: '',
        Primary_Research_Area_of_Expertise__c: '',
        Specific_Research_Areas__c: '',
        Additional_Research_Areas__c: '',
        Other_Research_Areas__c: ''
    };
    var defaultEducation = {
        Id: '', 
        Name: '',
        Current_Education_Status__c: '', 
        //Date_of_Expected_Graduation__c: null,       
        Degree__c: '', 
        Degree_Completion_Year__c: '', 
        Education_Related_to_Contact__c: ''
    };
    vm.contact = {};
    vm.educations = [];
    vm.education = {};
    vm.showEducationWrap = false;
    vm.deletedEducationIdList = [];
    

    
    
    // APPLICATION BOOTSTRAP POINT
    vm.doInit = function() {
        vm.getQualifyingQuestionsData();
    }
    

    
    
    // COMMON FUNCS
    function __getUrlParameter (name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)' , "i" );
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
	}
    
    function __mapToString (mapArr) {
        if (typeof(mapArr) != undefined) {
            return mapArr.join(';');
        } else {
            return '';
        }
    }

    function updateQueryParamsOfURL( baseUrl ) {
        //static query params to add in URL
        var queryParams = [
            {
                key : 'isjoin',
                value : __getUrlParameter( 'isjoin' )
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
    
    vm.goToNextStep = function (event) {
    	$window.location.href = updateQueryParamsOfURL( vm.nextStepURL );
    }
    
    vm.canelCurrentStep = function (event) {
        $window.location.href = updateQueryParamsOfURL( vm.cancelStepURL );
    }
    
    vm.goToPreviousStep = function (event) {
        $window.location.href = updateQueryParamsOfURL( vm.previousStepURL );
    }
    
    
    
    
    
    // CONTACT & EDUCATION CRUD
    vm.getQualifyingQuestionsData = function () {
        vm.page.loader = true;
        Remoting.getQualifyingQuestionsData(vm.stepId).then(function (result) {
            vm.page.loader = false;
            console.log("[AQQ-DATA]: ", result);
            if (result.Success) {
                __setupQualifyingQuestionsData(result);
            } else {
                ngToast.create({ className: "danger", content: result.Message });                
            }
        }, function (event) {
            vm.page.loader = false;            
            ngToast.create({ className: "danger", content: event.message });
        });
    }
    
    function __setupQualifyingQuestionsData (result) {
        // Populate Contact Data
        vm.contact = _.extend(_.clone(defaultContact), result.Data.Contact);
        vm.contact.Major_Focus__c = (typeof(vm.contact.Major_Focus__c) != 'undefined') ? vm.contact.Major_Focus__c.split(";") : [];
        vm.contact.Organ_Sites__c = (typeof(vm.contact.Organ_Sites__c) != 'undefined') ? vm.contact.Organ_Sites__c.split(";") : [];        
        vm.contact.Specific_Research_Areas__c = (typeof(vm.contact.Specific_Research_Areas__c) != 'undefined') ? vm.contact.Specific_Research_Areas__c.split(";") : [];
        vm.contact.Additional_Research_Areas__c = (typeof(vm.contact.Additional_Research_Areas__c) != 'undefined') ? vm.contact.Additional_Research_Areas__c.split(";") : [];
        vm.primaryResearchAreaMap = result.Metadata.PrimaryResearchAreaMap;
        
        // Populate Contact Education Data
        defaultEducation.Education_Related_to_Contact__c = vm.contact.Id;
        vm.academicDegreeMap = result.Metadata.AcademicDegreeMap;
        vm.educations = [];
        _.each(result.Data.Educations, function (education) {
			var newEducation = _.extend(_.clone(defaultEducation), education);            
        	vm.educations.push(newEducation);
        });
        
        // Populate Dual Picklist Data/Metadata
        vm.majorFocusMap = [];
        _.each(result.Metadata.MajorFocusMap, function (value, key) {
            var item = { Id: "Item_" + new Date().getTime(), Name: value, IsReadyToMove: false };
            item.IsSelected = (vm.contact.Major_Focus__c.indexOf(value) >= 0) ? true : false;            
            vm.majorFocusMap.push(item);
        });
        vm.organSiteMap = [];
        _.each(result.Metadata.OrganSiteMap, function (value, key) {
            var item = { Id: "Item_" + new Date().getTime(), Name: value, IsReadyToMove: false };
            item.IsSelected = (vm.contact.Organ_Sites__c.indexOf(value) >= 0) ? true : false;            
            vm.organSiteMap.push(item);
        });
        vm.specificResearchAreaMap = [];
        _.each(result.Metadata.SpecificResearchAreaMap, function (value, key) {
            var item = { Id: "Item_" + new Date().getTime(), Name: value, IsReadyToMove: false };
            item.IsSelected = (vm.contact.Specific_Research_Areas__c.indexOf(value) >= 0) ? true : false;            
            vm.specificResearchAreaMap.push(item);
        });
        vm.additionalResearchAreaMap = [];
        _.each(result.Metadata.AdditionalResearchAreaMap, function (value, key) {
            var item = { Id: "Item_" + new Date().getTime(), Name: value, IsReadyToMove: false };
            item.IsSelected = (vm.contact.Additional_Research_Areas__c.indexOf(value) >= 0) ? true : false;            
            vm.additionalResearchAreaMap.push(item);
        }); 
        
        // Populate Redirect URL's
        vm.cancelStepURL = result.Metadata.CancelStepURL;
        vm.nextStepURL = result.Metadata.NextStepURL;
        vm.previousStepURL = result.Metadata.PreviousStepURL;
    }
    
    vm.addNewEducation = function (event) {
        vm.education = _.clone(defaultEducation);
        vm.education.Id = "TempEdu_" + new Date().getTime();
        vm.showEducationWrap = true;
    }

    function __validateEducation() {
        if (_.isEmpty(vm.education.Name)) {            
            return false;
        }    
        
        return true;
    }
    
    vm.saveEducationEntry = function () {
        console.log( 'validate: ', __validateEducation(), vm.education );
        if (__validateEducation()) {
            /*if (_.startsWith(vm.education.Id, "TempEdu")) {
                console.log( "in push" );
                vm.educations.push(_.clone(vm.education));
            } else {
            	var existingEducation = _.find(vm.educations, { Id: vm.education.Id });
                _.extend(existingEducation, vm.education);      
                console.log( 'existingEducation', existingEducation );          
            }*/
            var existingEducation = _.find(vm.educations, { Id: vm.education.Id });
            if( angular.isUndefined( existingEducation ) ) {
                vm.educations.push(_.clone(vm.education));
            } else {
                _.extend(existingEducation, vm.education);   
            }
            vm.hideEducationModal();
        } else {
            ngToast.create({ className: "warning", content: "Please enter valid data for Education Entry" });
        }
    }   
    
    vm.hideEducationModal = function (event) {
        vm.showEducationWrap = false;
        vm.education = _.clone(defaultEducation);        
    }
    
    vm.editEducationEntry = function (event, education) {
        vm.education = _.clone(education);
        vm.showEducationWrap = true;
        $timeout(function () {
        	$anchorScroll("educationNewEditView");
            $(".education-edit-wrap").addClass("highlight");
            $timeout(function () {
                $(".education-edit-wrap").removeClass("highlight");
            }, 1500);
        }, 100);
    }
    
    vm.removeEducationEntry = function (event, education) {
        $ngConfirm({
            title: 'Confirm!',
            content: 'Do you want to delete this entry?',
            buttons: {
                yes: {
                    btnClass: "btn-blue",
                    action : function() {
                        $timeout( function() {
                            _.remove(vm.educations, function (item) {
                                return item.Id == education.Id;
                            });
                            if (!_.startsWith(education.Id, "TempEdu")) {
                                vm.deletedEducationIdList.push(education.Id);
                            }
                        }, 100 );
                       
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
    
    function __validateData(userContactData) {
        /*
        // Mark form as Valid
        ngForm.$invalid = false;        
        
        return !ngForm.$invalid;
        */
        //make Major focus field compulsory
        console.log( 'Major_Focus__c',userContactData.Major_Focus__c, typeof userContactData.Major_Focus__c );
        if( userContactData.Major_Focus__c && !userContactData.Major_Focus__c.length ) {
            return false;
        }  
        console.log( "userContactData.Other_Research_Areas__c ", userContactData.Other_Research_Areas__c  );
        if( userContactData.Primary_Research_Area_of_Expertise__c == 'Other (please specify) | other' 
            && ( userContactData.Other_Research_Areas__c == ''  || angular.isUndefined( userContactData.Other_Research_Areas__c ) ) ) {
            return false;
        }        
        return true;
    }
    
    vm.updateData = function (event) {
        var userContactData = {};
        
        if (__validateData(vm.contact)) {
            // Prepare Contact Data
            userContactData.Contact = { 
                Id: vm.contact.Id,
                Major_Focus__c: __mapToString(_.map(vm.contact.Major_Focus__c, 'Name')),
                Organ_Sites__c: __mapToString(_.map(vm.contact.Organ_Sites__c, 'Name')),
                Primary_Research_Area_of_Expertise__c: vm.contact.Primary_Research_Area_of_Expertise__c,
                Specific_Research_Areas__c: __mapToString(_.map(vm.contact.Specific_Research_Areas__c, 'Name')),
                Additional_Research_Areas__c: __mapToString(_.map(vm.contact.Additional_Research_Areas__c, 'Name')),
                Other_Research_Areas__c: vm.contact.Other_Research_Areas__c
            };
            
            // Prepare Contact Education Data
            userContactData.Educations = [];
            _.each(vm.educations, function (education) {
                var newEducation = _.pick(education, ["Name", "Degree__c", "Degree_Completion_Year__c", "Date_of_Expected_Graduation__c", "Education_Related_to_Contact__c"]);
                if ( angular.isDefined( newEducation.Date_of_Expected_Graduation__c ) 
                    && newEducation.Date_of_Expected_Graduation__c != '' 
                    && newEducation.Date_of_Expected_Graduation__c != null ) {
                	newEducation.Date_of_Expected_Graduation__c = moment(newEducation.Date_of_Expected_Graduation__c).format("YYYY-MM-DD");
                    newEducation.Date_of_Expected_Graduation__c = Date.parse(newEducation.Date_of_Expected_Graduation__c);
                } else {
                    //var my_date = new Date()
                    newEducation.Date_of_Expected_Graduation__c = null;
                }               
                if (!_.startsWith(education.Id, "TempEdu")) {
                    newEducation.Id = education.Id;
                }
               	userContactData.Educations.push(newEducation);
            });
            
            // Assign Deleted Eductions Id List
            userContactData.DeletedEducationIdList = vm.deletedEducationIdList;            
            
            // Post UserContactData
            console.log("[AQQ-POST-DATA]: ", userContactData);
            
            vm.page.loader = true;
            Remoting.saveUserContactData( JSON.stringify( userContactData) , vm.stepId ).then(function (result) {                
                console.log("[AQQ-POST-RESPONSE]: ", result);
                if (result.Success) {
                    // On Success go to next step of wizard
                    vm.goToNextStep();
                } else {
                    vm.page.loader = false;
                    ngToast.create({ className: "danger", content: result.Message });
                }
            }, function (event) {
                vm.page.loader = false;
                ngToast.create({ className: "danger", content: event.message });
            });
        } else {
            ngToast.create({ className: "danger", content: 'Please fill all required fields' });
        }
    }
}