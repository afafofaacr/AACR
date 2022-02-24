/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class MDTHelperTest {
    @IsTest
    public static void test_createMetadataContainer(){

        Map<String, String> mdtRecordMap = DimensionTagHelper.createDimTagMetadata('Test tag description', 'Contact', 'Public');

        Metadata.DeployContainer mdContainer = MDTHelper.createMetadataContainer('Dimension_Tags__mdt', 'Test Tag', mdtRecordMap);
        System.assertEquals(true, mdContainer != null);
    }
}