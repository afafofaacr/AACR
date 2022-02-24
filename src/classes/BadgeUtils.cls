/**
 * Created by lauren.lezberg on 5/15/2019.
 */

public with sharing class BadgeUtils {


    public static Boolean revokeDirectoryAccess(Id contactId){
        OrderApi__Badge__c dirBadge = BadgeUtils.getDirectoryBadge(contactId);
        if(dirBadge!=null) {
            return BadgeUtils.expireDirectoryBadge(contactId,dirBadge);
        }
        return false;
    }


    public static Boolean enableDirectoryAccess(Id contactId){
        OrderApi__Badge__c dirBadge = BadgeUtils.getDirectoryBadge(contactId);
        if(dirBadge!=null){
            return BadgeUtils.activateDirectoryBadge(contactId, dirBadge);
        } else {
            return BadgeUtils.createDirectoryBadge(contactId);
        }
    }

    public static void enableDirectoryAccess(Set<Id> contactIds){
        //get all directory access badges for specified contacts
        List<OrderApi__Badge__c> badges = BadgeUtils.getDirectoryBadges(contactIds);
        //activate all badges
        BadgeUtils.activateDirectoryBadges(badges);

        //if not all contacts have badges
        if(badges.size() != contactIds.size()){

            List<Id> contactsWithoutBadge = new List<Id>();
            Set<id> contactBadges = new Set<Id>();
            for(OrderApi__Badge__c badge : badges){
                contactBadges.add(badge.OrderApi__Contact__c);
            }

            for(Id conId : contactIds){
                if(!contactBadges.contains(conId)){
                    contactsWithoutBadge.add(conId);
                }
            }

            //create badges
            BadgeUtils.createDirectoryBadges(contactsWithoutBadge);
        }
        
    }

    public static List<OrderApi__Badge__c> getDirectoryBadges(Set<Id> contactIds){
        List<OrderApi__Badge__c> directoryBadges = [SELECT Id, OrderApi__Contact__c, OrderApi__Is_Active__c, Badge_Image__c, OrderApi__Badge_Type__r.OrderApi__Image_Location__c FROM OrderApi__Badge__c WHERE OrderApi__Badge_Type__r.Name='Directory Access' AND OrderApi__Contact__c IN: contactIds];

        return directoryBadges;
    }

    public static OrderApi__Badge__c getDirectoryBadge(Id contactId){
        List<OrderApi__Badge__c> directoryBadges = [SELECT Id, OrderApi__Is_Active__c, Badge_Image__c, OrderApi__Badge_Type__r.OrderApi__Image_Location__c FROM OrderApi__Badge__c WHERE OrderApi__Badge_Type__r.Name='Directory Access' AND OrderApi__Contact__c=: contactId];
        if(directoryBadges.size()==1){
            return directoryBadges[0];
        }
        return null;
    }

    public static void createDirectoryBadges(List<Id> contactIds){
        OrderApi__Badge_Type__c bt = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name='Directory Access'];
        List<OrderApi__Badge__c> toInsert = new List<OrderApi__Badge__c>();
        for(Id conId : contactIds){
            OrderApi__Badge__c dirBadge = new OrderApi__Badge__c(
                    OrderApi__Contact__c = conId,
                    OrderApi__Is_Active__c = true,
                    OrderApi__Awarded_Date__c = Date.today(),
                    OrderApi__Badge_Type__c = bt.Id
            );
            toInsert.add(dirBadge);
        }

        insert toInsert;
    }

    public static Boolean createDirectoryBadge(Id contactId){
        OrderApi__Badge_Type__c bt = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name='Directory Access'];
        OrderApi__Badge__c dirBadge = new OrderApi__Badge__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Is_Active__c = true,
                OrderApi__Awarded_Date__c = Date.today(),
                OrderApi__Badge_Type__c = bt.Id
        );
        try{
            insert dirBadge;
            return true;
        } catch(Exception e){
            System.debug('error inserting directory badge: ' + e.getMessage());
            return false;
        }
    }

    public static void expireDirectoryBadges(List<OrderApi__Badge__c> badges){
        for(OrderApi__Badge__c badge : badges){
            if(badge.OrderApi__Is_Active__c) {
                badge.OrderApi__Awarded_Date__c = null;
                badge.OrderApi__Is_Active__c = false;
                badge.OrderApi__Expired_Date__c = null;
            }
        }

        update badges;
    }

    public static void activateDirectoryBadges(List<OrderApi__Badge__c> badges){
        for(OrderApi__Badge__c badge : badges){
            if(!badge.OrderApi__Is_Active__c) {
                badge.OrderApi__Expired_Date__c = null;
                badge.OrderApi__Awarded_Date__c = Date.today();
                badge.OrderApi__Is_Active__c = true;
            }
        }

        update badges;
    }

    public static Boolean expireDirectoryBadge(Id contactId, OrderApi__Badge__c badge){
        if(badge.OrderApi__Is_Active__c){
            badge.OrderApi__Awarded_Date__c = null;
            badge.OrderApi__Is_Active__c = false;
            badge.OrderApi__Expired_Date__c = null;

            try{
                update badge;
                return true;
            } catch(Exception e){
                System.debug('error expiring badge: ' + e.getMessage());
                return false;
            }
        }
        return false;
    }


    public static Boolean activateDirectoryBadge(Id contactId, OrderApi__Badge__c badge){
        if(!badge.OrderApi__Is_Active__c){
            badge.OrderApi__Expired_Date__c = null;
            badge.OrderApi__Awarded_Date__c = Date.today();
            badge.OrderApi__Is_Active__c = true;
            try{
                update badge;
                return true;
            } catch(Exception e){
                System.debug('error activating badge: ' + e.getMessage());
                return false;
            }
        }
        return false;
    }

