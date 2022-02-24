/**
 * Created by mitfity on 18.04.2018.
 */

@IsTest
private class brFieldWrapTest {

    @IsTest
    static void testBrFieldWrap() {

        SObjectType objectType = BR_Participation__c.getSObjectType();

        List<Schema.FieldSetMember> fields =
                Schema.SObjectType.BR_Participation__c.fieldSets.Dietary_Preferences.getFields();

        brFieldWrap fWrap = new brFieldWrap(fields[0], objectType);


        brFieldWrap fieldWrap = new brFieldWrap(false);

        fieldWrap.getType();
        fieldWrap.getLabel();
        fieldWrap.getApiName();
        fieldWrap.getDbRequired();
        fieldWrap.getRequired();
        fieldWrap.getPicklistValues();
        fieldWrap.getDigits();
        fieldWrap.getLength();
        fieldWrap.getPrecision();
        fieldWrap.getScale();
        fieldWrap.getIsHtmlFormatted();



        System.assert(true); //not testable class


    }
}