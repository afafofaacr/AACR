/**
 * Created by afaf.awad on 9/9/2021.
 */
@IsTest
public with sharing class ExportHelper_LeadTest {

    @IsTest
    public static void test_exportTagsLeads() {

        Lead lead = TestDataFactory.buildLead();
        insert lead;

        Dimension_Tags__mdt DMT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Lead' AND Visibility__c = 'Public' LIMIT 1];
        SObject publicObj = DimensionTagHelper.createTagRecord(DMT.Id,  lead.Id);
        insert publicObj;

        ExportHelper_Lead.LeadExport le = ExportHelper_Lead.queryLeads(DMT.Id);

        System.assertEquals(1, le.Leads.size());
    }

}