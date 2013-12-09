var fs = require('fs');
var sourceText = fs.readFileSync('../chapter_text.txt', {encoding: 'utf8'});
var _ = require('lodash');
var Combinatorics = require('js-combinatorics').Combinatorics;
var util = require('util');


var html = '';
var processedHtml = [];

extractProposals(sourceText);
addParagraphs();
fs.writeFileSync('../../scripts/_tpp-data.coffee', 'window.tppData = JSON.parse(\'' + JSON.stringify(processedHtml).replace(/\\/g, '\\\\').replace(/'/g, '\\\'') + '\')');

function extractProposals(text){
  var lines = text.split('\n');
  var line;
  var stack = [];
  var character;
  var proposal;
  var lineHtml;
  var covotes;
  var endSlice;
  for (var no = 0; no < lines.length; no++){
    lineHtml = '';
    line = lines[no];
    for (var i = 0; i < line.length; i++){
      character = line[i];
      if (character === '['){
        // quickly use regexes to get all countries until next opening bracket
        endSlice = line.slice(i + 1).indexOf('[');
        if (endSlice === -1){
          endSlice = undefined;
        }
        covotes = line.slice(i, endSlice && (i + endSlice)).match(/(((CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)[\/\: $])+)/g);
        if (covotes){
          covotes = buildCovoteAttrs(covotes);
        }
        if (covotes && covotes.length){
          lineHtml += '<mark ' + covotes.join(' ') + '>[';
        }else{
          covotes = null;
          lineHtml += '[';
        }
        stack.push({startLine: no, start: i, covotes: covotes});
      }else if (character === ']'){
        if (!stack.length){
          console.error('close an unopened?');
          console.error({line: no, character: i, full: line});
        }
        proposal = stack.pop();
        lineHtml += ']';
        if (proposal.covotes){
          lineHtml += '</mark>';
        }
      }else{
        lineHtml += line[i];
      }
    }
    if (lineHtml.length){
      html += lineHtml + '\n';
    }
  }
  if (stack.length){
    console.error('never closed??');
    console.error(stack);
  }
}

function addParagraphs(){
  var stack = [];
  var lineNumber = 0;
  html.split('\n').forEach(function(line){
    var p = '';
    // add any unclosed stacks
    p += stack.join();
    for (var i = 0; i < line.length; i++){
      if (line.slice(i, i + 5) === '<mark'){
        stack.push(line.match(/<mark.*?>/)[0]);
      }else if (line.slice(i, i + 6) === '</mark'){
        stack.pop();
      }
    }
    // close any span tags
    p += line;
    p += _.map(stack, function(){ return '</mark>'; }).join();
    processedHtml.push({line: lineNumber, html: p, combos: extractCombos(line)});
    lineNumber++;
  });
  processedHtml = _.select(processedHtml, function(para){
    return !_.isEmpty(para.combos);
  });
}

function extractCombos(line){
  var combos = {};
  var covoteAttrs = line.match(/data-(.+?)="true"/g) || [];
  covoteAttrs.forEach(function(coVote){
    var datum = coVote.match(/data-(.*?)=/)[1];
    combos[datum] = true;
  });
  return combos;
}


function buildCovoteAttrs(covotes){
  if (!covotes) return [];
  return _.flatten(_.compact(_.map(covotes, function(vote){
    var combos;
    if (vote.split('/').length > 1){
      combos = Combinatorics.combination(vote.replace(/[^A-Z\/]/, '').split('/').sort(), 2).toArray();
      return _.map(combos, function(combo){
        return 'data-' + combo.join('') + '="true"';
      });
    }else{
      return [];
    }
  })));
}

