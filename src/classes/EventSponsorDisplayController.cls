/**
 * Created by afaf.awad on 6/29/2021.
 */

public without sharing class EventSponsorDisplayController {

    @AuraEnabled
    public static List<SponsorInfo> getSponsors(String eventId) {

        List<Sponsor__c> sponsors = [
                SELECT Id, Name, Sponsor__c, Sponsor__r.Name, Display_As__c, Level__c, Logo_URL__c, Logo_Image_Id__c, Event__c,
                        Event__r.Sponsorship_Level_1__c, Event__r.Sponsorship_Level_2__c, Event__r.Sponsorship_Level_3__c
                FROM Sponsor__c
                WHERE Event__c = :eventId
                ORDER BY Level__c, Display_As__c
        ];

        If ( !sponsors.isEmpty() ) {
            Set<Id> docIds = new Set<Id>();
            for (Sponsor__c s : sponsors) {
                docIds.add(s.Logo_Image_Id__c);
            }
            Map<String, String> imageMap = EventSponsorshipController.getSponsorImagesMap(docIds);

            List<SponsorInfo> sponsorInfo = new List<SponsorInfo>();

            for (Sponsor__c s : sponsors) {
                sponsorInfo.add(new SponsorInfo(s, imageMap.get(s.Logo_Image_Id__c)));
            }

            return sponsorInfo;

//            List<SponsorInfo> sponsorLevel1 = new List<SponsorInfo>();
//            List<SponsorInfo> sponsorLevel2 = new List<SponsorInfo>();
//            List<SponsorInfo> sponsorLevel3 = new List<SponsorInfo>();
//            for (Sponsor__c s : sponsors) {
//
//                switch on s.Level__c {
//                    when '1' {
//                        sponsorLevel1.add(new SponsorInfo(s, imageMap.get(s.Logo_Image_Id__c)));
//                        continue;
//                    }
//                    when '2' {
//                        sponsorLevel2.add(new SponsorInfo(s, imageMap.get(s.Logo_Image_Id__c)));
//                        continue;
//                    }
//                    when '3' {
//                        sponsorLevel3.add(new SponsorInfo(s, imageMap.get(s.Logo_Image_Id__c)));
//                        continue;
//                    }
//                }
//            }
//            SponsorInfoByLevel sibl = new SponsorInfoByLevel();
//            sibl.sponsorInfoLevel1 = sponsorLevel1;
//            sibl.sponsorInfoLevel2 = sponsorLevel2;
//            sibl.sponsorInfoLevel3 = sponsorLevel3;
//
//            return sibl;
        }else{
            return null;
        }
    }

    public class SponsorInfo {
        @AuraEnabled
        public Sponsor__c sponsor;

        @AuraEnabled
        public String sponsorImage;

        public SponsorInfo(Sponsor__c sponsor, String image){
            this.sponsor = sponsor;
            this.sponsorImage = image;
        }
    }

//    public class SponsorInfoByLevel{
//        @AuraEnabled
//        public List<SponsorInfo> sponsorInfoLevel1;
//        @AuraEnabled
//        public List<SponsorInfo> sponsorInfoLevel2;
//        @AuraEnabled
//        public List<SponsorInfo> sponsorInfoLevel3;
//
//    }

}