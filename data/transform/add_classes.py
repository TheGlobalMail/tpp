import re
import codecs
import csv
from bs4 import BeautifulSoup


def get_tags(input_file):
    cull = []
    soup = BeautifulSoup(open(input_file))

    # get all of the ps and h2s in the document
    p_h2 = soup.find_all(['h2', 'p'])

    return p_h2


def country_classes(tags):
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

    for tag in tags:
        tag_text = tag.text.replace('\n', ' ')
        print country_pattern.findall(tag_text)

    return out_html_str


def add_classes(input_file, output_file):
    tags = get_tags(input_file)
    classed_html = country_classes(tags)
    print classed_html
