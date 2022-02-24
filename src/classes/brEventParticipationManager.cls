/**
 * Created by mitfity on 15.07.2019.
 */

public without sharing class brEventParticipationManager {

    @AuraEnabled
    public static Boolean checkForTicketTypes(Id eventId){
        Integer segmentCount = [SELECT COUNT() FROM AC_Event_User_Segment__c WHERE AC_Event__c =: eventId];
        SYstem.debug('segmentCount: ' + segmentCount);
        if(segmentCount!=null && segmentCount>0){
            return true;
        }

        return false;
    }

    /**
     * Respond to event whether you are going or not.
     *
     * @param recordId
     * @param response
     * @param attendeesLimit
     *
     * @return
     */
    public static String respondToEvent(Id recordId, String response, Integer attendeesLimit) {
        if (String.isBlank(recordId) || String.isBlank(response)) {
            return 'error';
        }

        if (UserInfo.getUserType() == 'Guest') {
            return 'auth_required';
        }

        List<String> participationFieldsToUpdate = new List<String>();
        participationFieldsToUpdate.add('Participate__c');
        participationFieldsToUpdate.add('User__c');
        List<String> participationFieldsToCreate = new List<String>();
        participationFieldsToCreate.add('BR_Event__c');
        participationFieldsToCreate.add('Participate__c');
        participationFieldsToCreate.add('User__c');

        if (!BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null)
                || !BrEventsHelper.performAccessCheck('edit', 'BR_Participation__c', participationFieldsToUpdate)
                || !BrEventsHelper.performAccessCheck('create', 'BR_Participation__c', participationFieldsToCreate)) {
            return 'error';
        }

        String count_query = 'SELECT COUNT() FROM BR_Participation__c WHERE BR_Event__c = \'' + recordId +
                '\' AND Participate__c  = \'Yes\'';

        attendeesLimit = Integer.valueOf(attendeesLimit);

        if (attendeesLimit != 0 && response == 'Yes') {
            Integer attendeesCount = Database.countQuery(count_query);

            if (attendeesCount != 0 && attendeesCount >= attendeesLimit) {
                return 'limit_exceded';
            }

        }

        List<BR_Participation__c> participations = [
                SELECT Id
                FROM BR_Participation__c
                WHERE BR_Event__c = :recordId
                AND User__c = :UserInfo.getUserId()
                LIMIT 1
        ];

        BR_Participation__c p = new BR_Participation__c();

        if (participations.size() > 0) {
            p = participations[0];
            p.Participate__c = response;
        } else {
            p.BR_Event__c = recordId;
            p.Participate__c = response;
            p.User__c = UserInfo.getUserId();
        }

        try {
            upsert p;
            return String.valueOf(Database.countQuery(count_query));
        } catch (DmlException e) {
            System.debug(e.getMessage());
            new AACRCustomException(recordId, e.getMessage(), e.getStackTraceString(), 'Ticket Purchase');
            return 'error';
        }
    }

    /**
     * Calculates price of ticket for the event according to current user's segment.
     *
     * @param eventId
     *
     * @return
     */
