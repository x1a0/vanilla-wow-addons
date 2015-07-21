var async = require('async');
var fetch = require('./fetch');

var todo = {
  "Leather"       : require('./leather'),
  "Cloth"         : require('./cloth'),
  "Part"          : require('./part'),
  "Explosive"     : require('./explosive'),
  "Device"        : require('./device'),
  "Metal & Stone" : require('./metal_stone'),
  "Meet"          : require('./meet'),
  "Herb"          : require('./herb'),
  "Elemental"     : require('./elemental'),
  "Enchanting"    : require('./enchanting'),
  "Material"      : require('./material'),
  "Other"         : require('./other')
};

var tasks = {};

for (var k in todo) {
  tasks[k] = (function(key) {
    return function(cb) {
      fetch(todo[key], function(result) {
        console.log("-- " + key);
        for (cn in result) {
          console.log('Zh2En_Data["' + cn + '"] = "' + result[cn] + '"')
        }
        console.log("\n")
        cb(null)
      });
    };
  })(k);
}

async.series(tasks, function(err) {
  process.exit(0);
});

