/**
 * Created by lauren.lezberg on 2/26/2021.
 */

public with sharing class ExhibitorRegistrationController {

    @AuraEnabled
    public static String getContact(){
        return ECRMUtils.getCurrentLoginUserContactId();
    }

}