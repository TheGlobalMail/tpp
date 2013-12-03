#!/usr/bin/env python
import pandas as pd
import argparse
from transform.make_mds import make_mds
from transform.parse_html import parse_html
from transform.long_data import long_data

arg_parser = argparse.ArgumentParser(description='Parse some html')
arg_parser.add_argument('-i', '--input', default='tpp_ip_chapter.html', type=str, help='Name of html file to be parsed. Default: tpp_ip_chapter.html')
arg_parser.add_argument('-d', '--decisions', nargs='?', const='csv/decisions.csv', type=str, help='Name of CSV file with individual decisions and related countries. Default: decisions.csv')
arg_parser.add_argument('-p', '--positions', nargs='?', const='csv/mds_positions.csv', type=str, 
        help='Name of CSV file with MDS positions of countries. Default: mds_positions.csv')
arg_parser.add_argument('-l', '--long', nargs='?', const='csv/voting_similarity.csv', type=str, 
        help='Parse long-form data. Default: csv/voting_similarity.csv')
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
# dataframe of MDS positions position_df = make_mds(decisions_df, empty_df, country_map) 

def main():
    if args.decisions and not args.positions:
        print '-----------------------------------------------'
        print 'Rendering decisions to ' + args.decisions
        print '-----------------------------------------------'
        decisions_df.to_csv(args.decisions)
        return

    elif args.positions:
        print '-----------------------------------------------'
        print 'Rendering positions to ' + args.positions
        print '-----------------------------------------------'
        position_df.to_csv(args.positions)
        return

    elif args.long:
        long_df = long_data(decisions_df, empty_df, country_map)
        print '-----------------------------------------------'
        print 'Rendering long data to ' + args.long
        print '-----------------------------------------------'
        long_df.to_csv(args.long, index=False)

    else:
        print '-----------------------------------------------'
        print 'MDS POSITIONS'
        print '-----------------------------------------------'
        #print position_df.to_string()



if __name__ == '__main__':
    main()
