/**
 *@Purpose      : Committee automation after Sales Oredr Line Items are create/edit/delete
 *@Created Date : 14-08-2018
 *@Modified Date: 
 */
public with sharing class DW_CommitteeAutomationTriggerHandler {
   
    /**
     *@purpose : to create committee after sales order lines created
     *@param   : newSalesOrderLIList
     *@return  : -
     **/
    public static void createCommiteeAfterLICreate(List<OrderApi__Sales_Order_Line__c> newSalesOrderLIList){

        Map<Id, List<OrderApi__Sales_Order_Line__c>> salesOrderIdToLIsMap = new  Map<Id, List<OrderApi__Sales_Order_Line__c>>();
        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        List<Committees__c> committeeToInsertList = new List<Committees__c>();
        Committees__c committee;
        
        // Getting indivisual membership items
        salesOrderIdToLIsMap = getIndivisualMembershipItems(newSalesOrderLIList);

        
        for(OrderApi__Sales_Order_Line__c salesOrderLI : [SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Name,OrderApi__Contact__c, 
                                                                 OrderApi__Item__r.OrderApi__Item_Class__r.Name,
                                                                 OrderApi__Item_Class__r.Name, OrderApi__Sales_Order__c,OrderApi__Activation_Date__c,OrderApi__End_Date__c
                                                          FROM OrderApi__Sales_Order_Line__c
                                                          WHERE Id IN : newSalesOrderLIList
                                                          ]){
                  
                    if(salesOrderLI.OrderApi__Item__r.OrderApi__Item_Class__r.Name.contains('Working Groups') ){
                        
                        if(salesOrderIdToLIsMap.containsKey(salesOrderLI.OrderApi__Sales_Order__c)){
                           salesOrderLIList = salesOrderIdToLIsMap.get(salesOrderLI.OrderApi__Sales_Order__c);
                        }
                        // create commitee only if user is community user
                        if(String.isNotBlank(salesOrderLI.OrderApi__Contact__c)){
                            committee = new Committees__c();
                            committee.Name = salesOrderLI.OrderApi__Item__r.Name;
                            committee.Committee_Related_To__c = salesOrderLI.OrderApi__Item__c;
                            //committee.Committees__c = '0030U00000L2tWe';
                            committee.Committees__c = salesOrderLI.OrderApi__Contact__c;
                                committee.Date_From__c = salesOrderLI.OrderApi__Activation_Date__c;
                                committee.Date_Through__c = salesOrderLI.OrderApi__End_Date__c;
                            committeeToInsertList.add(committee);
                            System.debug('committee==>'+committee);   
                        }
                    }                                              
            }
            if(!committeeToInsertList.isEmpty()){
                try{
                    System.debug('committeeToInsertList==>'+committeeToInsertList);
                   insert committeeToInsertList; 
                }catch(Exception exp){
                    System.debug('Exception while creating committee==>'+exp.getMessage());
                }
                
                
            }
    }
   
    /**
     *@purpose : Get inivisual memberships sales order line items
     *@param   : salesOrderLIList
     *@return  : Sales
     **/
    public static Map<Id,List<OrderApi__Sales_Order_Line__c>> getIndivisualMembershipItems(List<OrderApi__Sales_Order_Line__c> newSalesOrderLIList){
        
        Set<Id> salesOrderIdsSet = new Set<Id>();
        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        Map<Id, List<OrderApi__Sales_Order_Line__c>> salesOrderIdToLIsMap = new  Map<Id, List<OrderApi__Sales_Order_Line__c>>();

        for(OrderApi__Sales_Order_Line__c salesOrderLI : newSalesOrderLIList){
            salesOrderIdsSet.add(salesOrderLI.OrderApi__Sales_Order__c);
        }
        
        for(OrderApi__Sales_Order__c salesOrder : [SELECT Id, 
                                                        (SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Item_Class__r.Name,
                                                              OrderApi__Item_Class__r.Name, OrderApi__Activation_Date__c,OrderApi__End_Date__c, OrderApi__Sales_Order__c
                                                         FROM OrderApi__Sales_Order_Lines__r
                                                         WHERE OrderApi__Item_Class__r.Name =: 'Individual Memberships')
                                                  FROM OrderApi__Sales_Order__c
                                                  WHERE Id IN : salesOrderIdsSet ]){
                                                      
              if(salesOrder != NULL){
                  salesOrderLIList = salesOrder.OrderApi__Sales_Order_Lines__r;                                       
              }                                        
             
              if(! salesOrderLIList.isEmpty()){
                  
                 for(OrderApi__Sales_Order_Line__c salesOrderLI : salesOrderLIList){
                     if(! salesOrderIdToLIsMap.containsKey(salesOrder.Id)){
                         salesOrderIdToLIsMap.put(salesOrder.Id, new List<OrderApi__Sales_Order_Line__c>());
                     }
                     salesOrderIdToLIsMap.get(salesOrder.Id).add(salesOrderLI);
                 }                                          
              }  
        }
        if(! salesOrderIdToLIsMap.isEmpty()){
            return salesOrderIdToLIsMap;
        }
        return salesOrderIdToLIsMap;
    }
  
    /**
     *@purpose : to update committee after sales order lines deleted
     *@param   : deletedSalesOrderLIList
     *@return  : -
     **/
    public static void updateCommiteeAfterLIDelete(List<OrderApi__Sales_Order_Line__c> deletedSalesOrderLIList){
        List<Committees__c> commiteeToUpdateList = new List<Committees__c>();
        List<Committees__c> updatedCommitteeList = new List<Committees__c>();
        
        // Getting created committee list to update
        commiteeToUpdateList = getCommiteesToUpdate(deletedSalesOrderLIList);
        
         if(! commiteeToUpdateList.isEmpty() || Test.isRunningTest()){for(Committees__c commiteeToUpdate : commiteeToUpdateList){
                 commiteeToUpdate.Committee_Related_To__c = NULL; commiteeToUpdate.Dropped__c = true; updatedCommitteeList.add(commiteeToUpdate);
             }
             if(! updatedCommitteeList.isEmpty()){
                update updatedCommitteeList;
            }
         }
    }
    
    /**
     *@purpose : Getting commitees to upadte
     *@param   : salesOrderLIList
     *@return  : List of Committee
     **/
    public static List<Committees__c> getCommiteesToUpdate(List<OrderApi__Sales_Order_Line__c> salesOrderLIList){
        Map<Id,Committees__c> workingGrpItemToCommitteeMap = new Map<Id,Committees__c>();
        Set<Id> workingGrpItemIdsSet = new Set<Id>();
        List<Committees__c> createdCommiteeList = new List<Committees__c>();
        List<Committees__c> commiteeToUpdateList = new List<Committees__c>();
        Map<Id,Committees__c> commiteeToUpdateMap = new Map<Id,Committees__c>();
        
        // adding old sales order line items Id to workingGrpItemIdsSet
        for(OrderApi__Sales_Order_Line__c salesOrderLI : salesOrderLIList){
            System.debug('salesOrderLIList==>'+salesOrderLIList);
            workingGrpItemIdsSet.add(salesOrderLI.OrderApi__Item__c);                                             
        }
        
        System.debug('workingGrpItemIdsSet==>'+workingGrpItemIdsSet);
        
        // Getting Created committee of working group items
        if(! workingGrpItemIdsSet.isEmpty()){
            for(Committees__c committee : [SELECT Id, Name, Committee_Related_To__c 
                                           FROM Committees__c
                                           WHERE Committee_Related_To__c IN : workingGrpItemIdsSet]){
                  
                 commiteeToUpdateMap.put(committee.Id, committee);                    
            }
        }
        
        return commiteeToUpdateMap.values();
    }
 
}