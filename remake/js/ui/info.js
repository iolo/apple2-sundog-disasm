// Small, keyboard-accessible explanations that leave the game visible.
export function infoButton(id, content, t, closeId = `${id}-close`) {
  return `<span class="info-menu"><button id="${id}" class="info-button" data-info="${id}-panel" aria-label="${t('help')}" title="${t('help')}" aria-expanded="false" aria-controls="${id}-panel">ⓘ</button><section id="${id}-panel" class="info-popover" role="dialog" tabindex="-1" aria-label="${t('help')}" hidden>${content}<button id="${closeId}" data-close-info>${t('close')}</button></section></span>`;
}

export function installInfoPopovers(root, pause) {
  const opened = () => root.querySelector('.info-popover:not([hidden])');
  const close = (restoreFocus = true) => {
    const panel = opened();
    if (!panel) return;
    panel.hidden = true;
    const button = root.querySelector(`[data-info="${panel.id}"]`);
    button.setAttribute('aria-expanded', 'false');
    if (restoreFocus) button.focus();
  };
  root.addEventListener('pointerdown', event => {
    if (opened() && !event.target.closest('.info-menu')) close(false);
  }, true);
  root.addEventListener('click', event => {
    const button = event.target.closest('[data-info], [data-close-info]');
    if (!button) return;
    event.preventDefault(); event.stopImmediatePropagation();
    if (button.hasAttribute('data-close-info') || button.getAttribute('aria-expanded') === 'true') { close(); return; }
    const id = button.id;
    close(false);
    pause(); // May render again; use the new controls below.
    const trigger = root.querySelector(`#${id}`), panel = root.querySelector(`#${trigger.dataset.info}`);
    trigger.setAttribute('aria-expanded', 'true'); panel.hidden = false;
    panel.scrollTop = 0;
    panel.focus({ preventScroll: true });
  }, true);
  root.addEventListener('keydown', event => {
    if (!opened()) return;
    event.stopImmediatePropagation();
    if (event.key === 'Escape') { event.preventDefault(); close(); }
    if (event.key === 'Tab') { event.preventDefault(); opened().querySelector('[data-close-info]').focus(); }
  }, true);
}
