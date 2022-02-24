/**
 * Created by afaf.awad on 11/12/2020.
 */

public with sharing class WorldBankJSON2Apex {

    public List<Countries> countries;

    public class Countries {
        public String id;
        public String iso2Code;
        public String name;
        public Region region;
        public Region adminregion;
        public Region incomeLevel;
        public Region lendingType;
        public String capitalCity;
        public String longitude;
        public String latitude;
    }

    public class Region {
        public String id;
        public String iso2code;
        public String value;
    }


    public static WorldBankJSON2Apex parse(String json) {
        return (WorldBankJSON2Apex) System.JSON.deserialize(json, WorldBankJSON2Apex.class);
    }

}