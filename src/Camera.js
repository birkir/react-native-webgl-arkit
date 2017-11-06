import React, { Component } from 'react';
import PropTypes from 'prop-types';
import RNWebGLARKitView from './RNWebGLARKitView';
import kelvin2rgb from './kelvin2rgb';

export default class Camera extends Component {

  static propTypes = {
    camera: PropTypes.any, // eslint-disable-line
    ambientLight: PropTypes.any, // eslint-disable-line
    onFrameUpdate: PropTypes.func,
  };

  static defaultProps = {
    camera: undefined,
    ambientLight: undefined,
    onFrameUpdate: undefined,
  }

  constructor(props) {
    super(props);
    if (this.props.camera) {
      // Set camera to class scope
      this.camera = this.props.camera;

      // Set dimensions
      this.aspect = this.camera.width / this.camera.height;
      this.camera.near = 0.01; // Fixed for now
      this.camera.far = 1000; // Fixed for now

      // Update perspective
      this.camera.updateMatrixWorld = () => {
        if (this.frame && this.frame.camera) {
          const { viewMatrix, projectionMatrix } = this.frame.camera || {};
          this.camera.matrixWorldInverse.fromArray(viewMatrix);
          this.camera.matrixWorld.getInverse(this.camera.matrixWorldInverse);
          this.camera.projectionMatrix.fromArray(projectionMatrix);
        }
      };

      // Update projection matrix
      this.camera.updateProjectionMatrix = () => this.camera.updateMatrixWorld();
    }
  }

  onFrameUpdate = (e) => {
    this.frame = e.nativeEvent;

    if (this.props.ambientLight) {
      const { ambientColorTemperature, ambientIntensity } = this.frame.lightEstimate;
      this.props.ambientLight.color.setRGB(...kelvin2rgb(ambientColorTemperature));
      this.props.ambientLight.intensity = ambientIntensity / 1000.0;
    }

    if (this.props.onFrameUpdate) {
      this.props.onFrameUpdate(e);
    }
  }

  render() {
    return (
      <RNWebGLARKitView
        {...this.props}
        onFrameUpdate={this.onFrameUpdate}
      />
    );
  }
}
