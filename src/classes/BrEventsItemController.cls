public without sharing class BrEventsItemController {

    @AuraEnabled
    public static BrEventsItemWrapper getEvent(Id recordId) {
        if (String.isBlank(recordId) || !BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null)
                || !BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null))
            return null;

        BrEventsItemWrapper itemWrapper = new BrEventsItemWrapper();
        BR_Event__c item = [
                SELECT Id, Name, Refunds_Open__c, Draft__c, Timezone__c, Description__c, Venue_Address__c, Location__Latitude__s,
                        Location__Longitude__s, Start_Date__c, Venue__c, Event_Stage__c, Virtual_Venue__c, Display_on_Landing_Page__c,
                        View_Landing_Page_Horizontally__c, Show_Landing_Page_Logos__c, End_Date__c, Hide_attendees__c, Limit_of_attendees__c,
                        Main_Image_Filename__c, Hide_Date_Time__c, List_Image_Filename__c, Ticket_Not_Required__c, CME_Survey_Link__c,
                        CME_Open__c, LOP_Open__c, LOI_Open__c, Enable_registration_for_guests__c, Parent_Event__c, Parent_Event__r.Name, (
                        SELECT Participate__c, Fon_Sales_Order__c, Refund_Requested__c
                        FROM BR_Participations__r
                        WHERE User__c = :UserInfo.getUserId()
                        LIMIT 1
                )
                FROM BR_Event__c
                WHERE Id = :recordId
        ];

        if(item.Virtual_Venue__c!=null){
            Virtual_Event_Details__c ved = [SELECT Exhibit_Open__c FROM Virtual_Event_Details__c WHERE Event__c=: item.Id];
            itemWrapper.exhibitOpen = ved.Exhibit_Open__c;
        } else {
            itemWrapper.exhibitOpen = false;
        }

        if(item.Venue__c!=null) {
            Venue__c venue = [SELECT Name, Street_1__c, Street_2__c, Street_3__c, City__c, State__c, Country__c, Zip__c FROM Venue__c WHERE Id = :item.Venue__c];
            itemWrapper.venue = venue;
        } else {
            itemWrapper.venue = null;
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


        itemWrapper.item = item;
        itemWrapper.itemDate = startDate.format('MMMM') + ' ' + startDate.day() + ', ' + startDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a')+ timezone;

        Date startDay = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
        Date endDay = Date.newInstance(endDate.year(), endDate.month(), endDate.day());

        if (endDate!=null) {
            if (diffMinutes != 0) {
                endDate = item.End_Date__c.addMinutes(diffMinutes);
            }

            if (endDate > startDate && endDay!=startDay) {
                itemWrapper.itemDate = startDate.month() == endDate.month() ?
                        startDate.format('MMMM') + ' ' + startDate.day() + '-' + endDate.day() + ', ' + endDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a') + timezone
                        : startDate.format('MMMM') + ' ' + startDate.day() + '-' + endDate.format('MMMM') + ' '+ endDate.day() + ', ' + endDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a') + timezone;
//                itemWrapper.itemDate = itemWrapper.itemDate.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.').replaceAll(':00', '');

//                itemWrapper.itemDate = startDate.format() + ' - ' + endDate.format() + timezone;
            }
        }

        itemWrapper.itemDate = itemWrapper.itemDate.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.');
        if(itemWrapper.itemDate.contains('12:00 a.m.')){
            itemWrapper.itemDate = itemWrapper.itemDate.replace('12:00 a.m.', 'Midnight');
        } else if(itemWrapper.itemDate.contains('12:00 p.m.')) {
            itemWrapper.itemDate = itemWrapper.itemDate.replace('12:00 p.m.', 'Noon');
        }
        itemWrapper.itemDate = itemWrapper.itemDate.replaceAll(':00', '');

        if (item.BR_Participations__r.isEmpty()) {
            itemWrapper.userIsParticipating = false;
        } else {
            BR_Participation__c participation = item.BR_Participations__r[0];
            itemWrapper.userIsParticipating = participation.Participate__c == 'Yes';
            if(participation.Fon_Sales_Order__c!=null && participation.Participate__c == 'Yes') {
                OrderApi__Sales_Order__c so = [SELECT OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE Id = :participation.Fon_Sales_Order__c];
                if (so.OrderApi__Total__c == 0.0) {
                    itemWrapper.isZeroDollars = true;
                }
            }
            if(participation.Refund_Requested__c){
                itemWrapper.refundRequested = true;
            }
        }

        return itemWrapper;
    }

    @AuraEnabled
    public static String getInviteToDownload(String eventId){
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm();

        String contactId = ECRMUtils.getCurrentLoginUserContactId();

        List<BR_Participation__c> participants= [SELECT Id, Contact__c, BR_Event__c FROM BR_Participation__c WHERE Contact__c=:contactId AND BR_Event__c=:eventId];

        for(BR_Participation__c  p: participants){
            if ( p.Contact__c != null ) {
                servUrl += '/LetterOfInvitation?Id=' + contactId + '&eventId=' + eventId + '&isLive=true';
            } else {
                system.debug('*** Contact is null ');
                servUrl += '/myAACRHelpCustom';
            }
        }

        system.debug('*** servUrl ' + servUrl);
        return servUrl;
    }

    @AuraEnabled
    public static String getLetterToDownload(String eventId){
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm();

        String contactId = ECRMUtils.getCurrentLoginUserContactId();

        List<BR_Participation__c> participants= [SELECT Id, Contact__c, BR_Event__c FROM BR_Participation__c WHERE Contact__c=:contactId AND BR_Event__c=:eventId];

        for(BR_Participation__c  p: participants){
            if ( p.Contact__c != null ) {
                servUrl += '/LetterOfParticipation?Id=' + contactId + '&eventId=' + eventId + '&isLive=true';
            } else {
                system.debug('*** Contact is null ');
                servUrl += '/myAACRHelpCustom';
            }
        }

        system.debug('*** servUrl ' + servUrl);
        return servUrl;
    }

    @AuraEnabled
    public static String goToVirtualMeeting(String eventId){
        BR_Event__c evt = [SELECT Id, Virtual_Venue__r.Integration_Controller__c FROM BR_Event__c WHERE Id=: eventId];

        String extensionClass = evt.Virtual_Venue__r.Integration_Controller__c;

        if(extensionClass!=null) {
            Callable ext = (Callable) Type.forName(extensionClass).newInstance();
            Map<String, Object> args = new Map<String, Object>();
            args.put('contactId', ECRMUtils.getCurrentLoginUserContactId());
            args.put('SFEventId', eventId);
            String result = (String) ext.call('goToVenue', args);

            return result;
        }

        return null;

    }

    @AuraEnabled
    public static Integer getAttendeesCount(Id recordId) {
        if (!BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null))
            return 0;

        String query = 'SELECT COUNT() FROM BR_Participation__c WHERE BR_Event__c = \'' + recordId + '\' AND Participate__c  = \'Yes\'';

        return Database.countQuery(query);
    }

    @AuraEnabled
    public static List<BR_Participation__c> getParticipations(Id recordId) {

        if (String.isBlank(recordId) || !BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null))
            return null;

        String rsvpType = 'Yes';

        return [
                SELECT User__r.Id, User__r.Name, User__r.FirstName, User__r.LastName, User__r.SmallPhotoUrl, Participate__c
                FROM BR_Participation__c
                WHERE BR_Event__c = :recordId AND Participate__c = :rsvpType
        ];
    }

    @AuraEnabled
    public static String rsvpEvent(Id recordId, String rsvpType, Integer attendeesLimit) {
        return brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
    }

    @AuraEnabled
    public static String getEventMainImage(Id recordId, String mainImageName) {
        if (String.isBlank(recordId) || String.isBlank(mainImageName) || !BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', null))
            return null;


        mainImageName = String.valueOf(mainImageName);

        List<ContentDocumentLink> chatterFiles = [
                SELECT ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                AND ContentDocument.Title = :mainImageName
        ];


        if (chatterFiles.size() > 0) {
            List<ContentDistribution> distributions = [Select Id, ContentDocumentId, ContentDownloadUrl, ContentVersion.Title from ContentDistribution WHERE ContentVersionId =: chatterFiles[0].ContentDocument.LatestPublishedVersionId ];

            if(distributions.size()>0){
                return distributions[0].ContentDownloadUrl;
            }
        }

        return null;
    }

    /**
     * Publishes event from draft.
     *
     * @param eventId
     */
    @AuraEnabled
    public static void publishEvent(Id eventId) {
        brSecurity.performAccessCheck('edit', BR_Event__c.getSObjectType(),
                new List<SObjectField> { BR_Event__c.Draft__c }
        );

        List<BR_Event__c> eventResult = [SELECT Draft__c FROM BR_Event__c WHERE Id = :eventId];

        if (eventResult.isEmpty()) {
            throw new AACRCustomException('Event not found', 'BREventsItemController.publishEvent', 'Portal Events');
//            throw new AuraHandledException('Event does not exist.');
        }

        BR_Event__c event = eventResult[0];

        if (event.Draft__c) {
            event.Draft__c = false;
            update event;
        }
    }

    /**
     * Returns event to draft.
     *
     * @param eventId
     */
    @AuraEnabled
    public static void draftEvent(Id eventId) {
        brSecurity.performAccessCheck('edit', BR_Event__c.getSObjectType(),
                new List<SObjectField> { BR_Event__c.Draft__c }
        );

        List<BR_Event__c> eventResult = [SELECT Draft__c FROM BR_Event__c WHERE Id = :eventId];

        if (eventResult.isEmpty()) {
            throw new AACRCustomException('Event not found', 'BREventsItemController.draftEvent', 'Portal Events');
//            throw new AuraHandledException('Event does not exist.');
        }

        BR_Event__c event = eventResult[0];

        if (!event.Draft__c) {
            event.Draft__c = true;
            update event;
        }
    }
}