import { createElement } from 'lwc';
import InfoPanel from 'c/infoPanel';

describe('c-info-panel', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        
        const element = createElement('c-info-panel', {
            is: InfoPanel
        });

        document.body.appendChild(element);

        await expect(element).toBeAccessible();
    });
});