/**
 * GeoMapControllerTest: Class to test GeoMap server-side functionality.
 *
 */
@isTest
private with sharing class GeoMapControllerTest {
  /**
   * createTestData: Setup method to create common test data.
   */
  @TestSetup
  static void createTestData() {
    /**
     * 5 accounts will have 10 assets.
     * 4 contacts will have 8 assets.
     * 2 products will have 8 assets.
     * 1 incident will have 10 assets.
     * 1 incident without asset.
     */
    List<Account> accounts = AIM_TestFactory.createAccounts(5);
    List<Contact> contacts = AIM_TestFactory.createContacts(4, accounts);
    List<Product2> products = new List<Product2>();
    List<Asset> assets = new List<Asset>();
    List<Incident> incidents = AIM_TestFactory.createIncidents(3);
    List<IncidentRelatedItem> incidentRelatedItems = new List<IncidentRelatedItem>();

    /**
     * Create 2 products. 1 has product family.
     */
    for (Integer counter = 1; counter <= 2; counter++) {
      Product2 product = new Product2(Name = 'Test Product ' + counter);
      if (counter == 1) {
        product.Family = 'None';
      }
      products.add(product);
    }
    insert products;

    /**
     * Create 10 assets. 8 have parent contact, account and product. 2 have only parent account.
     */
    for (Integer counter = 1; counter <= 10; counter++) {
      if (counter <= 8) {
        Contact contact = contacts.get(Math.mod(counter, 4));
        Asset asset = new Asset(
          Name = 'Test Asset ' + counter,
          ContactId = contact.Id,
          AccountId = contact.accountId,
          Latitude = 37 + Math.random(),
          Longitude = -122 + Math.random(),
          product2Id = products.get(Math.mod(counter, 2)).Id
        );
        assets.add(asset);
      } else {
        Asset asset = new Asset(
          Name = 'Test Asset ' + counter,
          AccountId = accounts.get(4).Id,
          Latitude = 37 + Math.random(),
          Longitude = -122 + Math.random()
        );
        assets.add(asset);
      }
    }
    insert assets;

    /**
     * Attach 10 assets to 1 incident. 1 incident will be without any asset.
     */
    for (Integer counter = 1; counter <= 10; counter++) {
      IncidentRelatedItem incidentRelatedItem = new IncidentRelatedItem(
        IncidentId = incidents.get(0).Id,
        AssetId = assets.get(counter - 1).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      incidentRelatedItems.add(incidentRelatedItem);
    }
    insert incidentRelatedItems;
  }

  /**
   * testAssetByAccount: method to test assets data related to the parent account records.
   */
  @isTest
  static void testAssetByAccount() {
    List<Id> accountIds = new List<Id>();
    for (Account account : [SELECT Id FROM ACCOUNT]) {
      accountIds.add(account.Id);
    }
    List<GeoMapAsset> response = GeoMapController.getAssets(accountIds);
    System.assertEquals(
      response.size(),
      10,
      'Incorrect numbner of Assets retrieved for Accounts.'
    );
  }

  /**
   * testAssetByContact: method to test assets data related to the parent contact records.
   */
  @isTest
  static void testAssetByContact() {
    List<Id> contactIds = new List<Id>();
    for (Contact contact : [SELECT Id FROM CONTACT]) {
      contactIds.add(contact.Id);
    }
    List<GeoMapAsset> response = GeoMapController.getAssets(contactIds);
    System.assertEquals(
      response.size(),
      8,
      'Incorrect numbner of Assets retrieved for Contacts.'
    );
  }

  /**
   * testAssetByProduct: method to test assets data related to the parent product records.
   */
  @isTest
  static void testAssetByProduct() {
    List<Id> productIds = new List<Id>();
    for (Product2 product : [SELECT Id FROM PRODUCT2]) {
      productIds.add(product.Id);
    }
    List<GeoMapAsset> response = GeoMapController.getAssets(productIds);
    System.assertEquals(
      response.size(),
      8,
      'Incorrect numbner of Assets retrieved for Products.'
    );
  }

  /**
   * testAssetByAsset: method to test assets data related to the asset records.
   */
  @isTest
  static void testAssetByAsset() {
    List<Id> assetIds = new List<Id>();
    for (Asset asset : [SELECT Id FROM ASSET]) {
      assetIds.add(asset.Id);
    }
    List<GeoMapAsset> response = GeoMapController.getAssets(assetIds);
    System.assertEquals(
      response.size(),
      10,
      'Incorrect numbner of Assets retrieved for Assets.'
    );
  }

  /**
   * testAssetByIncident: method to test assets data related to the incident records.
   */
  @isTest
  static void testAssetByIncident() {
    List<Id> incidentIds = new List<Id>();
    for (Incident incident : [SELECT Id FROM INCIDENT]) {
      incidentIds.add(incident.Id);
    }
    List<GeoMapAsset> response = GeoMapController.getAssets(incidentIds);
    System.assertEquals(
      response.size(),
      10,
      'Incorrect numbner of Assets retrieved for Incidents.'
    );
  }

  /**
   * testAssetByIncidentWithNoAsset: method to test assets data related to the incident records without assets.
   */
  @isTest
  static void testAssetByIncidentWithNoAsset() {
    List<Id> incidentIds = new List<Id>();
    for (Incident incident : [
      SELECT Id
      FROM INCIDENT
      WHERE Subject = 'Test Incident 2'
    ]) {
      incidentIds.add(incident.Id);
    }
    List<GeoMapAsset> response = GeoMapController.getAssets(incidentIds);
    System.assertEquals(
      response.size(),
      0,
      'Incorrect numbner of Assets retrieved for Incidents.'
    );
  }

  /**
   * testNullInput: method to test custom exception for null input.
   */
  @isTest
  static void testNullInput() {
    List<Id> incidentIds = null;
    Boolean exceptionThrown = false;
    try {
      List<GeoMapAsset> response = GeoMapController.getAssets(incidentIds);
      System.assert(response.size() != 0, 'Should not reach this line.');
    } catch (Exception e) {
      System.assert(
        e instanceof AIMBaseException.AIMInvalidInputException,
        'Incorrect Exception thrown for null input.'
      );
      exceptionThrown = true;
    } finally {
      System.assert(exceptionThrown, 'Exception was not thrown');
    }
  }

  /**
   * testNullInput: method to test custom exception for input of unsupported sObject type.
   */
  @isTest
  static void testUnsupportedInput() {
    List<Id> incidentRelatedItemIds = new List<Id>();
    for (IncidentRelatedItem incidentRelatedItem : [
      SELECT Id
      FROM IncidentRelatedItem
    ]) {
      incidentRelatedItemIds.add(incidentRelatedItem.Id);
    }
    Boolean exceptionThrown = false;
    try {
      List<GeoMapAsset> response = GeoMapController.getAssets(
        incidentRelatedItemIds
      );
      System.assert(response.size() != 0, 'Should not reach this line.');
    } catch (Exception e) {
      System.assert(
        e instanceof AIMBaseException.AIMInvalidInputException,
        'Incorrect Exception thrown for input of unsupported sObject type.'
      );
      exceptionThrown = true;
    } finally {
      System.assert(exceptionThrown, 'Exception was not thrown');
    }
  }
}