//        AACR FELLOWS BADGES
    //*****************************************
    public static Boolean revokeFellowAccess(Id contactId){
        OrderApi__Badge__c dirBadge = BadgeUtils.getFellowBadge(contactId);
        System.debug('FellowBadge = ' + dirBadge);
        if(dirBadge!=null) {
            System.debug(dirBadge);
            return BadgeUtils.expireFellowBadge(dirBadge);
        }
        System.debug('false');
        return false;

    }
    
    public static Boolean enableFellowAccess(Id contactId){
        OrderApi__Badge__c dirBadge = BadgeUtils.getFellowBadge(contactId);
        System.debug('FellowBadge = ' + dirBadge);
        if(dirBadge!=null){
            return BadgeUtils.activateFellowBadge(dirBadge);
        } else {
            return BadgeUtils.createFellowBadge(contactId);
        }
    }

    public static OrderApi__Badge__c getFellowBadge(Id contactId){
        List<OrderApi__Badge__c> fellowBadges = [SELECT Id, OrderApi__Is_Active__c, Badge_Image__c, OrderApi__Badge_Type__r.OrderApi__Image_Location__c
                                                        ,OrderApi__Awarded_Date__c
                                                    FROM OrderApi__Badge__c
                                                    WHERE OrderApi__Badge_Type__r.Name='AACR Fellow'
                                                    AND OrderApi__Contact__c=: contactId];
        if(fellowBadges.size()==1){
            return fellowBadges[0];
        }
        return null;
    }

    public static Boolean createFellowBadge(Id contactId){
        OrderApi__Badge_Type__c bt = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name='AACR Fellow'];
        OrderApi__Badge__c fellBadge = new OrderApi__Badge__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Is_Active__c = true,
                OrderApi__Awarded_Date__c = Date.today(),
                OrderApi__Badge_Type__c = bt.Id
        );
        try{
            insert fellBadge;
            return true;
        } catch(Exception e){
            System.debug('error inserting fellow badge: ' + e.getMessage());
            return false;
        }
    }


    public static Boolean expireFellowBadge(OrderApi__Badge__c badge){
        if(badge.OrderApi__Is_Active__c){
            badge.OrderApi__Is_Active__c = false;
            badge.OrderApi__Expired_Date__c = System.today().addDays(-1);

            try{
                update badge;
                return true;
            } catch(Exception e){
                System.debug('error expiring badge: ' + e.getMessage());
                return false;
            }
        }
        return false;
    }


    public static Boolean activateFellowBadge(OrderApi__Badge__c badge){
        if(!badge.OrderApi__Is_Active__c){
            badge.OrderApi__Expired_Date__c = null;
            badge.OrderApi__Awarded_Date__c =  badge.OrderApi__Awarded_Date__c == null ? Date.today() : badge.OrderApi__Awarded_Date__c;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Expired_Date__c = null;

            System.debug('awarded date == ' + badge.OrderApi__Awarded_Date__c);

            try{
                update badge;
                return true;
            } catch(Exception e){
                System.debug('error activating badge: ' + e.getMessage());
                return false;
            }
        }
        return false;
    }

}