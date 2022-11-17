/**
 * AIMTestDataFactory: Test data Factory class generates data that can be used in all the test classes
 */
@isTest
public with sharing class AIMTestDataFactory {
  /**
   * createIncidents : create Incident records
   * @param numberOfIncidents (integer): number of records to be created
   * @return List<Incident>: List of Incidents
   */

  public static List<Incident> createIncidents(integer numberOfIncidents) {
    List<Incident> incidents = new List<Incident>();
    for (Integer counter = 0; counter < numberOfIncidents; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Category = 'C' + counter,
        SubCategory = 'S' + counter,
        Type = 'T' + counter
      );
      incidents.add(incident);
    }
    insert incidents;
    return incidents;
  }

  /**
   * createAccounts : create Account records
   * @param numberOfAccounts (integer): number of records to be created
   * @return List<Account>: List of Accounts
   */
  public static List<Account> createAccounts(integer numberOfAccounts) {
    List<Account> accounts = new List<Account>();
    for (Integer counter = 0; counter < numberOfAccounts; counter++) {
      Account account = new Account(Name = 'Test Account ' + counter);
      accounts.add(account);
    }
    insert accounts;
    return accounts;
  }

  /**
   * createContacts : create Contact records
   * @param numberOfContacts (integer): number of records to be created
   * @param accounts (List<Account>):  List of Accounts
   * @return List<Contact>: List of Contacts
   */
  public static List<Contact> createContacts(
    integer numberOfContacts,
    List<Account> accounts
  ) {
    List<Contact> contacts = new List<Contact>();
    for (Integer counter = 0; counter < numberOfContacts; counter++) {
      Contact contact = new Contact();
      contact.LastName = 'Test Contact ' + counter;
      if (accounts != null && !accounts.isEmpty()) {
        contact.AccountId = accounts.get(0).Id;
      }

      contacts.add(contact);
    }
    insert contacts;
    return contacts;
  }
  /**
   * createProducts : create Product records
   * @param numberOfProducts (integer): number of records to be created
   * @return List<Product2>: List of Products
   */
  public static List<Product2> createProducts(integer numberOfProducts) {
    List<Product2> products = new List<Product2>();
    for (Integer counter = 0; counter < numberOfProducts; counter++) {
      Product2 product = new Product2(Name = 'Test Product ' + counter);
      products.add(product);
    }
    insert products;
    return products;
  }
  /**
   * createCases : create Case records
   * @param numberOfCases (integer): number of records to be created
   * @param contacts (List<Contact>): List of Contacts
   * @param accounts (List<Account>): List of Accounts
   * @return List<Case>: List of Cases
   */
  public static List<Case> createCases(
    integer numberOfCases,
    List<Contact> contacts,
    List<Account> accounts,
    List<Asset> assets
  ) {
    List<Case> cases = new List<Case>();
    for (Integer counter = 0; counter < numberOfCases; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New'
      );
      if (contacts != null && !contacts.isEmpty()) {
        caseRecord.contactId = contacts.get(0).Id;
      }
      if (accounts != null && !accounts.isEmpty()) {
        caseRecord.accountId = accounts.get(0).Id;
      }
      if (assets != null && !assets.isEmpty()) {
        caseRecord.AssetId = assets.get(0).Id;
      }
      cases.add(caseRecord);
    }
    insert cases;
    return cases;
  }

  /**
   * createAssets : create Asset records
   * @param numberOfAssets (integer): number of records to be created
   * @param contacts (List<Contact>): List of Contacts
   * @param products (List<Product2>): List of Products
   * @return List<Case>: List of Cases
   */
  public static List<Asset> createAssets(
    integer numberOfAssets,
    List<Product2> products,
    List<Contact> contacts
  ) {
    List<Asset> assets = new List<Asset>();
    for (Integer counter = 0; counter < numberOfAssets; counter++) {
      Contact contact = contacts.get(0);
      Asset asset = new Asset(
        Name = 'Test Asset ' + counter,
        ContactId = contact.Id,
        AccountId = contact.AccountId
      );
      if (products != null && !products.isEmpty()) {
        asset.Product2Id = products.get(0).Id;
      }

      assets.add(asset);
    }

    return assets;
  }
}
