/**
 * Created by lauren.lezberg on 12/13/2019.
 */
({
    getFieldsInFieldset: function(cmp, event, selectedOptionValue){

        console.log("allPreferences: " + JSON.stringify(cmp.get("v.allPreferences")));
        var fieldSets = cmp.get("v.allPreferences");
        console.log('selectedOptionValue: ' + JSON.stringify(selectedOptionValue));
        for(var key in fieldSets){
             console.log('key: ' + key);

            if(key.toString() == selectedOptionValue.toString()){
                console.log('found selected option: ' + fieldSets[key]);
                cmp.set("v.FSfields", fieldSets[key]);
            }
        }
    }
})