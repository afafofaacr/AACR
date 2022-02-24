/**
 * Created by afaf.awad on 6/30/2021.
 */

({
    goToLink :  function (cmp,event,helper){
        let sponsorUrl = event.target.id;
        console.log('url == ' + sponsorUrl);
        window.open( sponsorUrl, '_blank');
    }
});