/**
 * Created by lauren.lezberg on 2/15/2019.
 */
({
    /**
     * @purpose Fonteva limitation (checkout component) - Sets browser cookie for checkout
     * @param cname
     * @param cvalue
     * @param exdays
     */
    setCookie : function(cname, cvalue, exdays){ 
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires="+d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    },
})