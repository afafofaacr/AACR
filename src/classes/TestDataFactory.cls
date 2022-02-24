/**
 * TestDataFactory constructs objects/records for testing purposes and provides easily accessible methods to use for unit tests
 */
@isTest
public class TestDataFactory { 
 	public Contact testContact;
    public static Account testAccount;
    public static OrderApi__Business_Group__c testBusinessGroup;
    public static OrderApi__Payment_Terms__c paymentTerms;
    
    public TestDataFactory(){
        testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        testContact=new Contact(
            FirstName='test',
            LastName = 'contact',
            Email = 'test@example.com',
            Phone = '1234567890', 
        	AccountId = testAccount.Id); 
        insert testContact;
        
        testBusinessGroup = createMasterBusinessGroup();
        paymentTerms = createPaymentTerms();
    }
    
    /************ PUBLIC METHODS ************/
    /*
     * Creates list with @param count number of closed and unposted sales orders
     */
    public List<OrderApi__Sales_Order__c> createClosedUnpostedSalesOrders(Integer count){
        List<OrderApi__Sales_Order__c> lstSO = new List<OrderApi__Sales_Order__c>();
        
        Integer i;
        for(i = 0; i< count; i++){
            OrderApi__Sales_Order__c so = createClosedUnpostedSOStructure();
            lstSO.add(so);
        }
        insert lstSO;
        return lstSO;
    }


    public List<Account> createAccounts(Integer count){
        List<Account> lstAccts = new List<Account>();

        Integer i;
        for(i=0; i<count; i++){
            Account a = new Account();
            a.Name = 'Test Account ' + i;
            lstAccts.add(a);

        }

        insert lstAccts;
        return lstAccts;
    }

    public List<Account> createAccountsWithContacts(Integer count){
        List<Account> lstAccts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();

        Integer i;
        for(i=0; i<count; i++){
            Account a = new Account();
            a.Name = 'Test Account ' + i;
            lstAccts.add(a);
            for(Integer j =0; j<5 ; j++){
                Contact c = new Contact(
                        FirstName='test',
                        LastName = 'contact ' + j,
                        Email = 'testContact' + j + '@example.com',
                        Phone = '123456789' + j,
                        AccountId = a.Id);
                lstContacts.add(c);
            }
        }

        insert lstAccts;
        insert lstContacts;
        return lstAccts;
    }

    public OrderApi__Item_Class__c createIndividualMembershipItemClass(){
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.OrderApi__Business_Group__c = testBusinessGroup.Id;
        itemClass.Name = 'Individual Memberships';
        itemClass.Name = 'AACR Individual Membership Affiliation';
        itemClass.OrderApi__Is_Active__c = true;
        itemClass.Is_Membership__c = false;
        itemClass.OrderApi__Is_Subscription__c = true;
        insert itemClass;

        return itemClass;
    }

    public static OrderApi__Sales_Order__c buildOpenSalesOrder(Id accountId, Id contactId){
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Is_Posted__c = false;
        so.OrderApi__Status__c = 'Open';
        so.OrderApi__Contact__c = contactId;
        so.OrderApi__Account__c = accountId;
        so.OrderApi__Entity__c = 'Contact';
        so.OrderApi__Date__c = Date.valueOf(System.now());
        so.OrderApi__Schedule_Type__c = 'Simple Receipt';
        so.OrderApi__Posting_Entity__c = 'Receipt';
        so.OrderApi__Closed_Date__c = Date.valueOf(System.now());
        so.OrderApi__Posting_Status__c = 'Pending';
        so.OrderApi__Billing_Contact__c = contactId;
        so.OrderApi__Shipping_Contact__c = contactId;
        so.OrderApi__Billing_Country__c = 'Canada';
        return so;
    }

