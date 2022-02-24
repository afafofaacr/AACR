/**
 * Created by afaf.awad on 6/15/2021.
 */

@IsTest
public class DnBTriggerHandlerTest {

    @IsTest
    public static void test_updateMajorGroup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        SIC_Code__mdt sicCode = [SELECT Id, Label, Industry_Group__c, Major_Group__c, Specific_Code__c FROM SIC_Code__mdt WHERE Label = 'Industry/Private Sector'];

        DNBoptimizer__DnBCompanyRecord__c  dnb = new DNBoptimizer__DnBCompanyRecord__c();
        dnb.DNBoptimizer__MinorityOwnedIndicator__c = 'true';
        dnb.DNBoptimizer__SIC4Code1__c = sicCode.Major_Group__c;
        insert dnb;
        dnb.Name = dnb.Id;
        update dnb;

        acc.DNBoptimizer__DnBCompanyRecord__c = dnb.Id;
        update acc;

        Account accUpdate = [SELECT Id, Institution_Type__c, Minority_Institution__c FROM Account WHERE Name = 'Test Account'];

        System.assertEquals(sicCode.Label,accUpdate.Institution_Type__c);
        System.assertEquals(true,accUpdate.Minority_Institution__c);
    }

    @IsTest
    public static void test_updateIndustryGroup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        SIC_Code__mdt sicCode = [SELECT Id, Label, Industry_Group__c, Major_Group__c, Specific_Code__c FROM SIC_Code__mdt WHERE Label = 'Academia'];

        DNBoptimizer__DnBCompanyRecord__c  dnb = new DNBoptimizer__DnBCompanyRecord__c();
        dnb.DNBoptimizer__MinorityOwnedIndicator__c = 'true';
        dnb.DNBoptimizer__SIC4Code1__c = sicCode.Industry_Group__c;
        insert dnb;
        dnb.Name = dnb.Id;
        update dnb;

        acc.DNBoptimizer__DnBCompanyRecord__c = dnb.Id;
        update acc;

        Account accUpdate = [SELECT Id, Institution_Type__c, Minority_Institution__c FROM Account WHERE Name = 'Test Account'];

        System.assertEquals(sicCode.Label,accUpdate.Institution_Type__c);
        System.assertEquals(true,accUpdate.Minority_Institution__c);
    }

    @IsTest
    public static void test_updateSpecificGroup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        SIC_Code__mdt sicCode = [SELECT Id, Label, Industry_Group__c, Major_Group__c, Specific_Code__c FROM SIC_Code__mdt WHERE Label = 'Vendor'];

        DNBoptimizer__DnBCompanyRecord__c  dnb = new DNBoptimizer__DnBCompanyRecord__c();
        dnb.DNBoptimizer__MinorityOwnedIndicator__c = 'true';
        dnb.DNBoptimizer__SIC4Code1__c = sicCode.Specific_Code__c;
        insert dnb;
        dnb.Name = dnb.Id;
        update dnb;

        acc.DNBoptimizer__DnBCompanyRecord__c = dnb.Id;
        update acc;

        Account accUpdate = [SELECT Id, Institution_Type__c, Minority_Institution__c FROM Account WHERE Name = 'Test Account'];

//        System.assertEquals(sicCode.Label,accUpdate.Institution_Type__c);
//        System.assertEquals(true,accUpdate.Minority_Institution__c);

    }

    @IsTest
    public static void test_updateNullInstitution() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        DNBoptimizer__DnBCompanyRecord__c  dnb = new DNBoptimizer__DnBCompanyRecord__c();
        dnb.DNBoptimizer__MinorityOwnedIndicator__c = 'false';
        dnb.DNBoptimizer__SIC4Code1__c = '0000';
        insert dnb;
        dnb.Name = dnb.Id;
        update dnb;

        acc.DNBoptimizer__DnBCompanyRecord__c = dnb.Id;
        update acc;

        Account accUpdate = [SELECT Id, Institution_Type__c, Minority_Institution__c FROM Account WHERE Name = 'Test Account'];

        System.assertEquals('Other',accUpdate.Institution_Type__c);
        System.assertEquals(false,accUpdate.Minority_Institution__c);
    }
}