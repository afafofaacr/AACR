/**
 * Created by lauren.lezberg on 1/10/2019.
 */
 
public with sharing class JP_ProgressBarController {

    /**
      * Gets cancelURL if one is present from particular join process
      *
      * @param stepId
      *
      * @return String of cancel url or null if none exists
      */
    @AuraEnabled
    public static String getCancelURL(String stepId){
        Process_Steps__mdt pStep = [SELECT Process__r.Cancel_URL__c FROM Process_Steps__mdt WHERE Id=: stepId];
        if(pStep!=null){
            return pStep.Process__r.Cancel_URL__c;
        }
        return null;
    }

    /**
     * @purpose Finds all progress bar information for specific user in specific join process to display in progress bar
     *
     * @param stepId
     *
     * @return ProgressBarData record containing list of steps, isRenewal flag, and membership type
     */
    @AuraEnabled
    public static ProgressBarData getProgressBarData(String joinId, String salesOrderId){
        System.debug('Getting progress bar data -- joinId: ' + joinId + ' and salesOrderId: '+  salesOrderId);

        String lastAccessedStepId;
        List<JoinStep> joinSteps = new List<JoinStep>();
        Decimal lastStepOrder = JP_Helper.getLastAccessedStepOrder(joinId);
        List<Process_Steps__mdt> steps = [SELECT Id, Step_Order__c, Step_Title__c, Description__c, Join_Step__r.Component_Name__c, Join_Step__r.MasterLabel, Process__r.Is_Renewal__c FROM Process_Steps__mdt WHERE Process__c=: joinId ORDER BY Step_Order__c];
        System.debug('steps: ' + steps);
        //get all join steps in wrapper class
        for(Process_Steps__mdt step : steps){
            if(step.Step_Order__c == lastStepOrder){
                lastAccessedStepId = step.Id;
            }
            joinSteps.add(new JoinStep(step.Join_Step__r.MasterLabel, step.Id, step.Join_Step__r.Component_Name__c, step.Step_Order__c, step.Step_Title__c, step.Description__c));
        }
        //if there is no last accessed step, set it to step #1
        if(lastAccessedStepId==null){
            lastAccessedStepId = steps[0].Id;
        }
        //if its a portal renewal, get portal label for process
        if(salesOrderId!=null) {
            List<OrderApi__Sales_Order_Line__c> sol = [SELECT OrderApi__Item__r.Portal_Label__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item_Class__r.Name = 'Individual Memberships'];
            if(!sol.isEmpty()){
                return new ProgressBarData(joinSteps, sol[0].OrderApi__Item__r.Portal_Label__c, steps[0].Process__r.Is_Renewal__c, lastAccessedStepId);
            } else {
                return new ProgressBarData(joinSteps, null, steps[0].Process__r.Is_Renewal__c, lastAccessedStepId);
            }
        } else {
            //set last accessed step to 1 for ticket purchases
            BrEvents_Settings__c joinProcessId = BrEvents_Settings__c.getValues('Join Process Id');
            BrEvents_Settings__c virtualJoinProcessId = BrEvents_Settings__c.getValues('Virtual Join Process Id');
            if(joinId == joinProcessId.Value__c || joinId == virtualJoinProcessId.Value__c){
                lastAccessedStepId = steps[0].Id;
            }
            return new ProgressBarData(joinSteps, null, steps[0].Process__r.Is_Renewal__c, lastAccessedStepId);
        }
    }


    /**
     * Progress Bar Data Wrapper Object
     */
    public class ProgressBarData {
        @AuraEnabled
        public List<JoinStep> steps;

        @AuraEnabled
        public String membershipType;

        @AuraEnabled
        public Boolean isRenewal;

        @AuraEnabled
        public String lastStepId;


        public ProgressBarData(List<JoinStep> steps, String membershipType, Boolean isRenew, String lastStepId){
            this.steps = steps;
            this.membershipType = membershipType;
            this.isRenewal = isRenew;
            this.lastStepId = lastStepId;
        }

    }

    public class JoinStep{
        @AuraEnabled
        public String stepLabel;

        @AuraEnabled
        public String stepId;

        @AuraEnabled
        public String componentName;

        @AuraEnabled
        public Decimal stepOrder;

        @AuraEnabled
        public String stepTitle;

        @AuraEnabled
        public String description;

        public JoinStep(String label, String id, String name, Decimal order, String title, String description){
            this.stepLabel = label;
            this.stepId = id;
            this.componentName = name;
            this.stepOrder = order;
            this.stepTitle = title;
            this.description = description;
        }
    }

}