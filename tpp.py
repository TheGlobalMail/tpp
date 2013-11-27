#!/usr/bin/env python
import pandas as pd
import argparse
from transform.make_mds import transform
from transform.parse_html import parse_html

arg_parser = argparse.ArgumentParser(description='Parse some html')
arg_parser.add_argument('-i', '--input', help='Html file to be parsed', required=True)
arg_parser.add_argument('-d', '--decisions', type=str, help='Name of CSV file with individual decisions and related countries')
arg_parser.add_argument('-p', '--positions', type=str, help='Name of CSV file with MDS positions of countries')
args = arg_parser.parse_args()

country_map = {
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
country_abbrevs = sorted(country_map.keys())

# empty dataframe, which will be populated with MDS positions data
empty_df = pd.DataFrame(index=country_abbrevs, columns=country_abbrevs)
# make dataframe of individual votes and countries that voted
decisions_df = parse_html(args.input)
# dataframe of MDS positions
position_df = transform(decisions_df, empty_df, country_map)

def main():
    if args.decisions and not args.positions:
        print '-----------------------------------------------'
        print 'Rendering decisions to ' + args.decisions
        print '-----------------------------------------------'
        decisions_df.to_csv(args.decisions)
        return

    if args.positions:
        print '-----------------------------------------------'
        print 'Rendering positions to ' + args.positions
        print '-----------------------------------------------'
        position_df.to_csv(args.positions)
        return
    else:
        print '-----------------------------------------------'
        print 'MDS POSITIONS'
        print '-----------------------------------------------'
        print position_df.to_string()



if __name__ == '__main__':
    main()