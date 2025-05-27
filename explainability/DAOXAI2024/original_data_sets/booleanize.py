import pandas as pd

def booleanize_using_medians(df, columns, medians = {}):
    new_medians = {}
    bool_df = df.copy()
    for column in columns:
        if column in medians:
            median = medians[column]
            bool_df[column + '_above_median'] = df[column] > median
        else:
            median = df[column].median()
            new_medians[column] = median
            bool_df[column + '_above_median'] = df[column] > median
    bool_df.drop(columns = columns, inplace = True)
    return new_medians, bool_df

def booleanize_categorical_attributes(df, columns):
    df_copy = df.copy()
    for attribute in columns:
        df_copy[attribute] = df_copy[attribute].astype(str)
    one_hot_encoded = pd.get_dummies(df_copy[columns])
    concatenated_columns = pd.concat([df_copy, one_hot_encoded], axis=1)
    concatenated_columns.drop(columns = columns, inplace = True)
    return concatenated_columns