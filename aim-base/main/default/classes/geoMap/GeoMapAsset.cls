/**
 * GeoMapAsset: Apex type wrapper for geoMap lightning web component
 */
public with sharing class GeoMapAsset {
  @AuraEnabled
  public String relatedObjectType { get; set; }
  @AuraEnabled
  public String assetId { get; set; }
  @AuraEnabled
  public String assetName { get; set; }
  @AuraEnabled
  public String assetStatus { get; set; }
  @AuraEnabled
  public String accountId { get; set; }
  @AuraEnabled
  public String accountName { get; set; }
  @AuraEnabled
  public String contactId { get; set; }
  @AuraEnabled
  public String contactName { get; set; }
  @AuraEnabled
  public String incidentId { get; set; }
  @AuraEnabled
  public String incidentNumber { get; set; }
  @AuraEnabled
  public String incidentStatus { get; set; }
  @AuraEnabled
  public String assetLatitude { get; set; }
  @AuraEnabled
  public String assetLongitude { get; set; }
  @AuraEnabled
  public String productId { get; set; }
  @AuraEnabled
  public String productName { get; set; }
  @AuraEnabled
  public String productFamily { get; set; }
}
