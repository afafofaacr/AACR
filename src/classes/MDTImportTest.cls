/**
 * Created by afaf.awad on 11/20/2020.
 */
@isTest
private class MDTImportTest {

    @IsTest
    public static void testinsertMetadata() {
        String jsonString = '[{"abbreviation":"AF","country":"Afghanistan","label":"Afghanistan","countryCode":"AFG","region":"South Asia","incomeLevel":"Low income"},{"abbreviation":"AL","country":"Albania","label":"Albania","countryCode":"ALB","region":"Europe & Central Asia","incomeLevel":"Upper middle income"}]';

        MDTImport.insertMetadata('WorldBankTest', jsonString);
    }

}