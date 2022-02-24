/**
 * Created by afaf.awad on 8/4/2020.
 */

public with sharing class DunJSON2Apex {
    
    public class YearlyRevenue {
        public Double value;
        public String x_currency;
    }

    public class TradeStyleNames {
        public String name;
        public Integer priority;
    }

    public class PrimaryAddress {
        public AddressCountry addressCountry;
        public StreetAddress streetAddress;
        public AddressLocality addressLocality;
    }

    public class Organization {
        public String duns;
        public DunsControlStatus dunsControlStatus;
        public String primaryName;
        public PrimaryAddress primaryAddress;
        public CorporateLinkage corporateLinkage;
        public List<Financials> financials;
        public List<TradeStyleNames> tradeStyleNames;
        public List<PrimaryIndustryCodes> primaryIndustryCodes;
    }

    public List<SearchCandidates> searchCandidates;
    public List<GlobalUltimate> GlobalUltimates;

    public class DunsControlStatus {
        public Boolean isOutOfBusiness;
    }

    public class AddressLocality {
        public String name;
    }

    public class PrimaryIndustryCodes {
        public String usSicV4;
        public String usSicV4Description;
    }

    public class Organization_Y {
        public String duns;
        public DunsControlStatus dunsControlStatus;
        public String primaryName;
        public PrimaryAddress primaryAddress;
        public CorporateLinkage corporateLinkage;
        public List<Financials> financials;
        public List<PrimaryIndustryCodes> primaryIndustryCodes;
    }

    public class Organization_X {
        public String duns;
        public DunsControlStatus dunsControlStatus;
        public String primaryName;
        public PrimaryAddress_Z primaryAddress;
        public CorporateLinkage corporateLinkage;
        public List<Financials> financials;
        public List<PrimaryIndustryCodes> primaryIndustryCodes;
    }

    public class AddressCountry {
        public String isoAlpha2Code;
    }

    public class Organization_Z {
        public String duns;
        public DunsControlStatus dunsControlStatus;
        public String primaryName;
        public PrimaryAddress_Z primaryAddress;
        public CorporateLinkage corporateLinkage;
        public List<Financials> financials;
        public List<TradeStyleNames> tradeStyleNames;
        public List<PrimaryIndustryCodes> primaryIndustryCodes;
    }

    public class PrimaryAddress_Z {
        public AddressCountry addressCountry;
        public StreetAddress streetAddress;
        public AddressLocality addressLocality;
        public AddressLocality addressRegion;
    }

    public class StreetAddress {
        public String line1;
    }

    public class SearchCandidates {
        public Integer displaySequence;
        public Organization organization;
    }

    public class GlobalUltimate {
        public String duns;
        public String primaryName;
    }

    public class Financials {
        public List<YearlyRevenue> yearlyRevenue;
    }

    public class CorporateLinkage {
        public Boolean isBranch;
        public GlobalUltimate globalUltimate;
    }


    public static DunJSON2Apex parse(String json) {
        return (DunJSON2Apex) System.JSON.deserialize(json, DunJSON2Apex.class);
    }
}