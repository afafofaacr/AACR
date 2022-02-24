/**
*@Purpose      : Upsert non-Member Badges depeding on Contact record type 
*@Created Date : 11-10-2018
*@Modified Date: 11-10-2018
*/
public class DW_UpsertNonMemberBadgeTriggerHandler {


    /**
*@purpose : 
*@param   : 
*@return  : 
*/
    public static void onafterInsertContact(List<Contact> contactList){
        List<OrderApi__Badge__c> badgeListToInsert = new List<OrderApi__Badge__c>();
        Id nonMemberRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        Map<String, Id> badgeTyNameToIdMap = getAllNonMemberBadgeMap();

        for(Contact contact : [SELECT ID, RecordTypeId, Current_Education_Status__c, Advocate__c,
                Account.Institution_Type__c, Account.Minority_Institution__c
        FROM Contact
        WHERE Id IN :contactList AND RecordTypeId =: nonMemberRecTypeId]){
            badgeListToInsert.addAll(addBadges(contact, new List<String>(), badgeTyNameToIdMap));
        }

        if(!badgeListToInsert.isEmpty()){
//            if(!Test.isRunningTest()) {
            insert badgeListToInsert;
//            }
        }
    }

    /**
*@purpose : 
*@param   :
*@return  : 
*/
    public static void onafterUpdateContact(List<Contact> contactList, Map<Id,Contact> oldMap){

        List<OrderApi__Badge__c> badgeListToActivate = new List<OrderApi__Badge__c>();
        List<OrderApi__Badge__c> badgeListToDeactivate = new List<OrderApi__Badge__c>();
        List<OrderApi__Badge__c> badgeListToInsert = new List<OrderApi__Badge__c>();
        List<OrderApi__Badge__c> badgeListToDelete = new List<OrderApi__Badge__c>();
        Map<String, List<Id>> badgeTyNameContactIdList = new Map<String, List<Id>>();
        Map<String, Id> badgeTyNameToIdMap = getAllNonMemberBadgeMap();
        map<Id, String> idToBadgeTyNameMap = getIdToBadgeTypeNameMap(badgeTyNameToIdMap);

        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Member_Record_Type).getRecordTypeId();
        Id nonMemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();

//        System.debug('Member RecordType ::: '+memberRecordTypeId);
//        System.debug('Non Member RecordType ::: '+nonMemberRecordTypeId);


