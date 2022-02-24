/**
 * Created by lauren.lezberg on 1/17/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('JP_JournalItem init...');
        if(cmp.get("v.selectedItem")==undefined){
            // console.log('selected item is undefined');
        } else {
            cmp.set("v.selected", true);
        }

        var map = cmp.get("v.itemPriceMap");
        var journals = cmp.get("v.items");
        var items = [];
        journals.forEach(function(option){
            var item = {
                "label": option.Fon_Association_Journal_Type__c + ' -  $' + map[option.Id],
                "value": option.Id,
            };
            items.push(item);
        });
        cmp.set("v.itemOptions", items);

    },

    launchOpenAccessJournal : function(cmp, event, helper){
        window.open(cmp.get("v.openAccessURL"), '_blank');
    },

    /**
     * @purpose When user selects from dropdown to change to or from online/print, the price gets updated to reflect that change
     * @param cmp
     * @param event
     * @param helper
     */
    onSelectChange : function (cmp, event, helper){
        console.log('JP_JournalItem onSelectChange...');

        var changeValue = event.getSource().get("v.value");
        cmp.set("v.selectedItem", changeValue);
        var priceMap = cmp.get("v.itemPriceMap");
        cmp.set("v.price", priceMap[changeValue]);
    },

    /**
     * @purpose Sets journal to selected which when saved will add to sales order
     * @param cmp
     * @param event
     * @param helper
     */
    addToList : function(cmp, event, helper){
        console.log('JP_JournalItem addToList...');

        if(cmp.get("v.selected")) {
            cmp.set("v.selected", false);
        } else {
            cmp.set("v.selected", true);
        }
    }
})