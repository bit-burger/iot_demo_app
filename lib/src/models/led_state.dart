enum LedState {
  on,
  off,
  loading,
  error,
}

extension ToString on LedState {
  String toStringLong() {
    switch (this) {
      case LedState.on:
        return 'Led is on';
      case LedState.off:
        return 'Led is off';
      case LedState.loading:
        return 'Waiting for response...';
      case LedState.error:
        return 'Something went wrong, '
            'make sure your sensors are connected, '
            'and your board is connected to your local wlan';
    }
  }
}