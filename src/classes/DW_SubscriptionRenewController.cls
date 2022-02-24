/**
 *@Class Name   : DW_SubscriptionRenewController
 *@Purpose      : Controller for DW_SubscriptionRenew Page
 *@Created Date : 08-10-2018
 *@Modified Date: 08-10-2018
 */
public class DW_SubscriptionRenewController {
    public String salesOrderId {get;set;}
    public String duesOnlyRenewalUrl {get;set;}
    public String joinProcessRenewalUrl {get;set;}

    public DW_SubscriptionRenewController(){
        salesOrderId = ApexPages.currentPage().getParameters().get('salesOrder');
        setCartCookies();
        getRenewItem(salesOrderId);
//        setDuesOnlyRenewalUrl();
    }

    /**
     * @Purpose : Remove sales order lines for membership renewal and only leave prior dues
     * @Param:
     * @Return :
     */
    public void removeRenewalLinesFromSO(){
        List<OrderApi__Sales_Order_Line__c> SOLines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: salesOrderId AND OrderApi__Item_Class__r.Name != 'Prior Year Dues'];
        delete SOLines;
        setCartCookies();
    }

    /**
     * @Purpose : Gets join process url from custom metadata type and sets duesOnlyRenewalUrl variable
     * @Param:
     * @Return :
     */
