export default class BaseElement extends HTMLElement {
  constructor(...args) {
    super(...args);

    const tmpl = document.getElementById(args[0]);
    const content = tmpl.content.cloneNode(true);
    const root = this.attachShadow({mode: 'open'}).appendChild(content);

    this.appendChild(root);
  }
}
