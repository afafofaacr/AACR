/**
 *@Class Name   : DW_ECRMController
 *@Purpose      : Controller for DW_OptionalItems, DW_WorkingGroups, DW_JournalSubscription pages
 *@Created Date : 27-07-2018
 *@Modified Date: 19-09-2018
 */
public class DW_ECRMController {
    // to store Item class names
    public static Set<String> itemClassNamesSet;
    // Get and Set conatct record
    public Contact UserContactData{get; set;}
    
    public DW_ECRMController(){
        UserContactData = DW_ECRMHelper.getCurrentLoginContact();
    }
     /**
      *@Purpose : Getting Working Groups
      *@Param   : isRenewal
      *@return  : Response data
      */ 
    @RemoteAction
    public static DW_ECRMDTO.Response getWorkingGroups(Boolean isRenewal, String salesOrderId, String stepId, String type){
        
        itemClassNamesSet = new Set<String>();
        
        // Adding class names from custom setting.
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('Working Groups'));
        
        // IF itemClassNamesSet is not empty
        IF(! itemClassNamesSet.isEmpty()){
            return DW_ECRMHelper.getItemsOfSpecificClass(itemClassNamesSet, isRenewal, salesOrderId, stepId,type);
        }
        return new DW_ECRMDTO.Response(false, 'FAIL', NULL);
    }
    
    /**
      *@Purpose : Getting journal items
      *@Param   : isRenewal
      *@return  : Response data
      */ 
    @RemoteAction
    public static DW_ECRMDTO.Response getJournals(Boolean isRenewal, String salesOrderId, String stepId){
        itemClassNamesSet = new Set<String>();
        
        // Adding class names from custom setting.
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('Complimentary Journals'));
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('Journal Subscriptions'));
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('ZDecline of the Journals'));
        
        // IF itemClassNamesSet is not empty
        if(! itemClassNamesSet.isEmpty()){
            return DW_ECRMHelper.getItemsOfSpecificClass(itemClassNamesSet, isRenewal, salesOrderId, stepId, NULL);
        }
        return new DW_ECRMDTO.Response(false, 'FAIL', NULL);
    }
    
     /**
      *@Purpose : Getting optional items
      *@Param   : -
      *@return  : Response data
      */ 
    @RemoteAction
    public static DW_ECRMDTO.Response getOptionalItems(String stepId){
        
        itemClassNamesSet = new Set<String>();
        
        // Adding class names from custom setting.
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('Merchandise'));
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('Legacy Items'));
        
        // IF itemClassNamesSet is not empty
        if(! itemClassNamesSet.isEmpty()){
            return DW_ECRMHelper.getItemsOfSpecificClass(itemClassNamesSet,false,null,stepId, null);
        }
        return new DW_ECRMDTO.Response(false, 'FAIL', NULL);
    }
    
     /**
      *@Purpose : Updating Contact Last accessed Step
      *@Param   : currentStepId
      *@return  : Response data
      */ 
    @RemoteAction
    public static DW_ECRMDTO.Response updateContactLastAccessedStep(String currentStepId){
        if(String.isNotBlank(currentStepId)){
            // Upsert contact Last accessed step                                                                    
            DW_ECRMUtils.upsertContLastAccessedStep(currentStepId);
            return new DW_ECRMDTO.Response(true,'SUCCESS', NULL); 
        }
        return new DW_ECRMDTO.Response(false,'FAIL', NULL); 
    }
    
     /**
      *@Purpose : Create sales order line items
      *@Param   : salesOrderId, itemList to insert, className, itemList to delete, isJournalAddrSameAsPreferedAddr, currentStepId
      *@return  : Response data
      */ 
    @RemoteAction
    public static DW_ECRMDTO.Response createSalesOrderLines(String salesOrderId,
                                                            List<DW_ECRMDTO.ItemDTO> itemsToInsertList, 
                                                            String className, 
                                                            List<DW_ECRMDTO.ItemDTO> itemsToDeleteList,
                                                            Boolean isJournalAddrSameAsPreferedAddr,
                                                            String currentStepId
                                                            ){
        // if salesOrderId, className, itemList not Null or empty
        if(String.isNotBlank(salesOrderId) || ! itemsToInsertList.isEmpty() || String.isNotBlank(className)){
            return DW_ECRMHelper.createNDeleteSalesOrderLineItems(salesOrderId, itemsToInsertList, className, 
                                                                  itemsToDeleteList,
                                                                  isJournalAddrSameAsPreferedAddr,
                                                                  currentStepId);
        }
        return new DW_ECRMDTO.Response(false,'FAIL', NULL); 
    }
    
    /**
     *@Purpose : update contact's journal Address
     *@Param   : -
     *@return  : -
     */
    public void updateContactsJournalAddr(){
        // Update contact
        try{
            update UserContactData;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Journal Address Updated Successfully.!'));
        }
        catch(Exception exp){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
        }
    }
    
}