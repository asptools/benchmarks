import numpy as np
import pandas as pd
import optuna
import logging
import time
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from IPython.display import clear_output
from sklearn.model_selection import LeaveOneOut

optuna.logging.set_verbosity(optuna.logging.WARNING)

X_TRAIN = None
Y_TRAIN = None
X_TEST = None
Y_TEST = None

def objective(trial):
    max_depth = trial.suggest_categorical('max_depth', [None, 2, 3, 4])
    n_estimators = trial.suggest_int('n_estimators', 9.5, 3000.5, log = True)
    criterion = trial.suggest_categorical('criterion', ['gini', 'entropy'])
    max_features = trial.suggest_categorical('max_features', ['sqrt', 'log2', None, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])
    min_samples_split = trial.suggest_categorical('min_samples_split', [2, 3])
    min_samples_leaf = trial.suggest_int('min_samples_leaf', 1.5, 50.5, log = True)
    bootsrap = trial.suggest_categorical('bootstrap', [True, False])
    min_impurity_decrease = trial.suggest_categorical('min_impurity_decrease', [0.0, 0.01, 0.02, 0.05])

    rf = RandomForestClassifier(
        random_state = 42,
        max_depth = max_depth,
        n_estimators = n_estimators,
        criterion = criterion,
        max_features = max_features,
        min_samples_split = min_samples_split,
        min_samples_leaf = min_samples_leaf,
        bootstrap = bootsrap,
        min_impurity_decrease = min_impurity_decrease 
    )
    rf.fit(X_TRAIN, Y_TRAIN)
    y_pred = rf.predict(X_TEST)
    return accuracy_score(Y_TEST, y_pred)

def find_optimal_random_forest(X, y):
    global X_TRAIN
    global Y_TRAIN
    global X_TEST
    global Y_TEST

    index = int(len(X) * 0.7)
    X_TRAIN = X.iloc[:index]
    Y_TRAIN = y.iloc[:index]
    X_TEST = X.iloc[index:]
    Y_TEST = y.iloc[index:]

    study = optuna.create_study(direction = 'maximize')
    study.optimize(objective, n_trials = 100, n_jobs = -1, show_progress_bar = True)
    
    best_params = study.best_params
    logging.info(best_params)

    rf = RandomForestClassifier(
        random_state = 42,
        max_depth = best_params['max_depth'],
        n_estimators = best_params['n_estimators'],
        criterion = best_params['criterion'],
        max_features = best_params['max_features'],
        min_samples_split = best_params['min_samples_split'],
        min_samples_leaf = best_params['min_samples_leaf'],
        bootstrap = best_params['bootstrap'],
        min_impurity_decrease = best_params['min_impurity_decrease']
    )
    return rf

def cross_validation_one_split(dataset_name, target_feature, i):
    clear_output(wait = True)

    df_train = pd.read_csv(f'../cv_splits_10/non_booleanized_splits/{dataset_name}/{dataset_name}_split_{i}_train.csv')
    X_train = df_train.drop(columns = [target_feature])
    y_train = df_train[target_feature]

    df_test = pd.read_csv(f'../cv_splits_10/non_booleanized_splits/{dataset_name}/{dataset_name}_split_{i}_test.csv')
    X_test = df_test.drop(columns = [target_feature])
    y_test = df_test[target_feature]

    # Hyperparameter tuning.
    print(f'Optimizing hyperparameters for the {i}th split...')
    best_estimator = find_optimal_random_forest(X_train, y_train)

    best_estimator.fit(X_train, y_train)
    y_test_pred = best_estimator.predict(X_test)
    return accuracy_score(y_test, y_test_pred)

def cross_validation(dataset_name, target_feature):
    logging.basicConfig(filename = f'logs/{dataset_name}_rf.log', level = logging.INFO, force = True)
    accuracies = []
    for i in range(1,11):
        start_time = time.time()
        accuracy = cross_validation_one_split(dataset_name, target_feature, i)
        runtime = time.time() - start_time
        accuracies.append(accuracy)
        logging.info(f'Runtime in seconds for split {i}: {runtime}')
    return accuracies

def leave_one_out(dataset_name, target_feature):
    global FILE_PATH
    accuracies = []
    df = pd.read_csv(f'../original_data_sets/{dataset_name}/{dataset_name}.csv')
    loo = LeaveOneOut()
    for i, (train_index, test_index) in enumerate(loo.split(df)):
        df_train = df.iloc[train_index]
        df_test = df.iloc[test_index]
        df_train = df_train.sample(frac = 1, random_state = 42)

        X_train = df_train.drop(columns = [target_feature])
        y_train = df_train[target_feature]
        X_test = df_test.drop(columns = [target_feature])
        y_test = df_test[target_feature]

        # Drop constant columns.
        constant_columns = X_train.columns[X_train.nunique() == 1]
        X_train.drop(columns = constant_columns, inplace = True)
        X_test.drop(columns = constant_columns, inplace = True)

        # Hyperparameter tuning.
        print(f'Optimizing hyperparameters for the {i}th split...')
        best_estimator = find_optimal_random_forest(X_train, y_train)
        best_estimator.fit(X_train, y_train)
        y_test_pred = best_estimator.predict(X_test)
        accuracies.append(accuracy_score(y_test, y_test_pred))

        clear_output(wait = True)
    return accuracies

def run_cv_experiments(dataset_name, target_feature):
    accuracies = cross_validation(dataset_name, target_feature)

    clear_output(wait = True)
    
    print(f'Average accuracy: {np.mean(accuracies)}')
    print(f'Standard deviation: {np.std(accuracies)}')

def run_loocv_experiments(dataset_name, target_feature):
    accuracies = leave_one_out(dataset_name, target_feature)
    
    clear_output(wait = True)
    
    print(f'Average accuracy: {np.mean(accuracies)}')