//    public static Map<String,Double> getTicketPrice(Id eventId, Id currentUserId) {
//        SYstem.debug('getTicketPrice for user: ' + currentUserId + ' and eventId: ' + eventId);
//        List<BR_Event__c> eventRows = [SELECT Ignore_Segment_Priority__c FROM BR_Event__c WHERE Id = :eventId];
//
//        if (eventRows.isEmpty()) {
//            throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getTicketPrice', 'Ticket Purchase');
////            throw new brParticipationException('Event does not exists.');
//        }
//
////        Id currentUserId = UserInfo.getUserId();
//        List<AC_Event_User_Segment__c> eventUserSegments = [
//                SELECT AC_User_Segment__r.Query__c, AC_User_Segment__r.Name, Price__c, Priority__c,
//                        Early_Bird_Price__c, Early_Bird_Price_Deadline__c
//                FROM AC_Event_User_Segment__c WHERE AC_Event__c = :eventId
//        ];
//        List<AC_Event_User_Segment__c> currentUserSegments = new List<AC_Event_User_Segment__c>();
//
//        for (AC_Event_User_Segment__c eventUserSegment : eventUserSegments) {
//            SYstem.debug('userSEgment query: ' + eventUserSegment.AC_User_Segment__r.Query__c);
//
//            String segmentQuery = eventUserSegment.AC_User_Segment__r.Query__c + ' AND Id= \'' + currentUserId + '\'';
//            System.debug('segmentQuery with userId: ' + segmentQuery);
//            List<User> segmentUsers = Database.query(segmentQuery);
//
//            for (User segmentUser : segmentUsers) {
//                if (segmentUser.Id == currentUserId) {
//                    currentUserSegments.add(eventUserSegment);
//                    break;
//                }
//            }
//        }
//
//        if (currentUserSegments.isEmpty()) {
//            throw new AACRCustomException(eventId, 'User has no segments for this event.', 'brEventParticipationManager.getTicketPrice', 'Ticket Purchase');
////            throw new brParticipationException('User has no segments for this event.');
//        }
//
//        AC_Event_User_Segment__c topPrioritySegment;
//        BR_Event__c targetEvent = eventRows.get(0);
//        Map<String, Double> priceMap = new Map<STring, Double>();
//
//        for (AC_Event_User_Segment__c eventUserSegment : currentUserSegments) {
//            if (topPrioritySegment == null) {
//                topPrioritySegment = eventUserSegment;
//                continue;
//            }
//
//            if (targetEvent.Ignore_Segment_Priority__c) {
//                if (eventUserSegment.Price__c < topPrioritySegment.Price__c) {
//                    topPrioritySegment = eventUserSegment;
//                }
//            } else if (eventUserSegment.Priority__c < topPrioritySegment.Priority__c) {
//                topPrioritySegment = eventUserSegment;
//            }
//        }
//
//        if (topPrioritySegment.Early_Bird_Price__c != null
//                && Datetime.now() < topPrioritySegment.Early_Bird_Price_Deadline__c) {
//            priceMap.put(topPrioritySegment.AC_User_Segment__r.Name, topPrioritySegment.Early_Bird_Price__c);
//            return priceMap;
//        }
//
//
//        priceMap.put(topPrioritySegment.AC_User_Segment__r.Name, topPrioritySegment.Price__c);
//
//        return priceMap;
//    }
    public static Map<String,AC_Event_User_Segment__c> getTicketPrice(Id eventId, Id currentUserId) {
        SYstem.debug('getTicketPrice for user: ' + currentUserId + ' and eventId: ' + eventId);
        String contactId = [SELECT ContactId fROM User WHERE Id=:currentUserId].ContactId;

        List<BR_Event__c> eventRows = [SELECT Ignore_Segment_Priority__c FROM BR_Event__c WHERE Id = :eventId];

        if (eventRows.isEmpty()) {
            throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getTicketPrice', 'Ticket Purchase');
//            throw new brParticipationException('Event does not exists.');
        }

//        Id currentUserId = UserInfo.getUserId();
        List<AC_Event_User_Segment__c> eventUserSegments = [
                SELECT AC_User_Segment__r.Query__c, AC_User_Segment__r.Name, AC_User_Segment__r.Description__c, AC_User_Segment__r.Portal_Help_Text__c,Price__c, Priority__c,
                        Early_Bird_Price__c, Early_Bird_Price_Deadline__c, On_Demand_Price__c, On_Demand_Start_Date__c
                FROM AC_Event_User_Segment__c WHERE AC_Event__c = :eventId
        ];
        List<AC_Event_User_Segment__c> currentUserSegments = new List<AC_Event_User_Segment__c>();

        for (AC_Event_User_Segment__c eventUserSegment : eventUserSegments) {
            SYstem.debug('userSegment query: ' + eventUserSegment.AC_User_Segment__r.Query__c);

            String segmentQuery = eventUserSegment.AC_User_Segment__r.Query__c + ' AND Id= \'' + currentUserId + '\'';
            System.debug('segmentQuery with userId: ' + segmentQuery);
            List<User> segmentUsers = Database.query(segmentQuery);

            for (User segmentUser : segmentUsers) {
                if (segmentUser.Id == currentUserId) {
                    currentUserSegments.add(eventUserSegment);
                    break;
                }
            }
        }

        if (currentUserSegments.isEmpty()) {
            throw new AACRCustomException(eventId, 'User has no segments for this event.', 'brEventParticipationManager.getTicketPrice', 'Ticket Purchase');
//            throw new brParticipationException('User has no segments for this event.');
        }

        AC_Event_User_Segment__c topPrioritySegment;
        BR_Event__c targetEvent = eventRows.get(0);
        Map<String, AC_Event_User_Segment__c> priceMap = new Map<String, AC_Event_User_Segment__c>();

        for (AC_Event_User_Segment__c eventUserSegment : currentUserSegments) {
            if (topPrioritySegment == null) {
                topPrioritySegment = eventUserSegment;
                continue;
            }

            if (targetEvent.Ignore_Segment_Priority__c) {
                if (eventUserSegment.Price__c < topPrioritySegment.Price__c) {
                    topPrioritySegment = eventUserSegment;
                }
            } else if (eventUserSegment.Priority__c < topPrioritySegment.Priority__c) {
                topPrioritySegment = eventUserSegment;
            }
        }

        System.debug('topPrioritySegment: ' + topPrioritySegment);
        System.debug('dateTimeNow: ' + Datetime.now());
        System.debug('segment end date: ' + topPrioritySegment.Early_Bird_Price_Deadline__c);

        //EARLY BIRD PRICING
        if (topPrioritySegment.Early_Bird_Price__c != null
                && Datetime.now() < topPrioritySegment.Early_Bird_Price_Deadline__c) {
            System.debug('early bird...');
            priceMap.put(topPrioritySegment.AC_User_Segment__c, topPrioritySegment);
            return priceMap;
        }
        //ON DEMAND PRICING
        else if (topPrioritySegment.On_Demand_Price__c != null
                && Datetime.now() >= topPrioritySegment.On_Demand_Start_Date__c) {
            System.debug('on demand...');
            priceMap.put(topPrioritySegment.AC_User_Segment__c, topPrioritySegment);
            return priceMap;
        }


        else {
            priceMap.put(topPrioritySegment.AC_User_Segment__c, topPrioritySegment);
        }
        System.debug('priceMap: ' + priceMap);


        return priceMap;
    }


    /**
     * Calculates price of ticket for the event according to current user's segment.
     *
     * @param eventId
     *
     * @return
     */
    public static Double getTicketPrice(Id eventId) {
        List<BR_Event__c> eventRows = [SELECT Ignore_Segment_Priority__c FROM BR_Event__c WHERE Id = :eventId];

        if (eventRows.isEmpty()) {
            throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getTicketPrice', 'Ticket Purchase');
//            throw new brParticipationException('Event does not exists.');
        }

        Id currentUserId = UserInfo.getUserId();
        List<AC_Event_User_Segment__c> eventUserSegments = [
                SELECT AC_User_Segment__r.Query__c, Price__c, Priority__c,
                        Early_Bird_Price__c, Early_Bird_Price_Deadline__c
                FROM AC_Event_User_Segment__c WHERE AC_Event__c = :eventId
        ];
        List<AC_Event_User_Segment__c> currentUserSegments = new List<AC_Event_User_Segment__c>();

        for (AC_Event_User_Segment__c eventUserSegment : eventUserSegments) {
            List<User> segmentUsers = Database.query(eventUserSegment.AC_User_Segment__r.Query__c);

            for (User segmentUser : segmentUsers) {
                if (segmentUser.Id == currentUserId) {
                    currentUserSegments.add(eventUserSegment);
                    break;
                }
            }
        }

        if (currentUserSegments.isEmpty()) {
            throw new AACRCustomException(eventId, 'User has no segments for this event.', 'brEventParticipationManager.getTicketPrice()', 'Ticket Purchase');
//            throw new brParticipationException('User has no segments for this event.');
        }

        AC_Event_User_Segment__c topPrioritySegment;
        BR_Event__c targetEvent = eventRows.get(0);

        for (AC_Event_User_Segment__c eventUserSegment : currentUserSegments) {
            if (topPrioritySegment == null) {
                topPrioritySegment = eventUserSegment;
                continue;
            }

            if (targetEvent.Ignore_Segment_Priority__c) {
                if (eventUserSegment.Price__c < topPrioritySegment.Price__c) {
                    topPrioritySegment = eventUserSegment;
                }
            } else if (eventUserSegment.Priority__c < topPrioritySegment.Priority__c) {
                topPrioritySegment = eventUserSegment;
            }
        }

        if (topPrioritySegment.Early_Bird_Price__c != null
                && Datetime.now() < topPrioritySegment.Early_Bird_Price_Deadline__c) {
            return topPrioritySegment.Early_Bird_Price__c;
        }

        return topPrioritySegment.Price__c;
    }



    /**
     * Generates sales order with ticket for current user.
     *
     * @param ticketPrice
     *
     * @return
     */
    public static OrderApi__Sales_Order__c generateFonSalesOrderForTicket(AC_Event_User_Segment__c seg, Id eventId) {
        Savepoint savePoint = Database.setSavepoint();

        OrderApi__Sales_Order__c salesOrder;
        Id currentUserId = UserInfo.getUserId();

        try {
            User currentUser = [SELECT ContactId FROM User WHERE Id = :currentUserId LIMIT 1];

            salesOrder = new OrderApi__Sales_Order__c();
            salesOrder.OrderApi__Contact__c = currentUser.ContactId;
            salesOrder.OrderApi__Status__c = 'Open';

            insert salesOrder;



            OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='Live Event Tickets' AND AC_Event__c=: eventId ];


            OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
            salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
            salesOrderLine.OrderApi__Item__c = item.Id;
            salesOrderLine.OrderApi__Price_Override__c = true;
            if(seg.Early_Bird_Price__c != null
                    && Datetime.now() < seg.Early_Bird_Price_Deadline__c) {
                salesOrderLine.OrderApi__Sale_Price__c = seg.Early_Bird_Price__c;
            }
            else if(seg.On_Demand_Price__c != null
                    && Datetime.now() >= seg.On_Demand_Start_Date__c) {
                System.debug('on demand sales order line');
                salesOrderLine.OrderApi__Sale_Price__c = seg.On_Demand_Price__c;
            }
            else{
                salesOrderLine.OrderApi__Sale_Price__c = seg.Price__c;
            }
            salesOrderLine.AC_User_Segment__c = seg.AC_User_Segment__c;


            insert salesOrderLine;
        } catch (Exception e) {
            Database.rollback(savePoint);
            System.debug('exception: ' + e.getMessage());
             new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Ticket Purchase');
//            throw e;
        }

        return salesOrder;
    }

    public static List<brIFieldWrap> getEventPreferencesFormFields(Id eventId, Id currentUserId) {
        System.debug('getEventPreferencesFormFields with eventId : ' + eventId  + ' and currentUserId: ' + currentUserId);
//        Id currentUserId = UserInfo.getUserId();
        List<BR_Event__c> eventRows = [SELECT Ignore_Segment_Priority__c FROM BR_Event__c WHERE Id = :eventId];

        if (eventRows.isEmpty()) {
            throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getEventPreferencesFormFields', 'Ticket Purchase');
//            throw new brParticipationException('Event does not exists.');
        }

        List<AC_Event_User_Segment__c> eventUserSegments = [
                SELECT AC_User_Segment__r.Query__c, Priority__c
                FROM AC_Event_User_Segment__c WHERE AC_Event__c = :eventId
        ];
        System.debug('eventUserSegments: ' + eventUserSegments);
        List<AC_Event_User_Segment__c> currentUserSegments = new List<AC_Event_User_Segment__c>();
        for (AC_Event_User_Segment__c eventUserSegment : eventUserSegments) {
            List<User> segmentUsers = Database.query(eventUserSegment.AC_User_Segment__r.Query__c + ' AND Id=\'' + currentUserId + '\'');

            for (User segmentUser : segmentUsers) {
                if (segmentUser.Id == currentUserId) {
                    currentUserSegments.add(eventUserSegment);
                    break;
                }
            }
        }
        if (currentUserSegments.isEmpty()) {
            throw new AACRCustomException('User has no segments for this event.', 'brEventParticipationManager.getEventPreferencesFormFields', 'Ticket Purchase');
//            throw new brParticipationException('User has no segments for this event.');
        }
        System.debug('currentUserSegments: ' + currentUserSegments);

        AC_Event_User_Segment__c topPrioritySegment;
        BR_Event__c targetEvent = eventRows.get(0);

        for (AC_Event_User_Segment__c eventUserSegment : currentUserSegments) {
            if (topPrioritySegment == null) {
                System.debug('--- topPrioritySegment == null');
                topPrioritySegment = eventUserSegment;
                continue;
            }
            if (eventUserSegment.Priority__c < topPrioritySegment.Priority__c) {
                topPrioritySegment = eventUserSegment;
            }
        }

        List<AC_Event_User_Segment__c> eventResults = [
                SELECT Event_Preferences_Form_Fieldset__c, AC_User_Segment__r.Query__c, AC_User_Segment__c
                FROM AC_Event_User_Segment__c
                WHERE AC_Event__c = :eventId AND AC_User_Segment__c =: topPrioritySegment.AC_User_Segment__c
        ];

        System.debug('eventResults: ' + eventResults);
        if (eventResults.isEmpty()) {
            throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getEventPreferencesFormFields', 'Ticket Purchase');
//            throw new brParticipationException('Event does not exist.');
        }

        AC_Event_User_Segment__c event = eventResults.get(0);
        SYstem.debug('fieldSet name from event: ' + event.Event_Preferences_Form_Fieldset__c);
        Schema.DescribeSObjectResult objectDescribe = BR_Participation__c.SObjectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();

        if (!fieldSetMap.containsKey(event.Event_Preferences_Form_Fieldset__c)) {
            return new List<brIFieldWrap>();
        }

        Schema.FieldSet fieldSet = fieldSetMap.get(event.Event_Preferences_Form_Fieldset__c);
        System.debug('fieldSet: ' + fieldSet);

        return brFieldSetMemberListFactory.construct(fieldSet, 'update');
    }

    /**
     * Retrieves event preferences form fields.
     *
     * @param eventId
     *
     * @return
     */
    public static List<brIFieldWrap> getEventPreferencesFormFields(Id eventId) {
        Id currentUserId = UserInfo.getUserId();
        List<BR_Event__c> eventRows = [SELECT Ignore_Segment_Priority__c FROM BR_Event__c WHERE Id = :eventId];

    if (eventRows.isEmpty()) {
        throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getEventPreferencesFormFields', 'Ticket Purchase');
//        throw new brParticipationException('Event does not exists.');
    }

    List<AC_Event_User_Segment__c> eventUserSegments = [
        SELECT AC_User_Segment__r.Query__c, Priority__c
        FROM AC_Event_User_Segment__c WHERE AC_Event__c = :eventId
    ];
        List<AC_Event_User_Segment__c> currentUserSegments = new List<AC_Event_User_Segment__c>();
        for (AC_Event_User_Segment__c eventUserSegment : eventUserSegments) {
            List<User> segmentUsers = Database.query(eventUserSegment.AC_User_Segment__r.Query__c);

            for (User segmentUser : segmentUsers) {
                if (segmentUser.Id == currentUserId) {
                    currentUserSegments.add(eventUserSegment);
                    break;
                }
            }
        }
        if (currentUserSegments.isEmpty()) {
            throw new AACRCustomException('User has no segments for this event.', 'brEventParticipationManager.getEventPreferencesFormFields', 'Ticket Purchase');
//            throw new brParticipationException('User has no segments for this event.');
        }

        AC_Event_User_Segment__c topPrioritySegment;
        BR_Event__c targetEvent = eventRows.get(0);

        for (AC_Event_User_Segment__c eventUserSegment : currentUserSegments) {
            if (topPrioritySegment == null) {
                System.debug('--- topPrioritySegment == null');    
                topPrioritySegment = eventUserSegment;
                continue;
            }
            if (eventUserSegment.Priority__c < topPrioritySegment.Priority__c) {
                topPrioritySegment = eventUserSegment;
            }
        }

        List<AC_Event_User_Segment__c> eventResults = [
                SELECT Event_Preferences_Form_Fieldset__c, AC_User_Segment__r.Query__c, AC_User_Segment__c
                FROM AC_Event_User_Segment__c
                WHERE AC_Event__c = :eventId AND AC_User_Segment__c =: topPrioritySegment.AC_User_Segment__c
        ];

        if (eventResults.isEmpty()) {
            throw new AACRCustomException('Event does not exist', 'brEventParticipationManager.getEventPreferencesFormFields', 'Ticket Purchase');
//            throw new brParticipationException('Event does not exist.');
        }

        AC_Event_User_Segment__c event = eventResults.get(0);
        Schema.DescribeSObjectResult objectDescribe = BR_Participation__c.SObjectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();

        if (!fieldSetMap.containsKey(event.Event_Preferences_Form_Fieldset__c)) {
            return new List<brIFieldWrap>();
        }

        Schema.FieldSet fieldSet = fieldSetMap.get(event.Event_Preferences_Form_Fieldset__c);

        return brFieldSetMemberListFactory.construct(fieldSet, 'update');
    }

    /** 
     * Saves event preferences for current user.
     *
     * @param eventId
     * @param preferencesJson
     */
