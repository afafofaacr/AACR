/**
 * Created by lauren.lezberg on 12/11/2019.
 */

public with sharing class EventNew_OverrideController {

    /**
     * @purpose Get event builder join process id
     *
     * @return Id of join process
     */
    @AuraEnabled
    public static Id getEventBuilderJoinId(){
        return [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Event_Create'].Id; 
    }

}