/* eslint no-mixed-operators: 0 no-restricted-properties: 0 */
export default (kelvin) => {
  const t = kelvin / 100;
  const rgb = { r: 0, g: 0, b: 0 };

  if (t <= 66) {
    rgb.r = 255;
  } else {
    rgb.r = t - 60;
    rgb.r = 329.698727466 * Math.pow(rgb.r, -0.1332047592);
  }

  if (t <= 66) {
    rgb.g = t;
    rgb.g = 99.4708025861 * Math.log(rgb.g) - 161.1195681661;
  } else {
    rgb.g = t - 60;
    rgb.g = 288.1221695283 * Math.pow(rgb.g, -0.0755148492);
  }

  if (t >= 66) {
    rgb.b = 255;
  } else if (t <= 19) {
    rgb.b = 0;
  } else {
    rgb.b = t - 10;
    rgb.b = 138.5177312231 * Math.log(rgb.b) - 305.0447927307;
  }

  return Object.values(rgb)
    .map(value => Math.max(0, Math.min(1, value / 255)));
};
