import { html, css, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('simple-greeting')
class SimpleGreeting extends LitElement {
    static styles = css`p {color: blue}`;

    name = 'World';

    render() {
        return html`<p>Hello, ${this.name}!</p>`;
    }
}

export default SimpleGreeting;