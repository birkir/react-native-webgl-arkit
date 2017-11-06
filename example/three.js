/* global window */
window.addEventListener = () => {};

console.ignoredYellowBox = ['THREE.WebGL'];

const THREE = require('three');

global.THREE = THREE;

export default THREE;
