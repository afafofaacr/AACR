@isTest 
public class AccountBadgeControllerTest {
    static AccountBadgeController ext;
    static Account a;
    static Account aa;
    private static void init(){
    
	PageReference pageRef = Page.Badges;
	Test.setCurrentPage(pageRef); 
        a = new Account();
        a.Name = 'Test';
        a.AnnualRevenue = 100;
        insert a;
        
        aa = new Account();
        aa.Name = 'Test2';
        insert aa;
        
        Badge_Setting__c b = new Badge_Setting__c();
        b.Object__c = 'Account';
        b.Criteria__c = 'AnnualRevenue > 5';
        b.Active__c = TRUE;
        b.Sort_Order__c = 1;
        insert b;

	pageRef.getParameters().put('id', a.id);
        ApexPages.StandardController act = new ApexPages.StandardController(a);
        ext = new AccountBadgeController(act);
    }
    static testMethod void testBadges(){
        init();
        Test.startTest();
        ext.acct = a;
        ext.getBadges();
		ext.acct = aa;
        ext.getBadges();
        Test.stopTest();
    }
}