/**
 *@Class Name   : DW_SubscriptionsController
 *@Purpose      : Controller for DW_Subscriptions Page
 *@Created Date : 08-10-2018
 *@Modified Date: 08-10-2018
 */
public class DW_SubscriptionsController {
    // Get and Set conatct record
    public Contact UserContactData { get; set; }
    public String rType { get; set;}
    public String mStatus { get; set;}
    public String mType { get; set;}
    public Boolean nonMember { get; set;}
    public Boolean memberCurrent { get; set;}
    public Boolean memberSuspended { get; set;}
    public Boolean noAccess { get; set;}
    public Boolean showRenew {get;set;}
    public String joinURL {get;set;}

    private Maintenance_Mode_Config__mdt renewal {get; set;}

    //NOT USED
    public static Boolean memberYear { get; set;}
    public static Boolean memberComplete { get; set;}
    public static Boolean memberIncomplete { get; set;}
    public static Boolean prior { get; set; }

    public DW_SubscriptionsController() {
        System.debug('DW_Subscriptions controller init');
        UserContactData = DW_ECRMUtils.getCurrentLoginContact();
        getSiteConfigurations();
        getMembership();
        setBecomeAMemberURL();

    }

    private void getSiteConfigurations(){
        List<Maintenance_Mode_Config__mdt> configs = [SELECT Id, Is_Active__c FROM Maintenance_Mode_Config__mdt WHERE Label = 'Renewal Process Activation'];
        if(configs.size() == 1){
            renewal = configs[0];
        } else {
            renewal = null;
        }
    }

    public void getMembership(){
        System.debug('getMembership being called');
        rType = UserContactData.RecordType.Name;
        System.debug('rType: ' + rType);
        mStatus = UserContactData.Membership_Status__c;
        System.debug('mStatus: ' + mStatus);
        mType = UserContactData.Member_Type__c;
        System.debug('mType: ' + mType);

        if(rType=='Nonmember'){
            nonMember  = true;
        } else if ((rType == 'Prior Member' && (mStatus == 'Suspended (Delinquent)' || mStatus == 'Suspended (Resigned)')) || (rType=='Member' && mType=='Student Member' && mStatus == 'Ineligible')){
            memberSuspended = true;
        } else if ((rType == 'Member' && mStatus =='Current') || (rType == 'Prior Member' && mStatus=='1-YR Suspended' || mStatus == '2-YR Suspended')){
            if(UserContactData.Paid_thru_date__c!=null && renewal!=null){
                memberCurrent = true;
                if((UserContactData.Paid_thru_date__c.year() < System.now().year()) && renewal.Is_Active__c){
                    showRenew = true;
                } else {
                    showRenew = false;
                }
                System.debug('showRenew: ' + showRenew);
            }  else {
                System.debug('User has no paid through date');
                noAccess = true;
            }
        } else {
            noAccess = true;
        }
    }

    private void setBecomeAMemberURL(){
        List<joinapi__Join_Process__c> joins = [SELECT Id, joinapi__Landing_Url__c FROM joinapi__Join_Process__c WHERE joinapi__Join_Process_Display_Name__c = 'Become a Member' LIMIT 1];
        System.debug('joins: ' + joins);
        if(joins.size()==1){
            joinURL = joins[0].joinapi__Landing_Url__c;
        } else {
            joinURL = ApexPages.currentPage().getUrl();
        }
        System.debug('joinURL: ' + joinURL);
    }

//    /**
//     *@Purpose : Renew Subscription and redirect to correct join process
//     *@Param   : -
//     *@return  : Response data
//     */
//    public PageReference renewSubscription() {
//        DW_ECRMDTO.Response response = DW_SubscriptionsControllerHelper.renewSubscription(UserContactData);
//        if(response.isSuccess) {
//            DW_ECRMDTO.RenewDTO renewDTO = (DW_ECRMDTO.RenewDTO) JSON.deserialize(JSON.serialize(response.data), DW_ECRMDTO.RenewDTO.class);
//            JP_Helper.setCartCookies(ApexPages.currentPage(), renewDTO.salesOrderId);
//            PageReference pageRef = new PageReference(renewDTO.joinProcessURL);
//            return pageRef;
//        }
//        return null;
//    }

    
    /**
     *@Purpose : Getting Subscriptions page details
     *@Param   : -
     *@return  : Response data
     */
    @RemoteAction
    public static DW_ECRMDTO.Response getSubscriptionDetails() {
        return DW_SubscriptionsControllerHelper.getSubscriptionDetails();
    }

    /**
     *@Purpose : Renew Subscription plan
     *@Param   : -
     *@return  : Response data
     */
    @RemoteAction
    public static DW_ECRMDTO.Response renewSubscriptionPlan() {
        return DW_SubscriptionsControllerHelper.renewSubscriptionPlan();
    }

    /**
     *@Purpose : update contact's journal Address
     *@Param   : -
     *@return  : -
     */
    @RemoteAction
    public static DW_ECRMDTO.Response updateContactsJournalAddr(DW_ECRMDTO.ContactDTO contactDTORecord) {
        if (contactDTORecord != NULL) {
            return DW_SubscriptionsControllerHelper.updateContactsJournalAddr(contactDTORecord);
        }
        return new DW_ECRMDTO.Response(false, 'FAIL', NULL);
    }
    

}