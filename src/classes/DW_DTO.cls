public class DW_DTO {
    public class Response {
        public Boolean Success;
        public String Message;
        public Object Data;
        public Object Metadata;
        
        public Response () {            
            this.Success = false;
            this.Message = 'Blank Response';
            this.Data = null;        
            this.Metadata = null;
        }
    }
    
    public class UserContactData {
        public Contact Contact;
        
        public List<Education__c> Educations;
        
        public List<String> DeletedEducationIdList;
    }
}