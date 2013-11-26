#!/usr/bin/env python
import re
import csv
import sys, argparse
from bs4 import BeautifulSoup

arg_parser = argparse.ArgumentParser(description='Parse some html')
arg_parser.add_argument('-i', '--input', help='Input html file', required=True)
arg_parser.add_argument('-o', '--output', help='Output csv file', required=True)
args = arg_parser.parse_args()

# CA|US|US|PE|BN|NZ|AU|MX|SG|MY|CL|JP
country_abbrevs = {
    'US': 'United States',
    'JP': 'Japan',
    'MX': 'Mexico',
    'CA': 'Canada',
    'AU': 'Australia',
    'MY': 'Malaysia',
    'CL': 'Chile',
    'SG': 'Singapore',
    'PE': 'Peru',
    'VN': 'Vietnam',
    'NZ': 'New Zealand',
    'BN': 'Brunei'
}

def parse_html(input_file):
    cull = []
    soup = BeautifulSoup(open(input_file))

    pattern = re.compile(r'c\d+')
    p_h2s = soup.find_all(['h2', 'p'])

    for p_h2 in p_h2s:
        css_class = p_h2.get('class')
        if css_class and 'sdfootnote' not in css_class:
            cull.append(re.sub(r'(\/)\s', '\1', p_h2.text.replace('\n', '')))

    return cull


def main(html_in, csv_file):
    parsed = '\n'.join(parse_html(html_in))
    pro_opp_pattern = re.compile(r'((?:(?:CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)\/*)+\]*\s*)(\w+)?', re.UNICODE)
    matches = pro_opp_pattern.finditer(parsed)

    csv_out = csv.writer(open(csv_file, 'wb'), delimiter=',')
    csv_out.writerow(['countries', 'decision'])

    for m in matches:
        groups = m.groups()
        stance = groups[1].lower() if groups[1] else 'none'
        countries = m.groups()[0].replace('//', '/').replace(']', '')
        countries = [s.strip() for s in countries.split('/') if s.strip() != '']
        countries = '/'.join(countries)
        csv_out.writerow([countries, stance])
        #
        # GET actual country names with this. Not needed yet
        # named = [country_abbrevs[s] for s in cleaned if s != '']
        #

if __name__ == '__main__':
    main(args.input, args.output)