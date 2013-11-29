##TGM Chart template

Minimal template to automate some steps for making iframe charts for TGM stories. Offers coffeescript, less and livereload for rapid chart-making.

1. `npm install`
2. `bower install <package>` for the packages you want to use, eg `bower install jquery highcharts`
3. Add links to library scripts in `index.html` inside the library block
4. `grunt server` to view what is happening
5. `grunt build` to compile/minify/concatenate/etc

###TODO:
* Automate deployment to CDN
* Design template for standalone viz (for cases when people might want to link to the viz or chart directly). Might include:
  * branding
  * link back to original story
  * social media stupidity
* Templates/API for particular chart/viz types?