    public static OrderApi__Sales_Order_Line__c buildSOLine(Id soId, Id itemId, Id itemClassId){
        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=soId, OrderApi__Item_Class__c=itemClassId, OrderApi__Item__c=itemId);
        return soLine;
    }

    /**
    *@purpose   : build business group record
    *@return    : Business Group record
    */
    public static OrderApi__Business_Group__c buildMasterBusinessGroup(){
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.Name = 'Test Business Group';
        bg.OrderApi__Business_Entity_Type__c = 'Non-Profit 501(c)(3)';
        bg.OrderApi__Is_Master__c = true;
        bg.OrderApi__Type__c = 'Business Entity';
        bg.OrderApi__Merchant_Location__c = '615 Chestnut Street, 17th Floor Philadelphia, PA 19106';
        bg.OrderApi__Merchant_Name__c = 'American Association for Cancer Research';
        bg.OrderApi__Shipping_Rate_Basis__c = 'Item Value';
        bg.OrderApi__Enable_Shipping_By_Order_Total__c = true;
        bg.OrderApi__Calculate_Sales_Tax__c = true;
        bg.OrderApi__Required_Tax_Fields_CSV__c = 'MailingAddress';
        bg.OrderApi__Display_Name__c = 'Test Business Group';
        bg.OrderApi__Phone__c = '215-440-9300';
        bg.OrderApi__Homepage_URL__c = 'http://www.aacr.org';
        bg.OrderApi__Mailing_Address__c = '615 Chestnut Street 17th Floor, Philadelphia, PA 19106';
        return bg;

    }

    /**
     * @purpose build gl account record
     *
     * @return gl account record
     */
    public static OrderApi__GL_Account__c buildGLAccount(){
        OrderApi__Business_Group__c bg = buildMasterBusinessGroup();
        insert bg;

        OrderApi__GL_Account__c gl = new OrderApi__GL_Account__c();
        gl.Name = 'Test GL Account';
        gl.OrderApi__Business_Group__c = bg.Id;
        gl.Natural__c = '2501';
        gl.Cost_Center__c = '0010';
        gl.Funding_Source__c = '000';
        gl.Project__c = '000';

        return gl;

    }

    public static Opportunity buildOpportunity(Id accountId, Id contactId, Id appealCodeId, Id glAccountId){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = accountId;
        opp.npsp__Primary_Contact__c = contactId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Amount = 100.00;
        opp.c4g_Appeal_Code__c = appealCodeId;
        opp.GL_Account__c = glAccountId;

        return opp;
    }

    /**
*@purpose : To create Badge Type records.
*@param   : -
*@return  : List<OrderApi__Badge_Type__c>
*/
    Public static List<OrderApi__Badge_Type__c> createBadgeType(){

        List<OrderApi__Badge_Type__c> badgeTypeList = new List<OrderApi__Badge_Type__c>();

        for(DW_BadgeTypeName__mdt BadgeNameMeta : [SELECT MasterLabel, BadgeTypeName__c FROM DW_BadgeTypeName__mdt]){

            badgeTypeList.add(new OrderApi__Badge_Type__c(Name = BadgeNameMeta.BadgeTypeName__c,OrderApi__Is_Active__c = true));
        }
        // Unapproved Testing
        badgeTypeList.add(new OrderApi__Badge_Type__c(Name = 'Active Membership - Unapproved',OrderApi__Is_Active__c = true));

        System.debug('createBadgeType : badgeTypeList ::: '+badgeTypeList);
        return badgeTypeList;
    }


    /**
    *@purpose   : build Account record
    *@param     : accountName
    *@return    : Account record
    */
    public static Account buildAccount(String accountName){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();

        return new Account(RecordTypeId = recordTypeId,
                Name = accountName);
    }

    /**
    *@purpose   : build Lead record
    *@param     :
    *@return    : Lead record
    */
    public static Lead buildLead(){
        return new Lead(FirstName = 'Carol',
                LastName = 'Miller',
                Email = 'carol.miller@aacrtest.org',
                Company = 'MOM Corp.');
    }


    /**
     *@purpose   : Build Contact record for non-member
     *@param     : accountId
     *@return    : Contact record
     */
    public static Contact buildContact(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();

        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                AccountId = accountId,
                RecordTypeId = recordTypeId,
                Phone ='9878986789',
                Fax = 'fax',
                Email = 'testEmail@yopmail.com');
    }

    public static Id getContactRecordTypeId(String recordTypeName){
        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    /**
     *@purpose   : Build Contact record for member current
     *@param     : accountId
     *@return    : Contact record
     */
    public static Contact buildContactMemberCurrent(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Member_Record_Type).getRecordTypeId();

        // Creating Contact record
        return new Contact(LastName = 'Current Test contact ',
                AccountId = accountId,
                RecordTypeId = recordTypeId,
                Email = 'testContact@yopmail.com',
                Membership_Status__c = 'Current',
                Member_Type__c = 'Active Member',
                Application_Status__c = null,
                Phone ='9878986789',
                Fax = 'fax',
                Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31));
    }

    /**
     * @purpose Build badge type record
     *
     * @param accountId
     *
     * @return Badge_Type__c
     */
    public static OrderApi__Badge_Type__c buildBadgeType(String badgeTypeName){
        OrderApi__Badge_Type__c badgeType = new OrderApi__Badge_Type__c(
                OrderApi__Is_Active__c = true,
                Name=badgeTypeName,
                OrderApi__Short_Description__c = 'Test Description for badge'
        );
        return badgeType;
    }

    /**
     * @purpose Build badge for contact
     *
     * @param badgeTypeId
     * @param contactId
     *
     * @return Badge__c
     */
    public static OrderApi__Badge__c buildBadge(Id badgeTypeId, Id contactId){
        OrderApi__Badge__c badge = new OrderApi__Badge__c(
                OrderApi__Is_Active__c= true,
                OrderApi__Badge_Type__c = badgeTypeId,
                OrderApi__Contact__c = contactId,
                OrderApi__Awarded_Date__c = Date.today()); 
        return badge;
    }

    /**
     *@purpose   : Build Contact record for member current
     *@param     : accountId
     *@return    : Contact record
     */
    public static Contact buildContactMemberPrior(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();

        // Creating Contact record
        return new Contact(LastName = 'Prior Test contact',
                AccountId = accountId,
                RecordTypeId = recordTypeId,
                Member_Type__c = 'Active Member',
                Membership_Status__c = '1-YR Suspended',
                Phone ='9878986789',
                Fax = 'fax',
                Paid_thru_date__c = Date.newInstance(System.now().year()-1, 12, 31));
    }

    /**
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : User Record
     */
    public static User buildUser(Id contactId){
        // Fetching profile record
        Profile profileRecord = [SELECT Id
        FROM Profile
        WHERE Name =: 'Fonteva Customer Community Login User'
        LIMIT 1];

        // Create users record
        User userRecord = new User(alias = 'test',
                ContactId = contactId,
                // AccountId = contactRecord1.AccountId,
                ProfileId = profileRecord.Id,
                email = 'test@testorg.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Test User2',
                CommunityNickname = contactId,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + 'test@testorg2.com');
        return userRecord;
    }

    /**
    *@purpose   : Build User records from contacts
    *@param     : List<Contact>
    *@return    : List of User Records
    */
    public static List<User> buildPortalUsersFromContacts(List<Contact> cons){
        // Fetching profile record
        Profile profileRecord = [SELECT Id
        FROM Profile
        WHERE Name =: 'Fonteva Customer Community Login User'
        LIMIT 1];

        List<User> newUsers = new List<User>();

        for(Contact con: cons) {
            // Create users record
            User userRecord = new User(alias = 'test',
                    ContactId = con.Id,
                    // AccountId = contactRecord1.AccountId,
                    ProfileId = profileRecord.Id,
                    email = con.Email,
                    emailencodingkey = 'UTF-8',
                    lastname = con.LastName,
                    CommunityNickname = con.Id,
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    username = System.now().millisecond() + con.Email);
            newUsers.add(userRecord);
        }
        return newUsers;
    }


    /**
     *@purpose   : Build Item class record
     *@parameter : itemClassName
     *@return    : Itesm class record
     */
    public  static OrderApi__Item_Class__c buildItemClass(String itemClassName){
        return new OrderApi__Item_Class__c(Name = itemClassName,
                Is_Membership__c =  false, OrderApi__Is_Subscription__c = true);
    }

    /**
     *@purpose   : Build Item record
     *@parameter : itemClassId, itemName
     *@return    : Item record
     */
    public static OrderApi__Item__c buildItem(Id itemClassId, String itemName){
        return new OrderApi__Item__c(Name = itemName,
                OrderApi__Item_Class__c = itemClassId,
                OrderApi__Is_Active__c = true,
                Is_Active_Membership_Type__c =true,
                OrderApi__Price__c = 50,
                Eligible_Nominator_Membership__c = true,
                Portal_Label__c = itemName,
                OrderApi__Is_Subscription__c = true);
    }

    public static OrderApi__Price_Rule__c buildPriceRule(String name, String itemId, String itemClassId){
        return new OrderApi__Price_Rule__c(Name=name,
                    OrderApi__Is_Active__c = true,
                    OrderApi__Item__c=itemId,
                    OrderApi__Item_Class__c=itemClassId,
                    OrderApi__Price__c=630.00);
    }

    public static OrderApi__Source_Code__c buildSourceCode(String sourceCode){
        return new OrderApi__Source_Code__c(Name = sourceCode,
                OrderApi__Channel__c = 'Other',
                OrderApi__Active__c = true);
    }


    /**
     *@purpose   : Build item subscription plan
     *@parameter : -
     *@return    : -
     */
    public static OrderApi__Item_Subscription_Plan__c buildItemSubPlan(String itemId, String subPlanId){
        return new OrderApi__Item_Subscription_Plan__c(OrderApi__Item__c=itemId, OrderApi__Subscription_Plan__c=subPlanId);
    }

    /**
    *@purpose   : Build item subscription plan
    *@parameter : -
    *@return    : -
    */
    public static OrderApi__Subscription_Plan__c buildsubPlan(){
        return new OrderApi__Subscription_Plan__c(Name = '1YR Membership', Show_In_Portal__c = true, OrderApi__Is_Active__c=true, OrderApi__Type__c='Calendar');
    }

    /**
     *@purpose   : Build OrderApi__Subscription__c record
     *@param     : List of Contacts, subPlanId, itemId, itemclassId
     *@return    : List of Subscription records
     */
    public static OrderApi__Subscription__c buildExpiredSubscription(Id contactId, Id subPlanId,Id itemId, Id itemclassId){
        return new OrderApi__Subscription__c(OrderApi__Contact__c = contactId,
                OrderApi__Subscription_Plan__c = subPlanId,
                OrderApi__Item__c = itemId,
                OrderApi__Is_Active__c = false,
                OrderApi__Is_Expired__c = true,
                OrderApi__Item_Class__c = itemclassId,
                OrderApi__Days_To_Lapse__c = -730,
                OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-2, 1, 1),
                OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-2, 12, 31),
                OrderApi__Paid_Through_Date__c = Date.newInstance(System.now().year()-2, 12, 31));
    }

    /**
    *@purpose   : Build working group Committee__c record
    *@param     : committee name
    *@return    : Committee object record
    */
    public static Committee__c buildCommitteeWG(String committeeName){
        return new Committee__c(
                Name = committeeName,
                Type__c = 'Scientific Working Group',
                Is_Active__c = true,
                Established_Date__c = Date.today()

        );
    }


    /**
     *@purpose   : Build OrderApi__Subscription__c record
     *@param     : List of Contacts, subPlanId, itemId, itemclassId
     *@return    : List of Subscription records
     */
    public static OrderApi__Subscription__c buildSubscription(Id contactId, Id subPlanId,Id itemId, Id itemclassId){
        return new OrderApi__Subscription__c(OrderApi__Contact__c = contactId,
                OrderApi__Subscription_Plan__c = subPlanId,
                OrderApi__Item__c = itemId,
                OrderApi__Is_Active__c = True,
                OrderApi__Item_Class__c = itemclassId,
                OrderApi__Current_Term_Start_Date__c = system.today(),
                OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year(), 12, 31),
                OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year(), 12, 31));
    }


    /**
     *@purpose   : Build OrderApi__Subscription_Line__c record
     *@param     : subscriptionId, itemId, itemClassId
     *@return    : SubscriptionLine
     */
    public static OrderApi__Subscription_Line__c buildSubscriptionLine(Id subscriptionId, Id itemId, Id itemclassId) {
        return new OrderApi__Subscription_Line__c(OrderApi__Subscription__c = subscriptionId, OrderApi__Item__c = itemId, OrderApi__Item_Class__c = itemClassId);
    }

    /**
     *@Purpose : build Item Class Names Setting
     *@Param   : Name, itemClassName
     *@return  : Item Class Names Settings record
     */
    public static List<DW_Item_Class_Names_Setting__c> buildItemClassSetting(String itemClassName){
        List<DW_Item_Class_Names_Setting__c> itemClsNameSettingList = new List<DW_Item_Class_Names_Setting__c>();

        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Individual Memberships',
                Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Complimentary Journals',
                Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Journal Subscriptions',
                Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'ZDecline of the Journals',
                Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Working Groups',
                Class_Name__c = itemClassName));


        return itemClsNameSettingList;
    }

    /**
  * @Purpose : build EventApi__Event__c record
  * @Param :
  * @return : Event record
  */
    @isTest(SeeAllData=true)
    public static EventApi__Event__c buildEvent() {

//       EventApi__Event_Category__c evtCategory = [Select Id from EventApi__Event_Category__c where Name = 'Meetings' LIMIT 1];

        return new EventApi__Event__c (
                Name = 'Test Event',
                EventApi__Event_Category__c = 'a1T1I000000uE4NUAU',
                EventApi__Display_Name__c = 'Test Event',
                EventApi__Status__c = 'Active',
                EventApi__Event_Key__c = '5881117b-795e-4',
                EventApi__Time_Zone__c = 'America/New_York',
                EventApi__Ticket_Sales_Start_Date__c = Date.newInstance(2019, 12, 1),
                EventApi__Registration_Style__c = 'Lightning Event');

    }

    /**
     * @Purpose: Build EventApi__Ticket_Type__c record
     * @param event
     * @return Ticket Type record
     */
    public static EventApi__Ticket_Type__c buildTicketType(EventApi__Event__c event) {
        return new EventApi__Ticket_Type__c(
                EventApi__Event__c = event.Id,
                Name = 'Test Ticket',
                EventApi__Price__c = 5.00
        );

    }


    /**
     * @Purpose: Build PagesApi__Form__c
     * @param:
     * @return: Form record
     */
    public static PagesApi__Form__c buildForm() {
        return new PagesApi__Form__c(Name = 'Test Form');
    }

    /**
     * @purpose: Build PagesApi__Field_Group__c
     * @param form
     * @return: Form Field Group record
     */
    public static PagesApi__Field_Group__c buildFieldGroup(PagesApi__Form__c form) {
        return new PagesApi__Field_Group__c(
                Name = 'Test Field Group',
                PagesApi__Form__c = form.Id
        );
    }

    /**
     * @purpose : Build PagesApi__Field__c record
     * @param :  form, fieldGroup, fieldType
     * @return : Form Field record
     */

    public static PagesApi__Field__c buildField(PagesApi__Form__c form, PagesApi__Field_Group__c fieldGroup, String fieldType) {
        return new PagesApi__Field__c(
                Name = 'Test Field: Ask me anything',
                PagesApi__Type__c = fieldType,
                PagesApi__Field_Group__c = fieldGroup.Id,
                PagesApi__Form__c = form.Id
        );
    }

    /**
     * @pupose: Build ContentVersion record
     * @param fileName
     * @return Test File(Attachement) record
     */
    public static ContentVersion buildFile(String fileName) {
        return new ContentVersion(
                Title = fileName,
                PathOnClient = 'test',
                VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
    }


    public static void setupPriorMember(){
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;

        // Build Contact record
        Contact contact= buildContactMemberPrior(account.Id);
        insert contact;

        // Build User recod
        User user = buildUser(contact.Id);
        insert user;

        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c indMemClass = buildItemClass('Individual Memberships');
        insert indMemClass;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item_Class__c].size());

        // Build OrderApi__Item__c record
        OrderApi__Item__c activeMemitem = buildItem(indMemClass.Id, 'Active Membership');
        insert activeMemitem;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item__c].size());

        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c priorDuesClass = buildItemClass('Prior Year Dues');
        insert priorDuesClass;
        System.assertEquals(2, [SELECT Id FROM OrderApi__Item_Class__c].size());

        // Build OrderApi__Item__c record
        OrderApi__Item__c dues = buildItem(priorDuesClass.Id, '2018 Dues');
        insert dues;
        System.assertEquals(2, [SELECT Id FROM OrderApi__Item__c].size());

        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

        // Build OrderApi__Subscription__c record
        OrderApi__Subscription__c subscription = buildExpiredSubscription(contact.Id, subPlan.Id, activeMemitem.Id, indMemClass.Id );
        insert subscription;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription__c].size());

        //Build OrderApi__Subscription_Line__c record
        OrderApi__Subscription_Line__c  subscriptionLine = buildSubscriptionLine(subscription.Id, activeMemitem.Id, indMemClass.Id);
        insert subscriptionLine;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Line__c].size());

        List<DW_Item_Class_Names_Setting__c> itemClsNameSettingList = buildItemClassSetting(indMemClass.Name);
        insert itemClsNameSettingList;
        System.assertEquals(5, [SELECT Id FROM DW_Item_Class_Names_Setting__c].size());
    }


    public static void setupCurrentMember(){
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;

        // Build Contact record
        Contact contact= buildContactMemberCurrent(account.Id);
        insert contact;

        // Build User recod
        User user = buildUser(contact.Id);
        insert user;

        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c indMemClass = buildItemClass('Individual Memberships');
        insert indMemClass;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item_Class__c].size());

        // Build OrderApi__Item__c record
        OrderApi__Item__c activeMemitem = buildItem(indMemClass.Id, 'Active Membership');
        insert activeMemitem;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item__c].size());


        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

        // Build OrderApi__Subscription__c record
        OrderApi__Subscription__c subscription = buildSubscription(contact.Id, subPlan.Id, activeMemitem.Id, indMemClass.Id );
        insert subscription;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription__c].size());

        //Build OrderApi__Subscription_Line__c record
        OrderApi__Subscription_Line__c  subscriptionLine = buildSubscriptionLine(subscription.Id, activeMemitem.Id, indMemClass.Id);
        insert subscriptionLine;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Line__c].size());

        List<DW_Item_Class_Names_Setting__c> itemClsNameSettingList = buildItemClassSetting(indMemClass.Name);
        insert itemClsNameSettingList;
        System.assertEquals(5, [SELECT Id FROM DW_Item_Class_Names_Setting__c].size());
    }


    
    
    /************ PRIVATE METHODS ************/
    
    private OrderApi__Sales_Order__c createClosedUnpostedSOStructure(){
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Is_Posted__c = false;
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Contact__c = testContact.Id;
        so.OrderApi__Account__c = testAccount.Id;
        so.OrderApi__Entity__c = 'Contact';
        so.OrderApi__Date__c = Date.valueOf(System.now());
        so.OrderApi__Schedule_Type__c = 'Simple Receipt';
        so.OrderApi__Posting_Entity__c = 'Receipt';
        so.OrderApi__Closed_Date__c = Date.valueOf(System.now());
        so.OrderApi__Posting_Status__c = 'Pending';
        so.OrderApi__Billing_Contact__c = testContact.Id;
        so.OrderApi__Shipping_Contact__c = testContact.Id;
        so.OrderApi__Billing_Country__c = 'Canada';
        so.OrderApi__Business_Group__c = testBusinessGroup.Id;
        so.OrderApi__Payment_Terms__c = paymentTerms.Id;
        return so;
    }
    
    private OrderApi__Payment_Terms__c createPaymentTerms(){
        OrderApi__Payment_Terms__c pt = new OrderApi__Payment_Terms__c();
        pt.OrderApi__Business_Group__c = testBusinessGroup.Id;
        pt.Name = 'Net 30';
        pt.OrderApi__Display_Name__c = 'Due 30 Days from Receipt';
        pt.OrderApi__Display_Message__c = 'Please remit payment 30 days from receipt of this invoice';
        pt.OrderApi__Variable__c = 30.0;
        insert pt;
        
        return pt;
    }
    
    private OrderApi__Business_Group__c createMasterBusinessGroup(){
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.Name = 'Test Business Group';
        bg.OrderApi__Business_Entity_Type__c = 'Non-Profit 501(c)(3)';
        bg.OrderApi__Is_Master__c = true;
        bg.OrderApi__Type__c = 'Business Entity';
        bg.OrderApi__Merchant_Location__c = '615 Chestnut Street, 17th Floor Philadelphia, PA 19106';
        bg.OrderApi__Merchant_Name__c = 'American Association for Cancer Research';
        bg.OrderApi__Shipping_Rate_Basis__c = 'Item Value';
        bg.OrderApi__Enable_Shipping_By_Order_Total__c = true;
        bg.OrderApi__Calculate_Sales_Tax__c = true;
        bg.OrderApi__Required_Tax_Fields_CSV__c = 'MailingAddress';
        bg.OrderApi__Display_Name__c = 'Test Business Group';
        bg.OrderApi__Phone__c = '215-440-9300';
        bg.OrderApi__Homepage_URL__c = 'http://www.aacr.org';
        bg.OrderApi__Mailing_Address__c = '615 Chestnut Street 17th Floor, Philadelphia, PA 19106';
        insert bg;
        return bg;
        
    }

    public static User buildTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        User tuser = new User(  firstname = fName,
                lastName = lName,
                email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = profId);
        return tuser;
    }

    public static AACR_Error_Log__c buildErrorRequest(Id contactId){
        Id recordTypeId = [Select Id From RecordType where sobjecttype = 'AACR_Error_Log__c' and Name = 'User Request'].Id;
        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id FROM ServiceNow_Incident_Type__mdt];
        AACR_Error_Log__c newLog = new AACR_Error_Log__c();
        newLog.Issue_Type__c = 'Other';
        newLog.Incident_Id__c = incidentTypes[0].Id;
        newLog.Issue_Description__c = 'User Request';
        newLog.Contact__c = contactId;
        newLog.Error_Message__c = 'ERROR TEST';
        newLog.Stack_Trace__c = 'TEST ERROR STACKTRACE';
        newLog.RecordTypeId = recordTypeId;
        newLog.Contact_Name__c = 'Test User';
        newLog.Contact_Phone__c = '555-555-5555';
        newLog.Contact_Email__c = 'test.user@yopmail.com';
        newLog.Contact_Method__c = 'Email';
        newLog.URL__c = 'www.google.com';
        return newLog;
    }





   
       
}