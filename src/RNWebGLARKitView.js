import React, { Component } from 'react';
import { View, NativeModules, requireNativeComponent } from 'react-native';
import PropTypes from 'prop-types';

const { RNWebGLARKitManager } = NativeModules;

class RNWebGLARKit extends Component {

  static propTypes = {
    ...View.propTypes,
    debug: PropTypes.bool,
    planeDetection: PropTypes.bool,
    lightEstimation: PropTypes.bool,
    worldAlignment: PropTypes.number,
    onPlaneDetected: PropTypes.func,
    onPlaneUpdated: PropTypes.func,
    onPlaneRemoved: PropTypes.func,
    onFrameUpdate: PropTypes.func,
  }

  static defaultProps = {
    debug: false,
    planeDetection: true,
    lightEstimation: true,
    worldAlignment: undefined,
    onPlaneDetected: undefined,
    onPlaneUpdated: undefined,
    onPlaneRemoved: undefined,
    onFrameUpdate: undefined,
  }

  constructor(props) {
    super(props);
    RNWebGLARKitManager.reset();
  }

  componentDidMount() {
    RNWebGLARKitManager.resume();
  }

  componentWillUnmount() {
    RNWebGLARKitManager.pause();
  }

  render() {
    return (
      <RNWebGLARKitView
        {...this.props}
      />
    );
  }
}

const RNWebGLARKitView = requireNativeComponent('RNWebGLARKit', RNWebGLARKit);

export default RNWebGLARKitView;
