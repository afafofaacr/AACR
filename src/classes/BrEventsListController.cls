public without sharing class BrEventsListController {
    private static final Integer DEFAULT_ITEMS_PER_PAGE = 5;
    private static final Integer MAX_ITEMS_PER_PAGE = 500;



    @AuraEnabled
    public static List<BrEventsWrapper> getEvents(String zoneId, String jsonFilters, Integer page, Integer itemsPerPage) {
        Map<String, String> filterData = (Map<String, String>) JSON.deserialize(jsonFilters, Map<String, String>.class);
        System.debug('getEvents with zoneId: ' + zoneId + ' filterData: ' + filterData + ' page: ' + page + ' and itemsPerPage: ' + itemsPerPage);
        List<BrEventsWrapper> wrap_items = new List<BrEventsWrapper>();

        if (!BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null)
                || !BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null))
            return wrap_items;

/*        DateTime dT = DateTime.now();
        String currentTimeGMT = dT.formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        String todayEndTimeGMT = DateTime.newinstance(dT.year(), dT.month(), dT.day(), 23, 59, 0).formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');*/

        String queryFields = 'Id, Name, CreatedBy.TimeZoneSidKey, Parent_Event__c, Parent_Event__r.Name, Event_Stage__c, Timezone__c, Virtual_Venue__c, Description__c, Venue_Address__c, Location__Latitude__s, Location__Longitude__s, Start_Date__c, End_Date__c, Limit_of_attendees__c, Venue__r.Name, Venue__c,Featured__c, Hide_Date_Time__c, ' +
                'List_Image_Filename__c, Hide_attendees__c, Ticket_Not_Required__c, Owner.Name, OwnerId, Enable_registration_for_guests__c,(SELECT Exhibit_Open__c FROM Virtual_Event_Details__r), (SELECT Participate__c FROM BR_Participations__r WHERE User__c = \'' + UserInfo.getUserId() + '\')';
        String query = 'SELECT ' + queryFields + ' FROM BR_Event__c'
                + ' WHERE BR_Events_Zone__c = \'' + zoneId + '\' AND RecordType.Name!=\'Cancelled\'';

        String tab = filterData.get('tab');
        String queryOrder = 'ASC';

        if (String.isNotBlank(tab) && tab == 'Past') {
            query += ' AND End_Date__c < TODAY';
            queryOrder = 'DESC';
        } else {
            query += ' AND (Start_Date__c > YESTERDAY OR End_Date__c > YESTERDAY)';
            query += ' AND Event_Stage__c!=\'On Demand\'';
            queryOrder = 'ASC';
        }

        if (String.isBlank(tab) || tab != 'Attending' && tab!= 'Past') {
            query += ' AND Unlisted_Event__c = FALSE';
        }

        query += ' AND Draft__c = FALSE';

        String queryWhere = BrEventsHelper.compileWhereStatement(filterData);

        page = Integer.valueOf(page);
        itemsPerPage = Integer.valueOf(itemsPerPage);

        if (itemsPerPage < 1 || itemsPerPage > MAX_ITEMS_PER_PAGE) itemsPerPage = DEFAULT_ITEMS_PER_PAGE;

        query += String.isNotBlank(queryWhere) ? ' AND ' + queryWhere : '';
        query += (UserInfo.getUserType() == 'Guest') ? ' AND Publicly_available__c = true' : '';
        query += ' ORDER BY Featured__c DESC, Start_Date__c ' + queryOrder;
        query += ' LIMIT ' + itemsPerPage;
        query += (page > 1) ? ' OFFSET ' + String.valueOf(itemsPerPage * (page - 1)) : '';

        System.debug('finalQueryString: ' + query);
        List<BR_Event__c> query_items = Database.query(query);
        System.debug(query_items);
        if (query_items.size() < 1) {
            return wrap_items;
        }

        Set<Id> items_ids = (new Map<Id, BR_Event__c>(query_items)).keySet();
