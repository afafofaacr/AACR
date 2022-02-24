({
    retrieveItems: function (cmp, callback) {
        console.log('retrieve items...');



        var action = cmp.get('c.getEvents'),
            filters = cmp.get('v.filters'),
            spinner = cmp.find('spinner'),
            zoneId = cmp.get('v.zoneId'),
            communityPrefix = '';


        if(typeof zoneId === 'undefined' || !zoneId) {
            zoneId = '';
        }

        var getUrl = window.location;
        var baseUrl = getUrl.protocol + "//" + getUrl.host;
        // console.log('url: ' + baseUrl);
        // if(typeof $A.get("$SfdcSite") !== 'undefined'){
            communityPrefix = baseUrl;
        // }

        // console.log('communityPrefix: ' + communityPrefix);

        $A.util.removeClass(spinner, "slds-hide");
        cmp.set('v.listItems', []);

        console.log('page: ' + cmp.get("v.currentPage"));
        console.log('filters: ' + JSON.stringify(cmp.get("v.filters")));

        action.setParams({
            zoneId:       zoneId,
            jsonFilters:  JSON.stringify(filters),
            page:         cmp.get('v.currentPage'),
            itemsPerPage: cmp.get('v.itemsPerPage')
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();
            // console.log('resVal: ' + JSON.stringify(resVal));

            if (state === 'SUCCESS') {
                for(var i=0; i < resVal.length; i+=1){
                    console.log("Val: " + JSON.stringify(resVal[i]));
                    if(resVal[i].listImageURL === ''){
                        resVal[i].listImageURL = communityPrefix + '/resource/BrEvents/images/list-pic.jpg';
                    } else{
                        if (resVal[i].listImageURL.startsWith('http://') || resVal[i].listImageURL.startsWith('https://')) {
                            resVal[i].listImageURL = resVal[i].listImageURL;
                        } else {
                            resVal[i].listImageURL = communityPrefix + '/' + resVal[i].listImageURL;
                        }
                    }
                }

                cmp.set('v.listItems', resVal);

                console.log('set list items...');

                if (typeof callback === 'function') {
                    callback();
                }
            } else {
                console.log('ERROR');
            }
            $A.util.addClass(spinner, "slds-hide");
        });

        $A.enqueueAction(action);
    },

    retrievePagesTotal: function(cmp) {
        console.log('retrievePagesTotal...');
        var action = cmp.get('c.getEventsCount'),
            itemsPerPage = cmp.get('v.itemsPerPage'),
            filters = cmp.get('v.filters'),
            zoneId = cmp.get('v.zoneId'),
            spinner = cmp.find('spinner');

        if(typeof zoneId === 'undefined' || !zoneId) {
            zoneId = '';
        }

        $A.util.removeClass(spinner, "slds-hide");

        action.setParams({
            zoneId:     zoneId,
            filterData: filters
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                itemsCount = 0,
                pagesTotal = 1;

            if (state === 'SUCCESS') {
                itemsCount = response.getReturnValue();

                if (itemsCount > 0) {
                    pagesTotal = Math.ceil(itemsCount/itemsPerPage);
                }

                cmp.set('v.pagesTotal', pagesTotal);
            }
            $A.util.addClass(spinner, "slds-hide");
        });

        $A.enqueueAction(action);
    },

    inArray: function(arr, val) {
        return arr.some(function(arrVal) {
            return val === arrVal;
        });
    },

    resetPaginationControlls: function(cmp) {
        cmp.set('v.currentPage', 1);
        cmp.set('v.pagesTotal', 1);
    },

    toggleTabs: function(cmp, tabValue) {
        var tabAll = cmp.find('tabAll'),
            tabPast = cmp.find('tabPast'),
            tabAttending = cmp.find('tabAttending');

        if(tabValue === 'Attending'){
            $A.util.addClass(tabAttending, 'active');
            $A.util.removeClass(tabAll, 'active');
            $A.util.removeClass(tabPast, 'active');
        } else if(tabValue === 'Past'){
            $A.util.addClass(tabPast, 'active');
            $A.util.removeClass(tabAll, 'active');
            $A.util.removeClass(tabAttending, 'active');
        } else{
            $A.util.addClass(tabAll, 'active');
            $A.util.removeClass(tabAttending, 'active');
            $A.util.removeClass(tabPast, 'active');
        }
    },

    resetFilters: function(cmp){
        cmp.set('v.filters', {
            search: '',
            tab: '',
            date: ''
        });
    },

    scrollToTop: function() {
        window.scrollTo(0, 0);
    }
})