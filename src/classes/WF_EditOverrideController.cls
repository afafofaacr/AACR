/**
 * Created by afaf.awad on 9/27/2021.
 */

public with sharing class WF_EditOverrideController {

    /**
 * @purpose Get web forms builder join process id
 *
 * @return Id of join process
 */
    @AuraEnabled
    public static Id getWebFormJoinId(){
        return [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='WebForm_Create'].Id;
    }

}