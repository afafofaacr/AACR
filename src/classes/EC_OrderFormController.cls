/**
 * Created by afaf.awad on 2/9/2021.
 */

public without sharing class EC_OrderFormController {

    @AuraEnabled
    public static OrderInfo getOrderInfo(String orderId, String stepId){
        JP_Helper.upsertLastAccessedStep(stepId);
        //Get list of each picklist
        List<columnObject> countries = getColumnObject('Countries__c');
        List<columnObject> attendeeTypes = getColumnObject('Attendee_Type__c');
        List<columnObject> institutionTypes = getColumnObject('Institution_Type__c');
        List<columnObject> degrees = getColumnObject('Degrees__c');
        List<columnObject> organs = getColumnObject('Organ_Sites__c');
        List<columnObject> researchAreas = getColumnObject('Research_Area_of_Expertise__c');


        return new OrderInfo(countries, attendeeTypes, institutionTypes, degrees, organs, researchAreas, EC_Helper.getOrderRecord(orderId));

    }

    @AuraEnabled
    public static Boolean saveOrder(String orderId, String orderName, String countryJson, String attendeeJson ,String degreeJson, String institutionJson, String organJson, String researchJson){
        System.debug('Saving Exhibitor Order...');

        String countryString = String.join(deserializeList(countryJson), ';');
        String attendeeString = String.join(deserializeList(attendeeJson), ';');
        String degreeString = String.join(deserializeList(degreeJson), ';');
        String institutionString = String.join(deserializeList(institutionJson), ';');
        String organString = String.join(deserializeList(organJson), ';');
        String researchString = String.join(deserializeList(researchJson), ';');

        System.debug('countryList: ' + countryString);
        System.debug('attendeeList: ' + attendeeString);
        System.debug('degreeList: ' + degreeString);
        System.debug('institutionList: ' + institutionString);
        System.debug('organList: ' + organString);
        System.debug('researchList: ' + researchString);

        EC_Order__c newOrder = new EC_Order__c();
        newOrder.Id = orderId;
        newOrder.Order_Name__c = orderName;
        newOrder.Countries__c = countryString;
        newOrder.Attendee_Type__c = attendeeString;
        newOrder.Institution_Type__c = institutionString;
        newOrder.Degrees__c = degreeString;
        newOrder.Organ_Sites__c = organString;
        newOrder.Research_Area_of_Expertise__c = researchString;

        try{
            System.debug('Updating order...' + newOrder.Id);
            update newOrder;
            return true;
        }catch(Exception e){
            System.debug('Error upserting Exhibitor Order: ' + e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static List<columnObject> getColumnObject(String fieldName) {
        List<columnObject> columnObjects = new List<columnObject>();
        for (String c : ECRMUtils.getPicklistValues('EC_Order__c', fieldName)) {
            columnObject col = new columnObject();
            col.option = c;
            columnObjects.add(col);

        }
        return columnObjects;
    }


    public static List<String> deserializeList(String jsonString){
        List<columnObject> listObject = (List<columnObject>)JSON.deserialize(jsonString, List<columnObject>.class);

        List<String> returnList = new List<String>();
        for(columnObject co : listObject){
            returnList.add(co.option);
        }

        return returnList;
    }

    public class columnObject{
        @AuraEnabled
        public String option;
    }

    public class OrderInfo{
        @AuraEnabled
        public List<columnObject> countries;
        @AuraEnabled
        public List<columnObject> attendeeTypes;
        @AuraEnabled
        public List<columnObject> institutionTypes;
        @AuraEnabled
        public List<columnObject> degrees;
        @AuraEnabled
        public List<columnObject> organs;
        @AuraEnabled
        public List<columnObject> researchAreas;
        @AuraEnabled
        public EC_Order__c order;

        public OrderInfo(List<columnObject> country, List<columnObject> attendeeType, List<columnObject> institutionType,
                        List<columnObject> degree, List<columnObject> organ, List<columnObject> researchArea, EC_Order__c orderInfo){
            this.countries = country;
            this.attendeeTypes = attendeeType;
            this.institutionTypes = institutionType;
            this.degrees = degree;
            this.organs = organ;
            this.researchAreas = researchArea;
            this.order = orderInfo;

        }

    }

}