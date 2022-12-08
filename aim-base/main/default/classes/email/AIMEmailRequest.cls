/**
 * AIMEmailRequest Class to hold the content of email
 */
public with sharing class AIMEmailRequest {
  private String orgWideEmailAddressId;
  private String orgWideEmailAddress;
  private String orgWideEmailAddressName;
  private String templateId;
  private String subject;
  private String body;
  private String whatId;
  private SaveAsActivityEnum saveAsActivityMethod;
  private Integer batchSize;
  private String trackingTaskId;
  private Integer totalRecipients;
  private Integer totalSent;
  private Integer totalFailed;

  public AIMEmailRequest() {
    this.totalSent = 0;
    this.totalFailed = 0;
    this.batchSize = 100;
  }

  public String getOrgWideEmailAddressId() {
    return this.orgWideEmailAddressId;
  }

  public void setOrgWideEmailAddressId(String orgWideEmailAddressId) {
    this.orgWideEmailAddressId = orgWideEmailAddressId;
  }

  public String getOrgWideEmailAddress() {
    return this.orgWideEmailAddress;
  }

  public void setOrgWideEmailAddress(String orgWideEmailAddress) {
    this.orgWideEmailAddress = orgWideEmailAddress;
  }

  public String getOrgWideEmailAddressName() {
    return this.orgWideEmailAddressName;
  }

  public void setOrgWideEmailAddressName(String orgWideEmailAddressName) {
    this.orgWideEmailAddressName = orgWideEmailAddressName;
  }

  public String getTemplateId() {
    return this.templateId;
  }

  public void setTemplateId(String templateId) {
    this.templateId = templateId;
  }

  public String getSubject() {
    return this.subject;
  }

  public void setSubject(String subject) {
    this.subject = subject;
  }

  public String getBody() {
    return this.body;
  }

  public void setBody(String body) {
    this.body = body;
  }

  public String getWhatId() {
    return this.whatId;
  }

  public void setWhatId(String whatId) {
    this.whatId = whatId;
  }

  public SaveAsActivityEnum getSaveAsActivityMethod() {
    return this.saveAsActivityMethod;
  }

  public void setSaveAsActivityMethod(SaveAsActivityEnum saveAsActivityMethod) {
    this.saveAsActivityMethod = saveAsActivityMethod;
  }

  public Integer getBatchSize() {
    return this.batchSize;
  }

  public void setBatchSize(Integer batchSize) {
    this.batchSize = batchSize;
  }

  public String getTrackingTaskId() {
    return this.trackingTaskId;
  }

  public void setTrackingTaskId(String trackingTaskId) {
    this.trackingTaskId = trackingTaskId;
  }

  public Integer getTotalRecipients() {
    return this.totalRecipients;
  }

  public void setTotalRecipients(Integer totalRecipients) {
    this.totalRecipients = totalRecipients;
  }

  public Integer getTotalSent() {
    return this.totalSent;
  }

  public void setTotalSent(Integer totalSent) {
    this.totalSent = totalSent;
  }

  public Integer getTotalFailed() {
    return this.totalFailed;
  }

  public void setTotalFailed(Integer totalFailed) {
    this.totalFailed = totalFailed;
  }
}
