/**
 * Created by mitfity on 12.04.2018.
 */

public with sharing class brTestFieldWrap implements brIFieldWrap {

    private Boolean dbRequired;
    private String apiName;
    private String label;
    private Boolean required;
    private String type;
    private List<Map<String, Object>> picklistValues;
    private Integer digits;
    private Integer length;
    private Integer precision;
    private Integer scale;
    private Boolean htmlFormatted;

    public brTestFieldWrap(SObjectField field) {
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

        this.dbRequired = fieldDescribe.isNillable();
        this.apiName = fieldDescribe.getName();
        this.label = fieldDescribe.getLabel();
        this.required = fieldDescribe.isNillable();
        this.type = String.valueOf(fieldDescribe.getType());
    }

    @AuraEnabled
    public Boolean getDbRequired() {
        return this.dbRequired;
    }

    @AuraEnabled
    public String getApiName() {
        return this.apiName;
    }

    @AuraEnabled
    public String getLabel() {
        return this.label;
    }

    @AuraEnabled
    public Boolean getRequired() {
        return this.required;
    }

    @AuraEnabled
    public String getType() {
        return this.type;
    }

    @AuraEnabled
    public List<Map<String, Object>> getPicklistValues() {
        return this.picklistValues;
    }

    @AuraEnabled
    public Integer getDigits() {
        return this.digits;
    }

    @AuraEnabled
    public Integer getLength() {
        return this.length;
    }

    @AuraEnabled
    public Integer getPrecision() {
        return this.precision;
    }

    @AuraEnabled
    public Integer getScale() {
        return this.scale;
    }

    @AuraEnabled
    public Boolean getIsHtmlFormatted() {
        return this.htmlFormatted;
    }
}