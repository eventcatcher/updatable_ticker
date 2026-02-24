import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ipsum/ipsum.dart';
import 'package:updatable_ticker/updatable_ticker.dart';

class UpdatableTickerExamplePage extends StatefulWidget {
  const UpdatableTickerExamplePage({super.key});

  @override
  State<UpdatableTickerExamplePage> createState() =>
      UpdatableTickerExamplePageState();
}

class UpdatableTickerExamplePageState
    extends State<UpdatableTickerExamplePage> {
  final LinearGradient gradient = LinearGradient(
    colors: <Color>[Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final Duration oneSec = Duration(milliseconds: 500);
  final double minDesktopWidth = 768;
  final double linePadding = 20;
  final double gradientWidthInPx = 80;
  final double borderSpace = 64;
  final int fontMinSize = 12;
  final int fontMaxSize = 80;
  final int ledDotMinSize = 1;
  final int ledDotMaxSize = 10;
  final int maxLines = 4;

  final int modules = 21;
  final double ledGap = 0.2;
  final Color ledOnColor = Colors.red.shade500;
  final Color ledOffColor = const Color(0xFF000000);

  Orientation orientation = Orientation.portrait;
  DateTime lastUpdate = DateTime.now();
  String updatableText = '';
  double width = 1280;
  double height = 768;
  double gradientWidth = 0;
  double scrollSpeedDevice = 1.0;
  double fontSize = 12.0;
  double ledSize = 5.0;
  int rng = -1;
  int seconds = 0;
  bool withGradient = false;
  bool showLedVariant = false;
  bool useProportionalFont = true;

  @override
  void initState() {
    super.initState();

    randomUpdates();

    Timer.periodic(
      oneSec,
      (Timer t) => setState(() {
        final int value =
            rng - DateTime.now().difference(lastUpdate).inSeconds - 1;
        seconds = value > 0 ? value : 0;
      }),
    );
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  String textGenerator() {
    final int rng = random(5, 20);
    return Ipsum().words(rng);
  }

  randomUpdates() {
    rng = rng == -1 ? 2 : random(4, 60);

    Future.delayed(Duration(seconds: rng), () {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          setState(() {
            lastUpdate = DateTime.now();
            updatableText = textGenerator();
          });
        }
      });

      randomUpdates();
    });
  }

  List<Widget> sliders() => [
        Row(
          children: [
            SizedBox(
                width: width > minDesktopWidth ? null : 64.0,
                child: Text('Speed: ')),
            SizedBox(
              width: 170,
              child: Slider(
                value: scrollSpeedDevice,
                min: 0.75,
                max: 10,
                divisions: 100,
                thumbColor: Colors.red.shade700,
                activeColor: Colors.green.shade200,
                inactiveColor: Colors.grey.shade700,
                onChanged: (double value) {
                  setState(() {
                    scrollSpeedDevice = value;
                  });
                },
              ),
            ),
            Text('${(50 * scrollSpeedDevice).floor()} px/s'),
          ],
        ),
        if (width > minDesktopWidth) Expanded(child: SizedBox()),
        Row(
          children: [
            SizedBox(
                width: 64.0,
                child: Text(showLedVariant ? 'Dotsize' : 'Fontsize: ')),
            SizedBox(
              width: 170,
              child: Slider(
                value: showLedVariant ? ledSize : fontSize,
                min: showLedVariant
                    ? ledDotMinSize.toDouble()
                    : fontMinSize.toDouble(),
                max: showLedVariant
                    ? ledDotMaxSize.toDouble()
                    : fontMaxSize.toDouble(),
                divisions: showLedVariant
                    ? ledDotMaxSize - ledDotMinSize
                    : fontMaxSize - fontMinSize,
                thumbColor: Colors.red.shade700,
                activeColor: Colors.green.shade200,
                inactiveColor: Colors.grey.shade700,
                onChanged: (double value) {
                  setState(() {
                    if (showLedVariant) {
                      ledSize = value;
                    } else {
                      fontSize = value;
                    }
                  });
                },
              ),
            ),
            Text(showLedVariant ? '$ledSize px' : '$fontSize px'),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    gradientWidth =
        width > 0 ? 1 / (width - borderSpace) * gradientWidthInPx : 0;

    return SafeArea(
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 64,
          child: OrientationBuilder(
              builder: (BuildContext context, Orientation o) {
            orientation = o;

            return NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (notification) {
                width = MediaQuery.of(context).size.width;
                height = MediaQuery.of(context).size.height;
                build(context);
                return false;
              },
              child: SizeChangedLayoutNotifier(
                child: Container(
                  padding: EdgeInsets.only(top: 16.0),
                  key: ValueKey(
                    'UpdatableTickerWrapper-${orientation == Orientation.portrait ? 'portrait' : 'landscape'}-$width',
                  ),
                  width: width - 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          SizedBox(
                              width: 142,
                              height: 32.0,
                              child: Row(
                                children: [
                                  Text(
                                    'Options: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                          SizedBox(
                            width: 250.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: showLedVariant,
                                  onChanged: (bool? mode) {
                                    setState(() {
                                      showLedVariant = !showLedVariant;
                                    });
                                  },
                                ),
                                Text('display LED variant'),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: withGradient,
                                onChanged: (bool? mode) {
                                  setState(() {
                                    withGradient = !withGradient;
                                  });
                                },
                              ),
                              Text('with opacity fading'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 150.0,
                            child: Row(
                              children: [
                                Text(
                                  'width: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${width - 16}'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 220.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'orientation: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(orientation.name),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: linePadding),
                        child: SizedBox(
                          height: maxLines * 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'new text: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Flexible(
                                child: Text(
                                  updatableText,
                                  maxLines: maxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: linePadding),
                        child: Row(
                          children: [
                            Text(
                              'next update: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('in $seconds seconds'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: linePadding),
                        child: width > minDesktopWidth
                            ? Row(
                                children: sliders(),
                              )
                            : SizedBox(
                                height: 100.0,
                                child: SizedBox(
                                  height: 100.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: sliders(),
                                  ),
                                ),
                              ),
                      ),
                      if (width > minDesktopWidth)
                        Expanded(
                          child: SizedBox(),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Stack(
                          children: [
                            showLedVariant
                                ? SizedBox(
                                    width: modules * ledSize * 8,
                                    height: ledSize * 8,
                                    child: UpdatableLedTicker(
                                      key: ValueKey(
                                        'UpdatableTickerExamplePage-${orientation == Orientation.portrait ? 'portrait' : 'landscape'}-$width-$fontSize',
                                      ),
                                      updatableText: updatableText,
                                      modules: modules,
                                      useProportionalFont: useProportionalFont,
                                      ledSize: ledSize,
                                      ledGap: ledGap,
                                      onColor: ledOnColor,
                                      offColor: ledOffColor,
                                      pixelsPerSecond: 50 * scrollSpeedDevice,
                                      forceUpdate: false,
                                      separator: '    ////    ',
                                    ),
                                  )
                                : SizedBox(
                                    height: fontSize + 32,
                                    child: UpdatableTicker(
                                      key: ValueKey(
                                        'UpdatableTickerExamplePage-${orientation == Orientation.portrait ? 'portrait' : 'landscape'}-$width-$fontSize',
                                      ),
                                      updatableText: updatableText,
                                      style: TextStyle(
                                        fontFamily: 'whiteCupertino subtitle',
                                        fontSize: fontSize,
                                        color: Colors.black,
                                      ),
                                      pixelsPerSecond: 50 * scrollSpeedDevice,
                                      forceUpdate: false,
                                      separator: '    ////    ',
                                    ),
                                  ),
                            withGradient
                                ? Container(
                                    height: showLedVariant
                                        ? ledSize * 8
                                        : fontSize + 32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            Theme.of(context)
                                                .scaffoldBackgroundColor
                                                .withValues(alpha: 0.0),
                                            Theme.of(context)
                                                .scaffoldBackgroundColor
                                                .withValues(alpha: 0.0),
                                            Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          stops: [
                                            0.0,
                                            gradientWidth,
                                            1 - gradientWidth,
                                            1.0
                                          ]),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