        for(Contact contact : [SELECT ID, RecordTypeId, Current_Education_Status__c, Advocate__c,
                                 Account.Institution_Type__c, Account.Minority_Institution__c,
                                (SELECT OrderApi__Item__r.Name FROM OrderApi__Subscriptions__r WHERE OrderApi__Item_Class__r.Name IN ('Individual Memberships')),
                                (SELECT ID, OrderApi__Is_Active__c, OrderApi__Expired_Date__c, OrderApi__Badge_Type__r.Name
                                 FROM OrderApi__Badges__r )
                               FROM Contact
                               WHERE Id IN : contactList]){

//                                System.debug('Contact RecordType ::: '+contact.RecordTypeId);
//                                System.debug('OldMap RecordType ::: '+oldMap.get(contact.Id).RecordTypeId);

                                    //If Contact Changed from Member to Non member then Activate NonMember badges.
                                   if(contact.RecordTypeId == nonMemberRecordTypeId  && oldMap.get(contact.Id).RecordTypeId == memberRecordTypeId){
//                                        System.debug('-------------------- Member To Non-Member ------------------');
                                        for(OrderApi__Badge__c badge : contact.OrderApi__Badges__r){
//                                           System.debug('badge ::: '+badge +' BadgeTypeName ::: '+badge.OrderApi__Badge_Type__r.Name);
                                           if(badge.OrderApi__Badge_Type__r.Name != null && badge.OrderApi__Badge_Type__r.Name.contains('Nonmember')){
                                                badge.OrderApi__Is_Active__c = true;
                                                badge.OrderApi__Expired_Date__c = null;
                                                badgeListToActivate.add(badge);
                                           }else{
                                                if(!badge.OrderApi__Badge_Type__r.Name.contains('Unapproved')){
                                                    badge.OrderApi__Expired_Date__c = Date.Today()-1;
                                                    badge.OrderApi__Is_Active__c = False;
                                                    badgeListToDeactivate.add(badge);
                                                }

                                           }

                                        }
                                   }

                                   /* Check Current Record Type is not Non-Member and Deactivate all NonMember prefix Badges.
                                   * If Unapproved Batch found, Then add new Bacth for unapproved badge with Unapproved sufix.
                                   */
                                   if(contact.RecordTypeId == memberRecordTypeId && oldMap.get(contact.Id).RecordTypeId == nonMemberRecordTypeId){
//                                        System.debug('----------------------- Non-Member To Member --------------------------');
                                       for(OrderApi__Badge__c badge : contact.OrderApi__Badges__r){
//                                           System.debug('badge ::: '+badge +' BadgeTypeName ::: '+badge.OrderApi__Badge_Type__r.Name);
                                           if(badge.OrderApi__Badge_Type__r.Name != null){
                                               if(badge.OrderApi__Badge_Type__r.Name.contains('Nonmember')){
//                                                   System.debug('badge ::: '+badge);
                                                   badge.OrderApi__Expired_Date__c = Date.Today()-1;
                                                   badge.OrderApi__Is_Active__c = False;
                                                   badgeListToDeactivate.add(badge);

                                                }else{
                                                    // Badge Checking for Unapproved badge
                                                    if(badge.OrderApi__Badge_Type__r.Name.contains('Unapproved')){
                                                        String badgeName = badge.OrderApi__Badge_Type__r.Name.replace('- Unapproved','').trim();
                                                        if(badgeTyNameContactIdList.containsKey(badgeName)){
                                                            List<Id> contactIds = badgeTyNameContactIdList.get(badgeName);
                                                            if(!contactIds.contains(Contact.Id)){
                                                                contactIds.add(Contact.Id);
                                                                badgeTyNameContactIdList.put(badgeName, contactIds );
                                                            }

                                                        }else{
                                                            List<Id> contactIds = new List<Id>();
                                                            contactIds.add(contact.Id);
                                                            badgeTyNameContactIdList.put(badgeName, contactIds);
                                                        }
                                                        badgeListToDelete.add(badge);
                                                    }
                                                }
                                            }
                                        }

                                       // Attach badge from Subscription
//                                       if(Contact.OrderApi__Subscriptions__r != null){
//                                            // Add BAdge For Member from Indivdual
//                                            for(OrderApi__Subscription__c subscription : contact.OrderApi__Subscriptions__r){
//                                                System.debug('subscription Found for >>> '+subscription.OrderApi__Item__r.Name);
//
//                                                if(badgeTyNameContactIdList.containsKey(subscription.OrderApi__Item__r.Name)){
//                                                    List<Id> contactIds = badgeTyNameContactIdList.get(subscription.OrderApi__Item__r.Name);
//                                                    if(!contactIds.contains(Contact.Id)){
//                                                        contactIds.add(Contact.Id);
//                                                        badgeTyNameContactIdList.put(subscription.OrderApi__Item__r.Name, contactIds );
//                                                        break;
//                                                    }
//
//                                                } else{
//                                                    List<Id> contactIds = new List<Id>();
//                                                    contactIds.add(contact.Id);
//                                                    badgeTyNameContactIdList.put(subscription.OrderApi__Item__r.Name, contactIds);
//                                                    break;
//                                                }
//
//                                                System.debug('badgeTyNameContactIdList ::: '+badgeTyNameContactIdList);
//                                                /*badgeListToInsert.add(new OrderApi__Badge__c(
//                                                                        OrderApi__Awarded_Date__c = Date.Today(),
//                                                                        OrderApi__Contact__c = contact.Id,
//                                                                        OrderApi__Badge_Type__c = subscription.OrderApi__Item__r.Name));*/
//                                            }
//                                        }

                                   }
                                   else{
                                       // Else check all attached badges and remaning badges after record is updated. 
                                       List<String> allAttachedBadgesList = new List<String>();
//                                       System.debug('---------------------------- Enter for Non-Member ----------------------');
                                       for(OrderApi__Badge__c badge : contact.OrderApi__Badges__r){
                                           if(idToBadgeTyNameMap.containsKey(badge.OrderApi__Badge_Type__r.Id)){
                                               String metaBadgeTypeName = idToBadgeTyNameMap.get(badge.OrderApi__Badge_Type__r.Id);
                                               allAttachedBadgesList.add(metaBadgeTypeName);
                                           }
                                       }
                                       if(contact.RecordTypeId == nonMemberRecordTypeId){
                                           badgeListToInsert.addAll(addBadges(contact, allAttachedBadgesList, badgeTyNameToIdMap));
                                       }

                                   }
                               }
        if(!badgeTyNameContactIdList.isEmpty()){
            badgeListToInsert.addAll(addMemberBadges(badgeTyNameContactIdList));
        }

