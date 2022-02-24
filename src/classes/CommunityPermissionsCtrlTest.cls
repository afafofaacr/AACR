/**
 * Created by afaf.awad on 3/31/2021.
 */
@IsTest
public with sharing class CommunityPermissionsCtrlTest {

    @testSetup static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact contact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert contact;
        User u = TestDataFactory.buildUser(contact.Id);
        insert u;
    }

    @IsTest
    public static void test_checkPermissions(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        System.runAs(u) {
            CommunityPermissionsCtrl cpCtrl = new CommunityPermissionsCtrl();
            System.assertEquals(false, cpCtrl.ecAccess);
        }

        Community_Permission__c cp = new Community_Permission__c(Contact__c = con.Id);
        insert cp;

        System.runAs(u) {
            CommunityPermissionsCtrl cpCtrl = new CommunityPermissionsCtrl();
            System.assertEquals(true, cpCtrl.ecAccess);
        }


    }

}