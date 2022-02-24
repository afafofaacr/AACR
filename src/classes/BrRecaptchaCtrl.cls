/**
 * Controller class for lightning and visualforce components
 */
public with sharing class BrRecaptchaCtrl {
    /**
     * Returns domain obtained from util class
     *
     * @return Domain
     */
    @AuraEnabled
    public static String getDomain() {
        if ( Test.isRunningTest() ) {
            return 'Test domain';
        } else {
            return [SELECT Domain FROM Domain LIMIT 1].Domain;
        }
    }

    /**
     * Returns site key for recaptcha
     *
     * @return Site key
     */
    @AuraEnabled
    public static String getSiteKey() {
        String siteKey = '';

        BrEvents_Settings__c setting = BrEvents_Settings__c.getValues('recaptcha_key');

        if ( setting != null ) {
            siteKey = setting.Value__c;

        }

        if ( Test.isRunningTest() ) {
            return '1234';
        } else {
            return siteKey;
        }
    }

    @AuraEnabled
    public static List<String> getForceSiteDomain() {

        List<Site> siteList = [
                SELECT GuestUserId, Name,MasterLabel, Subdomain,
                        OptionsRequireHttps, UrlPathPrefix
                FROM Site
                WHERE Status = 'Active'
        ];

        List<String> siteFullUrlList = new List<String>();
        /** We can get instance of the org from organization object **/
        Organization org = [SELECT InstanceName,Name, IsSandbox, OrganizationType FROM Organization];
        if ( siteList != null && siteList.size() != 0 ) {
            for (Site s : siteList) {
                if ( s.Subdomain != null ) {
                    String httpStr = 'http://';
                    if ( s.OptionsRequireHttps == true ) {
                        httpStr = 'https://';
                    }
                    String siteFullUrl = httpStr;
                    if(org.IsSandbox == true) {
                        siteFullUrl += UserInfo.getUserName().substringAfterLast('.')+'-';
                    }
                    siteFullUrl += s.Subdomain + '.';
                    siteFullUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
                    if ( s.UrlPathPrefix != null ) {
                        siteFullUrl += '/' + s.UrlPathPrefix;
                    }
                    System.debug(siteFullUrl);
                    siteFullUrlList.add(siteFullUrl);
                }
            }

        }

        return siteFullUrlList;


    }
}