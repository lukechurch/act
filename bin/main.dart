// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;
import 'dart:convert' as convert;

import 'package:act/act.dart' as act;
import 'package:watcher/watcher.dart' as watcher;
import 'package:diff_match_patch/diff_match_patch.dart' as diff;

Map filesMap = {};
Map updatedMap = {};
String path = '/Users/lukechurch/actWorking';

main(List<String> arguments) {

  populateDirectory(path);

  var watch = new watcher.DirectoryWatcher(path);
  watch.events.listen((watcher.WatchEvent x) {
    if (x.type == watcher.ChangeType.MODIFY) respondToChange(x);
  });

  io.stdin.listen((x) {
    handleInput(x);
  });

}

handleInput(x) {
  var command = convert.UTF8.decode(x);
  switch (command.toLowerCase().trim()) {
    case "apply":
      updatedMap.forEach((k, v) {
        filesMap[k] = v;
      });
      print ("Patch applied");
      break;
    default:
      print ("unknown command: $command");
  }
}

respondToChange(watcher.WatchEvent event) {
  String oldCode = filesMap[event.path];
  String newCode = new io.File(event.path).readAsStringSync();
  updatedMap[event.path] = newCode;

  diff.diff(oldCode, newCode).forEach((diff.Diff df) {
    print(df);
  });
}

populateDirectory(String dir) {
  io.Directory dir = new io.Directory(path);
  dir.listSync().forEach((fse) {
    filesMap.putIfAbsent(fse.path, () => new io.File(fse.path).readAsStringSync());
  });
}

