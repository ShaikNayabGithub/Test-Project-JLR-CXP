global class AUSDataRemRestUtils {
	public static void setError(RestResponseModel response, String message, String stackTrace) {
        response.isSuccess = false;
        response.errors = new List<string> { message };
            if (stackTrace != null) {
                response.errors.add(stackTrace);
            }
    }
    
    global class RestResponseModel {
        public Boolean isSuccess { get; set; }
        public List<String> errors { get; set; }
        public RestResponseModel() {
            isSuccess = true;
        }
    }
    
     global class RestAccountRequestModel {
        public List<String> AccountIds { get; set; }
    }
}