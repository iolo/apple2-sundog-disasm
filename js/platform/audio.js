// The Apple II speaker is a one-bit toggle at $C030. These short square-wave
// cues suggest its character; their pitch and timing are browser adaptations.
const CUES = {
  select: [[560, 0.035]],
  confirm: [[620, 0.055], [880, 0.075]],
  transition: [[440, 0.055], [660, 0.085]],
  error: [[240, 0.11], [180, 0.13]],
  fire: [[900, 0.045], [470, 0.07]],
  alert: [[330, 0.09], [220, 0.09], [330, 0.09]],
  hit: [[180, 0.1], [120, 0.13]],
  warp: [[260, 0.1], [360, 0.1], [520, 0.15]],
  ending: [[440, 0.12], [550, 0.12], [660, 0.12], [880, 0.28]],
};
const preference = 'sundog.sound';

export function createAudio({ storage = localStorage, Audio = window.AudioContext || window.webkitAudioContext } = {}) {
  let enabled = true, context = null, gain = null;
  try { enabled = storage.getItem(preference) !== 'off'; } catch { /* Session preference still works. */ }
  const supported = typeof Audio === 'function';
  function activate() {
    if (!enabled || !supported) return false;
    try {
      if (!context) {
        context = new Audio();
        gain = context.createGain();
        gain.gain.value = 0.065;
        gain.connect(context.destination);
      }
      if (context.state === 'suspended') void context.resume().catch(() => {});
      return true;
    } catch { return false; }
  }
  function play(cue, gesture = false) {
    if (!enabled || !supported || !CUES[cue] || !(context || gesture && activate())) return;
    try {
      let at = context.currentTime + 0.005;
      for (const [frequency, duration] of CUES[cue]) {
        const oscillator = context.createOscillator(), envelope = context.createGain();
        oscillator.type = 'square';
        oscillator.frequency.setValueAtTime(frequency, at);
        envelope.gain.setValueAtTime(0, at);
        envelope.gain.linearRampToValueAtTime(1, at + 0.005);
        envelope.gain.setValueAtTime(1, at + Math.max(0.006, duration - 0.012));
        envelope.gain.linearRampToValueAtTime(0, at + duration);
        oscillator.connect(envelope); envelope.connect(gain);
        oscillator.start(at); oscillator.stop(at + duration);
        oscillator.onended = () => { oscillator.disconnect(); envelope.disconnect(); };
        at += duration + 0.018;
      }
    } catch { /* Audio is optional; the action must still work. */ }
  }
  function toggle() {
    enabled = !enabled;
    if (gain) gain.gain.value = enabled ? 0.065 : 0;
    try { storage.setItem(preference, enabled ? 'on' : 'off'); } catch { /* Keep the current choice. */ }
    if (enabled) play('confirm', true);
    return enabled;
  }
  return { get enabled() { return enabled; }, supported, activate, play, toggle };
}
