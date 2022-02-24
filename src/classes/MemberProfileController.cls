/**
 * Created by lauren.lezberg on 2/14/2019.
 */

public with sharing class MemberProfileController {
    public String contactId {get;set;}
    public Boolean ecAccess {get;set;}

    public MemberProfileController(){
        contactId = ECRMUtils.getCurrentLoginUserContactId();
        checkPermissions();
    }


    public void checkPermissions(){
        System.debug('contactId = ' + contactId);
        List<Community_Permission__c> cp = [SELECT Id FROM Community_Permission__c WHERE Contact__c =: contactId];
        System.debug('commPerm = ' + cp);
        if(!cp.isEmpty()) {
            ecAccess = true;
        }else{
            ecAccess = false;
        }
        System.debug('ec access = ' + ecAccess);

    }

    @AuraEnabled
    public static String getInvoicePaymentURL(String contactId){
        if(contactId!=null){
            OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c
                                            WHERE OrderApi__Contact__c=:contactId
                                            AND OrderApi__Status__c='Open'
                                            AND (Is_Transfer__c = true OR Is_Reinstatement__c = true)
                                            ORDER BY CreatedDate DESC
                                            LIMIT 1];
            return '/AACRPayment?salesOrder=' + so.Id;
        }

        return null;
    }
 
    @AuraEnabled
    public static MembershipData getMembershipData(){
        Contact currentContact = ECRMUtils.getCurrentLoginContact();

        //search for duplicates
        ECRMUtils.createDuplicateAlert(currentContact); 

        OrderApi__Subscription__c memSub;
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(currentContact.Id);
        if(!memSubs.isEmpty()){
            memSub = memSubs[0];
        }

        return new MembershipData(currentContact, memSub);
    }

    @AuraEnabled
    public static String cancelApplication(){
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        OrderApi__Sales_Order__c recentSO = JP_Helper.getMostRecentSO(currentContact.Id);
        if(recentSO!=null) {
            if (recentSO.OrderApi__Status__c == 'Open') {
                //find contact last access step
                List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :recentSO.Id AND OrderApi__Item_Class__r.Name = 'Individual Memberships'];
                Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE:'%' + lines[0].OrderApi__Item__r.Name + '%' AND Is_Renewal__c = false AND Campaign_Code__c = null LIMIT 1 ];
                contact_last_accessed_step__c las = [SELECT Step_Order__c, Join_Process__c FROM contact_last_accessed_step__c WHERE Contact__c = :currentContact.Id AND JoinId__c = :jp.Id];
                try {
                    currentContact.Application_Status__c = null;
                    update currentContact;
                    delete recentSO;
                    delete las;
                } catch (Exception e) {
                    System.debug('Error canceling application: ' + e.getMessage());
                    return null;
                }
            }
        }
        return '/apex/MembershipCategories';
    }

    public class MembershipData{

        @AuraEnabled
        public OrderApi__Subscription__c membership;

        @AuraEnabled
        public String membershipType;

        @AuraEnabled
        public String joinURL;

        @AuraEnabled
        public Id contactId;


        public MembershipData(Contact currentContact, OrderApi__Subscription__c membership){
            this.contactId = currentContact.Id;
            if(membership!=null) {
                this.membership = membership;
                this.membershipType = membership.OrderApi__Item__r.Name;
            } else {
                OrderApi__Sales_Order__c recentSO = JP_Helper.getMostRecentSO(currentContact.Id);
                if(recentSO!=null){
                    if (recentSO.OrderApi__Status__c == 'Open') {
                        List<OrderApi__Sales_Order_Line__c> membershipLines = [SELECT Id, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :recentSO.Id AND OrderApi__Item_Class__r.Name = 'Individual Memberships'];
                        if (membershipLines.size() == 1) {
                            this.membershipType = membershipLines[0].OrderApi__Item__r.Name;
                            Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%' + this.membershipType + '%' AND Is_Renewal__c = false AND Campaign_Code__c = null];
                            List<contact_last_accessed_step__c> las = [SELECT Step_Order__c, Join_Process__c, JoinId__c FROM contact_last_accessed_step__c WHERE Contact__c = :currentContact.Id AND JoinId__c =: jp.Id ];
                            if(!las.isEmpty()) {
                                this.joinURL = '/apex/JP_Container?id=' + las[0].JoinId__c + '&salesOrder=' + recentSO.Id;
                            } else {
                                this.joinURL = '/apex/MembershipCategories';
                            }
                        }
                    }
                }
            }
        }
    }

//    @AuraEnabled
//    public static RenewalData catchUpToCurrent(){
//        Contact UserContactData = ECRMUtils.getCurrentLoginContact();
//        DW_ECRMDTO.Response response = RenewalUtils.renewSubscriptions(UserContactData,false);
//
//        System.debug('response: ' + response);
//        if(response.isSuccess) {
//            DW_ECRMDTO.RenewDTO renewDTO = (DW_ECRMDTO.RenewDTO) JSON.deserialize(JSON.serialize(response.data), DW_ECRMDTO.RenewDTO.class);
//            return new RenewalData(renewDTO, response.message, response.isSuccess);
//        }
//        return new RenewalData(null, response.message, response.isSuccess);
//    }
//
//    @AuraEnabled
//    public static RenewalData renewSubscriptions(){
//        System.debug('renewSubscription was just called');
//        Contact UserContactData = ECRMUtils.getCurrentLoginContact();
//        //check for campaign code on contact record & get join id
//        String campaignId = UserContactData.Campaign_Code__c;
//
//        if(campaignId!=null){
//            DW_ECRMDTO.RenewDTO renewDTO = new DW_ECRMDTO.RenewDTO();
//            renewDTO.contactId = UserContactData.Id;
//            renewDTO.joinProcessURL = '/apex/BAMpaignRedirect?campaignId=' + campaignId;
//            return new RenewalData(renewDTO, null, true);
//        }
//
//
//        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
//        DW_ECRMDTO.Response response = RenewalUtils.renewSubscriptions(UserContactData, renewalProcess.Is_Active__c);
//
//        System.debug('response: ' + response);
//        if(response.isSuccess) {
//            DW_ECRMDTO.RenewDTO renewDTO = (DW_ECRMDTO.RenewDTO) JSON.deserialize(JSON.serialize(response.data), DW_ECRMDTO.RenewDTO.class);
//            //modify sales order if campaign id is not null
//            return new RenewalData(renewDTO, response.message, response.isSuccess);
////            JP_Helper.setCartCookies(ApexPages.currentPage(), renewDTO.salesOrderId);
////            String joinURL = renewDTO.joinProcessURL;
//        }
//        return new RenewalData(null, response.message, response.isSuccess);
//    }


//    public class RenewalData{
//        @AuraEnabled
//        public String joinURL;
//
//        @AuraEnabled
//        public String cookieName;
//
//        @AuraEnabled
//        public String userId;
//
//        @AuraEnabled
//        public String salesOrderId;
//
//        @AuraEnabled
//        public String message;
//
//        @AuraEnabled
//        public Boolean isSuccess;
//
//        public RenewalData(DW_ECRMDTO.RenewDTO renewDTO, String message, Boolean isSuccess){
//            if(renewDTO!=null) {
//                this.joinURL = renewDTO.joinProcessURL;
//                this.salesOrderId = renewDTO.salesOrderId;
//            }
//            this.message = message;
//            this.isSuccess = isSuccess;
//
//            this.userId = UserInfo.getUserId();
//            this.cookieName = UserInfo.getOrganizationId() + '-fonteva-shopping-cart';
//        }
//
//    }



}