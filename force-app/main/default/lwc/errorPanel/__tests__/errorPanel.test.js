import { createElement } from 'lwc';
import ErrorPanel from 'c/errorPanel';

describe('c-error-panel', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        
        const element = createElement('c-error-panel', {
            is: ErrorPanel
        });

        document.body.appendChild(element);

        await expect(element).toBeAccessible();
    });
});