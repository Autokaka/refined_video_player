library refined_video_player;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:screen/screen.dart';
import 'package:volume_watcher/volume_watcher.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'src/controller.dart';

part 'src/view/video_player.dart';
part 'src/view/video_view.dart';

part 'src/ui/builder.dart';
part 'src/ui/modifier.dart';

part 'src/ui/configs/bottom.dart';
part 'src/ui/configs/center.dart';
part 'src/ui/configs/default.dart';
part 'src/ui/configs/left.dart';
part 'src/ui/configs/right.dart';
part 'src/ui/configs/top.dart';
