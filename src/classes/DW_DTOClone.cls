public class DW_DTOClone {
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
    }
}