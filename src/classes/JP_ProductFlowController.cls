/**
 * Created by lauren.lezberg on 1/8/2019.
 */

public without sharing class JP_ProductFlowController {

//    @AuraEnabled
//    public static JP_Helper.JPResponse saveProductData(Id stepId){
//
//        return new JP_Helper.JPResponse(true, 'Success', null);
//    }

//    private static List<OrderApi__Sales_Order_Line__c> getAllSalesOrderLines(String salesOrderId) {
//        return [SELECT Id, OrderApi__Item__r.OrderApi__Is_Subscription__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sale_Price__c, OrderApi__GL_Account__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];
//    }
//
//    private static List<OrderApi__Sales_Order_Line__c> getMembershipSalesOrderLines(String salesOrderId) {
//        return [SELECT Id, OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId AND (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name = 'Prior Year Dues')];
//
//    }

    @AuraEnabled
    public static void saveEmeritusDues(Boolean hasEmeritusDues, String salesOrderId){
        List<OrderApi__Sales_Order_Line__c> lines = ECRMUtils.getMembershipSalesOrderLines(salesOrderId);
        OrderApi__Item__c voluntaryAssessment = [SELECT Id, OrderApi__Price__c, Name, OrderApi__Line_Description__c FROM OrderApi__Item__c WHERE Name='Emeritus Voluntary Assessment' LIMIT 1];
        if(hasEmeritusDues){
            if(lines.size()!=2){
                //add emeritus dues
                insert new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrderId, OrderApi__Item__c=voluntaryAssessment.Id);
            }
        } else {
            if(lines.size()==2){
                //remove emeritus dues
                for(OrderApi__Sales_Order_Line__c line : lines){
                    if(line.OrderApi__Item__c == voluntaryAssessment.Id){
                        delete line;
                    }
                }
            }
        }
    }


    @AuraEnabled
    public static Map<Integer, Decimal> getMembershipPriceMap(String soID, String itemId){
        //get both prices for 1YR & 2YR and store
        Map<Integer, Decimal> priceMap = new Map<Integer, Decimal>();

        OrderApi__Item__c item = [SELECT Id, OrderApi__Price__c, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Id=:itemId ];
        if(item.OrderApi__Price__c!=0.0) {

            OrderApi__Sales_Order__c so = [SELECT OrderApi__Source_Code__c, OrderApi__Entity__c, OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id = :soID];
            //clone sales order
            OrderApi__Sales_Order__c dummySO = so.clone(false);
            insert dummySO;
            //add 1YR membership
            OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = dummySO.Id, OrderApi__Item__c = itemId);
            insert line;

            line = [SELECT OrderApi__Total__c FROM OrderApi__Sales_Order_Line__c WHERE Id = :line.Id];
            //add one year price
            priceMap.put(1, line.OrderApi__Total__c);


            //get 2 yr sub plan
            OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE OrderApi__Is_Active__c = true AND OrderApi__Advanced_Calendar_Days__c = 365 LIMIT 1];
