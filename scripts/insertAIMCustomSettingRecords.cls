/**
 * currentUserId stores the current user id
 *
 */
static String currentUserId = System.UserInfo.getUserId();

/**
 * insertAIMIncidentDetectorSetting insert a custom setting record to bypass AIM - Incident Decetor flow
 */
public static void insertAIMIncidentDetectorSetting() {
    List<AIMBypassFlows__c> settings = new List<AIMBypassFlows__c>();
    settings = [
        SELECT Id, isActive__c
        FROM AIMBypassFlows__c
        WHERE
        Flow_Developer_Name__c = 'AIM_IncidentDetector'
        AND SetupOwnerId = :currentUserId
        LIMIT 1
    ];
    if (!settings.isEmpty()) {
        settings[0].isActive__c = true;
    } else {
        settings.add(
            new AIMBypassFlows__c(
                isActive__c = true,
                Flow_Developer_Name__c = 'AIM_IncidentDetector',
                SetupOwnerId = currentUserId
            )
        );
    }

    upsert settings;
}