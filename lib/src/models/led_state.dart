enum LedState {
  on,
  off,
  animating,
  loading,
  connectionError,
}

extension ErrorMessage on LedState {
  String get errorMessage {
    switch (this) {
      case LedState.loading:
        return 'Loading...';
      case LedState.connectionError:
        return 'Connection to the MicroController could not be established, '
            'make sure you:\n'
            ' - Specified the correct url (in Settings),\n'
            ' - are connected to the internet,\n'
            ' - and have connected the micro controller to the same local net, '
            'that you are connected to';
      case LedState.animating:
        return 'The micro controller is animating, '
            'wait for it to stop, '
            'or stop it in the AnimationControl';
      default:
        throw Error();
    }
  }
}

extension Description on LedState {
  String description() {
    switch (this) {
      case LedState.on:
        return 'Led is on';
      case LedState.off:
        return 'Led is off';
      case LedState.loading:
        return 'Waiting for response...';
      case LedState.connectionError:
        return 'Error ocurred';
      case LedState.animating:
        return 'Is animating...';
    }
  }
}
