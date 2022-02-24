/**
 * Created by lauren.lezberg on 4/25/2020.
 */
({
    doInit: function (cmp, event, helper) {

        var retURL = helper.getRetURL(cmp, event);
        console.log('retURL: ' + retURL);
        // var uri_enc = encodeURI(retURL);
        // console.log('uri_enc: ' + uri_enc);
        var uri_dec = decodeURIComponent(retURL);
        console.log('uri_dec: ' + uri_dec);

        setTimeout(function () {
            // window.open(decodeURI(retURL), '_self');
            window.location.href = uri_dec;
        }, 60000);

    }
})