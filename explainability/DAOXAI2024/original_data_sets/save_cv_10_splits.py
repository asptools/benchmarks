import os
from booleanize import booleanize_using_medians, booleanize_categorical_attributes
from sklearn.model_selection import KFold

def save_cv_10_splits(df, dataset_name, categorical_features = None, continous_features = None, boolean_features = None):
    output_dir = f'../cv_splits_10/non_booleanized_splits/{dataset_name}'
    os.makedirs(output_dir, exist_ok=True)
    output_dir = f'../cv_splits_10/{dataset_name}'
    os.makedirs(output_dir, exist_ok=True)

    bool_df = df.copy()
    bool_df['target'] = bool_df['target'].replace({1: True, 0: False})

    if categorical_features is not None:
        bool_df = booleanize_categorical_attributes(bool_df, categorical_features)

    if boolean_features is not None:
        for feature in boolean_features:
            bool_df[feature] = bool_df[feature].replace({1 : True, 0 : False})

    kfold = KFold(n_splits = 10, shuffle = True, random_state = 42)
    for i, (train_index, test_index) in enumerate(kfold.split(df)):
        df = df.sample(frac = 1, random_state = 42)
        bool_df = bool_df.sample(frac = 1, random_state = 42)

        df_train = df.iloc[train_index]
        valid_index = int(len(df_train) * 0.7)
        df_valid_train = df_train.iloc[:valid_index]
        df_valid_test = df_train.iloc[valid_index:]
        df_test = df.iloc[test_index]
        
        df_valid_train.to_csv(f'../cv_splits_10/non_booleanized_splits/{dataset_name}/{dataset_name}_split_{i + 1}_valid_train.csv', index = False)
        df_valid_test.to_csv(f'../cv_splits_10/non_booleanized_splits/{dataset_name}/{dataset_name}_split_{i + 1}_valid_test.csv', index = False)
        df_train.to_csv(f'../cv_splits_10/non_booleanized_splits/{dataset_name}/{dataset_name}_split_{i + 1}_train.csv', index = False)
        df_test.to_csv(f'../cv_splits_10/non_booleanized_splits/{dataset_name}/{dataset_name}_split_{i + 1}_test.csv', index = False)

        bool_df_train = bool_df.iloc[train_index]
        bool_df_valid_train = bool_df_train.iloc[:valid_index]
        bool_df_valid_test = bool_df_train.iloc[valid_index:]
        bool_df_test = bool_df.iloc[test_index]

        if continous_features is not None:
            medians, bool_df_valid_train = booleanize_using_medians(bool_df_valid_train, continous_features)
            _, bool_df_valid_test = booleanize_using_medians(bool_df_valid_test, continous_features, medians)
            medians, bool_df_train = booleanize_using_medians(bool_df_train, continous_features)
            _, bool_df_test = booleanize_using_medians(bool_df_test, continous_features, medians)

        bool_df_valid_train.to_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i + 1}_valid_train.csv', index = False)
        bool_df_valid_test.to_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i + 1}_valid_test.csv', index = False)
        bool_df_train.to_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i + 1}_train.csv', index = False)
        bool_df_test.to_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i + 1}_test.csv', index = False)