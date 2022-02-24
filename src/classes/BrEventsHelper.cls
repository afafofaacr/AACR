public without sharing class BrEventsHelper {

    public static String networkPrefix;

    public static Boolean performAccessCheck(String accessType, String objectName, List<String> fieldNames) {
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();

        if(accessType == 'read'){
            if(!objectDescribe.isAccessible()){
                return false;
            }

            if(fieldNames != null){
                Map<String, SObjectField> fields = objectDescribe.fields.getMap();
                for (String fieldName: fieldNames) {
                    if(!fields.get(fieldName).getDescribe().isAccessible()){
                        return false;
                    }
                }
            }
            return true;
        }
        else if(accessType == 'create'){
            if(!objectDescribe.isCreateable()){
                return false;
            }

            if(fieldNames != null){
                Map<String, SObjectField> fields = objectDescribe.fields.getMap();
                for (String fieldName: fieldNames) {
                    if(!fields.get(fieldName).getDescribe().isCreateable()){
                        return false;
                    }
                }
            }
            return true;
        } else if(accessType == 'edit'){
            if(!objectDescribe.isUpdateable()){
                return false;
            }

            if(fieldNames != null){
                Map<String, SObjectField> fields = objectDescribe.fields.getMap();
                for (String fieldName: fieldNames) {
                    if(!fields.get(fieldName).getDescribe().isUpdateable()){
                        return false;
                    }
                }
            }
            return true;
        } else if(accessType == 'delete') {
            if (!objectDescribe.isDeletable()) {
                return false;
            }
            return true;
        }
        else {
            return false;
        }
    }

    public static String compileWhereStatement(Map<String,String> filterData) {
        System.debug('compileWhereStatement: ' + filterData);
        List<String> whereList = new List<String>();
        List<String> searchIds = new List<String>();
        String searchQuery, tab, selectedDate;

        if (filterData == null) return '';

        searchQuery = filterData.get('search');
        tab = filterData.get('tab');
        selectedDate = filterData.get('date');

        if (String.isNotBlank(searchQuery)) {
            String query = 'FIND \'' + searchQuery + '*\' IN ALL FIELDS RETURNING BR_Event__c(Id)';
            List<List<SObject>> searchList = search.query(query);

            for (SObject obj : searchList[0]) {
                searchIds.add(obj.Id);
            }

            whereList.add('Id IN (\'' + String.join(searchIds, '\',\'') + '\')');
        }
        if(String.isNotBlank(selectedDate)){
            List<String> dateArr = selectedDate.split('-');

            if(dateArr.size() > 0 && String.isNotBlank(dateArr[0]) && String.isNotBlank(dateArr[1])
                    && String.isNotBlank(dateArr[2])){
                Integer yearInt = Integer.valueOf(dateArr[0]);
                Integer monthInt = Integer.valueOf(dateArr[1]);
                Integer dayInt = Integer.valueOf(dateArr[2]);
                DateTime selectedDateStart = DateTime.newInstance(yearInt, monthInt, dayInt);
                DateTime selectedDateEnd = DateTime.newInstance(yearInt, monthInt, dayInt, 23, 59, 0);

                whereList.add('Start_Date__c > ' + selectedDateStart.formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND Start_Date__c < '
                        + selectedDateEnd.formatGmt('YYYY-MM-dd\'T\'HH:mm:ss\'Z\''));
            }
        }
        if(String.isNotBlank(tab) && (tab == 'Attending' || tab == 'Past')){
            whereList.add('Id IN (SELECT BR_Event__c FROM BR_Participation__c WHERE User__c = \'' +
                    UserInfo.getUserId() +'\' AND Participate__c = \'Yes\')');

        }


        return String.join(whereList, ' AND ');
    }

    @future
    public static void insertUser(Id userId) {
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'Live_Events'];
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
    }

    public static String getImageSource() {
        return 'files';
    }


    public static String getConfigValue(String name) {
        List<BrEvents_Settings__c> settings = [SELECT Value__c FROM BrEvents_Settings__c WHERE Name = :name LIMIT 1];

        if(settings.size() > 0){
            return settings[0].Value__c;
        }
        else {
            return '';
        }
    }

    public static Map<Id, Map<String,String>> getAttachmentsForItems(Set<Id> items_ids){
        System.debug('getAttachmentsForItems...');
        Map<Id, Map<String,String>> itemsAttachments = new Map<Id, Map<String,String>>();

        if(items_ids.size() == 0 || !BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', null))
            return itemsAttachments;

        List<ContentDocumentLink> chatterFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId IN :items_ids];
        Set<Id> versionIds = new Set<Id>();
        Map<Id, Id> contentDocumentEntityMap = new Map<Id,Id>();

        for (ContentDocumentLink file: chatterFiles) {
            if(!contentDocumentEntityMap.containsKey(file.ContentDocumentId)) {
                versionIds.add(file.ContentDocument.LatestPublishedVersionId);
                contentDocumentEntityMap.put(file.ContentDocumentId, file.LinkedEntityId);
            }
        }

        List<ContentDistribution> distributions = [Select Id, ContentDocumentId, ContentDownloadUrl, ContentVersion.Title from ContentDistribution WHERE ContentVersionId IN: versionIds ];
        for(ContentDistribution d: distributions){
            if(!itemsAttachments.containsKey(contentDocumentEntityMap.get(d.ContentDocumentId))){
                itemsAttachments.put(contentDocumentEntityMap.get(d.ContentDocumentId), new Map<String, String>());
            }
            itemsAttachments.get(contentDocumentEntityMap.get(d.ContentDocumentId)).put(d.ContentVersion.Title, d.ContentDownloadUrl);
        }

        return itemsAttachments;
    }

