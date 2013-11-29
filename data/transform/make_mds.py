import pandas as pd
from sklearn_pandas import DataFrameMapper
from sklearn import manifold
from sklearn.metrics import euclidean_distances
from sklearn.decomposition import PCA


def relation_mean(df):
    combine = pd.concat((df, df.T))
    return combine.groupby(combine.index).mean()


def mds_positions(df, identifier, hash_map):
    euc = pd.DataFrame(euclidean_distances(df), index=df.index, columns=df.columns)
    mds = manifold.MDS(dissimilarity='precomputed', max_iter=3000)
    posdf = pd.DataFrame(mds.fit(euc).embedding_, index=euc.index)
    clf = PCA(n_components=2)
    posdf = pd.DataFrame(clf.fit_transform(posdf), index=posdf.index)
    posdf[identifier] = [hash_map[abb] for abb in posdf.index]
    return posdf


def normalize_(df_series):
    # put in terms of percentage of total votes lodged by a given df_series
    baseline = df_series[df_series.name]
    return df_series / baseline


def add_values(input_df, empty_df, col):
    # count number of matches for given pair of countries
    for i in empty_df.index:
        for c in empty_df.index:
            matches = len(input_df[(input_df[col].str.contains(i)) & (input_df[col].str.contains(c))])
            empty_df[c].ix[i] = float(matches)

    return empty_df


def make_mds(input_df, empty_df, hash_map, input_df_index='countries', output_df_index='country_name'):
    matrix = add_values(input_df, empty_df, input_df_index)
    matrix = matrix.apply(normalize_)
    matrix = relation_mean(matrix)
    matrix = mds_positions(matrix, output_df_index, hash_map)
    return matrix
