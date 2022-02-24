/**************************************************************************************************************************************************************************************************************************************************************
Name            :-  Fon_TransactionTrigger
Created Date    :-  05/15/2018
Updated Date    :-  
Created By      :-  Arpita Munjal
Dependencies    :-  
Description     :-  Trigger on Transaction to split Revenue
**************************************************************************************************************************************************************************************************************************************************************/

global class Fon_TransactionTrigger extends Framework.Domain{

    public Fon_TransactionTrigger(List<OrderApi__Transaction__c > sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_TransactionTrigger(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(Fon_TransactionTrigger.class.getName(),'beforeInsert');
         
        Framework.Log.pop();
    }
    public override void afterInsert(){
        Framework.Log.push(Fon_TransactionTrigger.class.getName(),'afterInsert');
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Fon_TransactionTrigger.class.getName(),'afterUpdate');

        List<OrderApi__Transaction_Line__c> lines = [SELECT Id, Plan__c FROM OrderApi__Transaction_Line__c WHERE (OrderApi__Credit__c =: (Decimal.valueOf(Label.SplitRevenueAmt)) OR OrderApi__Credit__c =: 2*(Decimal.valueOf(Label.SplitRevenueAmt))) AND OrderApi__Transaction__r.Id IN: records];
        if(Fon_TransactionService.runOnce() && lines.size()==0){
            Fon_TransactionService.splitRevenue((OrderApi__Transaction__c[])records,(Map<Id,OrderApi__Transaction__c>)oldMap);
        }
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Fon_TransactionTrigger.class.getName(),'beforeUpdate');
                
        Framework.Log.pop();
    }

    /*public override void beforeDelete(){
        
    } */

}