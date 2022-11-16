@isTest
public class TestFactory {
  public static List<Incident> createIncidents(integer numberOfIncidents) {
    List<Incident> incidents = new List<Incident>();
    for (Integer counter = 0; counter < numberOfIncidents; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical'
      );
      incidents.add(incident);
    }
    insert incidents;
    return incidents;
  }
  public static List<Incident> createIncidentsWithAttributes() {
    List<Incident> incidents = new List<Incident>();
    for (Integer counter = 0; counter < 5; counter++) {
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
    for (Integer counter = 5; counter < 8; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical',
        Category = 'C0',
        SubCategory = 'S0',
        Type = 'T0'
      );
      incidents.add(incident);
    }
    for (Integer counter = 8; counter < 10; counter++) {
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

  public static List<Account> createAccounts(integer numberOfAccounts) {
    List<Account> accounts = new List<Account>();
    for (Integer counter = 0; counter < numberOfAccounts; counter++) {
      Account account = new Account(Name = 'Test Account ' + counter);
      accounts.add(account);
    }
    insert accounts;
    return accounts;
  }

  public static List<Contact> createContacts(
    integer numberOfContacts,
    List<Account> accounts
  ) {
    List<Contact> contacts = new List<Contact>();
    for (Integer counter = 0; counter < numberOfContacts; counter++) {
      Contact contact = new Contact(
        LastName = 'Test Contact ' + counter,
        AccountId = accounts.get(counter).Id
      );
      contacts.add(contact);
    }
    insert contacts;
    return contacts;
  }

  public static List<Product2> createProducts(integer numberOfProducts) {
    List<Product2> products = new List<Product2>();
    for (Integer counter = 0; counter < numberOfProducts; counter++) {
      Product2 product = new Product2(Name = 'Test Product ' + counter);
      products.add(product);
    }
    insert products;
    return products;
  }

  public static List<Case> createCases(integer numberOfCases) {
    List<Case> cases = new List<Case>();
    for (Integer counter = 0; counter < numberOfCases; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New'
      );
      cases.add(caseRecord);
    }
    insert cases;
    return cases;
  }
}
