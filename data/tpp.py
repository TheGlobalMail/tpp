#!/usr/bin/env python
import argparse
from transform.add_classes import add_classes

arg_parser = argparse.ArgumentParser(description='Parse some html')
arg_parser.add_argument('-i', '--input', default='tpp_ip_chapter.html', type=str, help='Name of html file to be parsed. Default: tpp_ip_chapter.html')
arg_parser.add_argument('-p', '--positions', nargs='?', const='csv/mds_positions.csv', type=str, help='Name of CSV file with MDS positions of countries. Default: mds_positions.csv')
arg_parser.add_argument('-d', '--decisions', nargs='?', const='csv/decisions.csv', type=str, help='Name of CSV file with individual decisions and related countries. Default: decisions.csv')
arg_parser.add_argument('-l', '--long', nargs='?', const='csv/voting_similarity.csv', type=str, help='Parse long-form data. Default: csv/voting_similarity.csv')
arg_parser.add_argument('-c', '--css', nargs='?', const='classed.html', type=str, help='Parse long-form data. Default: csv/voting_similarity.csv')
args = arg_parser.parse_args()


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

    elif args.css:
        add_classes(args.input, args.css)
        print '-----------------------------------------------'
        print 'Ran add_classes() with arg ' + args.css
        print '-----------------------------------------------'


if __name__ == '__main__':
    main()
