public with sharing class AIMEmailRequest {
    public String orgWideEmailAddressId;
    public String orgWideEmailAddress;
    public String orgWideEmailAddressName;
    public String templateId;
    public String subject;
    public String body;
    public String whatId;
    public SaveAsActivityEnum saveAsActivityMethod;
    public Integer batchSize;
    public String trackingTaskId;
    public Integer totalRecipients;
    public Integer totalSent = 0;
    public Integer totalFailed = 0;


    public AIMEmailRequest() {

    }
}