//    public static void saveEventPreferences(Id eventId, Id userId, Id salesOrderId,  String preferencesJson) {
//        System.debug('saveEventPreferences...');
//        System.debug('eventId: ' + eventId);
//        System.debug('userId: ' + userId);
//        System.debug('preferences: ' + preferencesJson);
//
////        List<brIFieldWrap> eventPreferencesFields = getEventPreferencesFormFields(eventId, userId);
//
//        List<BR_Participation__c> participationResult = [
//                SELECT Id, Participate__c
//                FROM BR_Participation__c
//                WHERE BR_Event__c  = :eventId AND User__c = :userId
//        ];
//
//        SYstem.debug('participationResult: ' + participationResult);
//
//        BR_Participation__c participation;
//
////        if (participationResult.isEmpty()) {
////            participation = new BR_Participation__c();
////            participation.BR_Event__c = eventId;
////            participation.User__c = userId;
////            participation.Fon_Sales_Order__c = salesOrderId;
////        } else
//        if(!participationResult.isEmpty()){
//            participation = participationResult.get(0);
//        }
//
//        //dont need with record-edit-form
////        BR_Participation__c eventPreferences =
////                (BR_Participation__c) JSON.deserialize(preferencesJson, BR_Participation__c.class);
////
////        System.debug('eventPreferences: ' + eventPreferences);
////
////        for (brIFieldWrap fieldWrap : eventPreferencesFields) {
////            String fieldName = fieldWrap.getApiName();
////
////            if (fieldName == 'Participate__c') {
////                continue;
////            }
////
////            participation.put(fieldName, eventPreferences.get(fieldName));
////        }
//
//        try {
//
//            upsert participation;
//        } catch (Exception e) {
//            System.debug('Error :' + e.getMessage());
//            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Ticket Purchase');
//        }
//    }


}