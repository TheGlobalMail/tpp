import re
import codecs
import csv
from bs4 import BeautifulSoup

def get_tags(input_file):
    soup = BeautifulSoup(open(input_file))

    # get all of the ps and h2s in the document
    p_h2 = soup.find_all(['h2', 'p'])
    return country_classes(p_h2)


def country_classes(p_h2_tags):
    out_html_str = ''

    country_pattern = re.compile(r"""
        (\[?
            (?:
                (?:CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)
                (?:\/*)
            )+
        )
        (.*?
            (?=CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)
        )
        """, re.VERBOSE | re.DOTALL | re.MULTILINE ) 

    first_p_tag = True

    for tag in p_h2_tags:
        if tag.name != 'h2':
            row = tag.text.replace('\n', ' ').encode('utf-8')
            m = country_pattern.findall(row)
            if len(row) > 1:
                if len(m) > 0:
                    out_html_str += '</p>'
                    rowhtml = ''
                    first_p_tag = True
                    for match in m:
                        groups = match
                        countries_css = re.sub(r'(\/|\s|\[|\])', ' ', groups[0]).strip()
                        spantag = ' <span class="countries ' + countries_css + '">' + groups[0] + '</span>' + groups[1]
                        rowhtml += spantag
                    out_html_str += ''.join(['<p>', rowhtml, '</p>'])
                else:
                    if first_p_tag:
                        out_html_str += '<p>' + row
                        first_p_tag = False
                    else:
                        out_html_str += row
        else:
            out_html_str += '<h2>' + tag.text + '</h2>' + '\n'

    return out_html_str


def add_classes(input_file, output_file):
    tags = get_tags(input_file)
    classed_html = country_classes(tags)
