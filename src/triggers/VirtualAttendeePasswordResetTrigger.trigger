/**
 * Created by lauren.lezberg on 4/10/2020.
 */

trigger VirtualAttendeePasswordResetTrigger on User (after insert, after update) {

    List<Id> userIds = new List<Id>();

    for(User u : Trigger.new){
        //check for portal user
        if(u.ContactId!=null) {
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    userIds.add(u.Id);
                } else if (Trigger.isUpdate) {
                    if (u.IsActive && !Trigger.oldMap.get(u.Id).IsActive) {
                        userIds.add(u.Id);
                    }
                }
            }
        }
    }

    UserPasswordResetTriggerHandler.checkForVirtualAttendeeRecords(userIds);

}