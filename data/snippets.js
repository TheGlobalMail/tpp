var fs = require('fs');
var wikiHtml = fs.readFileSync(__dirname + '/tpp_ip_chapter.html', {encoding: 'utf8'});
var _ = require('lodash');
var cheerio = require('cheerio');
var Combinatorics = require('js-combinatorics').Combinatorics;

var countries = 'Australia,Brunei,Canada,Chile,Japan,Mexico,Malaysia,New Zealand,Peru,Singapore,United States,Vietnam'.split(',');
var abbrevs = {
  'Australia': 'AU',
  'Brunei': 'BN',
  'Canada': 'CA',
  'Chile': 'CL',
  'Japan': 'JP',
  'Mexico': 'MX',
  'Malaysia': 'MY',
  'New Zealand': 'NZ',
  'Peru': 'PE',
  'Singapore': 'SG',
  'United States': 'US',
  'Vietnam': 'VN'
};

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
var allCombos = {};
var allCountries = {};

function recordCombo(combo){
  var key = combo.sort().join('');
  allCombos[key] = allCombos[key] ? allCombos[key] + 1 : 1;
}

function recordCountry(country){
  allCountries[country] = allCountries[country] ? allCountries[country] + 1 : 1;
}
// record each combo
// record each vote by country
// generate 2d array of countries

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
    if (countries.length < 2){
      return countriesMatch;
    }
    // Drop footnotes where it is not a proposal
    if (html.match(/^\d+.*Negotiator/) && !html.match(/oppose|propose/)){
      //console.error('dropping:');
      //console.error(html);
      return countriesMatch;
    }
    var combos = Combinatorics.combination(countries, 2).toArray();
    // Records country and combos for later
    _.each(countries, recordCountry);
    _.each(combos, recordCombo);
    var dataAttrs = _.map(combos, function(combo){
      var key = combo.sort().join('');
      var dataAttr = 'data-' + key + '="true"';
      $p.attr('data-' + key, 'true');
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

  // scan again for single countries
  replacedHtml = replacedHtml.replace(/([\[ ])(CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)([^\/])/g, function(match, before, country, after, offset, string){
    if (string.match(/^\d+.*Negotiator/) && !string.match(new RegExp(country + ' (oppose|propose)'))){
      // dealing with a footnote that is not using oppose or propose
      return match;
    }
    recordCountry(country);
    //console.log('found ' + country + ' in  ' + match);
    //console.log(string);
    return before + '<strong data-country="'+country+'">' + country + '</strong>' + after;
  });

  $p.html(replacedHtml + '\n\n');
});


// put it back into the index doc
var indexPath = __dirname + '/../app/index.html';
var indexHtml = fs.readFileSync(indexPath, {encoding: 'utf8'});
var $index = cheerio.load(indexHtml);
$index('#transcripts').html($.html());
fs.writeFileSync(indexPath, $index.html(), {encoding: 'utf8'});

// write out csv doc
var csvPath = __dirname + '/../app/data/voting_similarity.csv';
var lines = ['voting_country,partner,sim_votes,sim_pct,baseline'];
_.each(countries, function(voter){
  var voterAbbrev = abbrevs[voter];
  var voterTotal = allCountries[voterAbbrev];
  _.each(countries, function(partner){
    var covote, partnerAbbrev;
    if (partner === voter){
      covote = voterTotal;
    }else{
      partnerAbbrev  = abbrevs[partner];
      covote = allCombos[[voterAbbrev,partnerAbbrev].sort().join('')];
    }
    lines.push([voter, partner, covote, covote/voterTotal, voterTotal].join(','));
  });
});
fs.writeFileSync(csvPath, lines.join('\n'), {encoding: 'utf8'});
