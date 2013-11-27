Turn the [TPP IP chapter html](https://wikileaks.org/tpp/) into a CSV of Euclidean distances, using Multi-Dimensional Scaling.

Requirements:
* `pandas`
* `scikit-learn`
* [sklearn-pandas](https://github.com/paulgb/sklearn-pandas)
* [BeautifulSoup4](http://www.crummy.com/software/BeautifulSoup/bs4/doc/)

##Usage

    usage: tpp.py [-h] [-i INPUT] [-d [DECISIONS]] [-p [POSITIONS]]

    Parse some html

    optional arguments:
      -h, --help            show this help message and exit
      -i INPUT, --input INPUT
                            Name of html file to be parsed. Default:
                            tpp_ip_chapter.html
      -d [DECISIONS], --decisions [DECISIONS]
                            Name of CSV file with individual decisions and related
                            countries. Default: decisions.csv
      -p [POSITIONS], --positions [POSITIONS]
                            Name of CSV file with MDS positions of countries.
                            Default: mds_positions.csv
