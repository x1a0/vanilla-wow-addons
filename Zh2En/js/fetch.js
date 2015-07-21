var Crawler = require("crawler");
var url = require('url');

/**
 * items {Object} key is item id and value is its english name
 */
var fetch = function(items, cb) {
  var fetched = {};

  var c = new Crawler({
    maxConnections : 10,
    forceUTF8: true,
    jQuery: {
      name: 'cheerio',
      options: {
        decodeEntities: false
      }
    },
    callback: function (error, result, $) {
      var itemId, itemZhName;

      $("#info .name a").each(function(i, a) {
        itemId = $(a).attr("href").slice(5).replace(".html", "");
        itemZhName = $(a).html();
      });

      //console.log("fetched: " + itemZhName);
      fetched[itemZhName] = items[itemId];
    },
    onDrain: function() {
      cb(fetched);
    }
  });

  //var baseUrl = "http://db.178.com/wow/cn/item";
  var baseUrl = "http://wowdb.games.sina.com.cn";

  var urls = [];
  for (var id in items) {
    urls.push(baseUrl + "/item-" + id + ".html");
  }

  c.queue(urls);
};


module.exports = fetch;
