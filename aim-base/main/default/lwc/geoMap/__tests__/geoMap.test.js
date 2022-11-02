import { createElement } from "lwc";
import GeoMap from "c/geoMap";
import { getObjectInfos } from "lightning/uiObjectInfoApi";
import getAssets from "@salesforce/apex/GeoMapController.getAssets";

// Import mock data to send through the wire adapter.
const mockGetObjectInfos = require("./data/getObjectInfos.json");
const mockGetAssets = require("./data/getAssets.json");

// Mock getContactList Apex wire adapter
jest.mock(
  "@salesforce/apex/GeoMapController.getAssets",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn())
    };
  },
  { virtual: true }
);

describe("c-geo-map", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }

    // Prevent data saved on mocks from leaking between tests
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  it("render map markers", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    getObjectInfos.emit(mockGetObjectInfos);
    getAssets.emit(mockGetAssets);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const lightningMap = element.shadowRoot.querySelector("lightning-map");
    expect(lightningMap.mapMarkers.length).toBe(11);

    const selectedMapPicker = element.shadowRoot.querySelector(
      "c-selected-map-picker"
    );
    expect(selectedMapPicker).toBeNull();
  });

  it("change product filters", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    getObjectInfos.emit(mockGetObjectInfos);
    getAssets.emit(mockGetAssets);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const filters = element.shadowRoot.querySelectorAll("lightning-combobox");

    filters[0].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "01tB0000002aoiTIAQ"
        }
      })
    );

    return Promise.resolve().then(() => {
      const lightningMap = element.shadowRoot.querySelector("lightning-map");
      expect(lightningMap.mapMarkers.length).toBe(1);

      element.shadowRoot
        .querySelector("lightning-input")
        .dispatchEvent(new CustomEvent("change"));
    });
  });

  it("change product family filters", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    getObjectInfos.emit(mockGetObjectInfos);
    getAssets.emit(mockGetAssets);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const filters = element.shadowRoot.querySelectorAll("lightning-combobox");

    filters[1].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "None"
        }
      })
    );

    return Promise.resolve().then(() => {
      const lightningMap = element.shadowRoot.querySelector("lightning-map");
      expect(lightningMap.mapMarkers.length).toBe(1);
    });
  });

  it("change asset status filters", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    getObjectInfos.emit(mockGetObjectInfos);
    getAssets.emit(mockGetAssets);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const filters = element.shadowRoot.querySelectorAll("lightning-combobox");

    filters[2].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Shipped"
        }
      })
    );

    return Promise.resolve().then(() => {
      const lightningMap = element.shadowRoot.querySelector("lightning-map");
      expect(lightningMap.mapMarkers.length).toBe(2);
    });
  });

  it("toggle list view", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    getObjectInfos.emit(mockGetObjectInfos);
    getAssets.emit(mockGetAssets);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    element.shadowRoot
      .querySelector("lightning-input")
      .dispatchEvent(new CustomEvent("change"));
  });

  it("select marker", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    getObjectInfos.emit(mockGetObjectInfos);
    getAssets.emit(mockGetAssets);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    element.shadowRoot
      .querySelector("lightning-map")
      .dispatchEvent(new CustomEvent("markerselect"));
  });

  it("is accessible", async () => {
    const element = createElement("c-geo-map", {
      is: GeoMap
    });

    document.body.appendChild(element);

    await expect(element).toBeAccessible();
  });
});
