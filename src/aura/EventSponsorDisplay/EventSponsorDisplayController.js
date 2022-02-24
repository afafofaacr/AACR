/**
 * Created by afaf.awad on 6/29/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('eventId == ' + cmp.get('v.eventId'));
        console.log('orientation = ' + cmp.get('v.orientation'));
        let action = cmp.get("c.getSponsors");
        action.setParams({
            'eventId' : cmp.get('v.eventId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                // console.log(JSON.stringify(data));
                let level1 = [];
                let level2 = [];
                let level3 = [];
                data.forEach((item) => {
                    switch(item.sponsor.Level__c){
                        case '1':
                            level1.push(item);
                            break;
                        case '2':
                            level2.push(item);
                            break;
                        case '3':
                            level3.push(item);
                            break;
                    }
                });
                cmp.set('v.sponsorLevel1', level1);
                cmp.set('v.sponsorLevel2', level2);
                cmp.set('v.sponsorLevel3', level3);


            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    },
});