//    public static Map<Id, Map<Id, String>> getAttachmentsForItems(Set<Id> items_ids, String imageSource){
//        Map<Id, Map<Id, String>> itemsAttachments = new Map<Id, Map<Id, String>>();
//
//        if(items_ids.size() == 0 || !BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', null))
//            return itemsAttachments;
//
//            List<ContentDocumentLink> chatterFiles = [SELECT ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
//                                                        FROM ContentDocumentLink WHERE LinkedEntityId IN :items_ids];
//
//            for (ContentDocumentLink file: chatterFiles) {
//                if(!itemsAttachments.containsKey(file.LinkedEntityId)){
//                    itemsAttachments.put(file.LinkedEntityId, new Map<Id, String>());
//                }
//                itemsAttachments.get(file.LinkedEntityId).put(file.ContentDocument.LatestPublishedVersionId, file.ContentDocument.Title);
//            }
//
//        return itemsAttachments;
//    }

    public static Map<BR_Event__c, String> getEventWithPhotoUrl(Set<String> userIds, List<BR_Event__c> query_items) {
        Map<BR_Event__c, String> eventWithUserPhotoUrl = new Map<BR_Event__c, String>();
        List<User> users = [SELECT SmallPhotoUrl FROM User WHERE Id IN :userIds];

        for (BR_Event__c item : query_items) {
            for (User user : users) {
                if (item.OwnerId == user.Id) {
                    eventWithUserPhotoUrl.put(item, user.SmallPhotoUrl);
                }
            }
        }

        return eventWithUserPhotoUrl;
    }

    public static List<BR_Participation__c> getParticipationsById(Set<Id> participationsIds) {
        return [
                SELECT Id, User__c, User__r.Name, Contact__c, Lead__c, Contact__r.Name, BR_Event__r.Timezone__c, External_Attendee_Id__c,
                        BR_Event__r.Name, BR_Event__r.Start_Date__c, Lead__r.Name, BR_Event__c, Bypass_Confirmation__c,
                        BR_Event__r.Venue_Address__c, BR_Event__r.CreatedBy.TimeZoneSidKey, BR_Event__r.Virtual_Venue__c,
                        BR_Event__r.End_Date__c, BR_Event__r.Description__c, BR_Event__r.Id, BR_Event__r.Registration_Confirmation_Message__c
                FROM BR_Participation__c
                WHERE Id IN :participationsIds 
                AND Participate__c = 'Yes'
        ];
    }

    public static List<BR_Participation__c> getPaticipationsByEventsIds(Set<Id> changedEventsIds) {
        return [
                SELECT Id, User__c, User__r.Name, Contact__c, Lead__c, Contact__r.Name, BR_Event__r.Timezone__c,
                        BR_Event__r.Name, BR_Event__r.Start_Date__c, Lead__r.Name, BR_Event__c,Bypass_Confirmation__c,
                        BR_Event__r.Venue_Address__c, BR_Event__r.CreatedBy.TimeZoneSidKey,
                        BR_Event__r.End_Date__c, BR_Event__r.Description__c, BR_Event__r.Id, BR_Event__r.Registration_Confirmation_Message__c
                FROM BR_Participation__c
                WHERE BR_Event__c IN :changedEventsIds
                AND Participate__c = 'Yes'
        ];
    }

    public static void sendEmails(List<BR_Participation__c> participations, String emailTemplateName) {
        String sendEmail = getConfigValue('send email');
        if (sendEmail == 'true') {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE Name = :emailTemplateName];
            String orgName = UserInfo.getOrganizationName();
            String emailSetting = '';
            String orgWideEmailId = getConfigValue('org wide email id');
            List<OrgWideEmailAddress> emailAddresses = [
                    SELECT Id, Address
                    FROM OrgWideEmailAddress
                    WHERE Id = :orgWideEmailId
            ];

            if (emailAddresses.isEmpty()) {
                emailSetting = getConfigValue('email');
            } else {
                emailSetting = emailAddresses[0].Address;
            }

            for (BR_Participation__c participation : participations) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Id targetId = null;
                Id userId = participation.User__c;
                Id contactId = participation.Contact__c;
                Id leadId = participation.Lead__c;

                if (userId != null) {
                    targetId = userId;
                } else if (contactId != null) {
                    targetId = contactId;
                } else if (leadId != null) {
                    targetId = leadId;
                }

                if (targetId != null) {

                    String body = emailTemplate.HtmlValue;
                    Integer diffMinutes = 0;
                    String eventTimezone = participation.BR_Event__r.Timezone__c;
                    String userTimezone = UserInfo.getTimeZone().toString();

                    if (eventTimezone != null) {
                        diffMinutes = BrEventsHelper.getDiffMinutesBetweenTimezones(eventTimezone, userTimezone);
                    } else {
                        eventTimezone = '';
                    }

                    Datetime startDate = participation.BR_Event__r.Start_Date__c.addMinutes(diffMinutes);
                    Datetime endDate = participation.BR_Event__r.End_Date__c;
                    String formattedStartDate = ' ' + startDate.format();

                    String userName = participation.User__r.Name;
                    userName = (userName == null) ? participation.Contact__r.Name : userName;
                    userName = (userName == null) ? participation.Lead__r.Name : userName;

                    String eventName = participation.BR_Event__r.Name;
                    String eventNameEncoded = EncodingUtil.urlEncode(eventName, 'UTF-8');

                    String startDateGmt = participation.BR_Event__r.Start_Date__c.formatGmt('yyyyMMdd\'T\'HHmm00\'Z\'');
                    String endDateGmt = (endDate == null) ? startDate.addHours(1).formatGmt('yyyyMMdd\'T\'HHmm00\'Z\'') :
                            endDate.formatGmt('yyyyMMdd\'T\'HHmm00\'Z\'');

                    String description = participation.BR_Event__r.Description__c;
                    description = (description == null) ? '' : description;
                    String descriptionEncoded = (description == '') ? description : EncodingUtil.urlEncode(description, 'UTF-8');

                    String address = participation.BR_Event__r.Venue_Address__c;
                    String conformationMessage = participation.BR_Event__r.Registration_Confirmation_Message__c;
                    address = (address == null) ? '' : address;
                    String addressEncoded = (address == '') ? address : EncodingUtil.urlEncode(address, 'UTF-8');
                    String addressURL = (address == null) ? '' :'https://www.google.com/maps/place/' + addressEncoded;

                    body = emailTemplate.HtmlValue.replace('{!userName}', userName)
                            .replace('{!eventName}', eventName)
                            .replace('{!startDate}', formattedStartDate)
                            .replace('{!gmt}', eventTimezone)
                            .replace('{!eventNameEncoded}', eventNameEncoded)
                            .replace('{!startDateGmt}', startDateGmt)
                            .replace('{!endDateGmt}', endDateGmt)
                            .replace('{!eventDetails}', description)
                            .replace('{!eventDetailsEncoded}', descriptionEncoded)
                            .replace('{!location}', address)
                            .replace('{!confirmationMessage}',conformationMessage)
                            .replace('{!locationURL}', addressURL)
                            .replace('{!address}', addressEncoded);

                    Integer index = 0;

                    String senderName = emailTemplateName;
                    String subject = Label.br_lblUpdated + ': ' + eventName;

                    if (emailTemplateName == 'Changed event') {
                        index = 1;
                    } else {
                        subject = eventName + ': ' + Label.br_lblRegistration;
                    }

                    String eventId = participation.BR_Event__r.Id;

                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.filename = 'event.ics';
                    attach.ContentType = 'text/calendar;';
                    attach.inline = true;
                    attach.body = createAttachmentBody(eventId, eventName, startDateGmt, endDateGmt, description, address, orgName, emailSetting, index);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                            attach
                    });


                    email.setHtmlBody(body);
                    if (emailAddresses.isEmpty()) {
                        email.setSenderDisplayName(orgName);
                    } else {
                        email.setOrgWideEmailAddressId(emailAddresses[0].Id);
                    }
                    email.setTargetObjectId(targetId);
                    email.setTemplateId(emailTemplate.Id);
                    email.setSubject(subject);
                    email.setWhatId(participation.Id);
                    email.setSaveAsActivity(false);
                    emails.add(email);
                }
            }

            if (!emails.isEmpty()) {
                try {
                    Messaging.sendEmail(emails);
                } catch (EmailException ex) {
                    System.debug(ex.getMessage());
                }
            }
        }
    }

    public static Blob createAttachmentBody(String eventId, String eventName, String startDate, String endDate, String description, String address,
        String organization, String email, Integer index) {
        eventName = (eventName == null) ? '' : eventName;
        address = (address == null) ? '' : address;
        description = (description == null) ? '' : description;

        String body = '';

        body += 'BEGIN:VCALENDAR\n';
        body += 'VERSION:2.0\n';
        body += 'METHOD:REQUEST\n';
        body += 'BEGIN:VEVENT\n';
        body += 'ORGANIZER;CN=' + organization + ':mailto:' + email + '\n';
        body += 'ATTENDEE;CN=' + organization + ':mailto:' + email + '\n';
        body += 'DTEND:' + endDate + '\n';
        body += 'DTSTART:' + startDate + '\n';
        body += 'LOCATION:' + address + '\n';
        body += 'SUMMARY:' + eventName + '\n';
        body += 'DESCRIPTION: ' + description + '\n';
        body += 'UID:' + eventId + '\n';
        body += 'SEQUENCE:' + index + '\n';
        body += 'LANGUAGE=en-us:Event\n';
        body += 'END:VEVENT\n';
        body += 'END:VCALENDAR';

        return Blob.valueOf(body);
    }

    public static String getDateTimeFormat(String locale) {
        Map<String, String> localFormat = new Map<String, String>();
        localFormat.put('ar', 'dd/MM/yyyy hh:mm a');
        localFormat.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        localFormat.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        localFormat.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        localFormat.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        localFormat.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        localFormat.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        localFormat.put('be_BY', 'dd.MM.yyyy H:mm');
        localFormat.put('bg_BG', 'yyyy-M-d H:mm');
        localFormat.put('ca', 'dd/MM/yyyy HH:mm');
        localFormat.put('ca_ES', 'dd/MM/yyyy HH:mm');
        localFormat.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        localFormat.put('cs', 'd.M.yyyy H:mm');
        localFormat.put('cs_CZ', 'd.M.yyyy H:mm');
        localFormat.put('da', 'dd-MM-yyyy HH:mm');
        localFormat.put('da_DK', 'dd-MM-yyyy HH:mm');
        localFormat.put('de', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_AT', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_CH', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_DE', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_LU', 'dd.MM.yyyy HH:mm');
        localFormat.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        localFormat.put('el_GR', 'd/M/yyyy h:mm a');
        localFormat.put('en_AU', 'd/MM/yyyy HH:mm');
        localFormat.put('en_B', 'M/d/yyyy h:mm a');
        localFormat.put('en_BM', 'M/d/yyyy h:mm a');
        localFormat.put('en_CA', 'dd/MM/yyyy h:mm a');
        localFormat.put('en_GB', 'dd/MM/yyyy HH:mm');
        localFormat.put('en_GH', 'M/d/yyyy h:mm a');
        localFormat.put('en_ID', 'M/d/yyyy h:mm a');
        localFormat.put('en_IE', 'dd/MM/yyyy HH:mm');
        localFormat.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
        localFormat.put('en_NZ', 'd/MM/yyyy HH:mm');
        localFormat.put('en_SG', 'M/d/yyyy h:mm a');
        localFormat.put('en_US', 'M/d/yyyy h:mm a');
        localFormat.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        localFormat.put('es', 'd/MM/yyyy H:mm');
        localFormat.put('es_AR', 'dd/MM/yyyy HH:mm');
        localFormat.put('es_BO', 'dd-MM-yyyy hh:mm a');
        localFormat.put('es_CL', 'dd-MM-yyyy hh:mm a');
        localFormat.put('es_CO', 'd/MM/yyyy hh:mm a');
        localFormat.put('es_CR', 'dd/MM/yyyy hh:mm a');
        localFormat.put('es_EC', 'dd/MM/yyyy hh:mm a');
        localFormat.put('es_ES', 'd/MM/yyyy H:mm');
        localFormat.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        localFormat.put('es_GT', 'd/MM/yyyy hh:mm a');
        localFormat.put('es_HN', 'MM-dd-yyyy hh:mm a');
        localFormat.put('es_MX', 'd/MM/yyyy hh:mm a');
        localFormat.put('es_PE', 'dd/MM/yyyy hh:mm a');
        localFormat.put('es_PR', 'MM-dd-yyyy hh:mm a');
        localFormat.put('es_PY', 'dd/MM/yyyy hh:mm a');
        localFormat.put('es_SV', 'MM-dd-yyyy hh:mm a');
        localFormat.put('es_UY', 'dd/MM/yyyy hh:mm a');
        localFormat.put('es_VE', 'dd/MM/yyyy hh:mm a');
        localFormat.put('et_EE', 'd.MM.yyyy H:mm');
        localFormat.put('fi', 'd.M.yyyy H:mm');
        localFormat.put('fi_FI', 'd.M.yyyy H:mm');
        localFormat.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        localFormat.put('fr', 'dd/MM/yyyy HH:mm');
        localFormat.put('fr_BE', 'd/MM/yyyy H:mm');
        localFormat.put('fr_CA', 'yyyy-MM-dd HH:mm');
        localFormat.put('fr_CH', 'dd.MM.yyyy HH:mm');
        localFormat.put('fr_FR', 'dd/MM/yyyy HH:mm');
        localFormat.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        localFormat.put('fr_LU', 'dd/MM/yyyy HH:mm');
        localFormat.put('fr_MC', 'dd/MM/yyyy HH:mm');
        localFormat.put('hr_HR', 'yyyy.MM.dd HH:mm');
        localFormat.put('hu', 'yyyy.MM.dd. H:mm');
        localFormat.put('hy_AM', 'M/d/yyyy h:mm a');
        localFormat.put('is_IS', 'd.M.yyyy HH:mm');
        localFormat.put('it', 'dd/MM/yyyy H.mm');
        localFormat.put('it_CH', 'dd.MM.yyyy HH:mm');
        localFormat.put('it_IT', 'dd/MM/yyyy H.mm');
        localFormat.put('iw', 'HH:mm dd/MM/yyyy');
        localFormat.put('iw_IL', 'HH:mm dd/MM/yyyy');
        localFormat.put('ja', 'yyyy/MM/dd H:mm');
        localFormat.put('ja_JP', 'yyyy/MM/dd H:mm');
        localFormat.put('kk_KZ', 'M/d/yyyy h:mm a');
        localFormat.put('km_KH', 'M/d/yyyy h:mm a');
        localFormat.put('ko', 'yyyy. M. d a h:mm');
        localFormat.put('ko_KR', 'yyyy. M. d a h:mm');
        localFormat.put('lt_LT', 'yyyy.M.d HH.mm');
        localFormat.put('lv_LV', 'yyyy.d.M HH:mm');
        localFormat.put('ms_MY', 'dd/MM/yyyy h:mm a');
        localFormat.put('nl', 'd-M-yyyy H:mm');
        localFormat.put('nl_BE', 'd/MM/yyyy H:mm');
        localFormat.put('nl_NL', 'd-M-yyyy H:mm');
        localFormat.put('nl_SR', 'd-M-yyyy H:mm');
        localFormat.put('no', 'dd.MM.yyyy HH:mm');
        localFormat.put('no_NO', 'dd.MM.yyyy HH:mm');
        localFormat.put('pl', 'yyyy-MM-dd HH:mm');
        localFormat.put('pt', 'dd-MM-yyyy H:mm');
        localFormat.put('pt_AO', 'dd-MM-yyyy H:mm');
        localFormat.put('pt_BR', 'dd/MM/yyyy HH:mm');
        localFormat.put('pt_PT', 'dd-MM-yyyy H:mm');
        localFormat.put('ro_RO', 'dd.MM.yyyy HH:mm');
        localFormat.put('ru', 'dd.MM.yyyy H:mm');
        localFormat.put('sk_SK', 'd.M.yyyy H:mm');
        localFormat.put('sl_SI', 'd.M.y H:mm');
        localFormat.put('sv', 'yyyy-MM-dd HH:mm');
        localFormat.put('sv_SE', 'yyyy-MM-dd HH:mm');
        localFormat.put('th', 'M/d/yyyy h:mm a');
        localFormat.put('th_TH', 'd/M/yyyy, H:mm ?.');
        localFormat.put('tr', 'dd.MM.yyyy HH:mm');
        localFormat.put('ur_PK', 'M/d/yyyy h:mm a');
        localFormat.put('vi_VN', 'HH:mm dd/MM/yyyy');
        localFormat.put('zh', 'yyyy-M-d ah:mm');
        localFormat.put('zh_CN', 'yyyy-M-d ah:mm');
        localFormat.put('zh_HK', 'yyyy-M-d ah:mm');
        localFormat.put('zh_TW', 'yyyy/M/d a h:mm');
        return localFormat.get(locale);
    }

    public static void createContactParticipation(String jsonString, String eventId) {
        if(!BrEventsHelper.performAccessCheck('read', 'Contact', null)
                || !BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null)
                || !BrEventsHelper.performAccessCheck('create', 'BR_Participation__c', new List<String>{'BR_Event__c','Participate__c','Contact__c'})){
            return;
        }

        String accountId;
        BrEvents_Settings__c setting = BrEvents_Settings__c.getValues('guest_account_id');

        if (setting == null || setting.Value__c == 'undefined') {
            return;

        } else {
            accountId = setting.Value__c;
        }

        List<Map<String,String>> deserializedList =
                (List<Map<String,String>>)JSON.deserialize(jsonString, List<Map<String,String>>.class);

        Contact contact = new Contact();

        for(Map<String,String> fieldMap: deserializedList) {
            for(String fieldMapKey: fieldMap.keySet()) {
                contact.put(fieldMapKey, fieldMap.get(fieldMapKey));
            }
        }

        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName = :String.valueOf(contact.get('LastName')) AND Email = :String.valueOf(contact.get('Email'))];

        if(contacts.isEmpty()) {
            BrEvents_Settings__c rtSetting = BrEvents_Settings__c.getValues('contact_recordtype_id');

            if(rtSetting != null && rtSetting.Value__c != 'undefined') {
                List<RecordType> rt = [SELECT Id FROM RecordType WHERE Id = :rtSetting.Value__c AND IsActive = TRUE LIMIT 1];

                if(!rt.isEmpty()) {
                    contact.put('RecordTypeId', rtSetting.Value__c);
                }
            }

            contact.put('AccountId', accountId);
            insert contact;

        } else {
            contact = contacts[0];
        }

        if(contact.Id != null) {
            List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c WHERE Contact__c = :contact.Id];

            if(participations.isEmpty()) {
                BR_Participation__c p = new BR_Participation__c();
                p.BR_Event__c = eventId;
                p.Participate__c = 'Yes';
                p.Contact__c = contact.Id;
                insert p;
            }
        }
    }

    public static void createLeadParticipation(String jsonString, String eventId) {
        if(!BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null)
                || !BrEventsHelper.performAccessCheck('create', 'BR_Participation__c', new List<String>{'BR_Event__c','Participate__c','Lead__c'})){
            return;
        }
        List<Map<String,String>> deserializedList =
                (List<Map<String,String>>)JSON.deserialize(jsonString, List<Map<String,String>>.class);

        Lead lead = new Lead();

        for(Map<String,String> fieldMap: deserializedList) {
            for(String fieldMapKey: fieldMap.keySet()) {
                lead.put(fieldMapKey, fieldMap.get(fieldMapKey));
            }
        }

        List<Lead> leads = [SELECT Id FROM Lead WHERE LastName = :String.valueOf(lead.get('LastName')) AND Email = :String.valueOf(lead.get('Email'))];

        if(leads.isEmpty()) {
            insert lead;

        } else {
            lead = leads[0];
        }

        if(lead.Id != null) {
            List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c WHERE Lead__c = :lead.Id];

            if(participations.isEmpty()) {
                BR_Participation__c p = new BR_Participation__c();
                p.BR_Event__c = eventId;
                p.Participate__c = 'Yes';
                p.Lead__c = lead.Id;
                insert p;
            }
        }
    }

    public static Integer getDiffMinutesBetweenTimezones(String eventTimezone, String userTimezoneSidKey) {
        String eventTimezoneGmt = eventTimezone.substringAfter('(GMT').substringBefore(')');
        String operation = eventTimezoneGmt.substring(0, 1);

        Integer lastIndex = eventTimezoneGmt.length();
        String eventTime = eventTimezoneGmt.substring(1, lastIndex);
        String firstChar = eventTime.substring(0, 1);
        String secondChar = eventTime.substring(1, 2);
        String preLastChar = eventTime.substring(lastIndex-3, lastIndex-2);
        String lastChar = eventTime.substring(lastIndex-2, lastIndex-1);

        Integer hours = Integer.valueOf(firstChar) * 10 + Integer.valueOf(secondChar);
        Integer eventTimezoneOffsetMinutes = hours * 60 + Integer.valueOf(preLastChar) * 10 + Integer.valueOf(lastChar);

        if (operation == '-') {
            eventTimezoneOffsetMinutes *= -1;
        }

        Timezone currentTimezone = Timezone.getTimeZone(userTimezoneSidKey);
        Integer userTimezoneOffsetMinutes = currentTimezone.getOffset(DateTime.now())/1000/60;

        return (eventTimezoneOffsetMinutes - userTimezoneOffsetMinutes);
    }



}