public static void populateData() {
    List<Account> accounts = new List<Account>();
    List<Contact> contacts = new List<Contact>();
    List<Case> cases = new List<Case>();
    List<Product2> products = new List<Product2>();
    List<Asset> assets = new List<Asset>();
    List<Incident> incidents = new List<Incident>();
    List<IncidentRelatedItem> incidentRelatedItems = new List<IncidentRelatedItem>();
    List<CaseRelatedIssue> caseRelatedIssues = new List<CaseRelatedIssue>();

    for (Integer counter = 1; counter <= 10; counter++) {
      Account account = new Account(Name = 'Test Account ' + counter);
      accounts.add(account);
    }
    insert accounts;

    for (Integer counter = 1; counter <= 20; counter++) {
      Contact contact = new Contact(
        LastName = 'Test Contact ' + counter,
        AccountId = accounts.get(Math.mod(counter, 10)).Id
      );
      contacts.add(contact);
    }
    insert contacts;

    for (Integer counter = 1; counter <= 40; counter++) {
      Case caseRecord = new Case(
        Subject = 'Test Case ' + counter,
        Status = 'New',
        ContactId = contacts.get(Math.mod(counter, 20)).Id
      );
      cases.add(caseRecord);
    }
    insert cases;

    for (Integer counter = 1; counter <= 10; counter++) {
      Product2 product = new Product2(Name = 'Test Product ' + counter);
      products.add(product);
    }
    insert products;

    for (Integer counter = 1; counter <= 40; counter++) {
      Contact contact = contacts.get(Math.mod(counter, 20));
      Asset asset = new Asset(
        Name = 'Test Asset ' + counter,
        ContactId = contact.Id,
        AccountId = contact.accountId,
        Latitude = 37 + Math.random(),
        Longitude = 122 + Math.random()
      );
      assets.add(asset);
    }
    insert assets;

    for (Integer counter = 1; counter <= 5; counter++) {
      Incident incident = new Incident(
        Subject = 'Test Incident ' + counter,
        Impact = 'High',
        Urgency = 'High',
        Priority = 'Critical'
      );
      incidents.add(incident);
    }
    insert incidents;

    for (Integer counter = 1; counter <= 40; counter++) {
      CaseRelatedIssue caseRelatedIssue = new CaseRelatedIssue(
        RelatedIssueId = incidents.get(Math.mod(counter, 5)).Id,
        CaseId = cases.get(counter - 1).Id,
        RelationshipType = 'Similar'
      );
      caseRelatedIssues.add(caseRelatedIssue);
    }
    insert caseRelatedIssues;

    for (Integer counter = 1; counter <= 80; counter++) {
      IncidentRelatedItem incidentRelatedItem = new IncidentRelatedItem(
        IncidentId = incidents.get(Math.mod(counter, 5)).Id,
        AssetId = assets.get(Math.mod(counter, 39)).Id,
        ImpactType = '	Partially Business-Blocking'
      );
      incidentRelatedItems.add(incidentRelatedItem);
    }
    insert incidentRelatedItems;
  }