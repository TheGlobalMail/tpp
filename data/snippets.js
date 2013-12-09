var fs = require('fs');
var wikiHtml = fs.readFileSync('tpp_ip_chapter.html', {encoding: 'utf8'});
var _ = require('lodash');
var cheerio = require('cheerio');
var Combinatorics = require('js-combinatorics').Combinatorics;

// pull out newlines
var strippedHtml = wikiHtml.replace(/(\r\n|\n|\r)/gm, ' ');
// strip out all spans (some are malformed)
strippedHtml = strippedHtml.replace(/<\/*?span.*?>/g, '');
// fix up the weird closing anchor tags in the footnotes
strippedHtml = strippedHtml.replace(/(>\d\d\d)<\/a>/g, '$1 ');
// fix up other weird closing anchor tags
strippedHtml = strippedHtml.replace(/(<p>)<\/a>/g, '$1');
// oh fuck it, let's get rid of the links
strippedHtml = strippedHtml.replace(/<\/*?a.*?>/g, '');
// Replace double slashes with single
strippedHtml = strippedHtml.replace(/\/\//g, '/');

var $ = cheerio.load(strippedHtml);

// split on paragraphs
$('p').each(function(i){
  var $p = $(this);
  $p.removeClass().addClass('tpp-text');
  var html = $p.html();
  var re = /(((CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)[\/\: <$])+)/g;
  var replacedHtml = html.replace(re, function(countriesMatch){
    var countries = countriesMatch.replace(/[^A-Z\/]/g, '').split('/').sort();
    if (countries.length < 2) return countriesMatch;
    var combos = Combinatorics.combination(countries, 2).toArray();
    var dataAttrs = _.map(combos, function(combo){
      var dataAttr = 'data-' + combo.join('') + '="true"';
      $p.attr('data-' + combo.join(''), 'true');
      return dataAttr;
    });
    var replacedHtml = '<span class="covotes" ' + dataAttrs.join(' ') + '>' +
        countriesMatch.replace(/(\w)([^\w]*)$/, '$1</span>$2');
    return replacedHtml;
  });
  $p.attr('id', 'paragraph-' + i);
  $p.html(replacedHtml + '\n\n');
});

// put it back into the index doc
var indexHtml = fs.readFileSync('../app/index.html', {encoding: 'utf8'});
var $index = cheerio.load(indexHtml);
$index('#transcripts').html($.html());
fs.writeFileSync('../app/index.html', $index.html(), {encoding: 'utf8'});
