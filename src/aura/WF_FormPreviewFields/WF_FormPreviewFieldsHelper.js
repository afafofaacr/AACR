/**
 * Created by afaf.awad on 10/29/2021.
 */

({

    selectOptions : function(cmp, field){
        let choices = field.Question_Responses__c.split('\n');
        let options = [];
        choices.forEach(c => {
            options.push({label: c, value: c});
        })
        // console.log('options = ' + JSON.stringify(options));
        cmp.set('v.options', options);

        // console.log('question type == ' + field.sqRecord.Question_Type__c);
        // if(field.sqRecord.Question_Type__c == 'Single-Select Horizontal'){
        //     console.log('is horizontal');
        //     let cmpTarget = cmp.find('singleSelect');
        //     $A.util.addClass(cmpTarget, 'customRadioCls');
        // }
    },
});