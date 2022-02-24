@isTest 
public class ContactBadgeControllerTest {
    static ContactBadgeController ext;
    static Contact a;
    static Contact aa;
    private static void init(){
    
	PageReference pageRef = Page.ContactBadges;
	Test.setCurrentPage(pageRef); 
        a = new Contact();
        a.LastName = 'Test';
        a.HasOptedOutOfEmail = TRUE;
        insert a;
        
        aa = new Contact();
        aa.LastName = 'Test2';
        insert aa;
        
        Badge_Setting__c b = new Badge_Setting__c();
        b.Object__c = 'Contact';
        b.Criteria__c = 'HasOptedOutOfEmail = TRUE';
        b.Active__c = TRUE;
        b.Sort_Order__c = 1;
        insert b;

	pageRef.getParameters().put('id', a.id);
        ApexPages.StandardController act = new ApexPages.StandardController(a);
        ext = new ContactBadgeController(act);
    }
    static testMethod void testBadges(){
        init();
        Test.startTest();
        ext.con = a;
        ext.getBadges();
		ext.con = aa;
        ext.getBadges();
        Test.stopTest();
    }
}