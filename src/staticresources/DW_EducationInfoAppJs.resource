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

// DWEducationInfoApp - Angular JS App
var DWEducationInfoApp = angular.module('DWEducationInfoApp', ["ngToast", "Remoting", "dwMonthYearPicker", 'cp.ngConfirm']);


// On Education edit button click we need to open that in fixed edit view on top 
// of Education List so we need to scroll up to it and highlight editable eduction 
// record for that we are using $anchorScroll to scroll to desired location on page
// Set extra offset of 10 pixcel for $anchorScroll
DWEducationInfoApp.run(['$anchorScroll', function($anchorScroll) {
    $anchorScroll.yOffset = 120;
}]);

DWEducationInfoApp.directive('integerOnly', function(){
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
DWEducationInfoApp.controller('DWEducationController', DWEducationController);
DWEducationController.$inject = ['$q', '$filter', '$timeout', '$scope', 'ngToast', 'Remoting', '$location', '$document', '$window', '$anchorScroll', '$ngConfirm'];
function DWEducationController($q, $filter, $timeout, $scope, ngToast, Remoting, $location, $document, $window, $anchorScroll, $ngConfirm) {
    var vm = this;    
    
    // GENERAL VARIABLES
    vm.stepId = __getUrlParameter("id") || "";
    vm.stepOrder = __getUrlParameter("order") || "";
    vm.page = {
        loader: false,
        isInitMetaLoading: false,
        notFound: false
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
    vm.educations = [];
    vm.education = {};
    vm.showEducationWrap = false;
    vm.deletedEducationIdList = [];

    // APPLICATION BOOTSTRAP POINT
    vm.doInit = function() {
        vm.getEducationInformation();
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

    /*function updateQueryParamsOfURL( baseUrl ) {
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
    }*/
    
    vm.goToNextStep = function (event) {
        $window.location.href = updateQueryParamsOfURL( vm.nextStepURL, true );
    }
    
    vm.canelCurrentStep = function (event) {
        //$window.location.href = updateQueryParamsOfURL( vm.cancelStepURL );
        $window.location.href = vm.cancelStepURL;
    }
    
    vm.goToPreviousStep = function (event) {
        $window.location.href = updateQueryParamsOfURL( vm.previousStepURL, true );
    }

    // CONTACT & EDUCATION CRUD
    vm.getEducationInformation = function () {
        vm.page.loader = true;
        Remoting.getEducationInformation(vm.stepId).then(function (result) {
            vm.page.loader = false;
            console.log("[AQQ-DATA]: ", result);
            if (result.isSuccess) {
                __setupEducationInformationData(result);
            } else {
                ngToast.create({ className: "danger", content: result.message });                
            }
        }, function (event) {
            vm.page.loader = false;            
            ngToast.create({ className: "danger", content: event.message });
        });
    }
    
    function __setupEducationInformationData (result) {        
        // Populate Contact Education Data
        defaultEducation.Education_Related_to_Contact__c = result.data.contactId; 
        vm.academicDegreeMap = result.data.AcademicDegreeMap;
        vm.educationStatusMap = result.data.EducationStatusMap;
        console.log( "vm.academicDegreeMap: ", vm.academicDegreeMap );
        vm.educations = [];
        _.each(result.data.Educations, function (education) {
            var newEducation = _.extend(_.clone(defaultEducation), education);            
            vm.educations.push(newEducation);
        });
        
        // Populate Redirect URL's
        vm.cancelStepURL = result.data.CancelStepURL;
        vm.nextStepURL = result.data.NextStepURL;
        vm.previousStepURL = result.data.PreviousStepURL;
        //keep add new form open if no records added
        if( !vm.educations.length ) {
            vm.addNewEducation();
        }        
    }
    
    vm.addNewEducation = function () {
        vm.education = _.clone(defaultEducation);
        vm.education.Id = "TempEdu_" + new Date().getTime();
        vm.showEducationWrap = true;
    }

    function __validateEducation() {
        console.log( "status: ",vm.education.Current_Education_Status__c, _.isEmpty( vm.education.Current_Education_Status__c ) );
        if ( _.isEmpty(vm.education.Name) || _.isEmpty(vm.education.Current_Education_Status__c) || _.isEmpty(vm.education.Date_of_Expected_Graduation__c)) {
            return false;
        }     
        return true;
    }
    
    vm.saveEducationEntry = function () {
        console.log( 'validate: ', __validateEducation(), vm.education );
        if ( __validateEducation() ) {
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
    
    function __validateData() {
        /*
        // Mark form as Valid
        ngForm.$invalid = false;        
        
        return !ngForm.$invalid;
        */
        return true;
    }
    
    vm.updateData = function (event) {
        var educationInformation = {};
        
        if ( vm.educations.length ) {
            // Prepare Contact Education Data
            educationInformation.Educations = [];
            _.each(vm.educations, function (education) {
                var newEducation = _.pick(education, ["Name", "Degree__c", "Degree_Completion_Year__c", 
                    "Date_of_Expected_Graduation__c", "Education_Related_to_Contact__c", "Current_Education_Status__c"]);
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
                educationInformation.Educations.push(newEducation);
            });
            
            // Assign Deleted Eductions Id List
            educationInformation.DeletedEducationIdList = vm.deletedEducationIdList;            
            
            // Post educationInformation
            console.log("[AQQ-POST-DATA]: ", educationInformation);
            
            vm.page.loader = true;
            Remoting.saveEducationInformation( JSON.stringify( educationInformation ) , vm.stepId ).then(function (result) {                
                console.log("[AQQ-POST-RESPONSE]: ", result);
                if (result.isSuccess) {
                    ngToast.create({ className: "success", content: result.message });
                    // On Success go to next step of wizard
                    vm.goToNextStep();
                } else {
                    vm.page.loader = false;
                    ngToast.create({ className: "danger", content: result.message });
                }
            }, function (event) {
                vm.page.loader = false;
                ngToast.create({ className: "danger", content: event.message });
            });
        } else {
            ngToast.create({ className: "danger", content: 'Please fill data for at least one record' });
        }
    }
}
DWEducationInfoApp.config(['ngToastProvider', function(ngToast) {
    ngToast.configure({
      combineDuplications: true,
      horizontalPosition: 'center'
    });
}]);