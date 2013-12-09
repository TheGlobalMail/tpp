var fs = require('fs');
var wikiHtml = fs.readFileSync('../tpp_ip_chapter.html', {encoding: 'utf8'});
var _ = require('lodash');
var cheerio = require('cheerio');
var Combinatorics = require('js-combinatorics').Combinatorics;

// strip out all spans (some are malformed)
var strippedHtml = wikiHtml.replace(/<\/*?span.*?>/g, '');
var strippedHtml = strippedHtml.replace(/(>\d\d\d)<\/a>/g, '$1 ');
// fix up the weird closing anchor tags in the footnotes
var strippedHtml = strippedHtml.replace(/(>\d\d\d)<\/a>/g, '$1 ');
var strippedHtml = strippedHtml.replace(/(p>)<\/a>/g, '$1');
// fix up other weird closing anchor tags
var $ = cheerio.load(strippedHtml);

// split on paragraphs
$('p').each(function(){
  var $p = $(this);
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
        countriesMatch.replace(/<$/, '') + '</span>' +
        (countriesMatch.match(/<$/) ? '<' : '');
    return replacedHtml;
  });
  $p.html(replacedHtml);
});

// put it back into the index doc
var indexHtml = fs.readFileSync('../../index.html', {encoding: 'utf8'});
var $index = cheerio.load(indexHtml);
$index('#transcripts').html($.html());
fs.writeFileSync('../../index.html', $index.html(), {encoding: 'utf8'});
