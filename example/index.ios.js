/* global requestAnimationFrame cancelAnimationFrame */
import React from 'react';
import { AppRegistry, StyleSheet, View } from 'react-native';
import { WebGLView } from 'react-native-webgl';
import { Camera } from 'react-native-webgl-arkit';
import THREE from './three';

export default class example extends React.Component {

  componentWillUnmount() {
    cancelAnimationFrame(this.requestId);
  }

  onContextCreate = (gl) => {
    const rngl = gl.getExtension('RN');

    const { drawingBufferWidth: width, drawingBufferHeight: height } = gl;
    const renderer = new THREE.WebGLRenderer({
      canvas: {
        width,
        height,
        style: {},
        addEventListener: () => {},
        removeEventListener: () => {},
        clientHeight: height,
      },
      context: gl,
    });
    renderer.setSize(width, height);
    renderer.setClearColor(0x000000, 0); // Make the renderer transparent

    // Set camera size
    this.camera.width = width;
    this.camera.height = height;

    let cube;

    const init = () => {
      const geometry = new THREE.BoxGeometry(0.1, 0.1, 0.1);
      for (let i = 0; i < geometry.faces.length; i += 2) {
        const hex = Math.random() * 0xffffff;
        geometry.faces[i].color.setHex(hex);
        geometry.faces[i + 1].color.setHex(hex);
      }

      const material = new THREE.MeshBasicMaterial({
        vertexColors: THREE.FaceColors,
        overdraw: 0.5,
      });

      cube = new THREE.Mesh(geometry, material);
      cube.position.z = -0.05;
      this.scene.add(cube);
    };

    const animate = () => {
      this.requestId = requestAnimationFrame(animate);

      // Update camera position
      this.camera.position.setFromMatrixPosition(this.camera.matrixWorld);
      renderer.render(this.scene, this.camera);

      cube.rotation.y += 0.05;

      gl.flush();
      rngl.endFrame();
    };

    init();
    animate();
  };

  onPlaneDetected = (e) => {
    const { center, extent } = e.nativeEvent;
    const geometry = new THREE.PlaneGeometry(extent.x, extent.z, 16);
    const material = new THREE.MeshBasicMaterial({ color: 0xffff00, side: THREE.DoubleSide, wireframe: true });
    const plane = new THREE.Mesh(geometry, material);
    plane.rotation.x = Math.PI / 2;
    plane.position.x = center.x;
    plane.position.y = center.y;
    plane.position.z = center.z;
    this.scene.add(plane);
  }

  requestId;
  ambientLight = new THREE.AmbientLight();
  camera = new THREE.PerspectiveCamera();
  scene = new THREE.Scene();

  render() {
    return (
      <View style={styles.container}>
        <Camera
          debug
          onPlaneDetected={this.onPlaneDetected}
          camera={this.camera}
          ambientLight={this.ambientLight}
          style={StyleSheet.absoluteFill}
        />
        <WebGLView
          style={StyleSheet.absoluteFill}
          onContextCreate={this.onContextCreate}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

AppRegistry.registerComponent('example', () => example);
