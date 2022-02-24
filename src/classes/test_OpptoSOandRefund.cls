@isTest (seealldata=true)
public class test_OpptoSOandRefund {
	
    public static testMethod void testOpportunityCash(){
        try{
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Donation Test';
        Opp.AccountId = acc.Id;
        Opp.CloseDate = date.today();
        Opp.StageName = 'Posted';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        Opp.c4g_Payment_Method__c = 'Cash';
        insert Opp;
        } catch(Exception ex){
            system.debug(ex.getStackTraceString() + ex.getMessage());
        }
    }
    
    public static testMethod void testOpportunity(){
        try{
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Donation Test1';
        Opp.AccountId = acc.Id;
        Opp.CloseDate = date.today();
        Opp.StageName = 'Posted';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        insert Opp;
        } catch(Exception ex){
            system.debug(ex.getStackTraceString() + ex.getMessage());
        }
    }
    
    public static testMethod void testOpportunityWire(){
        try{
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Donation Test1';
        Opp.AccountId = acc.Id;
        Opp.CloseDate = date.today();
        Opp.StageName = 'Posted';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        Opp.c4g_Payment_Method__c = 'Wire';
        insert Opp;
        } catch(Exception ex){
            system.debug(ex.getStackTraceString() + ex.getMessage());
        }
    }
    
    public static testMethod void testOpportunityCC(){
        try{
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Donation Test1';
        Opp.AccountId = acc.Id;
        Opp.CloseDate = date.today();
        Opp.StageName = 'Posted';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        Opp.c4g_Payment_Method__c = 'CC';
        insert Opp;
        } catch(Exception ex){
            system.debug(ex.getStackTraceString() + ex.getMessage());
        }
    }
    
    public static testMethod void testOpportunityCheck(){
        try{
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Donation Test1';
        Opp.AccountId = acc.Id;
        Opp.CloseDate = date.today();
        Opp.StageName = 'Posted';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        Opp.c4g_Payment_Method__c = 'Check';
            Opp.c4g_Check_Number__c = '123';
        insert Opp;
        } catch(Exception ex){
            system.debug(ex.getStackTraceString() + ex.getMessage());
        }
    }
    
    public static testMethod void testOpportunity1(){
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.AccountId = acc.Id;
        Opp.Name = 'Donation Test';
        Opp.CloseDate = date.today();
        Opp.StageName = 'Closed Won';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        insert Opp;
        Opp.ddrive__Donation_Payment_Status_Text__c = 'Refunded';
        Opp.ddrive__Refund_Amount__c = 100;
        Opp.ddrive__Donation_Refund_Date__c = date.today();
        Update Opp;
        
    }
    
    public static testMethod void testOpportunityRefund(){
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.AccountId = acc.Id;
        Opp.Name = 'Donation Test';
        Opp.CloseDate = date.today();
        Opp.StageName = 'Closed Won';
        Opp.RecordTypeId = OppRecId;
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        Opp.ddrive__Donation_Payment_Status_Text__c = 'Refunded';
        Opp.ddrive__Refund_Amount__c = 100;
        Opp.ddrive__Donation_Refund_Date__c = date.today();
        Insert Opp;
        
    }
    
    public static testMethod void testOpportunity2(){
        Id AccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = AccRecId;
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Lastname';
        con.AccountId = acc.Id;
        con.Email = 'test+1@mail.com';
        insert con;
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];
        Opportunity Opp = new Opportunity();
        Opp.AccountId = acc.Id;
        Opp.Name = 'Donation Test';
        Opp.npsp__Primary_Contact__c = con.Id;
        Opp.CloseDate = date.today();
        Opp.StageName = 'Pledged';
        Opp.RecordTypeId = OppRecId;
        Opp.c4g_Pledge_Type__c = 'Organization';
        Opp.Amount = 100;
        Opp.c4g_Appeal_Code__c = appCode.Id;
            Opp.GL_Account__c = GLCode.Id;
        Opp.c4g_Payment_Method__c = 'Cash';
        insert Opp;
    }
    
    public static testmethod void customExceptionTest(){
        CustomException ex= new CustomException('Refund Date and Refund Amount are required!');
    }
}