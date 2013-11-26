import pandas as pd
import argparse
from sklearn_pandas import DataFrameMapper
from sklearn import manifold
from sklearn.metrics import euclidean_distances

arg_parser = argparse.ArgumentParser(description='Find the similarity between the decisions')
arg_parser.add_argument('-i', '--input', help='Input csv', required=True)
arg_parser.add_argument('-o', '--output', help='Output csv, of decisions', required=True)
args = arg_parser.parse_args()


def decision_similarity(input_csv, output_csv):
    decisions = pd.read_csv(input_csv, delimiter=',')

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
    relation = pd.DataFrame(index=country_abbrevs, columns=country_abbrevs)

    # number of matches for given pair of countries
    for i in relation.index:
        for c in country_abbrevs:
            matches = len(decisions[(decisions.countries.str.contains(i)) & (decisions.countries.str.contains(c))])
            relation[c].ix[i] = float(matches)

    # put in terms of percentage of total votes
    def normalize_(country):
        baseline = country[country.name]
        return 1 - country / baseline

    relation = relation.apply(normalize_)
    combine = pd.concat((relation, relation.T))
    normalized = combine.groupby(combine.index).mean()
    euc = pd.DataFrame(euclidean_distances(normalized), index=normalized.index, columns=normalized.columns)

    mds = manifold.MDS()
    posdf = pd.DataFrame(mds.fit_transform(euc), index=euc.index)
    posdf['country_name'] = [country_map[abb] for abb in posdf.index]

    posdf.to_csv(output_csv)


if __name__ == '__main__':
    main(args.input, args.output)