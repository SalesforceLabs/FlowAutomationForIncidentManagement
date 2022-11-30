/**
 * GeoMapDataHandler: Handler class for dynamically retrieving Assets and related records and generating response wrapper.
 */
public with sharing class GeoMapDataHandler {
  /**
   * getAssetRecordsForIncidentType: Method to retrieve Assets and related records data when input is of Incident SObject type. Incident and Asset have many-to-many relations with IncidentRelatedItem as a juntion object.
   *
   * @param inputIds (List<Id>): List of Incident record Ids
   *
   * @return List<GeoMapAsset>: Apex Type wrapper with Assets and related records data.
   */
  public static List<GeoMapAsset> getAssetRecordsForIncidentType(
    List<Id> inputIds
  ) {
    List<GeoMapAsset> response = new List<GeoMapAsset>();
    SObjectAccessDecision decision = Security.stripInaccessible(
      System.AccessType.READABLE,
      [
        SELECT
          Id,
          AssetId,
          Asset.Name,
          Asset.Latitude,
          Asset.Longitude,
          Asset.Status,
          Asset.AccountId,
          Asset.Account.Name,
          Asset.ContactId,
          Asset.Contact.Name,
          Asset.Product2Id,
          Asset.Product2.Name,
          Asset.Product2.Family,
          IncidentId,
          Incident.IncidentNumber,
          Incident.Status
        FROM IncidentRelatedItem
        WHERE IncidentId IN :inputIds
      ]
    );
    for (SObject incidentRelatedItem : decision.getRecords()) {
      GeoMapAsset output = new GeoMapAsset();
      SObject asset = incidentRelatedItem.getSObject(
        SObjectFieldAPINameConstants.ASSET
      );
      SObject incident = incidentRelatedItem.getSObject(
        SObjectFieldAPINameConstants.INCIDENT
      );
      SObject account = asset?.getSObject(SObjectFieldAPINameConstants.ACCOUNT);
      SObject contact = asset?.getSObject(SObjectFieldAPINameConstants.CONTACT);
      SObject product = asset?.getSObject(SObjectFieldAPINameConstants.PRODUCT);
      output.relatedObjectType = GeoMapController.SupportedObject.INCIDENT.name();
      output.assetId = incidentRelatedItem.isSet(
          SObjectFieldAPINameConstants.ASSET_ID
        )
        ? (String) incidentRelatedItem
            ?.get(SObjectFieldAPINameConstants.ASSET_ID)
        : null;
      output.assetName = asset.isSet(SObjectFieldAPINameConstants.ASSET_NAME)
        ? (String) asset?.get(SObjectFieldAPINameConstants.ASSET_NAME)
        : null;
      output.assetStatus = asset.isSet(
          SObjectFieldAPINameConstants.ASSET_STATUS
        )
        ? (String) asset?.get(SObjectFieldAPINameConstants.ASSET_STATUS)
        : null;
      output.incidentId = incidentRelatedItem.isSet(
          SObjectFieldAPINameConstants.INCIDENT_ID
        )
        ? (String) incidentRelatedItem
            ?.get(SObjectFieldAPINameConstants.INCIDENT_ID)
        : null;
      output.incidentNumber = incident.isSet(
          SObjectFieldAPINameConstants.INCIDENT_NUMBER
        )
        ? (String) incident?.get(SObjectFieldAPINameConstants.INCIDENT_NUMBER)
        : null;
      output.incidentStatus = incident.isSet(
          SObjectFieldAPINameConstants.INCIDENT_STATUS
        )
        ? (String) incident?.get(SObjectFieldAPINameConstants.INCIDENT_STATUS)
        : null;
      output.assetLatitude = asset.isSet(
          SObjectFieldAPINameConstants.ASSET_LATITUDE
        )
        ? String.valueOf(
            asset?.get(SObjectFieldAPINameConstants.ASSET_LATITUDE)
          )
        : null;
      output.assetLongitude = asset.isSet(
          SObjectFieldAPINameConstants.ASSET_LONGITUDE
        )
        ? String.valueOf(
            asset?.get(SObjectFieldAPINameConstants.ASSET_LONGITUDE)
          )
        : null;
      output.accountId = asset.isSet(SObjectFieldAPINameConstants.ACCOUNT_ID)
        ? (String) asset?.get(SObjectFieldAPINameConstants.ACCOUNT_ID)
        : null;
      output.accountName = (asset.isSet(
          SObjectFieldAPINameConstants.ACCOUNT_ID
        ) &&
        account != null &&
        account.isSet(SObjectFieldAPINameConstants.ACCOUNT_NAME))
        ? (String) account?.get(SObjectFieldAPINameConstants.ACCOUNT_NAME)
        : null;
      output.contactId = asset.isSet(SObjectFieldAPINameConstants.CONTACT_ID)
        ? (String) asset?.get(SObjectFieldAPINameConstants.CONTACT_ID)
        : null;
      output.contactName = (asset.isSet(
          SObjectFieldAPINameConstants.CONTACT_ID
        ) &&
        contact != null &&
        contact.isSet(SObjectFieldAPINameConstants.CONTACT_NAME))
        ? (String) contact?.get(SObjectFieldAPINameConstants.CONTACT_NAME)
        : null;
      output.productId = asset.isSet(SObjectFieldAPINameConstants.PRODUCT_ID)
        ? (String) asset?.get(SObjectFieldAPINameConstants.PRODUCT_ID)
        : null;
      output.productName = (asset.isSet(
          SObjectFieldAPINameConstants.PRODUCT_ID
        ) &&
        product != null &&
        product.isSet(SObjectFieldAPINameConstants.PRODUCT_NAME))
        ? (String) product?.get(SObjectFieldAPINameConstants.PRODUCT_NAME)
        : null;
      output.productFamily = (asset.isSet(
          SObjectFieldAPINameConstants.PRODUCT_ID
        ) &&
        product != null &&
        product.isSet(SObjectFieldAPINameConstants.PRODUCT_FAMILY))
        ? (String) product?.get(SObjectFieldAPINameConstants.PRODUCT_FAMILY)
        : null;
      response.add(output);
    }
    return response;
  }

  /**
   * getAssetRecordsForObjectTypes Common method to retrieve Assets and related records data when input is of Sobject type that has one-to-many relationship with Asset like Account, Contact, Product etc.
   *
   * @param inputIds (List<Id>): List of related record Ids
   * @param objectType (GeoMapController.SupportedObject): Enum for the passed Ids' SObject type.
   *
   * @return List<GeoMapAsset>: Apex Type wrapper with Assets and related records data.
   *
   * @throws Class AIMBaseException.AIMNoAccessException Exception for User access check
   */
  public static List<GeoMapAsset> getAssetRecordsForObjectTypes(
    List<Id> inputIds,
    GeoMapController.SupportedObject objectType
  ) {
    String filteredSObjectField = GeoMapController.FILTER_FIELD_BY_ENUM.get(
      objectType
    );
    List<GeoMapAsset> response = new List<GeoMapAsset>();
    if (String.isNotBlank(filteredSObjectField)) {
      Boolean hasReadAccess = AIMSecurityUtility.checkReadAccess(
        'Asset',
        filteredSObjectField
      );
      if (hasReadAccess) {
        String query =
          'SELECT Id,    Name,    Latitude,    Longitude,    Status,    AccountId,    Account.Name,    ContactId,    Contact.Name,    Product2Id,    Product2.Name,    Product2.Family  FROM Asset  WHERE ' +
          String.escapeSingleQuotes(filteredSObjectField) +
          ' IN :inputIds';
        SObjectAccessDecision decision = Security.stripInaccessible(
          System.AccessType.READABLE,
          Database.query(query)
        );
        for (SObject asset : decision.getRecords()) {
          GeoMapAsset output = new GeoMapAsset();
          SObject account = asset
            ?.getSObject(SObjectFieldAPINameConstants.ACCOUNT);
          SObject contact = asset
            ?.getSObject(SObjectFieldAPINameConstants.CONTACT);
          SObject product = asset
            ?.getSObject(SObjectFieldAPINameConstants.PRODUCT);
          output.relatedObjectType = objectType.name();
          output.assetId = (String) asset.get(SObjectFieldAPINameConstants.ID);
          output.assetName = asset.isSet(
              SObjectFieldAPINameConstants.ASSET_NAME
            )
            ? (String) asset?.get(SObjectFieldAPINameConstants.ASSET_NAME)
            : null;
          output.assetLatitude = asset.isSet(
              SObjectFieldAPINameConstants.ASSET_LATITUDE
            )
            ? String.valueOf(
                asset?.get(SObjectFieldAPINameConstants.ASSET_LATITUDE)
              )
            : null;
          output.assetLongitude = asset.isSet(
              SObjectFieldAPINameConstants.ASSET_LONGITUDE
            )
            ? String.valueOf(
                asset?.get(SObjectFieldAPINameConstants.ASSET_LONGITUDE)
              )
            : null;
          output.assetStatus = asset.isSet(
              SObjectFieldAPINameConstants.ASSET_STATUS
            )
            ? (String) asset?.get(SObjectFieldAPINameConstants.ASSET_STATUS)
            : null;
          output.accountId = asset.isSet(
              SObjectFieldAPINameConstants.ACCOUNT_ID
            )
            ? (String) asset?.get(SObjectFieldAPINameConstants.ACCOUNT_ID)
            : null;
          output.accountName = (asset.isSet(
              SObjectFieldAPINameConstants.ACCOUNT_ID
            ) &&
            account != null &&
            account.isSet(SObjectFieldAPINameConstants.ACCOUNT_NAME))
            ? (String) account?.get(SObjectFieldAPINameConstants.ACCOUNT_NAME)
            : null;
          output.contactId = asset.isSet(
              SObjectFieldAPINameConstants.CONTACT_ID
            )
            ? (String) asset.get(SObjectFieldAPINameConstants.CONTACT_ID)
            : null;
          output.contactName = (asset.isSet(
              SObjectFieldAPINameConstants.CONTACT_ID
            ) &&
            contact != null &&
            contact.isSet(SObjectFieldAPINameConstants.CONTACT_NAME))
            ? (String) contact.get(SObjectFieldAPINameConstants.CONTACT_NAME)
            : null;
          output.productId = asset.isSet(
              SObjectFieldAPINameConstants.PRODUCT_ID
            )
            ? (String) asset.get(SObjectFieldAPINameConstants.PRODUCT_ID)
            : null;
          output.productName = (asset.isSet(
              SObjectFieldAPINameConstants.PRODUCT_ID
            ) &&
            product != null &&
            product.isSet(SObjectFieldAPINameConstants.PRODUCT_NAME))
            ? (String) product?.get(SObjectFieldAPINameConstants.PRODUCT_NAME)
            : null;
          output.productFamily = (asset.isSet(
              SObjectFieldAPINameConstants.PRODUCT_ID
            ) &&
            product != null &&
            product.isSet(SObjectFieldAPINameConstants.PRODUCT_FAMILY))
            ? (String) product?.get(SObjectFieldAPINameConstants.PRODUCT_FAMILY)
            : null;
          response.add(output);
        }
      } else {
        throw new AIMBaseException.AIMNoAccessException(
          String.format(
            System.Label.AIM_GeoMap_NoAccess,
            new List<Object>{ filteredSObjectField, 'Asset' }
          )
        );
      }
    }
    return response;
  }
}
