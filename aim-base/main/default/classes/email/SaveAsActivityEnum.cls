/**
 * SaveAsActivityEnum Enum for method of saving emails in the org.
 * OFF = Emails will not be logged.
 * AUTO = Emails will be logged using OOB Messaging.SingleEmailMessage setSaveAsActivity(true) method.
 * MANUAL = Emails will be logged as Task manually in the apex.
 */
public enum SaveAsActivityEnum {
  OFF,
  AUTO,
  MANUAL
}
