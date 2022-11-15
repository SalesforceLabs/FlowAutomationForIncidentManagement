@isTest
public class TestFactory {
  static List<Incident> incidents = new List<Incident>();
  static List<Account> accounts = new List<Account>();
  static List<Contact> contacts = new List<Contact>();
  static List<Product2> products = new List<Product2>();
  public static List<Incident> getIncidents() {
    if (!incidents.isEmpty()) {
      return incidents;
    }

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

  public static List<Account> getAccounts() {
    if (!accounts.isEmpty()) {
      return accounts;
    }
    for (Integer counter = 0; counter < 5; counter++) {
      Account account = new Account(Name = 'Test Account ' + counter);
      accounts.add(account);
    }
    insert accounts;
    return accounts;
  }

  public static List<Contact> getContacts() {
    if (!contacts.isEmpty()) {
      return contacts;
    }
    for (Integer counter = 0; counter < 5; counter++) {
      Contact contact = new Contact(
        LastName = 'Test Contact ' + counter,
        AccountId = accounts.get(counter).Id
      );
      contacts.add(contact);
    }
    insert contacts;
    return contacts;
  }

  public static List<Product2> getProducts() {
    if (!products.isEmpty()) {
      return products;
    }
    for (Integer counter = 0; counter < 10; counter++) {
      Product2 product = new Product2(Name = 'Test Product ' + counter);
      products.add(product);
    }
    insert products;
    return products;
  }
}
