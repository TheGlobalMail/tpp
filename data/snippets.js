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
strippedHtml = strippedHtml.replace(/(<p class="sdfootnote .*?>\d+)<\/a>/g, '$1 ');
// strip out all the links
strippedHtml = strippedHtml.replace(/(<\/*a.*?>)/g, '');

/*
// lets sort out those footnotes links
strippedHtml = strippedHtml.replace(/(<a.*?>)(.*?)(<\/a>)/g, function(match, startA, content){
  if (match.match(/class="sdfootnoteanc"/)){
    if (content.length){
      return '<sup>' + content + '</sup>';
    }else{
      return '<sup>' + startA.match(/id="\w+(\d+)\w+"/)[1] + '</sup>';
    }
  }else{
    return content;
  }
});
*/
// lets pull out the footnotes without a bracket in them to put back later
var footnotesToIgnore = [];
var ignoreFootnoteMarker = 'NNNNNNNNNOOOOOOOTTTTTTTEEEEEEE';
strippedHtml = strippedHtml.replace(/<p class="sdfootnote.*?>.*?<\/p>/g, function(match){
  if (match.match(/\[(((CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)[\/ ])+) *propose[^\w]|oppose:/)){
    return match;
  }else{
    footnotesToIgnore.push(match);
    return ignoreFootnoteMarker + (footnotesToIgnore.length - 1);
  }
});

// Replace double slashes with single
strippedHtml = strippedHtml.replace(/\/\//g, '/');
// Pull out all {}
strippedHtml = strippedHtml.replace(/\{|\}/g, ' ');

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

var re = /(((CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)[\/\: <$])+)/g;
var replacedHtml = strippedHtml.replace(re, function(countriesMatch){
  var countries = countriesMatch.replace(/[^A-Z\/]/g, '').split('/').sort();
  var parsedCountries = countriesMatch.match(/([\w\/]+)(.*)$/);
  var countryList = parsedCountries[1].split('/');
  var bitAtEnd = parsedCountries[2];
  if (countries.length < 2){
    return countriesMatch;
  }
  var combos = Combinatorics.combination(countries, 2).toArray();
  // Records country and combos for later
  _.each(countries, recordCountry);
  _.each(combos, recordCombo);
  var dataAttrs = _.map(combos, function(combo){
    var key = combo.sort().join('');
    var dataAttr = 'data-' + key + '="true"';
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
  recordCountry(country);
  return before + '<strong data-country="'+country+'">' + country + '</strong>' + after;
});


// put ignored footnotes back in
replacedHtml = replacedHtml.replace(new RegExp(ignoreFootnoteMarker + '(\\d+)', 'g'), function(match, m1){
  var index = parseInt(m1, 10);
  return footnotesToIgnore[index];
});

var $ = cheerio.load(replacedHtml);

$('h1').removeClass().addClass(function () {
    var id = ($(this).attr('id'));
    return id ? 'tpp-big-head section-title' : 'tpp-big-head';
  });

$('h2').removeClass().addClass('tpp-med-head');

console.error(allCountries);

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
