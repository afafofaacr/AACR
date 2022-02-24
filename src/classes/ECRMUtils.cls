/**
 * Created by lauren.lezberg on 3/29/2019.
 */

public without sharing class ECRMUtils {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
    public static List<Virtual_Meeting_Sponsor__mdt> virtualSponsors = new List<Virtual_Meeting_Sponsor__mdt>();

    public static final Id deceasedRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Deceased').getRecordTypeId();
    public static final Id priorMemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();
    public static final Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
    public static final Id nonmemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Nonmember').getRecordTypeId();


    /* ---------------------------------- SUBSCRIPTIONS UTILITIES ------------------------------------------------- */

    /**
     * @purpose Retrieves all subscriptions that match the provided membership by paid through date with the given item classes. The list includes the membership subscription.
     *
     * @param itemClassNames
     * @param membership
     *
     * @return List of subscriptions
     */
    public static List<OrderApi__Subscription__c> getSubscriptionsFromMembership(Set<String> itemClassNames, OrderApi__Subscription__c membership){

        Date compareDate = membership.OrderApi__Paid_Through_Date__c;

        String queryString = 'SELECT Id, OrderApi__Contact__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Account__c, OrderApi__Item_Class__c, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Is_Expired__c, OrderApi__Current_Term_End_Date__c, OrderApi__Business_Group__c,OrderApi__Item__c, OrderApi__Entity__c, OrderApi__Item__r.OrderApi__Is_Active__c, OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c, OrderApi__Item__r.Name, OrderApi__Item_Class__r.Name, OrderApi__Is_Active__c, OrderApi__Subscription_Plan__c, OrderApi__Enable_Auto_Renew__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = \'' + membership.OrderApi__Contact__c + '\' AND OrderApi__Paid_Through_Date__c = :compareDate AND OrderApi__Item__r.OrderApi__Is_Active__c = true AND OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true AND OrderApi__Is_Cancelled__c = false';
        System.debug('queryString: ' + queryString);
        if(itemClassNames!=null){
            if(!itemClassNames.isEmpty()){
                queryString += ' AND OrderApi__Item_Class__r.Name IN: itemClassNames';
            }
        }
        queryString += ' ORDER BY CreatedDate ASC';
        System.debug('queryString: ' + queryString);

        return Database.query(queryString);
    }

    /**
    * @purpose Cancels list of subscriptions
    *
    * @param subs
    */
    public static void cancelSubscriptions(List<OrderApi__Subscription__c> subs, String reason){
        /** Cancel all old subscriptions **/
        for(OrderApi__Subscription__c sub : subs){
            sub.OrderApi__Cancelled_Reason__c = reason;
            sub.OrderApi__Is_Cancelled__c = true;
        }
        update subs;

    }

    /**
     * @purpose Cancel all subscriptions for given contact
     *
     * @param contactId
     */
    public static void cancelAllSubscriptions(String contactId, String reason){
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!memSubs.isEmpty()){
            List<OrderApi__Subscription__c> allContactSubscriptions = [
                    SELECT Id
                    FROM OrderApi__Subscription__c
                    WHERE OrderApi__Contact__c = :contactId AND
                    OrderApi__Paid_Through_Date__c = :memSubs[0].OrderApi__Paid_Through_Date__c AND
                    OrderApi__Item__r.OrderApi__Is_Active__c = true
            ];
            if(!allContactSubscriptions.isEmpty()){
                cancelSubscriptions(allContactSubscriptions, reason);
            }
        }
    }

    /**
    * @purpose Cancel all subscriptions for given contact
    *
    * @param contactId
    */
    public static void cancelAllSubscriptionsWithBadges(String contactId, String reason){
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!memSubs.isEmpty()){
            List<OrderApi__Subscription__c> allContactSubscriptions = [
                    SELECT Id
                    FROM OrderApi__Subscription__c
                    WHERE OrderApi__Contact__c = :contactId AND
                    OrderApi__Paid_Through_Date__c = :memSubs[0].OrderApi__Paid_Through_Date__c AND
                    OrderApi__Item__r.OrderApi__Is_Active__c = true
            ];
            /** Cancel Badges **/
            /** Get badge to Expire (Badges with Sales Orders)**/
            List<OrderApi__Badge__c> oldBadges = [
                    SELECT Id
                    FROM OrderApi__Badge__c
                    WHERE OrderApi__Item__c != NULL
                    AND OrderApi__Is_Active__c = true
                    AND (Active_Lookup__c =: contactId OR Inactive_Lookup__c =: contactId)
            ];


            /**Remove sales order line lookup **/
            if ( !oldBadges.isEmpty() ) {
                for(OrderApi__Badge__c badge : oldBadges) {
                    badge.OrderApi__Sales_Order_Line__c = null;
                    badge.OrderApi__Is_Active__c = false;
                    badge.OrderApi__Expired_Date__c = Date.today().addDays(-1);
                }
            }

            if(!allContactSubscriptions.isEmpty()){
                cancelSubscriptions(allContactSubscriptions, reason);
            }

            if(oldBadges.size()>0) {
                update oldBadges;
            }
        }
    }

    /**
    * @purpose Modifies sales order line so that subscription terms are created correctly and GL accounts are set accordingly.
    * Note: Because of a fonteva limitation, you cannot update the GL on a sales order line with an item that is not a subscription, you can only set it on initial create.
    * In order to overcome this limitation, if a sales order line contains an item that is not a subscription, a duplicate line is created with the correct GL and the old line is deleted.
    *
    * @param subscriptionPlanId
    * @param salesOrderId
    * @param termStartYear
    */
    @Future
    public static void changeSubscriptionTerm(Id subscriptionPlanId, Id salesOrderId, String termStartYear){
        OrderApi__Subscription_Plan__c subPlan = [SELECT OrderApi__Advanced_Calendar_Days__c, Show_In_Portal__c FROM OrderApi__Subscription_Plan__c WHERE Id=: subscriptionPlanId];

        List<OrderApi__Sales_Order_Line__c> lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);

        //Used to update GL for lines with non subscription item --> Fonteva limitation: Cannot update GL of a sales order line with an item that is not a subscription
        //Workaround: For items that are not subscriptions, if GL needs to be updated, delete old line and add new line with correct GL
        List<OrderApi__Sales_Order_Line__c> linesToUpdate = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();

        for(OrderApi__Sales_Order_Line__c line : lines){
            if(line.OrderApi__Item__r.Name!='Honorary Membership' && line.OrderApi__Item__r.Name!='Emeritus Membership') {
                if (!line.OrderApi__Item__r.OrderApi__Not_For_Individual_Sale__c) {
                    line.OrderApi__Auto_Calculate_Activation_Date__c = false;
                    line.OrderApi__Activation_Date__c = Date.newInstance(Integer.valueOf(termStartYear), 1, 1);
                    if (line.OrderApi__Item__r.OrderApi__Is_Subscription__c) {
                        System.debug('item is a subscription item');
                        line.OrderApi__Subscription_Plan__c = subPlan.Id;
                        if (subPlan.OrderApi__Advanced_Calendar_Days__c == 365) { //2 YR Subscription plan
                            line.OrderApi__GL_Account__c = line.OrderApi__Item__r.OrderApi__Income_Account__c;
                        } else {
                            if (Integer.valueOf(termStartYear) == System.now().year()) { //current year subscription
                                line.OrderApi__GL_Account__c = line.OrderApi__Item__r.OrderApi__Income_Account__c;
                            } else { //future year subscription
                                line.OrderApi__GL_Account__c = line.OrderApi__Item__r.Future_Income_Account__c;
                            }
                        }
                        linesToUpdate.add(line);
                    } else {
                        System.debug('item is NOT a subscription item');
                        if (line.OrderApi__Item__r.Future_Income_Account__c != null && line.OrderApi__Item__r.Future_Income_Account__c != line.OrderApi__Item__r.OrderApi__Income_Account__c) {
                            OrderApi__Sales_Order_Line__c newLine = line.clone(false, false, false, false); // create new cloned sales order line
                            linesToDelete.add(line);
                            if (subPlan.OrderApi__Advanced_Calendar_Days__c == 365) {//2 YR Subscription plan
                                newLine.OrderApi__GL_Account__c = line.OrderApi__Item__r.OrderApi__Income_Account__c;
                            } else {
                                if (Integer.valueOf(termStartYear) == System.now().year()) { //current year subscription
                                    newLine.OrderApi__GL_Account__c = line.OrderApi__Item__r.OrderApi__Income_Account__c;
                                } else {
                                    newLine.OrderApi__GL_Account__c = line.OrderApi__Item__r.Future_Income_Account__c;
                                }
                            }
                            linesToUpdate.add(newLine);
                        }
                    }
                }
            }
        }


        delete linesToDelete;
        upsert linesToUpdate;


    }

    /* ------------------------------------- SALES ORDER UTILITIES -------------------------------------------------*/

    public static void markInvoiceAsPaid(String invoiceId){
        OrderApi__Invoice__c inv = [SELECT Id, OrderApi__Total__c, OrderApi__Sales_Order__c FROM OrderApi__Invoice__c WHERE Stripe_Invoice_Id__c=: invoiceId];
        inv.OrderApi__Paid_Date__c = Date.today();
        inv.OrderApi__Status__c = 'Posted';
        inv.OrderApi__Amount_Paid__c = inv.OrderApi__Total__c;

        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Status__c, OrderApi__Posting_Status__c FROM OrderApi__Sales_Order__c WHERE Id=: inv.OrderApi__Sales_Order__c];
        so.OrderApi__Posting_Status__c = 'Posted';
        so.OrderApi__Status__c = 'Closed';

        update so;

        update inv;
    }

    public static String startMembershipApplication(String itemId){
        //update application status
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        currentContact.Application_Status__c = 'Incomplete Application';
        try{
            update currentContact;
        } catch (Exception e){
            System.debug('Error setting application status: ' + e.getMessage());
            return null;
        }
        //get membership item
        OrderApi__Item__c membership = [SELECT Id, Name, OrderApi__Business_Group__c,OrderApi__Item_Class__c, OrderApi__Price__c FROM OrderApi__Item__c WHERE Id=: itemId LIMIT 1];
        //create SO with membership item
        OrderApi__Sales_Order__c newSO = JP_Helper.createNewMemberSOWithLine(currentContact, membership);

        return newSO.Id;
    }

    public static String startTransferApplication(String itemId){
        //update application status
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        currentContact.Application_Status__c = 'Incomplete Application';
        try{
            update currentContact;
        } catch (Exception e){
            System.debug('Error setting application status: ' + e.getMessage());
            return null;
        }

        List<OrderApi__Subscription__c> subs = [SELECT OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__c FROM OrderApi__Subscription__c WHERE OrderApi__Is_Active__c=true AND OrderApi__Contact__c=:currentContact.Id AND OrderApi__Item_Class__r.Name!='Individual Memberships'];
        //get membership item
        OrderApi__Item__c membership = [SELECT Id, Name, OrderApi__Business_Group__c,OrderApi__Item_Class__c, OrderApi__Price__c FROM OrderApi__Item__c WHERE Id=: itemId LIMIT 1];

        //create SO with membership item
        OrderApi__Sales_Order__c newSO = JP_Helper.createTransferSOWithLine(currentContact, membership);

        Boolean hasBloodCancerJournal = false;
        Id subPlan;
        List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();
        for(OrderApi__Subscription__c sub: subs){
            subPlan = sub.OrderApi__Subscription_Plan__c;
            if(sub.OrderApi__Item_Class__r.Name!='Complimentary Journals') {
                lines.add(new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = newSO.Id, OrderApi__Item__c = sub.OrderApi__Item__c, OrderApi__Subscription_Plan__c = sub.OrderApi__Subscription_Plan__c));
            } else if (sub.OrderApi__Item__r.Name == 'Blood Cancer Discovery - Online'){
                hasBloodCancerJournal = true;
            }
        }

        //add blood cancer discovery journal if not already there
        if(!hasBloodCancerJournal){
            OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Blood Cancer Discovery - Online'];
            insert new OrderApi__Sales_Order_Line__c(OrderApi__Subscription_Plan__c=subPlan, OrderApi__Sales_Order__c=newSO.Id, OrderApi__Item__c=bloodCancerJournal.Id, OrderApi__Item_Class__c=bloodCancerJournal.OrderApi__Item_Class__c);
        }

        //add emeritus voluntary dues
        if(membership.Name=='Emeritus Membership'){
            OrderApi__Item__c voluntaryAssessment = [SELECT Id FROM OrderApi__Item__c WHERE Name='Emeritus Voluntary Assessment' LIMIT 1];
            lines.add(new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = newSO.Id, OrderApi__Item__c = voluntaryAssessment.Id));
        }

        insert lines;

        return newSO.Id;
    }

    public static String startReinstateTransferApplication(String itemId){
        //update application status
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        currentContact.Application_Status__c = 'Incomplete Application';
        try{
            update currentContact;
        } catch (Exception e){
            System.debug('Error setting application status: ' + e.getMessage());
            return null;
        }

        List<OrderApi__Subscription__c> subs = [SELECT OrderApi__Item__c FROM OrderApi__Subscription__c WHERE OrderApi__Is_Active__c=true AND OrderApi__Contact__c=:currentContact.Id AND OrderApi__Item_Class__r.Name!='Individual Memberships'];
        //get membership item
        OrderApi__Item__c membership = [SELECT Id, Name, OrderApi__Business_Group__c,OrderApi__Item_Class__c, OrderApi__Price__c FROM OrderApi__Item__c WHERE Id=: itemId LIMIT 1];
        //create SO with membership item
        OrderApi__Sales_Order__c newSO = JP_Helper.createReinstateTransferSOWithLine(currentContact, membership);

        List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();
        for(OrderApi__Subscription__c sub: subs){
            lines.add(new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=newSO.Id, OrderApi__Item__c=sub.OrderApi__Item__c));
        }
        insert lines;

        return newSO.Id;
    }


    public static OrderApi__Sales_Order__c getSalesOrder(String soID){
        OrderApi__Sales_Order__c so= new OrderApi__Sales_Order__c();
        try{
            so = [SELECT Id, Name, OrderApi__Source_Code__c, OrderApi__Is_Posted__c, OrderApi__Is_Closed__c, Is2YR__c,
                    OrderApi__Total__c, OrderApi__Contact__c, OrderApi__Account__c
                    FROM OrderApi__Sales_Order__c
                    WHERE Id=:soID];
        }catch(Exception e){
            System.debug('Error getting sales order: ' + e.getMessage());
        }

        return so;
    }

    /**
   *@Purpose : Getting Individual Membership sales order LI's for specific sales order
   *@Param   : salesOrderId
   *@Return  : List of sales order LI's
   */
    public static List<OrderApi__Sales_Order_Line__c> getSpecificSalesOrderIndMemLIs( String salesOrderId ){
        List<OrderApi__Sales_Order_Line__c> membershipSalesOrderLIs = new List<OrderApi__Sales_Order_Line__c>();
        try{
            membershipSalesOrderLIs = ([SELECT Id, Name, OrderApi__Item__c, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c,
                    OrderApi__Sales_Order__c, OrderApi__Item__r.Name,
                    OrderApi__Item__r.Is_Active_Membership_Type__c
            FROM OrderApi__Sales_Order_Line__c
            WHERE OrderApi__Sales_Order__c =: salesOrderId AND
            OrderApi__Item_Class__r.Name = 'Individual Memberships'
            LIMIT 1]);
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return membershipSalesOrderLIs;
    }

    /**
     * @purpose Retrieve all sales order lines for a particular sales order
     *
     * @param salesOrderId
     *
     * @return List of sales order lines
     */
    public static List<OrderApi__Sales_Order_Line__c> getAllSalesOrderLines(String salesOrderId) {
        return [SELECT Id, OrderApi__Item__r.EventApi__Ticket_Type__c, OrderApi__Item__r.OrderApi__Is_Subscription__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Item__r.Future_Income_Account__c,
                OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c,
                OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c,
                OrderApi__Sale_Price__c, OrderApi__GL_Account__c, OrderApi__Total__c, OrderApi__Quantity__c, OrderApi__Item__r.Portal_Label__c, OrderApi__Sales_Order__r.OrderApi__Subtotal__c,
                OrderApi__Sales_Order__r.OrderApi__Source_Code__c, OrderApi__Sales_Order__r.OrderApi__Source_Code__r.Name, OrderApi__End_Date__c, OrderApi__Item_Class__r.EventApi__Event__r.EventApi__Start_Date__c,
                OrderApi__Item_Class__r.EventApi__Event__r.EventApi__Display_Name__c, OrderApi__Sales_Order__r.OrderApi__Contact__c, OrderApi__Item__r.OrderApi__Not_For_Individual_Sale__c, OrderApi__Item__r.Managed__c
        FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Sales_Order__c = :salesOrderId];

    }

    /**
     * @purpose Get all sales order lines containing a prior year dues or individual memberships item for a particular sales order
     *
     * @param salesOrderId
     *
     * @return List of sales order lines
     */
    public static List<OrderApi__Sales_Order_Line__c> getMembershipSalesOrderLines(String salesOrderId) {
        return [SELECT Id, OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Subscription_Plan__r.Name,
                OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c,
                OrderApi__Sale_Price__c, OrderApi__Item__r.OrderApi__Is_Subscription__c
        FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Sales_Order__c = :salesOrderId
        AND (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name = 'Prior Year Dues' OR OrderApi__Item_Class__r.Name='Internal Staff Use Only')];

    }


    /* ------------------------------------ CONTACT/USER UTILITIES ------------------------------------- */



    /**
     * @purpose Checks for contact duplicates based off email address
     *
     * @param email
     *
     * @return True or False
     */
    public static Boolean checkForContactDuplicates(String email){
        Integer dupeContacts = [SELECT COUNT() FROM Contact WHERE Email =: email];
        if(dupeContacts >0){
            return true;
        }

        return false;
    }

    public static void createDuplicateAlert(Contact con){
        Boolean foundDupes= false;
        List<Contact> contacts = new List<Contact>{con};
        List<Datacloud.FindDuplicatesResult> dupes = Datacloud.FindDuplicates.findDuplicates(contacts);

        if(dupes.size()>0){
            for (Datacloud.FindDuplicatesResult fdr : dupes) {
                for (Datacloud.DuplicateResult dupeResult : fdr.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) { 
                        if (matchResult.getMatchRecords().size() > 0) {
                            System.debug('found duplicates: ' + fdr);
                            foundDupes = true;
                        }
                    }
                }
            }

            if(foundDupes) {
                ServiceNow_Incident_Type__mdt incidentType = [SELECT Id,Type__c FROM ServiceNow_Incident_Type__mdt WHERE Type__c = 'Duplicate Alert'];
                List<AACR_Error_Log__c> logs = [SELECT Id FROM AACR_Error_Log__c WHERE Contact__c = :con.Id AND Incident_Id__c = :incidentType.Id];
                if (logs.size() == 0) { //only create duplicate ticket if one doesn't exist
                    AACR_Error_Log__c eLog = ErrorHelper.buildErrorLog(contacts[0], incidentType.Id, incidentType.Type__c, 'Contact has duplicates.');

                    try {
                        insert eLog;
                        ErrorHelper.sendServiceNowRequestEmail(con.Id, eLog.Id, null);
                    } catch (Exception e) {
                        System.debug('error: ' + e.getMessage());
                        new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Finding Duplicates');
                    }
                }
            }
        }
    }


    public static List<Contact> getContactDuplicates(String email){
        return [SELECT Id, Name, AccountId, OrderApi__Preferred_Phone__c, OrderApi__Preferred_Email__c FROM Contact WHERE Email=:email];
    }

    public static Boolean checkForUser(String email){
        Integer userInteger = [SELECT COUNT() FROM User WHERE Email=: email];
        if(userInteger == 1){
            return true;
        }

        return false;
    }

    /**
     * @purpose Updates contact work email with provided value
     *
     * @param userId
     * @param email
     */
    public static void updateContactWorkEmail(Id userId, String email){
        User u = [SELECT ContactId FROM User WHERE Id=: userId];
        Contact con = [SELECT Id, OrderApi__Work_Email__c FROM Contact WHERE Id=: u.ContactId];
        con.OrderApi__Work_Email__c = email;
        update con;
    }

    /**
     * @purpose Deactivate portal user record.
     * ***Needs to be @future because you cannot perform DML operation on setup object and non-setup object at the same time.
     *
     * @param contactId
     */
    @Future (callout=true)
    public static void deactivatePortalUser(Id contactId){
        List<User> usersToUpdate = new List<User>();
        for(User u : [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where u.ContactId=:contactId]){
            if(u.IsActive || u.IsPortalEnabled ){
                u.IsActive = false;
                u.IsPortalEnabled = false;
                usersToUpdate.add(u);
            }
        }

        if (usersToUpdate.size()>0){
            update usersToUpdate;
        }
    }

    /**
       *@Purpose : Getting current login user contact Id
       *@Param   : -
       *@Return  : conatct id
       */
    public static Id getCurrentLoginUserContactId(){
        // Getting current login user id
        Id userId = UserInfo.getUserId();
        User user;
        try{
            user = [SELECT Id, ContactId
            FROM User
            WHERE Id = : userId];
            System.debug('user id+'+ user);
        }catch(Exception exp){
            System.debug('Exception Occured while fetching User:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return user.ContactId;
    }

    /**
     *@Purpose : Getting Current Login user contact
     *@Param   : -
     *@Return  : Contact record
     */
    public static Contact getCurrentLoginContact(){
        // Getting current login user contact Id
        Id contactId = getCurrentLoginUserContactId();
        System.debug('contactId: ' + contactId);
        Contact contact;

        if(String.isNotBlank(contactId)){
            try{

                contact = [SELECT Id, Name, Gender__c, Preferred_Address__c, Is_Journal_Addr_Same_As_Preferred_Addr__c, MailingStateCode, OtherStateCode,
                        MailingStreet, MailingCity, MailingState, MailingPostalcode, Expected_Completion_Date__c, MailingCountry, MailingCountryCode, OtherCountryCode, Title, FirstName, LastName,
                        OtherStreet, OtherCity,  OtherState, OtherPostalCode, OtherCountry, Account.Name, OrderApi__Preferred_Phone_Type__c, OrderApi__Preferred_Email_Type__c,
                        Journal_Street__c, Journal_City__c, Journal_State_Province__c, is_affiliated_with_self__c, OrderApi__Preferred_Email__c, Salutation,
                        Journal_Zip_Postal_Code__c, Journal_Country__c, AccountId, Application_Status__c, Do_Not_Display_In_Directory__c, OrderApi__Work_Email__c, OrderApi__Personal_Email__c,
                        Member_Type__c, Initial_Join_Date__c, Membership_Status__c, Modify_Groups__c, RecordTypeId, OrderApi__Preferred_Phone__c, Work_Setting__c,
                        RecordType.Name, Paid_thru_date__c, Major_Focus__c, Organ_Sites__c, Primary_Research_Area_of_Expertise__c, Campaign_Code__c, Degrees_Held__c,
                        Specific_Research_Areas__c, Additional_Research_Areas__c, Other_Research_Areas__c, OrderApi__Badges__c, Birthdate, AACR_ID__c, MobilePhone
                FROM Contact
                WHERE Id =: contactId];
            }catch(Exception exp){
                System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        return contact;
    }


    /* ----------------------------------------------- OTHER UTILITIES -------------------------------------------*/


    @Future
    public static void updateOpenSalesOrderLines(String contactId){
        /** get most recent OPEN sales order with membership item **/
        List<OrderApi__Sales_Order_Line__c> membershipLines = [SELECT Id, OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__r.OrderApi__Contact__c =: contactId AND OrderApi__Sales_Order__r.OrderApi__Status__c = 'Open' AND OrderApi__Item_Class__r.Name = 'Individual Memberships' ORDER BY OrderApi__Sales_Order__r.LastModifiedDate DESC];
        if(!membershipLines.isEmpty()) {
            /** get all sales order lines in that order **/
            List<OrderApi__Sales_Order_Line__c> linesToUpdate = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__r.OrderApi__Contact__c = :contactId AND OrderApi__Sales_Order__r.OrderApi__Status__c = 'Open' AND OrderApi__Sales_Order__c=:membershipLines[0].OrderApi__Sales_Order__c FOR UPDATE];
            try {
                /** update sales order lines to re-fire Fonteva price rules **/
                update linesToUpdate;
            } catch (Exception e) {
                new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'SO Line Update');
            }
        }
    }


    private static Account buildIndividualAccount(String accountName , String email){
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name = 'Active Account' AND SobjectType = 'Account'];
        Account individualAcct = new Account();
        individualAcct.Name = accountName;
        individualAcct.OrderApi__Account_Email__c = email;
        individualAcct.RecordTypeId = recordTypes[0].Id;
        individualAcct.LD_USE_DnB_Optimize__c = false;
        individualAcct.Institution_Type__c = 'Individual';
        List<siteSettings__c> siteSettings = [SELECT ownerId__c FROM siteSettings__c LIMIT 1];
        if (siteSettings.size() == 1) {
            individualAcct.OwnerId = siteSettings[0].ownerId__c;
        }
        return individualAcct;
    }


    public static Account createOrFindIndividualAccount(String firstName, String lastName, String email, String contactId){
        Account newAcct = null;
        String accountName = firstName + ' ' + lastName + ' (Individual)';

        //check if contactId exists
        if(contactId!=null) {
            //check for individual account --> if none exists, create one
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE OrderApi__Primary_Contact__c=:contactId AND Name =: accountName];

            if(accounts.isEmpty()) {
                newAcct = buildIndividualAccount(accountName, email);

            } else {
                newAcct = accounts[0];
            }
        } else { //no contactId --> create new account
            newAcct = buildIndividualAccount(accountName, email);
        }

        try {
            upsert newAcct;

        } catch (Exception e) {
            System.debug('Could not upsert individual account: ' + e.getMessage());
            return null;
        }

        return newAcct;
    }


    public static void deleteRecord(String recordId){
        try{
            Database.delete(recordId);
        }catch(Exception e){
            new AACRCustomException(recordId, e.getMessage(), e.getStackTraceString(),'Delete Record');
        }
    }

    /**
    * @purpose Retrieves records based on search keyword from specific object type
    *
    * @param searchKeyWord
    * @param ObjectName
    *
    * @return List of records matching the search keyword
    */
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String filterString) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%' + searchKeyWord.replace(' ','%') + '%';

        List < sObject > returnList = new List < sObject > ();

        String sQuery =  'SELECT id, Name from ' +ObjectName + ' WHERE Name LIKE: searchKey';
        if(filterString !=null){
            sQuery += ' AND ' + filterString;
        }
        sQuery += ' ORDER BY createdDate DESC limit 5';

        System.debug('squery: ' + sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }


    /**
     * @purpose Get all record types for a particular object type
     *
     * @param sObjectType
     *
     * @return
     */
    @AuraEnabled
    public static List<RecordType> getRecordTypes(String sObjectType){
        return [SELECT Id, Name FROM RecordType WHERE SobjectType =: sObjectType AND IsActive = true ORDER BY Name];
    }


    /**
     * @purpose Retrieve global country picklist values
     *
     * @return country picklistValuesMap
     */
    public static Map<String, String> getCountryPicklistValues(){
        Map<String, String> countryMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            countryMap.put(f.getValue(), f.getLabel());
            System.debug(f.getLabel() +'::'+ f.getValue());
        }
        return countryMap;
    }

    /**
     * @purpose Retrieve global country picklist values but reverse map to get country code
     *
     * @return country picklistValuesMap
     */
    public static Map<String, String> getReverseCountryPicklistValues(){
        Map<String, String> countryMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            countryMap.put(f.getLabel(), f.getValue());
            System.debug(f.getValue() +'::'+ f.getLabel());
        }
        return countryMap;
    }

    /**
     * @purpose Retrieve global country picklist values
     *
     * @return country picklistValuesMap
     */
    public static Map<String, String> getCountryCodes(){
        Map<String, String> countryMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            countryMap.put(f.getLabel(),f.getValue());
//            System.debug(f.getLabel() +'::'+ f.getValue());
        }
        return countryMap;
    }



    /**
     * @purpose Retrieve global state picklist values
     *
     * @return state picklistValuesMap
     */
    public static Map<String, String> getStatePicklistValues(){
        Map<String, String> stateMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.StateCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            stateMap.put(f.getValue(), f.getLabel());
//            System.debug(f.getLabel() +'::'+ f.getValue());
        }
        return stateMap;
    }


    /**
    *@Purpose : Getting picklist values
    *@Param   : objectName, fieldName
    *@Return  : picklistValuesMap
    */
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();

        if (String.isNotBlank(objectName) && String.isNotBlank(fieldName)) {
            SObjectType objectToken = Schema.getGlobalDescribe().get(objectName);
            if (objectToken != NULL) {
                Map<String, SObjectField> fields = objectToken.getDescribe().fields.getMap();
                List<Schema.PicklistEntry> listOfPicklistEntries = fields.get(fieldName).getDescribe().getPickListValues();
                if (listOfPicklistEntries != NULL && !listOfPicklistEntries.isEmpty()) {
                    for (Schema.PicklistEntry pickListVal : listOfPicklistEntries) {
                        picklistValues.add(pickListVal.getValue());
                    }
                }
            }
        }
        return picklistValues;
    }


    public class MyPickListInfo
    {
        public String validFor;
    }

    /**
     * @purpose Gets a map of dependent picklist values based on give field values
     *
     * @param objectName
     * @param controllingField
     * @param dependentField
     * @param compareValue
     *
     * @return Map of dependent values
     */
    public static Map<String, String> getDependentPicklistValues(String objectName, String controllingField, String dependentField, String compareValue)
    {
        Map<String, String> stateValues = new Map<String, String>();
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            //System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            //System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);

            Integer baseCount = 0;

            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;

                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 8) == 8)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getValue());
                    if(controllingValues[baseCount + 0].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getValue(), currDependentValue.getLabel());
                    }
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getValue());
                    if(controllingValues[baseCount + 1].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getValue(), currDependentValue.getLabel());
                    }
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 2) == 2)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getValue());
                    if(controllingValues[baseCount + 2].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getValue(), currDependentValue.getLabel());
                    }
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 1) == 1)
                {
                    // System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getValue());
                    if(controllingValues[baseCount + 3].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getValue(), currDependentValue.getLabel());
                    }
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());
                }

                baseCount += 4;
            }
        }

        System.debug('stateValues: ' + stateValues);
        //System.debug('ControllingInfo: ' + controllingInfo);

        return stateValues;
    }


    /**
     * @purpose Gets a map of dependent picklist values based on given field values with label as key and value as value
     *
     * @param objectName
     * @param controllingField
     * @param dependentField
     * @param compareValue
     *
     * @return Map of dependent values
     */
    public static Map<String, String> getDependentPicklistValuesReverse(String objectName, String controllingField, String dependentField, String compareValue)
    {
        Map<String, String> stateValues = new Map<String, String>();
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            //System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            //System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);

            Integer baseCount = 0;

            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;

                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 8) == 8)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getValue());
                    if(controllingValues[baseCount + 0].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getLabel(), currDependentValue.getValue());
                    }
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getValue());
                    if(controllingValues[baseCount + 1].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getLabel(), currDependentValue.getValue());
                    }
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 2) == 2)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getValue());
                    if(controllingValues[baseCount + 2].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getLabel(), currDependentValue.getValue());
                    }
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 1) == 1)
                {
                    // System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getValue());
                    if(controllingValues[baseCount + 3].getValue() == compareValue){
                        System.debug(currDependentValue.getLabel());
                        stateValues.put(currDependentValue.getLabel(), currDependentValue.getValue());
                    }
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());
                }

                baseCount += 4;
            }
        }

