/**
 * Created by afaf.awad on 8/11/2021.
 */

public with sharing class LoginAsCommunityUserController {

    @AuraEnabled
    public static String getLoginURL(String contactId){

//        String domain = System.Url.getOrgDomainUrl().toExternalForm();
//
//        String orgId = UserInfo.getOrganizationId();
//        String conId = '0030200000AIOLfAAP';

        User user = [SELECT Id FROM User WHERE ContactId =: contactId];

        Network net = [SELECT Id, name FROM Network];

        String loginUrl = System.Url.getOrgDomainUrl().toExternalForm() +'/servlet/servlet.su?oid=' + UserInfo.getOrganizationId()
                + '&retURL=%2F' + contactId + '&sunetworkid=' + net.Id + '&sunetworkuserid='+ user.Id;

        System.debug('loginURl == ' + loginUrl);

        return loginUrl;

    }
}