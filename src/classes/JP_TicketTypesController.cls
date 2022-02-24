/**
 * Created by lauren.lezberg on 11/11/2019.
 */

public with sharing class JP_TicketTypesController {

    /**
     * @purpose Get ticket types and event user segments for specified event
     *
     * @param eventId
     *
     * @return Ticket types
     */
    @AuraEnabled
    public static TicketTypeInfo getTicketTypes(Id eventId){
        System.debug('---getting ticket types for event: ' + eventId);
        TicketTypeInfo tInfo = new TicketTypeInfo();
        if(String.isBlank(eventId)){
            new AACRCustomException('Null event Id','JP_TicketTypesController.getTicketTypes()', 'Event Builder');
            return tInfo;
        }
        BR_Event__c evt = [SELECT Show_Joint_Fields__c, Joint_Providership_Institution__r.Name, Show_Workshop_Fields__c, Show_Pre_Post_Doc__c FROM BR_Event__c WHERE Id=: eventId];

        //get all active user segments
        tInfo.userSegments = [SELECT Id, 
                                    Name, 
                                    Description__c 
                                    FROM AC_User_Segment__c 
                                    WHERE Active__c = true AND Available__c = true
                                    ORDER BY Name];

        //get all event user segments for specified event
        List<AC_Event_User_Segment__c> eus = [SELECT Price__c, 
                                                    Priority__c, 
                                                    AC_User_Segment__c, 
                                                    AC_User_Segment__r.Name, 
                                                    Early_Bird_Price__c,
                                                    Early_Bird_Price_Deadline__c, 
                                                    Event_Preferences_Form_Fieldset__c,
                                                    On_Demand_Price__c,
                                                    On_Demand_Start_Date__c
                                                    FROM AC_Event_User_Segment__c 
                                                    WHERE AC_Event__c=: eventId];

        List<TicketType> tTypes = new List<TicketType>();



        //add ticket type wrapper object for each event user segment
        if(!eus.isEmpty()){
            TicketType defaultSeg;
            for(AC_Event_User_Segment__c seg : eus){
                System.debug('segment: ' + seg);
//                Date ebDate=null;
//                String ebTime=null;
//                if(seg.Early_Bird_Price__c!=null){
//                    ebDate = date.newinstance(seg.Early_Bird_Price_Deadline__c.year(), seg.Early_Bird_Price_Deadline__c.month(), seg.Early_Bird_Price_Deadline__c.day());
//                    ebTime = seg.Early_Bird_Price_Deadline__c.format('hh:mm a');
//
//                }
                if(seg.AC_User_Segment__r.Name == 'Nonmember Individual'){
                    defaultSeg = new TicketType(seg.Price__c,
                            seg.Priority__c,
                            seg.AC_User_Segment__r.Name,
                            seg.AC_User_Segment__c,
                            seg.Early_Bird_Price__c,
                            seg.Early_Bird_Price_Deadline__c,
                            seg.On_Demand_Price__c,
                            seg.On_Demand_Start_Date__c,
                            seg.Event_Preferences_Form_Fieldset__c);
                } else {
                    tTypes.add(new TicketType(seg.Price__c,
                            seg.Priority__c,
                            seg.AC_User_Segment__r.Name,
                            seg.AC_User_Segment__c,
                            seg.Early_Bird_Price__c,
                            seg.Early_Bird_Price_Deadline__c,
                            seg.On_Demand_Price__c,
                            seg.On_Demand_Start_Date__c,
                            seg.Event_Preferences_Form_Fieldset__c));
                }
            }
            if(tTypes.size()>0) {
                tTypes.add(0, defaultSeg);
            } else {
                tTypes.add(defaultSeg);
            }
//            tInfo.ticketTypes = tTypes;
        } else{ //add default segment
            for(Integer j = 0; j< tInfo.userSegments.size(); j++){
                if(tInfo.userSegments[j].Name == 'Nonmember Individual'){
                    tTypes.add(new TicketType(0,
                            100,
                            tInfo.userSegments[j].Name,
                            tInfo.userSegments[j].Id,
                            null,
                            null,
                            null,
                            null,
                            null));
                    tInfo.userSegments.remove(j);
                }
            }

            //if show workshop fields --> create mentor/trainee segments
            if(evt.Show_Workshop_Fields__c){
                AC_User_Segment__c mentorSeg = createSeniorScientistSegment(eventId);
                tTypes.add(new TicketType(0,
                        0,
                        mentorSeg.Name,
                        mentorSeg.Id,
                        null,
                        null,
                        null,
                        null,
                        null));
                AC_User_Segment__c traineeSeg = createTraineeSegment(eventId);
                tTypes.add(new TicketType(0,
                        0,
                        traineeSeg.Name,
                        traineeSeg.Id,
                        null,
                        null,
                        null,
                        null,
                        null));
                System.debug('tTypes: ' + tTypes);
            }



        }
        if(evt.Show_Pre_Post_Doc__c) {
            AC_User_Segment__c prePostSeg = getPrePostDocSegment(eventId);
            if(prePostSeg!=null) {
                tTypes.add(new TicketType(0,
                        0,
                        prePostSeg.Name,
                        prePostSeg.Id,
                        null,
                        null,
                        null,
                        null,
                        null));
            }
        }
        if(evt.Show_Joint_Fields__c){
            AC_User_Segment__c jointSeg = createJointMemberSegment(eventId, evt.Joint_Providership_Institution__r.Name);
            if(jointSeg!=null) {
                tTypes.add(new TicketType(0,
                        0,
                        jointSeg.Name,
                        jointSeg.Id,
                        null,
                        null,
                        null,
                        null,
                        null));
                System.debug('tTypes: ' + tTypes);
            }
        }

        tInfo.ticketTypes = tTypes;

        return tInfo;
    }

    public static AC_User_Segment__c createJointMemberSegment(String eventId, String jointProvider){

        String queryString = 'SELECT Id, Name FROM User WHERE ContactId IN (SELECT Contact__c FROM BR_Participation__c WHERE Joint_Member_ID__c != null AND BR_Event__c=\'' + eventId + '\')';
        String segmentName = jointProvider + ' Member';
        List<AC_User_Segment__c> jcMemberSegs = [SELECT Id, Name FROM AC_User_Segment__c WHERE Event_Id__c =: eventId AND Name=:segmentName];
        System.debug('jcMemberSEgs: ' + jcMemberSegs);

        if(jcMemberSegs.size()==0) {
            AC_User_Segment__c jointMember = new AC_User_Segment__c(Name = segmentName, Event_Id__c=eventId, Description__c = 'Joint Conference Member', Query__c = queryString, Active__c = true, Available__c = false);

            try {
                insert jointMember;

                return jointMember;
            } catch (Exception e) {
                System.debug('exception: ' + e.getMessage());
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Joint Conference Member Segment');
            }
        }

        return null;
    }

    public static AC_User_Segment__c createTraineeSegment(String eventId){
        String queryString = 'SELECT Id, Name FROM User WHERE ContactId IN (SELECT Contact__c FROM BR_Participation__c WHERE Workshop_Groups__c = \'Trainee\' AND BR_Event__c=\'' + eventId + '\')';
        List<AC_User_Segment__c> traineeSegs = [SELECT Id, Name FROM AC_User_Segment__c WHERE Event_Id__c =: eventId AND Name='Trainee'];

        if(traineeSegs.size()==0) {
            AC_User_Segment__c trainee = new AC_User_Segment__c(Name = 'Trainee', Event_Id__c=eventId, Description__c = 'Trainee', Query__c = queryString, Active__c = true, Available__c = false);

            try {
                insert trainee;

                return trainee;
            } catch (Exception e) {
                System.debug('exception: ' + e.getMessage());
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Trainee Segment');
            }
        }

        return traineeSegs[0];
    }

    public static AC_User_Segment__c createSeniorScientistSegment(String eventId){
        System.debug('createSeniorScientistSegment...');
        String queryString = 'SELECT Id, Name FROM User WHERE ContactId IN (SELECT Contact__c FROM BR_Participation__c WHERE Workshop_Groups__c = \'Senior_Scientist\' AND BR_Event__c=\'' + eventId + '\')';
        List<AC_User_Segment__c> ssSegs = [SELECT Id, Name FROM AC_User_Segment__c WHERE Event_Id__c =: eventId AND Name='Senior Scientist'];
        System.debug('ssSegs: ' + ssSegs);
        if(ssSegs.size()==0) {
            SYstem.debug('creating segment...');
            AC_User_Segment__c ss = new AC_User_Segment__c(Name = 'Senior Scientist', Event_Id__c=eventId, Description__c = 'Senior Scientist', Query__c = queryString, Active__c = true, Available__c = false);

            try {
//                System.debug('Senior Scientist segment: ' + mentor);
                insert ss;

                return ss;
            } catch (Exception e) {
                System.debug('exception: ' + e.getMessage());
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Senior Scientist Segment');
            }
        }

        return ssSegs[0];
    }

    public static AC_User_Segment__c getPrePostDocSegment(String eventId){
        List<AC_Event_User_Segment__c> eus = [SELECT Id FROM AC_Event_User_Segment__c WHERE AC_Event__c=: eventId AND AC_User_Segment__r.Name = 'Pre/Post Doc'];
        if(eus.isEmpty()){
            AC_User_Segment__c prePost = [SELECT Id, AC_User_Segment__c.Name FROM AC_User_Segment__c WHERE Name='Pre/Post Doc' AND Available__c = true AND Active__c = true];
            return prePost;
        }

        return null;
    }


//    public static AC_User_Segment__c createPrePostDocSegment(String eventId){
//        String queryString = 'SELECT Id, Name FROM User WHERE ContactId IN (SELECT Contact__c FROM BR_Participation__c WHERE Pre_Post_Doc__c = true AND BR_Event__c=\'' + eventId + '\')';
//        List<AC_User_Segment__c> prePostSegs = [SELECT Id, Name FROM AC_User_Segment__c WHERE Event_Id__c =: eventId AND Name = 'Pre/Post Doc'];
//
//        if(prePostSegs.size()==0) {
//            AC_User_Segment__c prePost = new AC_User_Segment__c(Name = 'Pre/Post Doc', Event_Id__c=eventId, Description__c = 'pre/post doc and clinical fellows', Query__c = queryString, Active__c = true, Available__c = false);
//
//            try {
//                insert prePost;
//
//                return prePost;
//            } catch (Exception e) {
//                System.debug('exception: ' + e.getMessage());
//                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Pre/Post Doc Segment');
//            }
//        }
//
//        return prePostSegs[0];
//    }

    /**
     * @purpose Save selected ticket types as event user segments
     *
     * @param eventId
     * @param ticketTypes
     */
    @AuraEnabled
    public static void saveEventUserSegments(String eventId, List<Object> ticketTypes){
        System.debug('---saving ' + ticketTypes +  ' ticket types for eventId ' + eventId);
        if(String.isBlank(eventId)){
            new AACRCustomException('Null event Id','JP_TicketTypesController.saveEventUserSegments()', 'Event Builder');
            return;
        }
        //get all old user segments
        List<AC_Event_User_Segment__c> oldSegments = [SELECT Price__c, 
                                                            Priority__c, 
                                                            AC_User_Segment__c, 
                                                            AC_User_Segment__r.Name, 
                                                            Early_Bird_Price__c,
                                                            Early_Bird_Price_Deadline__c, 
                                                            Event_Preferences_Form_Fieldset__c,
                                                            On_Demand_Price__c,
                                                            On_Demand_Start_Date__c
                                                            FROM AC_Event_User_Segment__c 
                                                            WHERE AC_Event__c=:eventId];
        System.debug('oldSegments: ' + oldSegments);
        //put old segments into map
        Map<Id, AC_Event_User_Segment__c> segmentMap = new Map<Id, AC_Event_User_Segment__c>();
        for(AC_Event_User_Segment__c seg : oldSegments){
            segmentMap.put(seg.AC_User_Segment__c, seg);
        }
        System.debug('segmentMap: ' + segmentMap);

        Set<Id> newIds = new Set<Id>();
        List<AC_Event_User_Segment__c> newSegments = new List<AC_Event_User_Segment__c>();

        //iterate through new ticket types and determine whether they already exist to update or need to be inserted
        for(Object type: ticketTypes){
            TicketType ttype = (TicketType)JSON.deserialize(JSON.serialize(type), TicketType.class);
            System.debug('ticket type deserialized: ' + ttype);
            newIds.add(ttype.Id);
            //if ticket type does not already exist as a user segment - add it
            if(!segmentMap.keySet().contains(ttype.Id)) {
                newSegments.add(new AC_Event_User_Segment__c(AC_Event__c = eventId, 
                                                            Price__c = ttype.Price, 
                                                            Priority__c = ttype.Priority, 
                                                            AC_User_Segment__c = ttype.Id, 
                                                            Early_Bird_Price__c = ttype.EBPrice,
                                                            Early_Bird_Price_Deadline__c=ttype.EBDate,
                                                            On_Demand_Price__c = ttype.ODPrice,
                                                            On_Demand_Start_Date__c = ttype.ODDate,
                                                            Event_Preferences_Form_Fieldset__c = ttype.DietPreferences));
            } else { // if ticket type already exists - update it
                AC_Event_User_Segment__c seg = segmentMap.get(ttype.Id);
                seg.Price__c = ttype.Price;
                seg.Priority__c = ttype.Priority;
                seg.Early_Bird_Price__c = ttype.EBPrice;
                seg.Early_Bird_Price_Deadline__c=ttype.EBDate;
                seg.On_Demand_Price__c = ttype.ODPrice;
                seg.On_Demand_Start_Date__c = ttype.ODDate;
                seg.Event_Preferences_Form_Fieldset__c=ttype.DietPreferences;
                newSegments.add(seg);
            }

        }

        //remove any ticket types that no longer exist
        oldSegments = new List<AC_Event_User_Segment__c>();
        for(Id segmentId : segmentMap.keySet()){
            if(!newIds.contains(segmentId)){
                oldSegments.add(segmentMap.get(segmentId));
            }
        }
        try {
            upsert newSegments;
            delete oldSegments;
        } catch (Exception e) {
            new AACRCustomException(eventId,e.getMessage(), e.getStackTraceString(), 'Event Builder');
            System.debug('Could not add/update/delete ticket types: ' + e.getMessage()); 
        }
            

    }
        public class TicketTypeInfo{
            @AuraEnabled
            public List<AC_User_Segment__c> userSegments;
    
            @AuraEnabled
            public List<TicketType> ticketTypes;
    
           public TicketTypeInfo(){}
        }
    
        public class TicketType{
            @AuraEnabled
            public Decimal Price;
    
            @AuraEnabled
            public Decimal Priority;
    
            @AuraEnabled
            public String Name;
    
            @AuraEnabled
            public String Id;
    
            @AuraEnabled
            public Decimal EBPrice;
    
            @AuraEnabled
            public Datetime EBDate;

            @AuraEnabled
            public Decimal ODPrice;

            @AuraEnabled
            public Datetime ODDate;

            @AuraEnabled
            public String DietPreferences;
    
    
            public TicketType(Decimal price, Decimal priority, String name, String id, Decimal ebprice, Datetime ebdate,Decimal odprice, Datetime oddate, String DietPreferences){
                this.Price = price;
                this.Priority = priority;
                this.Name = name;
                this.Id = id;
                this.EBPrice = ebprice;
                this.EBDate = ebdate;
                this.ODPrice = odprice;
                this.ODDate = oddate;
                this.DietPreferences = DietPreferences;
            }
        }
        
}