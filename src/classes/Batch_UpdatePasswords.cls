/**
 * Created by afaf.awad on 6/10/2021.
 */

global class Batch_UpdatePasswords implements Database.Batchable<sObject>, Database.Stateful{

    String password;
    List<Id> userIds;
    Integer recordsProcessed = 0;
    Map<Id, String> usersDidNotUpdate = new Map<Id, String>();

        global Batch_UpdatePasswords(String pass, List<Id> users){
            this.password = pass;
            this.userIds = users;
        }

        global Database.QueryLocator start(Database.BatchableContext BC) {
            String query = 'SELECT Id, UserName, Email, Contact.FirstName, Contact.LastName from User WHERE IsPortalEnabled = True AND ProfileId = \'00e1I000001Rt2xQAC\' AND Id IN: userIds';
            return Database.getQueryLocator(query);
        }


        global void execute(Database.BatchableContext BC, List<User> scope) {

            List<User> userList = new List<User>();
            for (User u : scope)
            {
                u.IsActive = TRUE;
                userList.add(u);
            }

            try {
                update userList;
                for (User u : scope) {
                    System.setPassword(u.Id, password);

                }
            } catch (Exception e) {
                for(User u : scope){
                 usersDidNotUpdate.put(u.Id, e.getMessage());
                }
                System.debug('Exception occurred while updating Users :::' + e.getMessage() + '\t' + e.getStackTraceString());
            }

            recordsProcessed = recordsProcessed + userList.size();
            System.debug('Number of records processed so far: ' + recordsProcessed);

        }

        global void finish(Database.BatchableContext BC) {

            System.debug('record Processed ::: ' + recordsProcessed);
            System.debug('usersDidNotUpdate == ' + usersDidNotUpdate.size());

            MassUpdateUserPasswordController.sendRecordErrors(usersDidNotUpdate, recordsProcessed, bc.getJobId());
        }


    }