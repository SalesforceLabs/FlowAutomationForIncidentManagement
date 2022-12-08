public with sharing class AIMConstants {
  public static final Integer MAX_TASK_SUBJECT_LENGTH = Task.Subject.getDescribe()
    .getLength();
  public static final Integer MAX_TASK_DESCRIPTION_LENGTH = Task.Description.getDescribe()
    .getLength();
  public static final Integer TASK_DESCRIPTION_TRUNCATION_THRESHOLD =
    Task.Description.getDescribe().getLength() - 300;

  public static final Integer APEX_QUEUEABLE_BATCH_COUNT_THRESHOLD = 5;
  public static final Integer BATCH_APEX_FLEX_QUEUE_THRESHOLD = 95;

  public static final String[] HTML2TEXT_REGEX_PATTERNS = new List<String>{
    '(?i)(?s)<style.*?>.*?</style>',
    '(?i)<br\\s*/?>',
    '<(?i).*?>',
    '\t',
    '\n{3,}'
  };
  public static final String[] HTML2TEXT_REPLACEMENTS = new List<String>{
    '\n',
    '\n',
    '\n',
    '\n',
    '\n\n'
  };
  public static final String EMAIL_TASK_DESCRIPTION = 'From: {0} ({1})\n\n Subject: {2}\nBody: {3}';

  public static final String TRACKING_TASK_SUBJECT = 'Send Emails Job Tracker [{0}]';
  public static final String TRACKING_TASK_DESCRIPTION_HEADER = 'Emails Queued at {0}\nTotal Emails Queued: {1}';
  public static final String TRACKING_TASK_DESCRIPTION_BODY = '\n\n ========================= \n{0} At: {1}\nTotal Emails Sent: {2}\n Total Emails Failed: {3}';
  public static final String TRACKING_TASK_DESCRIPTION_TRUNCATED = '\n\n[logs truncated due to size limit]{0}';
}
