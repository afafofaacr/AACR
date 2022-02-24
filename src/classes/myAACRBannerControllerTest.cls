/**
 * Created by lauren.lezberg on 12/7/2020.
 */

@IsTest
private class myAACRBannerControllerTest {

    @TestSetup
    public static void setup() {
        //build portal user
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        //build user segments
        AC_User_Segment__c defaultSeg = LiveTestDataFactory.buildUserSegment('Default');
        defaultSeg.Query__c = 'SELECT Id FROM User WHERE ContactId!=null';
        insert defaultSeg;

        AC_User_Segment__c memberSeg = LiveTestDataFactory.buildUserSegment('Members');
        memberSeg.Query__c = 'SELECT Id FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE RecordType.Name=\'Member\')';
        insert memberSeg;

        Banner_Interval_Seconds__c bis = new Banner_Interval_Seconds__c(Seconds__c=5);
        insert bis;


        //add test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User tUser= new User(Alias = 'myAACR', Email='myAACRBannerTest@testorg.com',
                EmailEncodingKey='UTF-8', LastName='BannerTest', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='myAACRBannerTest@testorg.com');
        insert tUser;





    }

    @IsTest
    static void test_createEditDeleteBannerImage() {
        User u = [SELECT Id FROM User WHERE LastName='BannerTest'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'myAACR_Banner_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

        Map<Id, AC_User_Segment__c> segments = new Map<Id, AC_User_Segment__c>([SELECT Id FROM AC_User_Segment__c]);
        String jsonString = JSON.serialize(segments.keySet());

        myAACR_Image__c img = new myAACR_Image__c();
        img.Name = 'TEST';
        img.Header_Text__c = 'TEST HEADER';
        img.Image_Link__c = 'https://google.com';
        img.Image_Text__c = 'THIS IS A TEST';
        img.Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/nrVTQRRu_Carousel_AssocMbr_30YR_DH_1807050C_2_jpg';
        img.Is_Active__c = true;
        img.Is_Default__c = true;

        System.runAs(u) {

            Test.startTest();

            myAACRBannerController.createBannerImage(img, jsonString);

            List<myAACR_Image__c> imgs = myAACRBannerController.getBannerImages();
            System.assertEquals(1, imgs.size());

            List<String> imgSegments = myAACRBannerController.getImageSegmentIds(img.Id);
            System.assertEquals(segments.size(), imgSegments.size());

            imgs[0].Header_Text__c = 'THIS IS A HEADER UPDATE';
            List<myAACR_Image__c> updatedImages = myAACRBannerController.updateBannerImage(imgs[0]);
            System.assertEquals(imgs[0].Header_Text__c, updatedImages[0].Header_Text__c);

            List<myAACR_Image__c> deletedImages = myAACRBannerController.deleteBannerImage(imgs[0]);
            System.assertEquals(0, deletedImages.size());

            Test.stopTest();
        }
    }


    @IsTest
    public static void test_getBannerSettings(){
        User u = [SELECT Id FROM User WHERE LastName='BannerTest'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'myAACR_Banner_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

        Map<Id, AC_User_Segment__c> segments = new Map<Id, AC_User_Segment__c>([SELECT Id FROM AC_User_Segment__c]);
        String jsonString = JSON.serialize(segments.keySet());

        myAACR_Image__c img = new myAACR_Image__c();
        img.Name = 'TEST';
        img.Header_Text__c = 'TEST HEADER';
        img.Image_Link__c = 'https://google.com';
        img.Image_Text__c = 'THIS IS A TEST';
        img.Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/nrVTQRRu_Carousel_AssocMbr_30YR_DH_1807050C_2_jpg';
        img.Is_Active__c = true;
        img.Is_Default__c = true;

        System.runAs(u) {

            Test.startTest();

            myAACRBannerController.createBannerImage(img, jsonString);

            myAACRBannerController.BannerSettings bs = myAACRBannerController.getImages();
            System.assertEquals(1, bs.images.size());
            System.assertEquals(2, bs.segments.size());

            myAACRBannerController.setBannerInterval(10);

            bs = myAACRBannerController.getImages();
            System.assertEquals(10, bs.interval);


            Test.stopTest();
        }
    }


    @IsTest
    public static void test_deactivateBanner(){
        User u = [SELECT Id FROM User WHERE LastName='BannerTest'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'myAACR_Banner_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);


        Map<Id, AC_User_Segment__c> segments = new Map<Id, AC_User_Segment__c>([SELECT Id FROM AC_User_Segment__c]);
        String jsonString = JSON.serialize(segments.keySet());


        myAACR_Image__c img = new myAACR_Image__c();
        img.Name = 'TEST';
        img.Header_Text__c = 'TEST HEADER';
        img.Image_Link__c = 'https://google.com';
        img.Image_Text__c = 'THIS IS A TEST';
        img.Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/nrVTQRRu_Carousel_AssocMbr_30YR_DH_1807050C_2_jpg';
        img.Is_Active__c = true;
        img.Is_Default__c = true;

        myAACR_Image__c img2 = new myAACR_Image__c();
        img2.Name = 'TEST 2';
        img2.Header_Text__c = 'TEST HEADER 2';
        img2.Image_Link__c = 'https://google.com';
        img2.Image_Text__c = 'THIS IS A TEST 2';
        img2.Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/00D2a000000DRYNEA4/KUciOFvC_Announcement_974_jpg';
        img2.Is_Active__c = true;
        img2.Is_Default__c = false;

        System.runAs(u) {

            Test.startTest();

            myAACRBannerController.createBannerImage(img, jsonString);
            myAACRBannerController.createBannerImage(img2, jsonString);

            myAACRBannerController.deactivateBanner();

            List<myAACR_Image__c> imgs = [SELECT Id FROM myAACR_Image__c WHERE Is_Active__c = true];
            System.assertEquals(1, imgs.size());

            Test.stopTest();

        }

    }

    @IsTest
    public static void test_getBannerInfo(){
        Contact con = [SELECT Id FROM Contact WHERE Account.name = 'Test Account'];
        User u = [SELECT id FROM User WHERE ContactId=: con.Id];

        List<AC_User_Segment__c> segments = [SELECT Id, Name FROM AC_User_Segment__c];
        Set<Id> defaultId = new Set<Id>();
        Set<Id> membersId = new Set<Id>();
        for(AC_User_Segment__c seg : segments){
            if(seg.Name == 'Default'){
                defaultId.add(seg.Id);
            } else {
                membersId.add(seg.Id);
            }
        }
        String defaultjsonString = JSON.serialize(defaultId);
        String memberJSONString = JSON.serialize(membersId);


        myAACR_Image__c img = new myAACR_Image__c();
        img.Name = 'DEFAULT';
        img.Header_Text__c = 'TEST HEADER';
        img.Image_Link__c = 'https://google.com';
        img.Image_Text__c = 'THIS IS A TEST';
        img.Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/nrVTQRRu_Carousel_AssocMbr_30YR_DH_1807050C_2_jpg';
        img.Is_Active__c = true;
        img.Is_Default__c = true;

        myAACR_Image__c img2 = new myAACR_Image__c();
        img2.Name = 'Members';
        img2.Header_Text__c = 'TEST HEADER 2';
        img2.Image_Link__c = 'https://google.com';
        img2.Image_Text__c = 'THIS IS A TEST 2';
        img2.Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/00D2a000000DRYNEA4/KUciOFvC_Announcement_974_jpg';
        img2.Is_Active__c = true;
        img2.Is_Default__c = false;

        myAACRBannerController.createBannerImage(img, defaultjsonString);
        myAACRBannerController.createBannerImage(img2, memberJSONString);


        System.runAS(u) {
            Test.startTest();

            myAACRBannerController.myAACRBannerInfo bInfo = myAACRBannerController.getBannerInfo();

            Test.stopTest();

            System.assertEquals(1, bInfo.images.size());
            System.assertEquals(5, bInfo.intervalSeconds);
        }
    }


}