import { createElement } from "lwc";
import SelectedMapPicker from "c/selectedMapPicker";

const data = {
  accountId: "001B000001RHDc3IAH",
  accountName: "Test Account 1",
  assetId: "02iB0000001qR0bIAE",
  assetLatitude: "37.052854654411200",
  assetLongitude: "-121.166374839168850",
  assetName: "Test Asset 19",
  assetStatus: "Installed",
  contactId: "003B000000Ll9nZIAR",
  contactName: "Test Contact 20",
  productId: "01tB0000002aoiTIAQ",
  productName: "Test Product 10",
  incidentStatus: "New",
  incidentNumber: "Test Incident 1",
  relatedObjectType: "INCIDENT"
};

const labels = {
  AccountLabel: "Account",
  ContactLabel: "Contact",
  ProductLabel: "Product",
  ProductFamilyLabel: "Product Family",
  AssetLabel: "Asset",
  IncidentLabel: "Incident",
  IncidentStatusLabel: "Status"
};

describe("c-selected-map-picker", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders links for available objects only", () => {
    const element = createElement("c-selected-map-picker", {
      is: SelectedMapPicker
    });

    element.selectedMarkerData = data;
    element.objectsInfo = labels;

    document.body.appendChild(element);

    const anchorList = element.shadowRoot.querySelectorAll("a");
    expect(anchorList.length).toBe(5);
  });

  it("render tiles without input data", () => {
    const element = createElement("c-selected-map-picker", {
      is: SelectedMapPicker
    });

    document.body.appendChild(element);

    const anchorList = element.shadowRoot.querySelectorAll(".slds-tile");
    expect(anchorList.length).toBe(0);
  });

  it("click the record in tile", () => {
    const element = createElement("c-selected-map-picker", {
      is: SelectedMapPicker
    });

    element.selectedMarkerData = data;
    element.objectsInfo = labels;

    document.body.appendChild(element);

    const anchorList = element.shadowRoot.querySelectorAll("a");
    anchorList[0].dispatchEvent(new CustomEvent("click"));
    anchorList[1].dispatchEvent(new CustomEvent("click"));
    anchorList[2].dispatchEvent(new CustomEvent("click"));
    anchorList[3].dispatchEvent(new CustomEvent("click"));
    anchorList[4].dispatchEvent(new CustomEvent("click"));
  });

  it("is accessible", async () => {
    const element = createElement("c-selected-map-picker", {
      is: SelectedMapPicker
    });

    element.selectedMarkerData = data;
    element.objectsInfo = labels;

    document.body.appendChild(element);

    await expect(element).toBeAccessible();
  });
});
