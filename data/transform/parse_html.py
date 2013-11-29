import re
import csv
import pandas as pd
from bs4 import BeautifulSoup


def cull_html(input_file):
    cull = []
    soup = BeautifulSoup(open(input_file))

    # get all of the ps and h2s in the document
    p_h2s = soup.find_all(['h2', 'p'])

    for p_h2 in p_h2s:
        # ignore the footnotes
        css_class = p_h2.get('class')
        if css_class and 'sdfootnote' not in css_class:
            cull.append(re.sub(r'(\/)\s', '\1', p_h2.text.replace('\n', '')))

    return cull

    
def parse_html(html_in):
    parsed = '\n'.join(cull_html(html_in))
    # this pattern appears to catch all the decisions, as well as the subsequent word (if there is one)
    pro_opp_pattern = re.compile(r'((?:(?:CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)\/*)+\]*\s*)(\w+)?', re.UNICODE)
    matches = pro_opp_pattern.finditer(parsed)
    d = []

    for m in matches:
        groups = m.groups()
        stance = groups[1].lower() if groups[1] else 'none'
        countries = m.groups()[0].replace('//', '/').replace(']', '')
        countries = [s.strip() for s in countries.split('/') if s.strip() != '']
        countries = '/'.join(countries)

        row = {
            'countries': countries,
            'stance': stance
        }

        d.append(row)

    return pd.DataFrame.from_records(d)
