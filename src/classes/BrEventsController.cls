public without sharing class BrEventsController {
    public String zoneId {get;set;}

    public BrEventsController(){
        zoneId = BrEventsHelper.getConfigValue('default zone id');
    }

    @AuraEnabled
    public static Boolean testMethodBoolean(){
        return true;
    }

    @AuraEnabled
    public static Map<String, String> getUserInfo(){
        System.debug('getUserInfo...');
        Map<String, String> uInf = new Map<String, String>();
        uInf.put('Id', UserInfo.getUserId());
        uInf.put('Name', UserInfo.getName());
        uInf.put('Username', UserInfo.getUserName());
        uInf.put('Email', UserInfo.getUserEmail());
        uInf.put('Type', UserInfo.getUserType());

        System.debug('usrInfo: ' + uInf);
        return uInf;
    }
}