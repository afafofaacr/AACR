/**
 *@Purpose      : DTO for ECRM classes
 *@Created Date : 27-07-2018
 */
public class DW_ECRMDTO {
    
    public class InitialDataDTO{
        public ItemDTO[] items;
    }
    
    /**
     *@Purpose    : Showing Item's details
     */
    public class ItemDTO{
        public String Id; // Item Id
        public String name; // Item name
        public Decimal price; // Item price
        public String type; // Item Type
        public String parentId; // salesorder Id
        public String salesOrderLineItemId; // salesorder line item Id
        public Boolean hideInJoin; //whether to hide item in join process
        public Boolean defaultSelectedInJoin; //whether to keep Item default checked in join process
        public String protalLabel; //Display name of item
    }
    
    /**
     *@Purpose    : Showing Item's details
     */
    public class JournalAddressDTO{
        public String street; // Journal street
        public String city; // Journal city
        public String state; // Journal state or Province
        public String country; // Journal country
        public string zipCode; // Jornal zip or postal code
    }
    
    /**
     *@Purpose    : Showing Item's data, messages,success status
     */
    public class Response{
        
        public boolean isSuccess;
        public String message;
        public Object data;
        public Response () {            
            this.isSuccess = true;
            this.message = '';
            this.data = null; 
        }
        public Response(boolean isSuccess, String message, Object data){
            this.isSuccess = isSuccess;
            this.message = message;
            this.data = data;
        }
    }

    public class StepDTO {
        public String Id {get;set;}
        public String nextStepUrl {get;set;}
        public String prevStepUrl {get;set;}
        public String nextStepId {get;set;}
        public Integer order {get;set;}
        public String title {get;set;}  
        public Boolean isSkip {get;set;}
        public String pageName {get;set;}
    }

    public class EducationInfoDTO {
        public List<Education__c> Educations;        
        public List<String> DeletedEducationIdList;
        public String PreviousStepURL;        
        public String NextStepURL;        
        public String CancelStepURL;
        public String contactId;   
        public Map<String, String> AcademicDegreeMap;
        public Map<String, String> EducationStatusMap;
    }
    
    /**
     *@Purpose   : Showing Item's details
     */
    public class SubcriptionItemDTO{
        public String Id; // Item Id
        public String name; // Item name
        public String type; // Item Type
        public String role;
        public String since;
    }
    
    /**
     *@Purpose   : Contact DTO
     */
    public class ContactDTO{
        public String Id;
        public String name;
        public String membershipStatus;
        public String initialJoinDate;
        public String memberType;
        public string modifyWorkingGroup;
        public String journalStreet;
        public String journalCity;
        public String journalState;
        public String journalcountry;
        public String journalzipcode;
        public String recordTypeName;
    }
    
    /**
     *@Purpose   : Badge DTO
     */
    public class BadgeDTO{
        public String Id;
        public String badgeType;
        public String badge;
        public String item;
    }
    
    /**
     *@Purpose   : Subscription DTO
     */
    public class SubscriptionDTO{
        public String Id;
        public String currentTermEndDate;
        public Decimal daysToLapse;
    }
    
    /**
     *@Purpose   : Renew DTO
     */
    public class RenewDTO{
        public String contactId;
        public String salesOrderId;
        public String joinProcessURL;
        public Object item;
    }
}