//        String imageSource = BrEventsHelper.getImageSource();
//        Map<Id, Map<Id, String>> itemsAttachments = BrEventsHelper.getAttachmentsForItems(items_ids, imageSource);
        Map<Id, Map<String, String>> itemsAttachments = BrEventsHelper.getAttachmentsForItems(items_ids);

        //get virtual details
        List<Virtual_Event_Details__c> virtualDetails = [SELECT Id, Exhibit_Open__c, Event__c FROM Virtual_Event_Details__c WHERE Event__c IN :items_ids];
        Map<Id, Virtual_Event_Details__c> detailsMap = new Map<Id, Virtual_Event_Details__c>();
        for (Virtual_Event_Details__c ved : virtualDetails) {
            detailsMap.put(ved.Event__c, ved);
        }

        //get attendees count for all events
        List<BR_Participation__c> participations = [SELECT BR_Event__c FROM BR_Participation__c WHERE BR_Event__c IN :items_ids AND Participate__c = 'Yes'];

        Map<Id, Integer> itemsParticipations = new Map<Id, Integer>();

        for (BR_Participation__c part : participations) {
            if (itemsParticipations.containsKey(part.BR_Event__c)) {
                itemsParticipations.put(part.BR_Event__c, itemsParticipations.get(part.BR_Event__c) + 1);
            } else {
                itemsParticipations.put(part.BR_Event__c, 1);
            }
        }

        Set<String> userIds = new Set<String>();

        for (BR_Event__c item : query_items) {
            userIds.add(item.OwnerId);
        }

//        Map<BR_Event__c, String> eventWithUserPhotoUrl = BrEventsHelper.getEventWithPhotoUrl(userIds, query_items);

