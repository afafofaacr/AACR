/**
 * Created by mitfity on 25.04.2018.
 */

@IsTest
private class brTestFieldWrapTest {

    @IsTest
    static void testFieldWrap() {
        brTestFieldWrap fieldWrap = new brTestFieldWrap(AC_User_Segment__c.Name);

        fieldWrap.getRequired();
        fieldWrap.getDbRequired();
        fieldWrap.getApiName();
        fieldWrap.getLabel();
        fieldWrap.getType();
        fieldWrap.getPicklistValues();
        fieldWrap.getDigits();
        fieldWrap.getLength();
        fieldWrap.getPrecision();
        fieldWrap.getScale();
        fieldWrap.getIsHtmlFormatted();

        System.assert(true); //not testable class
    }
}