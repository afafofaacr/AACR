/**
 * Created by lauren.lezberg on 9/22/2020.
 */

({

    htmlDecode : function(input){

        var doc = new DOMParser().parseFromString(input, "text/html");
        // console.log('htmlDecode: ' + doc.documentElement.textContent);
        return doc.documentElement.textContent;
    },

    incrementPanel : function(cmp){
        console.log('incrementPanel...');
        var increment = cmp.get("v.intervalSeconds") * 1000;
        var index = 0;
        var images = cmp.get("v.cImages");

        if(images.length>1) {
            var timer = cmp.get("v.timer");
            // console.log('timer: ' + JSON.stringify(timer));
            if(timer==null || timer==undefined) {
                timer = setInterval(function () {
                    images.forEach(function (img, idx) {
                        // console.log('idx: ' + idx);
                        if (img.Id == cmp.get("v.selectedPanel")) {
                            if (idx + 1 > images.length - 1) {
                                index = 0;
                            } else {
                                index = idx + 1;
                            }
                        }
                    });
                    // console.log('index: ' + index);
                    // console.log('selected: ' + images[index].Id);
                    cmp.set("v.selectedPanel", images[index].Id);
                    this.incrementPanel(cmp);
                }, increment);
                cmp.set("v.timer", timer);
            }
        }
        // this.incrementPanel(cmp);
    }
});