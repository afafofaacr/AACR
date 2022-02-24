/**
 * Created by afaf.awad on 10/11/2021.
 */

public with sharing class WF_FormFieldDropLayoutController {

    @AuraEnabled
    public static void deleteSQRecord(Id sqId){
        //TODO: delete image content
        Survey_Question__c sq = new Survey_Question__c(Id = sqId);

        delete sq;

    }

}