public class Response {
    public Boolean isSuccess;
    public String message;
    public Object data;

    public Response( Exception ex ) {
        isSuccess = false;
        message = ex.getMessage();
        data = new Map<String, Object> {'exception' => ex.getStackTraceString()};
    }
    public Response( Boolean isSuccess, String message, Map<String, Object> data ) {
        this.isSuccess = isSuccess;
        this.message = message;
        this.data = data;
    }
    public Response( Boolean isSuccess, String message ) {
        this.isSuccess = isSuccess;
        this.message = message;
    }
}