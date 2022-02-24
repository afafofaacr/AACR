@IsTest
private class BrSelectCtrlTest {
    /**
     * Test methods gets all countries
     */
    @IsTest
    static void testGetCountryRecords() {
        Test.startTest();

        List<Map<String,String>> options = BrSelectCtrl.getPicklistOptions('Salutation');

        System.assertEquals(true, options.size() > 0, 'wrong number of options');

        Test.stopTest();
    }
}