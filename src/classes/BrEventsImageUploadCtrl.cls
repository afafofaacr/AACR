public with sharing class BrEventsImageUploadCtrl {
    public transient Blob mainImageFile {get;set;}
    public transient String mainImageFileName{get;set;}
    public transient Boolean isDeletePrevMainImage{get;set;}
    public transient Blob fileListViewImage {get;set;}
    public transient String fileListViewImageName{get;set;}
    public transient Boolean isDeletePrevListViewImage{get;set;}

    public BrEventsImageUploadCtrl(ApexPages.StandardController controller) {

    }

    public BrEventsImageUploadCtrl() {

    }

    public String getFileMainImageId() {
        return BrEventsImageUploadHelper.getFileUploadId('mainImage');
    }

    public String getFileListViewId() {
        return BrEventsImageUploadHelper.getFileUploadId('listViewImage');
    }

    public PageReference saveMainImage() {
        BrEventsImageUploadHelper.uploadImage(mainImageFile, mainImageFileName, isDeletePrevMainImage, 'mainImage');
        isDeletePrevMainImage = false;
        return null;
    }

    public PageReference saveListViewImage() {
        BrEventsImageUploadHelper.uploadImage(fileListViewImage, fileListViewImageName, isDeletePrevListViewImage, 'listViewImage');
        isDeletePrevListViewImage = false;
        return null;
    }

}