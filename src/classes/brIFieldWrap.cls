/**
 * Created by mitfity on 12.04.2018.
 */

public interface brIFieldWrap {
    Boolean getDbRequired();
    String getApiName();
    String getLabel();
    Boolean getRequired();
    String getType();
    List<Map<String, Object>> getPicklistValues();
    Integer getDigits();
    Integer getLength();
    Integer getPrecision();
    Integer getScale();
    Boolean getIsHtmlFormatted();
}