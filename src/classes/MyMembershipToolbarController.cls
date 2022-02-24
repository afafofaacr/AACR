/**
 * Created by lauren.lezberg on 4/15/2021.
 */

public with sharing class MyMembershipToolbarController {

    @AuraEnabled
    public static String catchUpToCurrent() {
        Contact UserContactData = ECRMUtils.getCurrentLoginContact();
        DW_ECRMDTO.Response response = RenewalUtils.renewSubscriptions(UserContactData, false);

        System.debug('response: ' + response);
        if (response.isSuccess) {
            DW_ECRMDTO.RenewDTO renewDTO = (DW_ECRMDTO.RenewDTO) JSON.deserialize(JSON.serialize(response.data), DW_ECRMDTO.RenewDTO.class);
            return renewDTO.joinProcessURL;
        }
        return null;
    }

    @AuraEnabled
    public static String startRecertification() {
        Contact UserContactData = ECRMUtils.getCurrentLoginContact();
        List<OrderApi__Subscription__c> individualMemSubList = RenewalUtils.getIndividualMembershipSubscription(UserContactData.Id);
        if (!individualMemSubList.isEmpty()) {
            //build renewal sales order
            DW_ECRMDTO.Response response = RenewalUtils.renewSubscriptions(UserContactData, false);
            if (response.isSuccess) {
                DW_ECRMDTO.RenewDTO renewDTO = (DW_ECRMDTO.RenewDTO) JSON.deserialize(JSON.serialize(response.data), DW_ECRMDTO.RenewDTO.class);
                String redirectURL = renewDTO.joinProcessURL;

                return redirectURL;
            }
        }

        return null;
    }

    @AuraEnabled
    public static String startReinstatement() {
        Contact UserContactData = ECRMUtils.getCurrentLoginContact();
        List<OrderApi__Subscription__c> individualMemSubList = RenewalUtils.getIndividualMembershipSubscription(UserContactData.Id);
        if (!individualMemSubList.isEmpty()) {
            //start application
            String salesOrderId = ECRMUtils.startMembershipApplication(individualMemSubList[0].OrderApi__Item__c);
            OrderApi__Sales_Order__c so = [SELECT Is_Reinstatement__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
            so.Is_Reinstatement__c = true;
            update so;

            Join_Process__mdt jp;
            if (individualMemSubList[0].OrderApi__Item__r.Name.contains('Student')) {
                jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Recertify_Student'];
            } else {
                jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Transfer_General'];
            }


            Decimal lastStepOrder = JP_Helper.getLastAccessedStepOrder(jp.Id);
            if (lastStepOrder != null) {
                if (lastStepOrder != 0) {
                    contact_last_accessed_step__c las = [SELECT Id FROM contact_last_accessed_step__c WHERE JoinId__c = :jp.Id AND Contact__c = :UserContactData.Id];
                    delete las;
                }
            }

            String redirectURL = '/apex/JP_Container?id=' + jp.Id + '&salesOrder=' + salesOrderId + '&isInvoice=true';

            return redirectURL;
        } else {
            return '/MembershipCategories';
        }
    }

    @AuraEnabled
    public static String renewSubscriptions() {
        System.debug('renewSubscription was just called');
        Contact UserContactData = ECRMUtils.getCurrentLoginContact();
        //check for campaign code on contact record & get join id
        String campaignId = UserContactData.Campaign_Code__c;

        if (campaignId != null) {
            return '/apex/BAMpaignRedirect?campaignId=' + campaignId;
        }


        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
        DW_ECRMDTO.Response response = RenewalUtils.renewSubscriptions(UserContactData, renewalProcess.Is_Active__c);

        System.debug('response: ' + response);
        if (response.isSuccess) {
            DW_ECRMDTO.RenewDTO renewDTO = (DW_ECRMDTO.RenewDTO) JSON.deserialize(JSON.serialize(response.data), DW_ECRMDTO.RenewDTO.class);
            //modify sales order if campaign id is not null
            return renewDTO.joinProcessURL;
//            JP_Helper.setCartCookies(ApexPages.currentPage(), renewDTO.salesOrderId);
//            String joinURL = renewDTO.joinProcessURL;
        }
        return null;
    }

    @AuraEnabled
    public static MembershipActions getMembershipActions() {
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        List<OrderApi__Subscription__c> membershipSubs = RenewalUtils.getIndividualMembershipSubscription(currentContact.Id);
        return new MembershipActions(currentContact, membershipSubs[0]);
    }

    public class MembershipActions {
        @AuraEnabled
        public Boolean canRenew;

        @AuraEnabled
        public Boolean renewalsOpen;

        @AuraEnabled
        public Boolean canCatchUp;

        @AuraEnabled
        public Boolean canTransfer;

        @AuraEnabled
        public Boolean canReinstate;

        @AuraEnabled
        public Boolean canReinstateTransfer;

        @AuraEnabled
        public Boolean pendingApproval;

        @AuraEnabled
        public Boolean canRecertify;

        @AuraEnabled
        public Boolean noOperations;


        public MembershipActions(Contact currentContact, OrderApi__Subscription__c membership) {
            this.canRenew = RenewalUtils.canRenew(currentContact.Id);
            Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
            this.canCatchUp = this.canRenew && (Integer) renewalProcess.Term_Year__c - 1 == System.now().year() && membership.OrderApi__Current_Term_End_Date__c.year() < renewalProcess.Term_Year__c - 1;
            this.renewalsOpen = renewalProcess.Is_Active__c;
            this.canTransfer = currentContact.RecordType.Name == 'Member' && currentContact.Membership_Status__c == 'Current' && membership.OrderApi__Item__r.Show_In_Portal__c == true && membership.OrderApi__Subscription_Plan__r.Name!='Lifetime';
            this.canReinstate = membership.OrderApi__Is_Active__c == false && currentContact.RecordType.Name == 'Prior Member' && (currentContact.Membership_Status__c == 'Suspended (Delinquent)' || currentContact.Membership_Status__c == 'Suspended (Resigned)' || currentContact.Membership_Status__c == 'Ineligible');
            this.canReinstateTransfer = this.canReinstate;
            this.pendingApproval = currentContact.Application_Status__c == 'Pending Transfer' || currentContact.Application_Status__c == 'Pending Reinstatement' || currentContact.Application_Status__c == 'Pending Reinstatement-Transfer';
            this.canRecertify = getCanRecertify(currentContact,membership);
            this.noOperations = checkForNoOperations(membership, this.canRecertify, this.canReinstate, this.canTransfer, this.canRenew, this.canCatchUp);

        }

        public Boolean checkForNoOperations(OrderApi__Subscription__c membership, Boolean canRecertify, Boolean canReinstate, Boolean canTransfer, Boolean canRenew, Boolean canCatchUp){
            Boolean noOperations = false;

            if(membership.OrderApi__Item__r.Show_In_Portal__c == false || membership.OrderApi__Subscription_Plan__r.Name=='Lifetime' || (!canRecertify && !canReinstate && !canTransfer && !canRenew && !canCatchUp)){
                noOperations = true;
            }

            return noOperations;
        }



        public Boolean getCanRecertify(Contact currentContact, OrderApi__Subscription__c membership) {
            Boolean canRecertify = false;
            //if membership is student or associate, active and within grace period
            if(currentContact.Application_Status__c!='Deferred') {
                if (!membership.OrderApi__Item__r.Managed__c && (membership.OrderApi__Item__r.Name.contains('Student') || membership.OrderApi__Item__r.Name.contains('Associate'))) {
                    if (membership.OrderApi__Is_Active__c) {
//                        if (membership.OrderApi__In_Grace_Period__c) {
                            //students can only recertify if their graduation year is the upcoming year
                            if(membership.OrderApi__Item__r.Name.contains('Student')){
                                if(currentContact.Expected_Completion_Date__c.year() == System.now().year()+1){
                                    canRecertify = true;
                                }
                            } else {
                                if(membership.OrderApi__Paid_Through_Date__c.year() == System.now().year()) {
                                    canRecertify = true;
                                }
                            }
//                        }
                    }
                }
            }
            return canRecertify;
        }


    }
}