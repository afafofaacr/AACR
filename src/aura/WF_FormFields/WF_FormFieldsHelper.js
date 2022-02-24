/**
 * Created by afaf.awad on 9/29/2021.
 */

({
    selectOptions : function(cmp, field){
        let choices = field.sqRecord.Question_Responses__c.split('\n');
        let options = [];
        choices.forEach(c => {
            options.push({label: c, value: c});
        })
        // console.log('options = ' + JSON.stringify(options));
        cmp.set('v.options', options);

    },


});