//        Set<Id> pastEvents = new Set<Id>();
//        if(String.isNotBlank(tab) && tab == 'Past'){
//            List<BR_Participation__c> pastParticipations = [SELECT Id, BR_Event__c FROM BR_Participation__c WHERE BR_Event__c IN: items_ids AND User__c=: UserInfo.getUserId() AND Participate__c = 'Yes'];
//            for(BR_Participation__c p : pastParticipations){
//                pastEvents.add(p.BR_Event__c);
//            }
//        }
//
//        System.debug('pastEvents: ' + pastEvents.size());

        //put all items data to wrapper object
        for (BR_Event__c item : query_items) {
//            if ((String.isNotBlank(tab) && tab == 'Past' && pastEvents.contains(item.Id)) || tab!= 'Past') {
            BrEventsWrapper bew = new BrEventsWrapper();
            bew.item = item;
            bew.listImageURL = '';
//            bew.userImageUrl = eventWithUserPhotoUrl.get(item);

            System.debug('virtualDetails: ' + item.Virtual_Event_Details__r);
            if (!item.Virtual_Event_Details__r.isEmpty()) {
                bew.exhibitOpen = item.Virtual_Event_Details__r[0].Exhibit_Open__c;

            } else {
                bew.exhibitOpen = false;
            }
//                if(detailsMap.keySet().contains(item.Id)){
//                    bew.exhibitOpen = detailsMap.get(item.Id).Exhibit_Open__c;
//                } else {
//                    bew.exhibitOpen = false;
//                }


            System.debug('itemsAttachments: ' + itemsAttachments);
            for (Id item_id : itemsAttachments.keySet()) {
                Map<String, String> itemAttachments = itemsAttachments.get(item_id);
                for (String att : itemAttachments.keySet()) {
                    if (item.List_Image_Filename__c == att) {
                        bew.listImageURL = itemAttachments.get(att);
                    }
                }
            }

            String listImageFileName = item.List_Image_Filename__c;

//                if (listImageFileName != null && (listImageFileName.startsWith('http://') || listImageFileName.startsWith('https://'))) {
//                    bew.listImageURL = listImageFileName;
//                }

            if (itemsParticipations.containsKey(item.Id)) {
                bew.attendeesCount = itemsParticipations.get(item.Id);
            } else {
                bew.attendeesCount = 0;
            }

            Integer diffMinutes = 0;
            String eventTimezone = item.Timezone__c;
            String userTimezone = UserInfo.getTimeZone().toString();

            if (eventTimezone != null) {
                diffMinutes = BrEventsHelper.getDiffMinutesBetweenTimezones(eventTimezone, userTimezone);
            }

            Datetime startDate = item.Start_Date__c.addMinutes(diffMinutes);
            Datetime endDate = item.End_Date__c;
            String timezone = ' ' + eventTimezone;

            if (UserInfo.getUserType() != 'Guest') {
                if (diffMinutes == 0) {
                    timezone = '';
                }
            } else {
                if (eventTimezone == null) {
                    timezone = '';
                }
            }

            Organization org = [SELECT Id, TimeZoneSidKey FROM ORganization LIMIT 1];

//                bew.itemDates = startDate.format('MM/dd/yyyy h:mm a', org.TimeZoneSidKey);
            bew.itemDates = startDate.format('MMMM') + ' ' + startDate.day() + ', ' + startDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a');

            Date startDay = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
            Date endDay = Date.newInstance(endDate.year(), endDate.month(), endDate.day());

            if (endDate != null) {
                if (diffMinutes != 0) {
                    endDate = item.End_Date__c.addMinutes(diffMinutes);
                }

                if (endDate > startDate && endDay!=startDay) {
//                    bew.itemDates = startDate.format('MMMM') + ' ' + startDate.day() + '-' + endDate.day() + ', ' + endDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a');
                    bew.itemDates = startDate.month() == endDate.month() ?
                            startDate.format('MMMM') + ' ' + startDate.day() + '-' + endDate.day() + ', ' + endDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a') + timezone
                            : startDate.format('MMMM') + ' ' + startDate.day() + '-' + endDate.format('MMMM') + ' '+ endDate.day() + ', ' + endDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a') + timezone;
//                        bew.itemDates = startDate.format('MM/dd/yyyy h:mm a', org.TimeZoneSidKey) + ' - ' + endDate.format('MM/dd/yyyy h:mm a', org.TimeZoneSidKey) ;
                }
            }

            bew.itemDates = bew.itemDates.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.');
            if (bew.itemDates.contains('12:00 a.m.')) {
                bew.itemDates = bew.itemDates.replace('12:00 a.m.', 'Midnight');
            } else if (bew.itemDates.contains('12:00 p.m.')) {
                bew.itemDates = bew.itemDates.replace('12:00 p.m.', 'Noon');
            }
            bew.itemDates = bew.itemDates.replaceAll(':00', '');

            wrap_items.add(bew);
//            }
        }

        return wrap_items;
    }


    @AuraEnabled
    public static Integer getEventsCount(String zoneId, Map<String, String> filterData) {
        System.debug('getEventsCount with zonId: ' + zoneId + ' and filterData: ' + filterData);
        Integer result_count = 0;

        if (!BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null))
            return result_count;

//        String currentTimeGMT = DateTime.now().formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');

        String query = 'SELECT COUNT() FROM BR_Event__c'
                + ' WHERE BR_Events_Zone__c = \'' + zoneId + '\'';

        query += ' AND Draft__c = FALSE';
        query += ' AND RecordType.Name!=\'Cancelled\'';

        String tab = filterData.get('tab');

        if (String.isNotBlank(tab) && tab == 'Past') {
            query += ' AND Start_Date__c < TODAY';
        } else {
            query += ' AND (Start_Date__c > YESTERDAY OR End_Date__c > YESTERDAY)';
            query += ' AND Event_Stage__c!=\'On Demand\'';
        }

        if (String.isBlank(tab) || tab != 'Attending') {
            query += ' AND Unlisted_Event__c = FALSE';
        }

        String queryWhere = BrEventsHelper.compileWhereStatement(filterData);
        System.debug('queryWhere: ' + queryWhere);

        query += String.isNotBlank(queryWhere) ? ' AND ' + queryWhere : '';
//        query += (UserInfo.getUserType() == 'Guest') ? ' AND Publicly_available__c = true' : '';


        result_count = Database.countQuery(query);

        return result_count;
    }
}