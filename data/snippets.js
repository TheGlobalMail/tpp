var fs = require('fs');
var wikiHtml = fs.readFileSync(__dirname + '/tpp_ip_chapter.html', {encoding: 'utf8'});
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
// Pull out all {}
strippedHtml = strippedHtml.replace(/\{|\}/g, '');

var $ = cheerio.load(strippedHtml);

$('h1').removeClass().addClass(function () {
    var id = ($(this).attr('id'));
    return id ? 'tpp-big-head section-title' : 'tpp-big-head'
  });

$('h2').removeClass().addClass('tpp-med-head');

var highlightIndex = 0;

// split on paragraphs
$('p').each(function(){
  var $p = $(this);
  $p.removeClass().addClass('tpp-text');
  var html = $p.html();
  var re = /(((CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)[\/\: <$])+)/g;
  var replacedHtml = html.replace(re, function(countriesMatch){
    var countries = countriesMatch.replace(/[^A-Z\/]/g, '').split('/').sort();
    var parsedCountries = countriesMatch.match(/([\w\/]+)(.*)$/);
    var countryList = parsedCountries[1].split('/');
    var bitAtEnd = parsedCountries[2];
    if (countries.length < 2) return countriesMatch;
    // Drop footnotes where it is not a proposal
    if (html.match(/^\d\d+/) && !html.match(/oppose|propose/)){
      //console.error('dropping:');
      //console.error(html);
      return countriesMatch;
    }
    var combos = Combinatorics.combination(countries, 2).toArray();
    var dataAttrs = _.map(combos, function(combo){
      var dataAttr = 'data-' + combo.join('') + '="true"';
      $p.attr('data-' + combo.join(''), 'true');
      return dataAttr;
    });
    var replacedHtml = '<span class="covotes" ' +
        'id="covote-' + highlightIndex + '" ' +
        dataAttrs.join(' ') + '>' +
        _.map(countryList, function(c){ return '<strong data-country="'+c+'">' + c + '</strong>'; }).join('/') +
        '</span>' + bitAtEnd;
    highlightIndex++;
    return replacedHtml;
  });
  $p.html(replacedHtml + '\n\n');
});

// put it back into the index doc
var indexPath = __dirname + '/../app/index.html';
var indexHtml = fs.readFileSync(indexPath, {encoding: 'utf8'});
var $index = cheerio.load(indexHtml);
$index('#transcripts').html($.html());
fs.writeFileSync(indexPath, $index.html(), {encoding: 'utf8'});
