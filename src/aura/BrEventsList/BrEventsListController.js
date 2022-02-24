({
    doInit: function (cmp, event, helper) {
        console.log('list doInit..');
        var dateFilter = cmp.get('v.dateFilter');
        console.log('dateFIlter: ' + dateFilter);

        helper.resetFilters(cmp);

        if (dateFilter && dateFilter !== '') {
            cmp.set('v.filters.date', dateFilter);
        }

        helper.retrieveItems(cmp, function () {
            helper.retrievePagesTotal(cmp);
        });

    },
    openNextPage: function (cmp, event, helper) {
        var p = cmp.get('v.currentPage'),
            pagesTotal = cmp.get('v.pagesTotal');

        if (p < pagesTotal) {
            cmp.set('v.currentPage', p + 1);
            helper.retrieveItems(cmp);
            helper.scrollToTop();
        }
    },
    openPreviousPage: function (cmp, event, helper) {
        var p = cmp.get('v.currentPage');

        if (p > 1) {
            cmp.set('v.currentPage', p - 1);
            helper.retrieveItems(cmp);
            helper.scrollToTop();
        }
    },
    searchEvents: function (cmp, event, helper) {
        var query = cmp.get('v.searchQuery');

        cmp.set('v.filters.search', query);

        helper.resetPaginationControlls(cmp);
        helper.retrieveItems(cmp, function () {
            helper.retrievePagesTotal(cmp);
        });
    },

    selectTab: function (cmp, event, helper) {
        var targetEl = event.currentTarget,
            tabValue = targetEl.dataset.target;

        console.log('tabValue: ' + tabValue);

        cmp.set('v.filters.date', '');
        cmp.set('v.filters.tab', tabValue);
        helper.toggleTabs(cmp, tabValue);

        helper.resetPaginationControlls(cmp);
        helper.retrieveItems(cmp, function () {
            helper.retrievePagesTotal(cmp);
        });
    },

    retrieveItemsForDate: function(cmp, event, helper) {
        cmp.set('v.filters.date', event.getParam('date'));

        helper.resetPaginationControlls(cmp);
        helper.retrieveItems(cmp, function(){
            helper.retrievePagesTotal(cmp);
        });
    }
})