//        ECRMUtils.changeSubscriptionTerm(subPlan.Id, dummySO.Id, String.valueOf(System.now().year()));
            line.OrderApi__Subscription_Plan__c = subPlan.Id;
            update line;

            line = [SELECT OrderApi__Total__c FROM OrderApi__Sales_Order_Line__c WHERE Id = :line.Id];

            //add 2 year price
            priceMap.put(2, line.OrderApi__Total__c);

            delete dummySO;
        }

        return priceMap;
    }



    @AuraEnabled
    public static MembershipData addNextMembershipTerm(String SOId, String activationYear, Integer subYears) {
        System.debug('adding next membership term with salesorder: ' + SOId + ' activationYear: ' + activationYear + ' and subYears ' + subYears);
        OrderApi__Sales_Order__c so = [SELECT Id, Is2YR__c FROM OrderApi__Sales_Order__c WHERE Id=: SOId];
        Integer advancedCalendarDays = subYears == 2 ? 365 : null;
        if(subYears == 2){
            advancedCalendarDays = 365;
            so.Is2YR__c = true;
        } else {
            so.Is2YR__c = false;
        }
        update so;

        List<OrderApi__Sales_Order_Line__c> membershipLine = [SELECT Id, OrderApi__Item__c
                                                                FROM OrderApi__Sales_Order_Line__c
                                                                WHERE OrderApi__Sales_Order__c = :SOId
                                                                AND OrderApi__Item_Class__r.Name = 'Individual Memberships'];

        OrderApi__Item_Subscription_Plan__c itemSubPlan = [SELECT Id, OrderApi__Subscription_Plan__c
                                                            FROM OrderApi__Item_Subscription_Plan__c
                                                            WHERE OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true
                                                            AND OrderApi__Item__c=: membershipLine[0].OrderApi__Item__c
                                                            AND OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c =: advancedCalendarDays
                                                            ORDER BY OrderApi__Subscription_Plan__r.Show_In_Portal__c DESC LIMIT 1];


        ECRMUtils.changeSubscriptionTerm(itemSubPlan.OrderApi__Subscription_Plan__c, SOId, activationYear);

        List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();

        lines = ECRMUtils.getMembershipSalesOrderLines(SOId);


        return new MembershipData(lines, null);
    }

    /** OFFER APP CODE **/
    @AuraEnabled
    public static MembershipData getMembershipData(String SOId, String stepId, String itemId){
        System.debug('getMembershipData with salesOrderId: ' + soId + ' and stepId: ' + stepId);
        Process_Steps__mdt ps = [SELECT Id, Process__r.Is_Renewal__c FROM Process_Steps__mdt WHERE Id=:stepId];

        List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();

        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        if(SOId!=null){ //sales order exists & is present in the url
            OrderApi__Sales_Order__c so = [SELECT OrderApi__Entity__c, Id, OrderApi__Source_Code__r.Name FROM OrderApi__Sales_Order__c WHERE Id=: SOId];
            OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE OrderApi__Is_Active__c = true AND OrderApi__Advanced_Calendar_Days__c = 365 LIMIT 1];
            System.debug('subscription Plan : ' + subPlan);

            lines = ECRMUtils.getMembershipSalesOrderLines(SOId);
            if(lines.size()==0){ //empty sales order aka OFFER
                OrderApi__Item__c item = [SELECT Id, OrderApi__Item_Class__c, OrderApi__Price__c FROM OrderApi__Item__c WHERE Id=:itemId];
                OrderApi__Sales_Order_Line__c membershipLine = JP_Helper.createSOLine(so, item, false);
                if(so.OrderApi__Source_Code__r.Name == 'BOGO'){
                    membershipLine.OrderApi__Subscription_Plan__c = subPlan.Id;
                    update membershipLine;
                }
                lines.add(membershipLine);

                //add blood cancer discovery journal
                OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Blood Cancer Discovery - Online'];
                OrderApi__Sales_Order_Line__c bloodCancerLine = new OrderApi__Sales_Order_Line__c(OrderApi__Subscription_Plan__c=membershipLine.OrderApi__Subscription_Plan__c, OrderApi__Sales_Order__c=SOId, OrderApi__Item__c=bloodCancerJournal.Id, OrderApi__Item_Class__c=bloodCancerJournal.OrderApi__Item_Class__c);
                lines.add(bloodCancerLine);



            }
//            else {
//                //if there is price change, we need to re-fire the price rule and then retrieve the new lines
//                update lines;
//            }

            lines = ECRMUtils.getMembershipSalesOrderLines(SOId);
        }

        return new MembershipData(lines, ps.Process__r.Is_Renewal__c);
    }


    /**
     * @purpose Look for salesorder lines that contain membership and prior dues, if none are found, create new sales order with membership
     *
     * @param SOId
     * @param stepId
     *
     * @return list of sales order lines containing membership and prior dues
     */
    @AuraEnabled
    public static MembershipData getProductData(String SOId, String stepId) {
        System.debug('getSOLines with salesorderId: ' + soId + ' and stepId: ' + stepId);
        Process_Steps__mdt ps = [SELECT Id, Process__r.Is_Renewal__c FROM Process_Steps__mdt WHERE Id=:stepId];
        List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();

        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        //if sales order id is present in url
        if (SOId != null) {
            //if there is price change, we need to re-fire the price rule and then retrieve the new lines
            lines = ECRMUtils.getMembershipSalesOrderLines(SOId);
            update lines;
            lines = ECRMUtils.getMembershipSalesOrderLines(SOId);
//            lines = [SELECT Id, OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: SOId AND (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name='Prior Year Dues')];
        } else {
            OrderApi__Sales_Order__c lastSO = JP_Helper.getMostRecentSO(u.ContactId);
            if (lastSO != null) {
                if (lastSO.OrderApi__Status__c == 'Open') {
                    lines = [SELECT OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, Id, OrderApi__Subscription_Plan__r.Name, OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :lastSO.Id AND (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name = 'Prior Year Dues')];
                } else {
                    Process_Steps__mdt step = [SELECT Process__r.Item__c, Process__r.Campaign_Code__c FROM Process_Steps__mdt WHERE Id = :stepId];
                    if (step.Process__r.Campaign_Code__c != null) {
                        OrderApi__Item__c item = [SELECT Id, OrderApi__Business_Group__c, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name = :step.Process__r.Item__c LIMIT 1];
                        Contact currentContact = [SELECT AccountId, Id FROM Contact WHERE Id = :u.ContactId LIMIT 1];
                        OrderApi__Sales_Order__c newSO = JP_Helper.createNewMemberSOWithLine(currentContact, item);

                        newSO.OrderApi__Description__c = 'Campaign Code: ' + step.Process__r.Campaign_Code__c;
                        update newSO;

                        lines = [SELECT Id, OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :newSO.Id AND (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name = 'Prior Year Dues')];
                    }

                }
            } else {
                Process_Steps__mdt step = [SELECT Process__r.Item__c, Process__r.Campaign_Code__c FROM Process_Steps__mdt WHERE Id = :stepId];
                OrderApi__Item__c item = [SELECT Id, OrderApi__Business_Group__c, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name = :step.Process__r.Item__c LIMIT 1];
                Contact currentContact = [SELECT AccountId, Id FROM Contact WHERE Id = :u.ContactId LIMIT 1];
                OrderApi__Sales_Order__c newSO = JP_Helper.createNewMemberSOWithLine(currentContact, item);
                if (step.Process__r.Campaign_Code__c != null) {
                    newSO.OrderApi__Description__c = 'Campaign Code: ' + step.Process__r.Campaign_Code__c;
                    update newSO;
                }

                lines = [SELECT Id, OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Item__c, OrderApi__Item__r.OrderApi__Line_Description__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Name, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :newSO.Id AND (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name = 'Prior Year Dues')];

            }
        }

        JP_Helper.upsertLastAccessedStep(stepId);
        return new MembershipData(lines, ps.Process__r.Is_Renewal__c);
    }


    public class MembershipData {
        @AuraEnabled
        public List<OrderApi__Sales_Order_Line__c> lines;

        @AuraEnabled
        public Map<Integer, Decimal> priceMap;

        @AuraEnabled
        public String salesOrderId;

        @AuraEnabled
        public Boolean canPurchaseNextYear;

        @AuraEnabled
        public OrderApi__Item__c voluntaryAssessment;

        public MembershipData(List<OrderApi__Sales_Order_Line__c> lines, Boolean isRenew) {
            this.voluntaryAssessment = [SELECT Id, OrderApi__Price__c, Name FROM OrderApi__Item__c WHERE Name='Emeritus Voluntary Assessment' LIMIT 1];
            this.lines = lines;
            if(!lines.isEmpty()) {
                this.salesOrderId = lines[0].OrderApi__Sales_Order__c;
            }
            this.canPurchaseNextYear = false;
            this.priceMap = new Map<Integer, Decimal>();

            Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
            if (renewalProcess.Is_Active__c) { //if renewals are turned on

                if (System.now().year() == renewalProcess.Term_Year__c - 1) { //if its one year before renewal term
                    List<OrderApi__Subscription__c> individualMemSubList = RenewalUtils.getIndividualMembershipSubscription(ECRMUtils.getCurrentLoginUserContactId());
                    if (individualMemSubList.isEmpty() || isRenew == false ) { // if contact has no existing membership subscriptions or its not a renewal
                        this.canPurchaseNextYear = true;
                    }
                }
                if(isRenew == false){
                    this.canPurchaseNextYear = true;
                }
                if(!lines.isEmpty()) {
                    this.priceMap = getMembershipPriceMap(lines[0].OrderApi__Sales_Order__c, lines[0].OrderApi__Item__c);
                }
            }
        }
    }


}