//    private void setDuesOnlyRenewalUrl(){
//        List<joinapi__Join_Process__c> joins = [SELECT Id, joinapi__Landing_Url__c FROM joinapi__Join_Process__c WHERE joinapi__Join_Process_Display_Name__c = 'Pay Dues Only' LIMIT 1];
//        if(joins.size()==1){
//            duesOnlyRenewalUrl = joins[0].joinapi__Landing_Url__c;
//        } else {
//            duesOnlyRenewalUrl = ApexPages.currentPage().getUrl();
//        }
//    }

    /**
     *@Purpose : Set fonteva-shopping-cart cookie for dues to appear in shopping cartvisual
     *@Param   :
     *@return  :
     */
    public void setCartCookies(){
        Map<String, Object> fontevaCartExistingCookie = new Map<String, Object>();
        String cookieName = UserInfo.getOrganizationId() + '-fonteva-shopping-cart';

        if (ApexPages.currentPage().getCookies().get(cookieName) != null) {
            fontevaCartExistingCookie = (Map<String, Object>) JSON.deserializeUntyped(ApexPages.currentPage().getCookies().get(cookieName).getValue());
        }
        fontevaCartExistingCookie.put('userId', UserInfo.getUserId());
        fontevaCartExistingCookie.put('salesOrderId', salesOrderId);
        Cookie fontevaCartUpdatedCookie = new Cookie(cookieName, JSON.serialize(fontevaCartExistingCookie), null, -1, true);
        ApexPages.currentPage().setCookies(new Cookie[]{fontevaCartUpdatedCookie});
    }

    /**
     *@Purpose : Getting Renew item
     *@Param   :
     *@return  : Response
     */
    public DW_ECRMDTO.Response getRenewItem(Id salesOrderId){
        DW_ECRMDTO.Response response;

        // Getting sales order LI
        OrderApi__Sales_Order_Line__c salesOrderLI = getSalesOrderLIs(salesOrderId);

        if(salesOrderLI != NULL){
            //OrderApi__Item__c item = getItem(salesOrderLI.OrderApi__Item__c);
            // DW_ECRMDTO.RenewDTO renewDTO = createRenewDTO(item, salesOrderId);
            DW_ECRMDTO.RenewDTO renewDTO = createRenewDTO(salesOrderLI, salesOrderId);
            response = new DW_ECRMDTO.Response(true, 'SUCCESS', renewDTO);
        }else{
            response = new DW_ECRMDTO.Response(false, 'Failure', NULL);
        }
        return response;
    }
    /**
     *@Purpose : Getting Sales Order LIs
     *@Param   :
     *@return  :
     */
    public OrderApi__Sales_Order_Line__c getSalesOrderLIs(Id salesOrderId){

        OrderApi__Sales_Order_Line__c salesOrderLI;
        try{
            salesOrderLI = [SELECT Id, OrderApi__Item_Class__r.Name, OrderApi__Item__c, OrderApi__Sale_Price__c, OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Description__c
            FROM OrderApi__Sales_Order_Line__c
            WHERE OrderApi__Sales_Order__c =: salesOrderId AND
            OrderApi__Item_Class__r.Name = 'Prior Year Dues' LIMIT 1];
        }catch(Exception exp){
            System.debug('Exception Occured While inserting Sales Order LIs:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return salesOrderLI;
    }

    /**
     *@Purpose : Create RenewDTO record
     *@Param   : contactId
     *@return  :
     */
    public DW_ECRMDTO.RenewDTO createRenewDTO(OrderApi__Sales_Order_Line__c item, Id salesOrderId){
        // getting join process landing URL
        joinProcessRenewalUrl = DW_ECRMUtils.getJoinProcessURL(salesOrderId);
        joinProcessRenewalUrl += '&isRenew=true';

        DW_ECRMDTO.RenewDTO renewDTO = new DW_ECRMDTO.RenewDTO();
        renewDTO.item = item;
        renewDTO.joinProcessURL = String.isNotBlank(joinProcessRenewalUrl) ? joinProcessRenewalUrl : '';

        return renewDTO;
    }


//     /**
//      *@Purpose : Getting Renew item
//      *@Param   :
//      *@return  : Response
//      */
//    @RemoteAction
//    public static DW_ECRMDTO.Response getRenewItem(Id salesOrderId){
//        DW_ECRMDTO.Response response;
//
//        // Getting sales order LI
//        OrderApi__Sales_Order_Line__c salesOrderLI = getSalesOrderLIs(salesOrderId);
//
//        if(salesOrderLI != NULL){
//            //OrderApi__Item__c item = getItem(salesOrderLI.OrderApi__Item__c);
//            // DW_ECRMDTO.RenewDTO renewDTO = createRenewDTO(item, salesOrderId);
//            DW_ECRMDTO.RenewDTO renewDTO = createRenewDTO(salesOrderLI, salesOrderId);
//            response = new DW_ECRMDTO.Response(true, 'SUCCESS', renewDTO);
//        }else{
//            response = new DW_ECRMDTO.Response(false, 'Failure', NULL);
//        }
//        return response;
//    }
//     /**
//      *@Purpose : Getting Sales Order LIs
//      *@Param   :
//      *@return  :
//      */
//    public static OrderApi__Sales_Order_Line__c getSalesOrderLIs(Id salesOrderId){
//
//        OrderApi__Sales_Order_Line__c salesOrderLI;
//        try{
//          salesOrderLI = [SELECT Id, OrderApi__Item_Class__r.Name, OrderApi__Item__c, OrderApi__Sale_Price__c, OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Description__c
//                          FROM OrderApi__Sales_Order_Line__c
//                          WHERE OrderApi__Sales_Order__c =: salesOrderId AND
//                                OrderApi__Item_Class__r.Name = 'Prior Year Dues' LIMIT 1];
//        }catch(Exception exp){
//            System.debug('Exception Occured While inserting Sales Order LIs:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
//        }
//        return salesOrderLI;
//    }
//
//    /**
//     *@Purpose : Create RenewDTO record
//     *@Param   : contactId
//     *@return  :
//     */
//    public static DW_ECRMDTO.RenewDTO createRenewDTO(OrderApi__Sales_Order_Line__c item, Id salesOrderId){
//         // getting join process landing URL
//        String joinProcessURL = DW_ECRMUtils.getJoinProcessURL(salesOrderId);
////        joinProcessRenewalUrl = joinProcessURL;
//
//        DW_ECRMDTO.RenewDTO renewDTO = new DW_ECRMDTO.RenewDTO();
//        renewDTO.item = item;
//        renewDTO.joinProcessURL = String.isNotBlank(joinProcessURL) ? joinProcessURL : '';
//
//        return renewDTO;
//    }
    
//    /**
//     *@Purpose : get Item
//     *@Param   : itemId
//     *@return  :
//     */
//    public static OrderApi__Item__c getItem(Id itemId){
//        OrderApi__Item__c item;
//        try{
//            item = [SELECT Id, Name, OrderApi__Price__c, Fon_Association_Journal_Type__c, OrderApi__Item_Class__r.Name,
//                           OrderApi__Description__c
//                    FROM OrderApi__Item__c
//                    WHERE Id =: itemId];
//        }
//        catch(Exception exp){
//            System.debug('Exception Occured While fetching Join Process :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
//        }
//        return item;
//    }
}