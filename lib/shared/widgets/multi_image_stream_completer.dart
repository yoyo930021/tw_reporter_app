// Ported from cached_network_image (MIT License)
// https://github.com/Baseflow/flutter_cache_manager
// Original author: Rene Floor
//
// Modified: removed custom timeDilation global, use scheduler's instead.

import 'dart:async';
import 'dart:ui' as ui show Codec, FrameInfo;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding, timeDilation;

/// An [ImageStreamCompleter] with support for loading multiple images.
///
/// Unlike [MultiFrameImageStreamCompleter] which takes a `Future<Codec>`,
/// this takes a `Stream<Codec>` — allowing it to handle cache-then-network
/// flows where a cached image arrives first and is later replaced by a
/// freshly downloaded version.
class MultiImageStreamCompleter extends ImageStreamCompleter {
  /// Creates a [MultiImageStreamCompleter].
  ///
  /// [codec] is a stream with the images that should be shown.
  /// [chunkEvents] indicates the download progress of the first image.
  MultiImageStreamCompleter({
    required Stream<ui.Codec> codec,
    required double scale,
    Stream<ImageChunkEvent>? chunkEvents,
    InformationCollector? informationCollector,
  })  : _informationCollector = informationCollector,
        _scale = scale {
    codec.listen(
      (event) {
        if (_timer != null) {
          _nextImageCodec = event;
        } else {
          _handleCodecReady(event);
        }
      },
      onError: (Object error, StackTrace stack) {
        reportError(
          context: ErrorDescription('resolving an image codec'),
          exception: error,
          stack: stack,
          informationCollector: informationCollector,
          silent: true,
        );
      },
    );
    if (chunkEvents != null) {
      _chunkSubscription = chunkEvents.listen(
        reportImageChunkEvent,
        onError: (Object error, StackTrace stack) {
          reportError(
            context: ErrorDescription('loading an image'),
            exception: error,
            stack: stack,
            informationCollector: informationCollector,
            silent: true,
          );
        },
      );
    }
  }

  ui.Codec? _codec;
  ui.Codec? _nextImageCodec;
  final double _scale;
  final InformationCollector? _informationCollector;
  ui.FrameInfo? _nextFrame;

  // When the current frame was first shown.
  late Duration? _shownTimestamp;

  // The requested duration for the current frame.
  Duration? _frameDuration;

  // How many frames have been emitted so far.
  int _framesEmitted = 0;
  Timer? _timer;
  StreamSubscription<ImageChunkEvent>? _chunkSubscription;

  // Guards against registering multiple _handleAppFrame callbacks.
  late bool _frameCallbackScheduled = false;

  // We must avoid disposing if no listener was ever added.
  late bool _hadAtLeastOneListener = false;

  late bool _disposed = false;

  void _switchToNewCodec() {
    _framesEmitted = 0;
    _timer = null;
    _handleCodecReady(_nextImageCodec!);
    _nextImageCodec = null;
  }

  void _handleCodecReady(ui.Codec codec) {
    _codec = codec;
    if (hasListeners) {
      unawaited(_decodeNextFrameAndSchedule());
    }
  }

  void _handleAppFrame(Duration timestamp) {
    _frameCallbackScheduled = false;
    if (!hasListeners) return;
    if (_isFirstFrame() || _hasFrameDurationPassed(timestamp)) {
      _emitFrame(ImageInfo(image: _nextFrame!.image, scale: _scale));
      _shownTimestamp = timestamp;
      _frameDuration = _nextFrame!.duration;
      _nextFrame = null;
      if (_framesEmitted % _codec!.frameCount == 0 &&
          _nextImageCodec != null) {
        _switchToNewCodec();
      } else {
        final completedCycles = _framesEmitted ~/ _codec!.frameCount;
        if (_codec!.repetitionCount == -1 ||
            completedCycles <= _codec!.repetitionCount) {
          unawaited(_decodeNextFrameAndSchedule());
        }
      }
      return;
    }
    final delay = _frameDuration! - (timestamp - _shownTimestamp!);
    _timer = Timer(delay * timeDilation, _scheduleAppFrame);
  }

  bool _isFirstFrame() => _frameDuration == null;

  bool _hasFrameDurationPassed(Duration timestamp) =>
      timestamp - _shownTimestamp! >= _frameDuration!;

  Future<void> _decodeNextFrameAndSchedule() async {
    try {
      _nextFrame = await _codec!.getNextFrame();
    } on Object catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: _informationCollector,
        silent: true,
      );
      return;
    }
    if (_codec!.frameCount == 1) {
      if (!hasListeners) return;
      _emitFrame(ImageInfo(image: _nextFrame!.image, scale: _scale));
      return;
    }
    _scheduleAppFrame();
  }

  void _scheduleAppFrame() {
    if (_frameCallbackScheduled) return;
    _frameCallbackScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback(_handleAppFrame);
  }

  void _emitFrame(ImageInfo imageInfo) {
    setImage(imageInfo);
    _framesEmitted += 1;
  }

  @override
  void addListener(ImageStreamListener listener) {
    _hadAtLeastOneListener = true;
    if (!hasListeners && _codec != null) {
      unawaited(_decodeNextFrameAndSchedule());
    }
    super.addListener(listener);
  }

  @override
  void removeListener(ImageStreamListener listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _timer?.cancel();
      _timer = null;
      _tryDispose();
    }
  }

  late int _keepAliveHandles = 0;

  @override
  ImageStreamCompleterHandle keepAlive() {
    final delegateHandle = super.keepAlive();
    return _Handle(this, delegateHandle);
  }

  void _tryDispose() {
    if (!_hadAtLeastOneListener ||
        _disposed ||
        hasListeners ||
        _keepAliveHandles != 0) {
      return;
    }
    _disposed = true;
    _chunkSubscription?.onData(null);
    unawaited(_chunkSubscription?.cancel());
    _chunkSubscription = null;
  }
}

class _Handle implements ImageStreamCompleterHandle {
  _Handle(this._completer, this._delegateHandle) {
    _completer!._keepAliveHandles += 1;
  }

  MultiImageStreamCompleter? _completer;
  final ImageStreamCompleterHandle _delegateHandle;

  @override
  void dispose() {
    assert(_completer != null, 'Handle already disposed');
    assert(_completer!._keepAliveHandles > 0, 'No keep-alive handles');
    assert(!_completer!._disposed, 'Completer already disposed');

    _delegateHandle.dispose();

    _completer!._keepAliveHandles -= 1;
    _completer!._tryDispose();
    _completer = null;
  }
}
