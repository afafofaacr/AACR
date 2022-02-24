public with sharing class Fon_TestUtil {
    
    static Boolean isInstalled = false;
    private static Contact con1 = new Contact();
    private static Account acct = new Account();
    private static User portalAccountOwner;
    private static list<OrderApi__Badge__c> allBadges = new list<OrderApi__Badge__c>();
    private static list<OrderApi__Item__c> allItems = new list<OrderApi__Item__c>();
    private static List<OrderApi__Sales_Order__c> sos = new List<OrderApi__Sales_Order__c>();
    private static list<OrderApi__Sales_Order_Line__c> solis = new list<OrderApi__Sales_Order_Line__c>();
    private static  EventApi__Sponsor__c score = new EventApi__Sponsor__c();
    public static void install() {
        Fon_PackageScripts.testInstall();
         // Important if you want to see the exception coming from the product
        //system.assertEquals([SELECT Id, Framework__Type__c, Framework__Exception_Data__c, Framework__Data__c FROM Framework__System_Log__c],new List<Framework__System_Log__c>());
  
    }

    public static User getPortalUser(){
        return portalAccountOwner;
    }/*
    public static Account getAccount(){
        return acct;
    }*/
    public static Contact getContact(){
        return con1;
    }

    public static  list<OrderApi__Sales_Order__c> allSalesOrder(){
        return sos;
    }
    public static  list<OrderApi__Sales_Order_Line__c> salesOrderLineOne(){
        return solis;
    }
     public static void contaccCreation(){
       install();          
        acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        con1 = new Contact();
        con1.LastName = 'LASTNAME';
        con1.AccountId = acct.Id;
        con1.Email ='testemail@testemail.com';
        con1.OtherStreet = 'teststreet1 \n teststreet2 \n teststreet3';
        con1.MailingStreet = 'testmailingstreet1 \n testmailingstreet2 \n testmailingstreet3';
        insert con1; 
     }
    public static void BasicObjectCreation(){
        contaccCreation();
        OrderApi__Business_Group__c BG1 =  new OrderApi__Business_Group__c();
        BG1.Name = 'BG1Name';
        insert BG1;
        list<OrderApi__GL_Account__c> gls =  new list<OrderApi__GL_Account__c>();
        OrderApi__GL_Account__c gl1 = new OrderApi__GL_Account__c(Natural__c='0000', Funding_Source__c='000', Cost_Center__c='0000', Project__c='000',name='1AC-4160-00 - ACC-Annual Update',OrderApi__Business_Group__c = bg1.id);
        gls.add(gl1);
        insert gls;
        Id p = [select id from profile where name LIKE '%Fonteva Customer Community User%' limit 1].id;
        map<id,profile>  adprofile= new map<id,Profile>([select id from profile where name LIKE '%System Administrator%' limit 1]);
        list<User> adminuser =[select id from user where IsActive =true AND UserRoleId!=null AND profileid IN :adprofile.Keyset()];
        portalAccountOwner = new User(      
            ProfileId = p,
            Username = 'billst45@test.com',
            Alias = 'tu204',
            Email='test@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='tu',
            Lastname='twoOfour',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            ContactId =con1.id
        );
        insert portalAccountOwner;
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Contact__c = con1.ID;
        so.OrderApi__Schedule_Type__c ='Simple Invoice';
        sos.add(so);
        OrderApi__Sales_Order__c so1 = new OrderApi__Sales_Order__c();
        so1.OrderApi__Contact__c = con1.ID;
        sos.add(so1);
        insert sos;
        //system.debug('6sos==='+sos);
        OrderApi__Item_Class__c itmc = new OrderApi__Item_Class__c();
        itmc.Name = 'Test Class';
        //itmc.OrderApi__Is_Subscription__c=true;
        itmc.OrderApi__Is_Active__c = true;
        itmc.OrderApi__Business_Group__c = BG1.ID;
        insert itmc;
        //system.debug('itmc==='+itmc);
        OrderApi__Item__c itm = new OrderApi__Item__c();
        itm.OrderApi__Price__c = 315;
        itm.OrderApi__Cost__c = 315;
        itm.OrderApi__Item_Class__c = itmc.Id;
        itm.OrderApi__Business_Group__c = BG1.Id;
        itm.Name = 'Active Membership';
        itm.OrderApi__Is_Active__c = true;
        itm.OrderApi__Income_Account__c=gl1.id;
        itm.OrderApi__Adjustment_Account__c =gl1.id;
        itm.OrderApi__Discount_Account__c = gl1.id;
        //itm.OrderApi__Deferred_Revenue_Account__c =gl1.id;
         itm.OrderApi__Refund_Account__c =gl1.id;
         itm.Is_Active_Membership_Type__c = true;
        allItems.add(itm);

        OrderApi__Item__c itm1 = new OrderApi__Item__c();
        itm1.OrderApi__Price__c = 0;
        itm1.OrderApi__Cost__c =0;
        itm1.OrderApi__Item_Class__c = itmc.Id;
        itm1.OrderApi__Business_Group__c = BG1.Id;
        itm1.Name = 'testUpgrade';
        itm1.OrderApi__Is_Active__c = true;
        itm1.OrderApi__Income_Account__c=gl1.id;
        itm1.OrderApi__Adjustment_Account__c =gl1.id;
        itm1.OrderApi__Discount_Account__c = gl1.id;
        itm1.Is_Complimentary__c =true;
        itm1.OrderApi__Refund_Account__c =gl1.id;
         itm1.Is_Active_Membership_Type__c = false;
         allItems.add(itm1);

        insert allItems;

        solis = new list<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c soli = new OrderApi__Sales_Order_Line__c();
        soli.OrderApi__Contact__c = con1.ID;
        soli.OrderApi__Item__c = itm.id;
        soli.OrderApi__Sales_Order__c = so.id;
        //soli.OrderApi__Subscription_Plan__c = plan.id;
        solis.add(soli);

        OrderApi__Sales_Order_Line__c soli1 = new OrderApi__Sales_Order_Line__c();
        soli1.OrderApi__Contact__c = con1.ID;
        soli1.OrderApi__Item__c = itm1.id;
        soli1.OrderApi__Sales_Order__c = so.id;
        //soli.OrderApi__Subscription_Plan__c = plan.id;

         solis.add(soli1);
        insert solis;
        
    }
     public static void BasicObjectCreationSubs(){
        contaccCreation();
        OrderApi__Business_Group__c BG1 =  new OrderApi__Business_Group__c();
        BG1.Name = 'BG1Name';
        insert BG1;
        list<OrderApi__GL_Account__c> gls =  new list<OrderApi__GL_Account__c>();
        OrderApi__GL_Account__c gl1 = new OrderApi__GL_Account__c(Natural__c='0000', Funding_Source__c='000', Cost_Center__c='0000', Project__c='000',name='1AC-4160-00 - ACC-Annual Update',OrderApi__Business_Group__c = bg1.id);
        gls.add(gl1);
        insert gls;
       
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Contact__c = con1.ID;
        so.OrderApi__Schedule_Type__c ='Simple Receipt';
        sos.add(so);
        insert sos;
        //system.debug('6sos==='+sos);
        OrderApi__Item_Class__c itmc = new OrderApi__Item_Class__c();
        itmc.Name = 'Test Class';
        itmc.OrderApi__Is_Subscription__c=true;
        itmc.OrderApi__Is_Active__c = true;
        itmc.OrderApi__Business_Group__c = BG1.ID;
        insert itmc;
        
//system.debug('6allItems==='+allItems);
        
        OrderApi__Subscription_Plan__c plan = new OrderApi__Subscription_Plan__c();
        plan.OrderApi__Type__c = 'Termed';
        plan.OrderApi__Initial_Term_Months__c = 12;
        plan.OrderApi__Is_Active__c = true;
        plan.OrderApi__Business_Group__c = BG1.Id;
        insert plan;  
        

        
        OrderApi__Item__c itm = new OrderApi__Item__c();
        itm.OrderApi__Price__c = 315;
        itm.OrderApi__Cost__c = 315;
        itm.OrderApi__Item_Class__c = itmc.Id;
        itm.OrderApi__Business_Group__c = BG1.Id;
        itm.Name = 'Active Membership';
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Income_Account__c=gl1.id;
        itm.OrderApi__Adjustment_Account__c =gl1.id;
        itm.OrderApi__Discount_Account__c = gl1.id;
        //itm.OrderApi__Deferred_Revenue_Account__c =gl1.id;
         itm.OrderApi__Refund_Account__c =gl1.id;
         itm.Is_Active_Membership_Type__c = true;
        allItems.add(itm);

        insert allItems;
        //system.debug('allItems==='+allItems);
        OrderApi__Item_Subscription_Plan__c spl = new OrderApi__Item_Subscription_Plan__c();
        spl.OrderApi__Item__c = itm.Id;
        spl.OrderApi__Subscription_Plan__c = plan.Id;
        spl.OrderApi__Is_Default__c = true;
        insert spl;
        itm.OrderApi__Is_Active__c = true;
        update itm;
        solis = new list<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c soli = new OrderApi__Sales_Order_Line__c();
        soli.OrderApi__Contact__c = con1.ID;
        soli.OrderApi__Item__c = itm.id;
        soli.OrderApi__Sales_Order__c = so.id;
        soli.OrderApi__Subscription_Plan__c = plan.id;
        solis.add(soli);

        insert solis;
        
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        sub.OrderApi__Item__c = itm.Id;
        sub.OrderApi__Subscription_Plan__c=plan.id;
        sub.OrderApi__Is_Expired__c=true;
        sub.OrderApi__Contact__c =con1.id;
        sub.OrderApi__Current_Term_End_Date__c = system.today()-10;
        sub.OrderApi__Business_Group__c = BG1.id;
        insert sub;                
       
        //system.debug('6==='+sub);
        
    }
   
}