import pandas as pd
import numpy as np

def get_num_matches(df, var1, var2):
    matches = df[(df.countries.str.contains(var1)) & (df.countries.str.contains(var2))]
    return len(matches)

def long_data(input_df, empty_df):
    long_df = empty_df.unstack().reset_index()
    long_df.columns = ['voting_country', 'partner', 'sim_votes']
    long_df['sim_pct'] = np.nan

    for i, r in long_df.iterrows():
        voter = r['voting_country']
        partner = r['partner']
        baseline = float(get_num_matches(input_df, voter, voter))
        matches = float(get_num_matches(input_df, voter, partner))
        long_df['sim_pct'].ix[i] = matches / baseline
        long_df['sim_votes'].ix[i] = matches

    return long_df