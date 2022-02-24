/**
 * Created by lauren.lezberg on 9/22/2020.
 */

public without sharing class myAACRBannerController {
    //BANNER CONTROLS

    /**
     * @purpose Retrieves initial banner info (targeted images & interval seconds) to display to portal user
     * @return Banner info DTO
     */
    @AuraEnabled
    public static myAACRBannerInfo getBannerInfo() {
        return new myAACRBannerInfo();
    }


    /**
     * @purpose Retrieves images targeted to specific user
     * @param userId
     *
     * @return list of banner images
     */
    public static List<myAACR_Image__C> getTargetImages(Id userId) {
        List<myAACR_Image__c> activeImages = new List<myAACR_Image__c>();
        List<myAACR_Image_Segment__c> imgSegments = [SELECT Id, AC_User_Segment__c, AC_User_Segment__r.Query__c, myAACR_Image__c FROM myAACR_Image_Segment__c WHERE myAACR_Image__c IN (SELECT Id FROM myAACR_Image__c WHERE Is_Active__c = true) AND AC_User_SEgment__r.Active__c = true];
        Set<Id> uniqueSegments = new Set<Id>();
        Set<Id> segmentIds = new Set<Id>();

        //get banner image segments that apply to user
        for (myAACR_Image_Segment__c is : imgSegments) {
            if (!uniqueSegments.contains(is.AC_User_Segment__c)) {
                uniqueSegments.add(is.AC_User_Segment__c);
                String segmentQuery = is.AC_User_Segment__r.Query__c + ' AND Id= \'' + userId + '\'';
                List<User> segmentUsers = Database.query(segmentQuery);
                for (User segmentUser : segmentUsers) {
                    if (segmentUser.Id == userId) {
                        segmentIds.add(is.AC_User_Segment__c);
                    }
                }

            }
        }

        Set<Id> imgIds = new Set<Id>();
        for (myAACR_Image_Segment__c is : imgSegments) {
            if (segmentIds.contains(is.AC_User_Segment__c)) {
                imgIds.add(is.myAACR_Image__c);
            }
        }

        if (imgIds.isEmpty()) {
            activeImages = [SELECT Id,Name, Image_URL__c, Is_Active__c, Image_Link__c, Image_Text__c, Header_Text__c, Is_Default__c FROM myAACR_Image__c WHERE Is_Default__c = true];
        } else {
            activeImages = [SELECT Id,Name, Image_URL__c, Is_Active__c, Image_Link__c, Image_Text__c, Header_Text__c, Is_Default__c FROM myAACR_Image__c WHERE Id IN:imgIds ORDER BY Is_Default__c DESC];

        }

        return activeImages;

    }


    public class myAACRBannerInfo {

        @AuraEnabled
        public List<myAACR_Image__c> images;

        @AuraEnabled
        public Integer intervalSeconds;

        public myAACRBannerInfo() {
            images = getTargetImages(UserInfo.getUserId());
            Banner_Interval_Seconds__c bis = Banner_Interval_Seconds__c.getOrgDefaults();
            intervalSeconds = (Integer) bis.Seconds__c;
        }
    }

    //BANNER SETTINGS CONTROLS

    public class BannerSettings {
        @AuraEnabled
        public Integer interval;

        @AuraEnabled
        public List<myAACR_Image__c> images;

        @AuraEnabled
        public List<AC_User_Segment__c> segments;

    }

    /**
     * @purpose Set interval at which banner images rotate
     * @param seconds
     */
    @AuraEnabled
    public static void setBannerInterval(Integer seconds) {
        Banner_Interval_Seconds__c bis = Banner_Interval_Seconds__c.getOrgDefaults();
        bis.Seconds__c = (Decimal) seconds;
        update bis;
    }

    /**
     * @purpose saves image segments - checks if any have been added or deleted
     * @param imgId
     * @param jsonString
     */
    @AuraEnabled
    public static void saveImageSegments(String imgId, String jsonString) {
        Set<String> segmentIds = (Set<String>) JSON.deserialize(jsonString, Set<String>.class);
        System.debug('segmentIds: ' + segmentIds);
        //get set of segmentIds that already exists
        Set<Id> sIds = new Set<Id>();
        for (myAACR_Image_Segment__c s : [SELECT Id, AC_User_Segment__c FROM myAACR_Image_Segment__c WHERE myAACR_Image__c = :imgId]) {
            sIds.add(s.AC_User_Segment__c);
        }

        //check if new segmentIds already exist
        List<myAACR_Image_Segment__c> segments = new List<myAACR_Image_Segment__c>();
        for (String s : segmentIds) {
            if (!sIds.contains((Id) s)) {
                segments.add(new myAACR_Image_Segment__c(
                        AC_User_Segment__c = (Id) s,
                        myAACR_Image__c = imgId
                ));
            }
        }

        //check if any segments need to be deleted
        List<Id> toDelete = new List<STring>();
        for (String s : sIds) {
            if (!segmentIds.contains(s)) {
                toDelete.add(s);
            }
        }

        delete [SELECT Id, AC_User_Segment__c FROM myAACR_Image_Segment__c WHERE myAACR_Image__c = :imgId AND AC_User_Segment__c IN:toDelete];

        insert segments;
    }

    /**
     * @purpose Get image segment ids - for visibility
     * @param imgId
     *
     * @return List of image segments
     */
    @AuraEnabled
    public static List<String> getImageSegmentIds(String imgId) {
        List<String> segmentIds = new List<String>();
        for (myAACR_Image_Segment__c seg : [SELECT Id, AC_User_Segment__c FROM myAACR_Image_Segment__c WHERE myAACR_Image__c = :imgId]) {
            segmentIds.add(seg.AC_User_Segment__c);
        }

        return segmentIds;
    }

    /**
     * @purpose Retrieves all available banner images
     * @return list of banner images
     */
    public static List<myAACR_Image__c> getBannerImages() {
        if (FeatureManagement.checkPermission('Banner_Images')) {
            return [SELECT Name, Id, Image_URL__c, Image_Link__c, Image_Text__c, Header_Text__c, Is_Default__c, Is_Active__c, (SELECT Id, AC_User_Segment__r.Id, AC_User_Segment__r.Name FROM myAACR_Image_Segments__r) FROM myAACR_Image__c ORDER BY Is_Default__c DESC];
        }
        return null;
    }

    /**
     * @purpose Creates new banner image
     * @param img
     * @param jsonString
     */
    @AuraEnabled
    public static void createBannerImage(myAACR_Image__c img, String jsonString) {

        upsertBannerImage(img);
        saveImageSegments(img.Id, jsonString);
    }

    /**
     * @purpose Gets initial info about banner settings - interval, user segments, images
     * @return BannerSettings DTO
     */
    @AuraEnabled
    public static BannerSettings getImages() {
        BannerSettings bs = new BannerSettings();
        bs.segments = AACRAdminUtils.getActiveUserSegments();
        bs.images = getBannerImages();
        Banner_Interval_Seconds__c bis = Banner_Interval_Seconds__c.getOrgDefaults();
        bs.interval = (Integer) bis.Seconds__c;

        return bs;
    }

    /**
     * @purpose updates banner image
     * @param img
     */
    public static void upsertBannerImage(myAACR_Image__c img) {
        try {
            upsert img;
        } catch (Exception e) {
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Banner App - Upsert');
        }
    }

    /**
     * @purpose Deletes banner image
     * @param img
     */
    private static void deleteImage(myAACR_Image__c img) {
        try {
            delete img;
        } catch (Exception e) {
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Banner App - Delete');
        }
    }

    /**
     * @purpose Deletes banner image - only available if image is deactivated
     * @param img
     *
     * @return updated list of banner images
     */
    @AuraEnabled
    public static List<myAACR_Image__c> deleteBannerImage(myAACR_Image__c img) {
        deleteImage(img);
        return getBannerImages();
    }

    /**
     * @purpose Updates banner image
     * @param img
     *
     * @return updated list of banner images
     */
    @AuraEnabled
    public static List<myAACR_Image__c> updateBannerImage(myAACR_Image__c img) {
        upsertBannerImage(img);
        return getBannerImages();
    }


    /**
     * @purpose Deactivates all banner images
     */
    @AuraEnabled
    public static void deactivateBanner() {
        List<myAACR_Image__c> imgs = getBannerImages();

        for (myAACR_Image__c i : imgs) {

            if (!i.Is_Default__c) {
                i.Is_Active__c = false;
            } else {
                i.Is_Active__c = true;
            }
        }

        try {
            update imgs;
        } catch (Exception e) {
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Banner App - Deactivate');
        }

    }

}