//        System.debug('stateValues: ' + stateValues);
        //System.debug('ControllingInfo: ' + controllingInfo);

        return stateValues;
    }

    public static List<npe4__Relationship__c> getCurrentRelationships(String relationshipType, String contactId) {

        if(contactId==null) {
            contactId = getCurrentLoginUserContactId();
        }

        return [
                
                SELECT npe4__RelatedContact__c,
                        npe4__Status__c,
                        npe4__RelatedContact__r.Salutation,
                        npe4__RelatedContact__r.Name,
                        npe4__RelatedContact__r.LastName,
                        npe4__RelatedContact__r.FirstName,
                        npe4__RelatedContact__r.OrderApi__Work_Phone__c,
                        npe4__RelatedContact__r.HomePhone,
                        npe4__RelatedContact__r.MobilePhone,
                        npe4__RelatedContact__r.OrderApi__Preferred_Phone_Type__c,
                        npe4__RelatedContact__r.OrderApi__Preferred_Email__c,
                        npe4__RelatedContact__r.OrderApi__Work_Email__c,
                        npe4__RelatedContact__r.OrderApi__Personal_Email__c,
                        npe4__RelatedContact__r.OrderApi__Preferred_Email_Type__c,
                        npe4__RelatedContact__r.RecordTypeId,
                        npe4__Contact__c
                FROM npe4__Relationship__c
                WHERE npe4__Type__c = :relationshipType
                AND npe4__Status__c = 'Current'
                AND npe4__Contact__c = :contactId
        ];


    }


    public static String getVirtualSponsorsHTML(String eventId){
        String htmlString = null;
        List<Virtual_Meeting_Links__mdt> meetings;
        if(!Test.isRunningTest()){
            meetings = [SELECT Id FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c=: eventId];
        } else {
            meetings = virtualMeetings;
        }


        if(!meetings.isEmpty()) {
            List<Virtual_Meeting_Sponsor__mdt> sponsors;
            if(!Test.isRunningTest()){
                sponsors = [SELECT Sponsor_Type__c, MasterLabel FROM Virtual_Meeting_Sponsor__mdt WHERE Virtual_Meeting__c = :meetings[0].Id ORDER BY MasterLabel];
            } else{
                sponsors = virtualSponsors;
            }

            List<Virtual_Meeting_Sponsor__mdt> supporters = new List<Virtual_Meeting_Sponsor__mdt>();
            List<Virtual_Meeting_Sponsor__mdt> cureLevel = new List<Virtual_Meeting_Sponsor__mdt>();
            List<Virtual_Meeting_Sponsor__mdt> progressLevel = new List<Virtual_Meeting_Sponsor__mdt>();

            for (Virtual_Meeting_Sponsor__mdt vms : sponsors) {
                if (vms.Sponsor_Type__c == 'Underwriting Sponsor') {
                    supporters.add(vms);
                }
                if (vms.Sponsor_Type__c == 'Cure Level') {
                    cureLevel.add(vms);
                }
                if (vms.Sponsor_Type__c == 'Progress Level') {
                    progressLevel.add(vms);
                }
            }

            htmlString = '<center>';
            if (!supporters.isEmpty()) {
                htmlString += '<br/><strong>Underwriting Supporters</strong><br/>';
                for (Virtual_Meeting_Sponsor__mdt supporter : supporters) {
                    htmlString += supporter.MasterLabel + '<br/>';
                }
            }
            if (!cureLevel.isEmpty()) {
                htmlString += '<br/><strong>Cure Level</strong><br/>';
                for (Virtual_Meeting_Sponsor__mdt cl : cureLevel) {
                    htmlString += cl.MasterLabel + '<br/>';
                }
            }
            if (!progressLevel.isEmpty()) {
                htmlString += '<br/><strong>Progress Level</strong><br/>';
                for (Virtual_Meeting_Sponsor__mdt pl : progressLevel) {
                    htmlString += pl.MasterLabel + '<br/>';
                }
            }
            htmlString += '</center>';
        }

        return htmlString;
    }

    public static String cleanStringCase(String dirtyString) {

        System.debug('dirtyString = ' + dirtyString);
        String cleanString;

        if ( dirtyString.contains(' ') ) {
            // Hold each word
            List<String> pieces = new List<String>();
            // Split
            for (String s : dirtyString.split(' ')) {
                if ( s.contains('\'') ) {
                    List<String> subPiece = new List<String>();

                    for (String a : s.split('\'')) {
                        // Capitalize each piece
                        a = a.toLowerCase().capitalize();
                        subPiece.add(a);
                    }
                    //Rejoin
                    s = String.join(subPiece, '\'');
                } else {
                    // Capitalize each piece
                    s = s.toLowerCase().capitalize();
                }
                pieces.add(s);
            }
            //Rejoin
            cleanString = String.join(pieces, ' ');

        } else if ( dirtyString.contains('-') ) {
            // Hold each word
            List<String> pieces = new List<String>();
            // Split
            for (String s : dirtyString.split('-')) {
                if ( s.contains('\'') ) {
                    List<String> subPiece = new List<String>();

                    for (String a : s.split('\'')) {
                        // Capitalize each piece
                        a = a.toLowerCase().capitalize();
                        subPiece.add(a);
                    }
                    //Rejoin
                    s = String.join(subPiece, '\'');
                } else {
                    // Capitalize each piece
                    s = s.toLowerCase().capitalize();
                }
                pieces.add(s);
            }
            //Rejoin
            cleanString = String.join(pieces, '-');
        } else if ( dirtyString.contains('\'') ) {
            List<String> pieces = new List<String>();

            for (String s : dirtyString.split('\'')) {
                // Capitalize each piece
                s = s.toLowerCase().capitalize();
                pieces.add(s);
            }
            //Rejoin
            cleanString = String.join(pieces, '\'');
        }
//        else if( dirtyString.length() > 3 && dirtyString.substring(0,3).toLowerCase() == 'mac'){
//            cleanString = dirtyString.left(1).capitalize() + dirtyString.substring(1,3).toLowerCase() + dirtyString.substring(3,4).capitalize() + dirtyString.substring(4, dirtyString.length()).toLowerCase() ;
//        }else if( dirtyString.length() > 2 && dirtyString.substring(0,2).toLowerCase() == 'mc'){
//            cleanString = dirtyString.left(1).capitalize() + dirtyString.substring(1,2).toLowerCase() + dirtyString.substring(2,3).capitalize() + dirtyString.substring(3, dirtyString.length()).toLowerCase() ;
//        }

        else {
            cleanString = dirtyString.toLowerCase().capitalize();
        }

        return cleanString;
    }


}