import { createElement } from "lwc";
import EmailTemplateEditor from "c/emailTemplateEditor";
import getSenderAddresses from "@salesforce/apex/EmailTemplateEditorController.getSenderAddresses";
import getEmailTemplates from "@salesforce/apex/EmailTemplateEditorController.getEmailTemplates";

// Import mock data to send through the wire adapter.
const mockGetEmailTemplates = require("./data/getEmailTemplates.json");
const mockGetSenderAddresses = require("./data/getSenderAddresses.json");

// Mock getSenderAddresses Apex wire adapter
jest.mock(
  "@salesforce/apex/EmailTemplateEditorController.getSenderAddresses",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn())
    };
  },
  { virtual: true }
);

// Mock getEmailTemplates Apex wire adapter
jest.mock(
  "@salesforce/apex/EmailTemplateEditorController.getEmailTemplates",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn())
    };
  },
  { virtual: true }
);

describe("c-email-template-editor", () => {
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

  it("render email template editor", async () => {
    // Arrange
    const element = createElement("c-email-template-editor", {
      is: EmailTemplateEditor
    });

    // Act
    document.body.appendChild(element);

    getSenderAddresses.emit(mockGetSenderAddresses);
    getEmailTemplates.emit(mockGetEmailTemplates);

    // Wait for any asynchronous DOM updates
    await flushPromises();
  });

  it("change folder", async () => {
    const element = createElement("c-email-template-editor", {
      is: EmailTemplateEditor
    });

    document.body.appendChild(element);

    getSenderAddresses.emit(mockGetSenderAddresses);
    getEmailTemplates.emit(mockGetEmailTemplates);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const filters = element.shadowRoot.querySelectorAll("lightning-combobox");

    filters[0].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "00lB00000010HR4IAM"
        }
      })
    );
  });

  it("change template", async () => {
    const element = createElement("c-email-template-editor", {
      is: EmailTemplateEditor
    });

    document.body.appendChild(element);

    getSenderAddresses.emit(mockGetSenderAddresses);
    getEmailTemplates.emit(mockGetEmailTemplates);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const filters = element.shadowRoot.querySelectorAll("lightning-combobox");

    filters[0].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "00lB00000010HR4IAM"
        }
      })
    );

    filters[1].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "00XB0000000PSbTMAW"
        }
      })
    );
  });

  it("change sender address", async () => {
    const element = createElement("c-email-template-editor", {
      is: EmailTemplateEditor
    });

    document.body.appendChild(element);

    getSenderAddresses.emit(mockGetSenderAddresses);
    getEmailTemplates.emit(mockGetEmailTemplates);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const filters = element.shadowRoot.querySelectorAll("lightning-combobox");

    filters[2].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "0D2B000000008yDKAQ"
        }
      })
    );
  });

  it("test send email button click", async () => {
    const element = createElement("c-email-template-editor", {
      is: EmailTemplateEditor
    });

    document.body.appendChild(element);

    getSenderAddresses.emit(mockGetSenderAddresses);
    getEmailTemplates.emit(mockGetEmailTemplates);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const emailSubject = element.shadowRoot.querySelectorAll("lightning-input");

    emailSubject[0].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Test Subject"
        }
      })
    );

    const emailBody = element.shadowRoot.querySelectorAll(
      "lightning-input-rich-text"
    );

    emailBody[0].dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Test Body"
        }
      })
    );

    element.shadowRoot.querySelector(
      'lightning-input[data-name="testEmail"]'
    ).value = "test@aim.example.com";

    element.shadowRoot.querySelector(
      'lightning-input[data-name="testEmail"]'
    ).checkValidity = jest.fn().mockReturnValue(true);

    const buttons = element.shadowRoot.querySelectorAll("lightning-button");

    buttons[0].dispatchEvent(new CustomEvent("click"));
  });
});