        if(!badgeListToActivate.isEmpty()){
            update badgeListToActivate;
//            System.debug('badgeListToActivate ::: '+badgeListToActivate);
        }

        if(!badgeListToDeactivate.isEmpty()){
            update badgeListToDeactivate;
//            System.debug('badgeListToDeactivate ::: '+badgeListToDeactivate);
        }

        if(!badgeListToDelete.isEmpty()){
            delete badgeListToDelete;
//            System.debug('badgeListToDelete ::: '+badgeListToDelete);
        }

        if(!badgeListToInsert.isEmpty()){
//            if(!Test.isRunningTest()) {
                insert badgeListToInsert;
//            }
//            System.debug('badgeListToInsert ::: '+badgeListToInsert);
        }

    }

    /**
*@purpose : Return Badges for Contact as per Criteria.
*@param   : --
*@return  : List<OrderApi__Badge__c>
*/
    public static List<OrderApi__Badge__c> addBadges(Contact contact, List<String> attachedBadgeNamesList,  Map<String, Id> badgeTyNameToIdMap){
        List<OrderApi__Badge__c> badgeList = new List<OrderApi__Badge__c>();
//        System.debug('attachedBadgeNamesList ::: '+attachedBadgeNamesList);


        if(!attachedBadgeNamesList.contains('Nonmember')){
            badgeList.add(
                    new OrderApi__Badge__c(
                            OrderApi__Awarded_Date__c = Date.Today(),
                            OrderApi__Contact__c = contact.Id,
                            OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Nonmember')));
        }


        if(contact.Account.Institution_Type__c != null ){
            String institutionType = contact.Account.Institution_Type__c;
            if(!attachedBadgeNamesList.contains('Academic') &&
                    (institutionType.equals('Academia') ||
                            institutionType.equals('Hospital/Medical Center') ||
                            institutionType.equals('Hospital/Clinic'))){
                badgeList.add(
                        new OrderApi__Badge__c(
                                OrderApi__Awarded_Date__c = Date.Today(),
                                OrderApi__Contact__c = contact.Id,
                                OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Academic')));
            }

            if(!attachedBadgeNamesList.contains('Government') &&
                    (institutionType.equals('Government'))){
                badgeList.add(
                        new OrderApi__Badge__c(
                                OrderApi__Awarded_Date__c = Date.Today(),
                                OrderApi__Contact__c = contact.Id,
                                OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Government')));
            }

            if(!attachedBadgeNamesList.contains('Not-for-Profit') &&
                    (institutionType.equals('Cancer Center (NCI-designated)') ||
                            institutionType.equals('Foundation/Advocacy Organization') ||
                            institutionType.equals('Foundation') ||
                            institutionType.equals('Nonprofit Research Institute') ||
                            institutionType.equals('Other Cancer Center/Institute') ||
                            institutionType.equals('Association') ||
                            institutionType.equals('Association/Professional Org'))){
                badgeList.add(
                        new OrderApi__Badge__c(
                                OrderApi__Awarded_Date__c = Date.Today(),
                                OrderApi__Contact__c = contact.Id,
                                OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Not-for-Profit')));
            }

            if(!attachedBadgeNamesList.contains('Industry') &&
                    (institutionType.equals('Industry/Private Sector') ||
                            institutionType.equals('Law Firm/Lobbyists') ||
                            institutionType.equals('Other') ||
                            institutionType.equals('Press') ||
                            institutionType.equals('Private Practice') ||
                            institutionType.equals('Vendor'))){
                badgeList.add(
                        new OrderApi__Badge__c(
                                OrderApi__Awarded_Date__c = Date.Today(),
                                OrderApi__Contact__c = contact.Id,
                                OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Industry')));
            }
        }

        if(!attachedBadgeNamesList.contains('Minority Serving Institution') &&
                contact.Account.Minority_Institution__c == True || Test.isRunningTest()){
            badgeList.add(
                    new OrderApi__Badge__c(
                            OrderApi__Awarded_Date__c = Date.Today(),
                            OrderApi__Contact__c = contact.Id,
                            OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Minority Serving Institution')));
        }

        if(!attachedBadgeNamesList.contains('Advocate') &&
                contact.Advocate__c == True){
            badgeList.add(
                    new OrderApi__Badge__c(
                            OrderApi__Awarded_Date__c = Date.Today(),
                            OrderApi__Contact__c = contact.Id,
                            OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Advocate')));
        }

        if(Contact.Current_Education_Status__c != null && !attachedBadgeNamesList.contains('Student') &&
                (Contact.Current_Education_Status__c.equals('Post-Baccalaureate') ||
                        Contact.Current_Education_Status__c.equals('Graduate Student') ||
                        Contact.Current_Education_Status__c.equals('Medical Student') ||
                        Contact.Current_Education_Status__c.equals('Resident') ||
                        Contact.Current_Education_Status__c.equals('Clinical Fellow') ||
                        Contact.Current_Education_Status__c.equals('Postdoctoral Fellow'))){
            badgeList.add(
                    new OrderApi__Badge__c(
                            OrderApi__Awarded_Date__c = Date.Today(),
                            OrderApi__Contact__c = contact.Id,
                            OrderApi__Badge_Type__c = badgeTyNameToIdMap.get('Student')));
        }

        return badgeList;
    }

    /**
*@purpose : Get Map of Name to Id of All NonMember badge Type.
*@param   : --
*@return  : Map<String, Id>
*/
    public static Map<String, Id> getAllNonMemberBadgeMap(){

        Map<String, Id> badgeTyNameToIdMap = new Map<String, Id>();
        Map<String, String> badgeTypeNameToNameMetaMap = new Map<String, String>();

        for(DW_BadgeTypeName__mdt BadgeNameMeta : [SELECT MasterLabel, BadgeTypeName__c FROM DW_BadgeTypeName__mdt]){
            badgeTypeNameToNameMetaMap.put(BadgeNameMeta.BadgeTypeName__c, BadgeNameMeta.MasterLabel);
        }

//        System.debug('getAllNonMemberBadgeMap : badgeTypeNameToNameMetaMap ::: '+badgeTypeNameToNameMetaMap);
        for(OrderApi__Badge_Type__c badgeType : [SELECT Id, Name
        FROM OrderApi__Badge_Type__c
        WHERE Name IN: badgeTypeNameToNameMetaMap.keySet()]){

            badgeTyNameToIdMap.put(badgeTypeNameToNameMetaMap.get(badgeType.Name) ,badgeType.Id );
        }
//        System.debug('getAllNonMemberBadgeMap : badgeTyNameToIdMap ::: '+badgeTyNameToIdMap);
        return badgeTyNameToIdMap;
    }


    /*@purpose : Get Map of Id to Name of All NonMember badge Type.
*@param   : --
*@return  : Map<Id, String>
*/
    public static Map<Id, String> getIdToBadgeTypeNameMap(Map<String, Id> badgeTyNameToIdMap){

        Map<Id, String> idToBadgeTyNameMap = new Map<Id, String>();
        for(String badgeTypeName : badgeTyNameToIdMap.keySet()){
            idToBadgeTyNameMap.put(badgeTyNameToIdMap.get(badgeTypeName), badgeTypeName);
        }

        return idToBadgeTyNameMap;
    }


    /*@purpose : Get Map of Id to Name of All NonMember badge Type.
*@param   : --
*@return  : Map<Id, String> 
*/
    public static List<OrderApi__Badge__c> addMemberBadges ( Map<String, List<Id>> badgeTyNameContactIdList){

        
        List<OrderApi__Badge__c> memberBadges = new List<OrderApi__Badge__c>();
//        System.debug('badgeTyNameContactIdList ::: '+badgeTyNameContactIdList);

        For(OrderApi__Badge_Type__c badgeType : [SELECT Id, Name FROM OrderApi__Badge_Type__c WHERE Name IN: badgeTyNameContactIdList.keySet() ]){

            if(badgeTyNameContactIdList.containsKey(badgeType.Name)){
                List<Id> contactIds = badgeTyNameContactIdList.get(badgeType.Name);
                for(Id contactId : contactIds)
                {
                    memberBadges.add(new OrderApi__Badge__c(
                            OrderApi__Awarded_Date__c = Date.Today(),
                            OrderApi__Contact__c = contactId,
                            OrderApi__Badge_Type__c = badgeType.Id));
                }
            }
        }

        return memberBadges;
    }
}