from __future__ import division
import pandas as pd
import numpy as np

def get_num_matches(df, var1, var2):
    matches = df[(df.countries.str.contains(var1)) & (df.countries.str.contains(var2))]
    return len(matches)

def long_data(input_df, empty_df, hash_map):
    long_df = empty_df.unstack().reset_index()
    long_df.columns = ['voting_country', 'partner', 'sim_votes']
    long_df['sim_pct'] = np.nan
    long_df['baseline'] = np.nan

    for i, r in long_df.iterrows():
        voter = r['voting_country']
        partner = r['partner']
        baseline = get_num_matches(input_df, voter, voter)
        matches = get_num_matches(input_df, voter, partner)
        long_df['baseline'].ix[i] = baseline
        long_df['sim_votes'].ix[i] = matches
        long_df['sim_pct'].ix[i] = matches / baseline

    long_df['voting_country'] = [hash_map[c] for c in long_df['voting_country']]
    long_df['partner'] = [hash_map[c] for c in long_df['partner']]
    long_df['baseline'] = long_df['baseline'].astype(int)
    return long_df
