/**
 * Created by afaf.awad on 8/31/2021.
 */

({
    sortData: function (cmp, fieldName, sortDirection) {
        let data = cmp.get("v.dimTagData");
        let reverse = sortDirection !== 'asc';
        fieldName = fieldName == 'link' ? 'tagName' : fieldName;
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        console.log('New data = ' + JSON.stringify(data));
        cmp.set("v.dimTagData", data);
    },

    sortBy: function (field, reverse, primer) {
        console.log('sorting...');
        let key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }

});