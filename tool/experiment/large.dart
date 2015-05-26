import "dart:math";

import "package:dslink/dslink.dart";
import "package:dslink/nodes.dart";

LinkProvider link;

int current = 0;

main(List<String> args) {
  link = new LinkProvider(args, "Large-", defaultNodes: {
    "Generate": {
      r"$invokable": "write",
      r"$is": "generate",
      r"$params": [
        {
          "name": "count",
          "type": "number",
          "default": 50
        }
      ]
    },
    "Reduce": {
      r"$invokable": "write",
      r"$is": "reduce",
      r"$params": [
        {
          "name": "target",
          "type": "number",
          "default": 1
        }
      ]
    }
  }, profiles: {
    "generate": (String path) => new SimpleActionNode(path, (Map<String, dynamic> params) {
      var count = params["count"] != null ? params["count"] : 50;
      generate(count);
    }),
    "reduce": (String path) => new SimpleActionNode(path, (Map<String, dynamic> params) {
      var target = params["target"] != null ? params["target"] : 1;
      for (var name in link["/"].children.keys.where((it) => it.startsWith("Node_")).toList()) {
        link.removeNode("/${name}");
      }
      generate(target);
    }),
    "test": (String path) {
      CallbackNode node;

      node = new CallbackNode(path, onCreated: () {
        nodes.add(node);
      }, onRemoving: () {
        nodes.remove(node);
      });

      return node;
    }
  });

  link.connect();

  Scheduler.every(Interval.THREE_HUNDRED_MILLISECONDS, () {
    nodes.forEach((node) {
      var l = link["${node.path}/RNG/Value"];
      if (l.hasSubscriber) {
        l.updateValue(random.nextInt(100));
      }
    });
  });
}

Random random = new Random();
List<SimpleNode> nodes = [];

void generate(int count) {
  for (var i = 1; i <= count; i++) {
    link.addNode("/Node_${i}", {
      r"$is": "test",
      r"$name": "Node ${i}",
      "Values": {
        "String_Value": {
          r"$name": "String Value",
          r"$type": "string",
          r"$writable": "write",
          "?value": "Hello World"
        },
        "Number_Value": {
          r"$name": "Number Value",
          r"$type": "number",
          r"$writable": "write",
          "?value": 5.0
        },
        "Integer_Value": {
          r"$name": "Integer Value",
          r"$type": "number",
          r"$writable": "write",
          "?value": 5
        }
      },
      "RNG": {
        "Value": {
          r"$type": "number",
          "?value": 0.0
        }
      }
    });
    current++;
  }
}