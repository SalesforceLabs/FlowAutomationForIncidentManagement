/**
 * GeoMapController: Apex Controller for GeoMap LWC. The controller processes different SObject types and returns Assets along with their related information as Apex Type wrapper.
 */
public with sharing class GeoMapController {
  /**
   * SupportedObject: Enum for supported SObjects as input.
   */
  public enum SupportedObject {
    ACCOUNT,
    CONTACT,
    PRODUCT2,
    ASSET,
    INCIDENT
  }

  public static final Map<SupportedObject, String> FILTER_FIELD_BY_ENUM = new Map<SupportedObject, String>{
    SupportedObject.ACCOUNT => 'AccountId',
    SupportedObject.CONTACT => 'ContactId',
    SupportedObject.PRODUCT2 => 'Product2Id',
    SupportedObject.ASSET => 'Id',
    SupportedObject.INCIDENT => ''
  };

  /**
   * getAssets: Entry point to the apex controller from LWC. This method returns Assets inforation wrapped in an Apex type.
   *
   * @param inputIds (List<Id>): List of SObject record Ids.
   *
   * @return List<GeoMapAsset>: Apex Type wrapper with Assets and related records data.
   *
   * @throws Class AIMBaseException.AIMInvalidInputException Input validation like null, empty.
   * @throws Class AIMBaseException Generic user-friendly exception.
   */
  @AuraEnabled(cacheable=true scope='global')
  public static List<GeoMapAsset> getAssets(List<Id> inputIds) {
    try {
      if (inputIds != null && !inputIds.isEmpty()) {
        SupportedObject sObjectType = SupportedObject.valueOf(
          String.valueOf(inputIds.get(0)?.getSObjectType())
        );
        switch on sObjectType {
          when INCIDENT {
            return GeoMapDataHandler.getAssetRecordsForIncidentType(inputIds);
          }
          when ACCOUNT, CONTACT, PRODUCT2, ASSET {
            return GeoMapDataHandler.getAssetRecordsForObjectTypes(
              inputIds,
              sObjectType
            );
          }
        }
      }
      throw new AIMBaseException.AIMInvalidInputException(
        System.Label.AIM_GeoMap_Null_Exception
      );
    } catch (AIMBaseException.AIMInvalidInputException aimInvalidInputException) {
      throw aimInvalidInputException;
    } catch (NoSuchElementException noSuchElementException) {
      throw new AIMBaseException.AIMInvalidInputException(
        String.format(
          System.Label.AIM_GeoMap_Unsupported_Exception,
          new List<String>{ String.valueOf(inputIds.get(0)?.getSObjectType()) }
        ),
        noSuchElementException
      );
    } catch (Exception e) {
      throw new AIMBaseException(System.Label.AIM_GeoMap_Generic_Exception, e);
    }
  }
}
