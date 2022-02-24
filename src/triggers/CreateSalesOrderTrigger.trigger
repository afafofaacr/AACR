/*
    CreateSalesOrderTrigger - v1.0
    Description: Create Sales Order when Opportunity stage is Closed Won.
    Author: Aung
    CreatedDate: 21/09/2018
    LastModifiedDate: 28/09/2018
    LastModifiedBy: Afaf Awad
*/
trigger CreateSalesOrderTrigger on Opportunity (after insert, after update) {

    if ( CreateSalesOrderHandler.isFirstTime ) {
        CreateSalesOrderHandler.isFirstTime = false;

        Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults();

        if ( ts.Create_SO_from_Opportunity__c ) {

            Integer i = 0;

            for (Opportunity opp : Trigger.new) {
                if ( !opp.Do_Not_Create_Sales_Order__c ) {
                    System.debug('Creating Sales Order from Opportunity.....');

                    Boolean pass = false;
                    if ( Trigger.isUpdate ) {
                        Id DD_Donation = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DD Donations').getRecordTypeId();
                        Id Ticket_Holder = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DD Ticket Holders').getRecordTypeId();

                        if ( opp.GL_Account__c != trigger.old[i].GL_Account__c
                                && (DD_Donation == Opp.RecordTypeId || Ticket_Holder == Opp.recordTypeId) ) {
                            pass = true;
                        }
                    }
                    if ( opp.GL_Account__c != null && opp.c4g_Appeal_Code__c != null &&
                            (opp.stageName == 'Pledged' || opp.stageName == 'Awarded' || opp.stageName == 'Posted' || opp.stageName == 'Closed Won') ) {
                        pass = true;
                    }

                    if ( pass ) {
                        CreateSalesOrderHandler.CreateSalesOrder(opp);
                    }
                }

                i++;
            }
        }
    }
}