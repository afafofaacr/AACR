/**
 * Created by afaf.awad on 4/23/2021.
 */

public without sharing class EventSponsorshipController {


    @AuraEnabled
    public static String getSponsorSetting(){
        return Event_Sponsors__c.getInstance().Instructions__c;
    }

    @AuraEnabled
    public static List<Sponsor__c> getSponsorInfo(String eventId){

        return [SELECT Id, Name, Display_As__c, Sponsor__c, Sponsor__r.Name , Level__c, Logo_URL__c, Logo_Image_Id__c, Event__c FROM Sponsor__c WHERE Event__c =: eventId];
    }

    @AuraEnabled
    public static Account getAccountInfo(String accId){
        return [SELECT Id, Name FROM Account WHERE Id =: accId];
    }

    @AuraEnabled
    public static String getSponsorImages(String sponsorId){
        System.debug('--getting images for sponsorId: ' + sponsorId);
        if(String.isBlank(sponsorId)){
            return null;
        }else {
//            List<Sponsor__c> sponsors = [SELECT Logo_Image_Id__c FROM Sponsor__c WHERE Id = :sponsorId];
            return [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :sponsorId].ContentDocumentId;
        }

    }

    @AuraEnabled
    public static Boolean clearSponsorLevel(String eventId, String level){
        try{

            List<Sponsor__c> sponsors = [SELECT Id, Name, Display_As__c, Sponsor__c, Sponsor__r.Name , Level__c, Logo_URL__c, Logo_Image_Id__c, Event__c
            FROM Sponsor__c WHERE Event__c =: eventId AND Level__c=: level];

            List<String> imageIds = new List<String>();
            for(Sponsor__c s : sponsors){
                imageIds.add(s.Logo_Image_Id__c);
            }

            list<ContentDocument> DocsToDelete = new list<ContentDocument>();

            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :imageIds]) {
               DocsToDelete.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }

            Set<ContentDocument> setDocsToDelete = new Set<ContentDocument>();
            list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
            setDocsToDelete.addAll(DocsToDelete);
            lstCntDocsToDelete.addAll(setDocsToDelete);

            System.debug('list docs to delete == ' + lstCntDocsToDelete);
            if(!lstCntDocsToDelete.isEmpty() && lstCntDocsToDelete != null) {
                Database.delete(lstCntDocsToDelete, false);
            }
            delete sponsors;
            return true;

        }catch(Exception e){
            System.debug('Cannot delete: ' + e.getMessage());
            new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Clear Sponsor Level');
            return false;

        }


    }

    @AuraEnabled
    public static Boolean deleteSponsorRecord(String sponsorId){

        try{

            Sponsor__c sponsor = [SELECT Id, Name, Display_As__c, Sponsor__c, Sponsor__r.Name , Level__c, Logo_URL__c, Logo_Image_Id__c, Event__c
                                    FROM Sponsor__c WHERE Id =: sponsorId];

            list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();

            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink where ContentDocumentId = :sponsor.Logo_Image_Id__c LIMIT 1]) {
                lstCntDocsToDelete.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }

            if(!lstCntDocsToDelete.isEmpty() && lstCntDocsToDelete != null) {
                Database.delete(lstCntDocsToDelete, false);
            }
            delete sponsor;
            return true;

        }catch(Exception e){
            System.debug('Cannot delete: ' + e.getMessage());
            new AACRCustomException(sponsorId, e.getMessage(), e.getStackTraceString(), 'Delete Sponsor');
            return false;

        }
    }


    /**
     * @purpose Set sponsor logo image to public visibility
     *
     * @param fileId
     */
    @AuraEnabled
    public static void setImageToPublic(String fileId){
        System.debug('setImageToPublic...' + fileId);

//        Sponsor__c sponsor = [SELECT Logo_Image_Id__c FROM Sponsor__c WHERE Id=: sponsorId];
//        System.debug('sponsor: ' + sponsor);

        if(fileId!=null) {
            List<ContentDocumentLink> cdls = [SELECT Visibility, Id, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId = :fileId];
            for (ContentDocumentLink link : cdls) {
                link.Visibility = 'AllUsers';

            }

            ContentVersion cv = [select id, ContentDocumentId, Title from contentversion where contentdocumentid = :fileId];

            ContentDistribution cd = new ContentDistribution();
            cd.Name = cdls[0].ContentDocument.Title;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;

            try {
                update cdls;
                insert cd;

                System.debug('contentDistribution: ' + cd);

            } catch (Exception e) {
                new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'Add Sponsorships');
            }
        } else {
            new AACRCustomException('Null file Id','EventSponsorshipController.setImagesToPublic()', 'Add Sponsorships');
        }
    }

    public static String buildLogosInEmail(String eventId){

        List<Sponsor__c> sponsors = [SELECT Id, Display_As__c, Level__c, Logo_URL__c, Logo_Image_Id__c,
                Event__r.Sponsorship_Level_1__c, Event__r.Sponsorship_Level_2__c, Event__r.Sponsorship_Level_3__c
        FROM Sponsor__c WHERE Event__c = :eventId ORDER BY Level__c,Display_As__c];

//        System.debug('sponsors: ' + sponsors);

        If(!sponsors.isEmpty()) {
            Set<Id> docIds = new Set<Id>();
            for (Sponsor__c s : sponsors) {
                docIds.add(s.Logo_Image_Id__c);
            }
            Map<String, String> imageMap = getSponsorImagesMap(docIds);

            List<Sponsor__c> sponsorLevel1 = new List<Sponsor__c>();
            List<Sponsor__c> sponsorLevel2 = new List<Sponsor__c>();
            List<Sponsor__c> sponsorLevel3 = new List<Sponsor__c>();
            for (Sponsor__c s : sponsors) {

                switch on s.Level__c {
                    when '1' {
                        sponsorLevel1.add(s);
                        continue;
                    }
                    when '2' {
                        sponsorLevel2.add(s);
                        continue;
                    }
                    when '3' {
                        sponsorLevel3.add(s);
                        continue;
                    }
                }
            }

//            System.debug('Sponsor 1 : ' + sponsors[0].Event__r.Sponsorship_Level_1__c + '...size= ' + sponsorLevel1.size());
//            System.debug('Sponsor 2 : ' + sponsors[0].Event__r.Sponsorship_Level_2__c + '...size= ' + sponsorLevel2.size());
//            System.debug('Sponsor 3 : ' + sponsors[0].Event__r.Sponsorship_Level_3__c + '...size= ' + sponsorLevel3.size());

            String sponsorHtml = '';
            if ( !sponsorLevel1.isEmpty() ) {
                //Add Sponsor header
                sponsorHtml += '<tr align="center">\n' +
                        '<td>\n' +
                        '<h2 align="center" style="background-image:none; color: #4bba40;">' + sponsorLevel1[0].Event__r.Sponsorship_Level_1__c + '</h2>\n' +
                        '</td>\n' +
                        '</tr>\n' ;

                for (Sponsor__c s : sponsorLevel1) {
//                    System.debug('Level ' + s.Level__c + ': ' + s.Display_As__c);
//                    System.debug('imageMap ' + imageMap.get(s.Logo_Image_Id__c));
                    sponsorHtml += buildLogoHTML(s, imageMap);
                }
            }

            if ( !sponsorLevel2.isEmpty() ) {
//                System.debug('sponsorlevel2...');
                sponsorHtml += '<tr align="center">\n' +
                        '<td>\n' +
                        '<h2 align="center" style="background-image:none; color: #4bba40;">' + sponsorLevel2[0].Event__r.Sponsorship_Level_2__c + '</h2>\n' +
                        '</td>\n' +
                        '</tr>\n' ;
                for (Sponsor__c s : sponsorLevel2) {
//                    System.debug('Level ' + s.Level__c + ': ' + s.Display_As__c);
//                    System.debug('imageMap ' + imageMap.get(s.Logo_Image_Id__c));
                    sponsorHtml += buildLogoHTML(s, imageMap);
                }
            }

            if ( !sponsorLevel3.isEmpty() ) {
                //Add Sponsor header
                sponsorHtml += '<tr align="center">\n' +
                        '<td>\n' +
                        '<h2 align="center" style="background-image:none; color: #4bba40; font-size:1.2rem">' + sponsorLevel3[0].Event__r.Sponsorship_Level_3__c + '</h2>\n' +
                        '</td>\n' +
                        '</tr>\n' ;
                for (Sponsor__c s : sponsorLevel3) {
                    sponsorHtml += buildLogoHTML(s, imageMap);
                }
            }
            return sponsorHtml;
        }

        return '';
    }


    public static String buildLogosInEmail(String eventId, Boolean showSponsors, Boolean showLogos){

        List<Sponsor__c> sponsors = [SELECT Id, Display_As__c, Level__c, Logo_URL__c, Logo_Image_Id__c,
                                            Event__r.Sponsorship_Level_1__c, Event__r.Sponsorship_Level_2__c, Event__r.Sponsorship_Level_3__c
                                    FROM Sponsor__c WHERE Event__c = :eventId ORDER BY Level__c,Display_As__c];


        if(showSponsors) {
            If ( !sponsors.isEmpty() ) {
                Set<Id> docIds = new Set<Id>();
                for (Sponsor__c s : sponsors) {
                    docIds.add(s.Logo_Image_Id__c);
                }
                Map<String, String> imageMap = getSponsorImagesMap(docIds);

                List<Sponsor__c> sponsorLevel1 = new List<Sponsor__c>();
                List<Sponsor__c> sponsorLevel2 = new List<Sponsor__c>();
                List<Sponsor__c> sponsorLevel3 = new List<Sponsor__c>();
                for (Sponsor__c s : sponsors) {

                    switch on s.Level__c {
                        when '1' {
                            sponsorLevel1.add(s);
                            continue;
                        }
                        when '2' {
                            sponsorLevel2.add(s);
                            continue;
                        }
                        when '3' {
                            sponsorLevel3.add(s);
                            continue;
                        }
                    }
                }

//            System.debug('Sponsor 1 : ' + sponsors[0].Event__r.Sponsorship_Level_1__c + '...size= ' + sponsorLevel1.size());
//            System.debug('Sponsor 2 : ' + sponsors[0].Event__r.Sponsorship_Level_2__c + '...size= ' + sponsorLevel2.size());
//            System.debug('Sponsor 3 : ' + sponsors[0].Event__r.Sponsorship_Level_3__c + '...size= ' + sponsorLevel3.size());

                String sponsorHtml = '';
                if ( !sponsorLevel1.isEmpty() ) {
                    //Add Sponsor header
                    sponsorHtml += buildLevelHeader(sponsorLevel1[0].Event__r.Sponsorship_Level_1__c);
                    if(showLogos) {
                        sponsorHtml += buildLogoHTML(sponsorLevel1, imageMap);
                    }else{
                        sponsorHtml += buildTextHTML(sponsorLevel1);
                    }
                }

                if ( !sponsorLevel2.isEmpty() ) {
                    sponsorHtml += buildLevelHeader(sponsorLevel2[0].Event__r.Sponsorship_Level_2__c);

                    if(showLogos) {
                        sponsorHtml += buildLogoHTML(sponsorLevel2, imageMap);
                    }else{
                        sponsorHtml += buildTextHTML(sponsorLevel2);
                    }
                }
                if ( !sponsorLevel3.isEmpty() ) {
                    //Add Sponsor header
                    sponsorHtml += buildLevelHeader(sponsorLevel3[0].Event__r.Sponsorship_Level_3__c);
                    if(showLogos) {
                        sponsorHtml += buildLogoHTML(sponsorLevel3, imageMap);
                    }else{
                        sponsorHtml += buildTextHTML(sponsorLevel3);
                    }
                }
//                System.debug('sponsorHTML: ' + sponsorHtml);
                return sponsorHtml;
            }else{
                return '';
            }
        }else{
            return '';
        }

    }
    

    public static String buildLogoHTML(List<Sponsor__c> sponsors, Map<String, String> imageMap){

        String logoHTML='';

        for(Sponsor__c s: sponsors) {

            logoHTML += '<tr align="center">\n' +
                    '<td>\n' +
                    '<table align="center" border="0" cellpadding="0" cellspacing="0" class="emailButton" style="margin: 0 auto;">\n' +
                    '<tr>\n' +
                    '<td align="center" bgcolor="#ffffff" style="padding: 8px 8px; margin: 0px auto !important; line-height: 120%;" valign="middle">\n' +
                    '<div style="max-width=300; max-height=119">\n' +
                    '<a href="' + s.Logo_URL__c + '" title="' + s.Display_As__c + '">\n' +
                    '<img alt="' + s.Display_As__c + '" height="119" src="' + imageMap.get(s.Logo_Image_Id__c) + '" style="padding: 0px; max-height: 119px; max-width: 300px; text-align: center; border: 0px;"></a>\n' +
                    '</div>\n' +
                    '</td>\n' +
                    '</tr>\n' +
                    '</table>\n' +
                    '</td>\n' +
                    '</tr>\n';
        }

        return logoHTML;

    }

    public static String buildLevelHeader(String title){
        return '<tr align="center">\n' +
                '<td>\n' +
                '<h2 align="center" style="background-image:none; color: #4bba40; font-size:1.2rem">' + title + '</h2>\n' +
                '</td>\n' +
                '</tr>\n' ;
    }

    public static String buildLogoHTML(Sponsor__c s, Map<String, String> imageMap){

        return '<tr align="center">\n' +
                '<td>\n' +
                '<table align="center" border="0" cellpadding="0" cellspacing="0" class="emailButton" style="margin: 0 auto;">\n' +
                '<tr>\n' +
                '<td align="center" bgcolor="#ffffff" style="padding: 8px 8px; margin: 0px auto !important; line-height: 120%;" valign="middle">\n' +
                '<div style="max-width=300; max-height=119">\n' +
                '<a href="' + s.Logo_URL__c + '" title="">\n' +
                '<img alt="'+ s.Display_As__c +'" height="119" src="' + imageMap.get(s.Logo_Image_Id__c) + '" style="padding: 0px; max-height: 119px; max-width: 300px; text-align: center; border: 0px;"></a>\n' +
                '</div>\n' +
                '</td>\n' +
                '</tr>\n' +
                '</table>\n' +
                '</td>\n' +
                '</tr>\n';
    }

    public static String buildTextHTML(List<Sponsor__c> sponsors){

        String textHTML = '<tr align="center">\n' +
                '<td align="center" style="margin: 0px auto !important;" valign="middle">';

        for(Sponsor__c s : sponsors) {
            textHTML += '<a href="' + s.Logo_URL__c + '" title="" style="text-decoration: none;color: inherit;">' + s.Display_As__c  + '</a> <br/>';
        }

        textHTML += '<tr align="center">\n' +
                '<td align="center" style="margin: 0px auto !important;" valign="middle">';

        return textHTML;
    }


    public static Map<String, String> getSponsorImagesMap(Set<Id> docIds){
        System.debug('getSponsorImagesMap: '  + docIds);
        Map<String, String> imgMap = new Map<String, String>();
//        if(sponsorIds.size() == 0 || !BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', null))
//            return imgMap;

        List<ContentDocumentLink> files = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE ContentDocumentId IN :docIds];

        System.debug('SponsorImageFiles: '  + files);

        if(!files.isEmpty()) {
            Map<Id, Id> contentDocumentEntityMap = new Map<Id, Id>();
            Set<Id> versionIds = new Set<Id>();

            for (ContentDocumentLink file : files) {
                if (!contentDocumentEntityMap.containsKey(file.ContentDocumentId)) {
                    versionIds.add(file.ContentDocument.LatestPublishedVersionId);
                    contentDocumentEntityMap.put(file.ContentDocument.LatestPublishedVersionId, file.ContentDocumentId);
                }
            }
            System.debug('versionsIds: '  + versionIds);
            System.debug('contentDocumentEntityMap: '  + contentDocumentEntityMap);

            List<ContentDistribution> distributions = [Select Id, ContentDocumentId, ContentDownloadUrl, ContentVersionId, ContentVersion.Title,
                                                        RelatedRecordId from ContentDistribution WHERE ContentVersionId IN:versionIds];
            System.debug('distributions: '  + distributions.size());
            for (ContentDistribution d : distributions) {
                imgMap.put(contentDocumentEntityMap.get(d.ContentVersionId), d.ContentDownloadUrl);
            }
            System.debug('imgMap: '  + imgMap);
        }

        return imgMap;
    }

}