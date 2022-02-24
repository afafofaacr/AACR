/**
 * Created by afaf.awad on 2/22/2021.
 */

public without sharing class EC_DatePickerController {

        @AuraEnabled
        public static List<EC_Schedule__c> getEventsForMonth(String zoneId, Integer year, Integer month, String eventId) {

            System.debug('eventId = ' + eventId);
//            BR_Event__c event;
            EC_Event__c globalEvent = EC_Event__c.getOrgDefaults();
//            If(Test.isRunningTest()){
//                event = [SELECT Id FROM BR_Event__c WHERE Name = 'Text Exhibitor Event'];
//            }else{
//                event = [SELECT Id FROM BR_Event__c WHERE Name = 'Tumor Heterogeneity: From Single Cells to Clinical Impact'];
//            }

            List<EC_Schedule__c> itemsList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM EC_Schedule__c WHERE Event__c =: globalEvent.Event_Id__c];
//            List<EC_Schedule__c> itemListFormatted = new List<EC_Schedule__c>();
//
//            for (EC_Schedule__c item : itemsList) {
//                item.Start_Date__c = DateTime.newInstanceGmt(item.Start_Date__c.date(), item.Start_Date__c.time());
//                itemListFormatted.add(item);
//            }

            System.debug('itemsList:: ' + itemsList);

            return itemsList;

//            if(!BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null)
//                    || !BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null))
//                return itemsList;

//            year = Integer.valueOf(year);
//            month = Integer.valueOf(month);
//            String currentTimeGMT = DateTime.now().formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
//            Integer numberOfDays = Date.daysInMonth(year, month);
//            DateTime monthDateStartGMT = DateTime.newInstanceGMT(year, month, 1);
//            DateTime monthDateEndGMT = DateTime.newInstanceGMT(year, month, numberOfDays, 23, 59, 0);

//            String query = 'SELECT Id, Name, Start_Date__c, End_Date__c FROM EC_Schedule__c WHERE Event__c =: eventId';
//            String query = 'SELECT Start_Date__c, (SELECT Participate__c FROM BR_Participations__r' +
//                    ' WHERE User__c = \'' + UserInfo.getUserId() +'\' AND Participate__c = \'Yes\')' +
//                    ' FROM BR_Event__c WHERE BR_Events_Zone__c = \'' + zoneId + '\' AND Start_Date__c > YESTERDAY' +
//                    ' AND Start_Date__c > ' + monthDateStartGMT.formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND Start_Date__c < '
//                    + monthDateEndGMT.formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND RecordType.Name!=\'Cancelled\'';

//            List<BR_Participation__c> participations = [
//                    SELECT BR_Event__c
//                    FROM BR_Participation__c
//                    WHERE User__c = :UserInfo.getUserId() AND Participate__c = 'Yes'
//            ];
//            List<Id> eventsUserIsParticipating = new List<Id>();
//
//            for (BR_Participation__c participation : participations) {
//                eventsUserIsParticipating.add(participation.BR_Event__c);
//            }
//
//            if (eventsUserIsParticipating.isEmpty()) {
//                query += ' AND Unlisted_Event__c = FALSE';
//            } else {
//                query += ' AND (Unlisted_Event__c = FALSE OR Id IN (\'' + String.join(eventsUserIsParticipating, '\', \'') + '\') )';
//            }

//            itemsList = Database.query(query);
//
//            List<EC_Schedule__c> itemListFormatted = new List<EC_Schedule__c>();
//
//            for (EC_Schedule__c item : itemsList) {
//                item.Start_Date__c = DateTime.newInstanceGmt(item.Start_Date__c.date(), item.Start_Date__c.time());
//                itemListFormatted.add(item);
//            }
//
//            System.debug('itemsList:: ' + itemsList);
//
//            return itemsList;

        }

}