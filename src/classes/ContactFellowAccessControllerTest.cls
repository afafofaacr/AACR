/**
 * Created by afaf.awad on 1/21/2021.
 */

@isTest
private with sharing class ContactFellowAccessControllerTest {
        @testSetup
        public static void setup(){
            Account acc = TestDataFactory.buildAccount('Test Account');
            insert acc;

            Contact con = TestDataFactory.buildContact(acc.Id);
            con.Member_Type__c = 'Active Member';
            insert con;

            User u = TestDataFactory.buildUser(con.Id);
            insert u;

            OrderApi__Badge_Type__c badgeType = TestDataFactory.buildBadgeType('AACR Fellow');
            insert badgeType;

            OrderApi__Badge__c badge = TestDataFactory.buildBadge(badgeType.Id, con.Id);
            insert badge;

        }

        @isTest
        public static void testGetFellowAccessBadgeAccess(){
            Contact con = [SELECT Id FROM Contact LIMIT 1];

            Test.startTest();
            ContactFellowAccessController.FellowBadgeInfo badgeInfo = ContactFellowAccessController.getFellowAccessBadge(con.Id);
            System.assertNotEquals(null, badgeInfo);
            System.assertNotEquals(null, badgeInfo.dirBadge);
            System.assertEquals(true, badgeInfo.canEdit);
            Test.stopTest();
        }

        @isTest
        public static void testGetFellowAccessBadgeNoAccess(){
            Contact con = [SELECT Id, Member_Type__c FROM Contact LIMIT 1];
            con.Member_Type__c = 'Student Member';
            update con;

            Test.startTest();
            ContactFellowAccessController.FellowBadgeInfo badgeInfo = ContactFellowAccessController.getFellowAccessBadge(con.Id);
            System.assertNotEquals(null, badgeInfo);
            System.assertNotEquals(null, badgeInfo.dirBadge);
            System.assertEquals(false, badgeInfo.canEdit);
            Test.stopTest();
        }

        @isTest
        public static void testEnableAndDisableFellowBadge(){
            Contact con = [SELECT Id FROM Contact LIMIT 1];

            Test.startTest();
            Boolean success = ContactFellowAccessController.revokeFellowForContact(con.Id);
            System.assertEquals(true, success);
            OrderApi__Badge__c dirBadge = [SELECT OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Badge_Type__r.Name='AACR Fellow'];
            System.assertEquals(false, dirBadge.OrderApi__Is_Active__c);

            success = ContactFellowAccessController.enableFellowForContact(con.Id);
            System.assertEquals(true, success);
            dirBadge = [SELECT OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Badge_Type__r.Name='AACR Fellow'];
            System.assertEquals(true, dirBadge.OrderApi__Is_Active__c);

            Test.stopTest();
        }
    }