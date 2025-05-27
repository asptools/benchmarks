import numpy as np
import pandas as pd
import optuna
import xgboost as xgb
import logging
import time
from sklearn.metrics import accuracy_score
from IPython.display import clear_output
from sklearn.model_selection import LeaveOneOut

optuna.logging.set_verbosity(optuna.logging.WARNING)

X_TRAIN = None
Y_TRAIN = None
X_TEST = None
Y_TEST = None

def objective(trial):
    max_depth = trial.suggest_int('max_depth', 1, 11)
    n_estimators = trial.suggest_int('n_estimators', 100, 5900, step = 200)
    min_child_weight = trial.suggest_float('min_child_weight', 1.0, 100.0, log = True)
    subsample = trial.suggest_float('subsample', 0.5, 1.0)
    learning_rate = trial.suggest_float('learning_rate', 1e-5, 0.7, log = True)
    colsample_bylevel = trial.suggest_float('colsample_bylevel', 0.5, 1.0)
    colsample_bytree = trial.suggest_float('colsample_bytree', 0.5, 1.0)
    gamma = trial.suggest_float('gamma', 1e-8, 7.0, log = True)
    reg_lambda = trial.suggest_float('reg_lambda', 1.0, 4.0, log = True)
    reg_alpha = trial.suggest_float('reg_alpha', 1e-8, 100.0, log = True)

    xgboost = xgb.XGBClassifier(
        random_state = 42,
        verbosity = 0,
        max_depth = max_depth,
        n_estimators = n_estimators,
        min_child_weight = min_child_weight,
        subsample = subsample,
        learning_rate = learning_rate,
        colsample_bylevel = colsample_bylevel,
        colsample_bytree = colsample_bytree,
        gamma = gamma,
        reg_lambda = reg_lambda,
        reg_alpha = reg_alpha
    )
    xgboost.fit(X_TRAIN, Y_TRAIN)
    y_pred = xgboost.predict(X_TEST)
    return accuracy_score(Y_TEST, y_pred)

def early_stopping(study, _):
    if study.best_value == 1.0:
        study.stop()

def find_optimal_xgboost(X, y):
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
    study.optimize(objective, n_trials = 100, n_jobs = - 1, show_progress_bar = True, callbacks = [early_stopping])
    
    best_params = study.best_params
    logging.info(best_params)

    xgboost = xgb.XGBClassifier(
        random_state = 42,
        verbosity = 0,
        max_depth = best_params['max_depth'],
        n_estimators = best_params['n_estimators'],
        min_child_weight = best_params['min_child_weight'],
        subsample = best_params['subsample'],
        learning_rate = best_params['learning_rate'],
        colsample_bylevel = best_params['colsample_bylevel'],
        colsample_bytree = best_params['colsample_bytree'],
        gamma = best_params['gamma'],
        reg_lambda = best_params['reg_lambda'],
        reg_alpha = best_params['reg_alpha']
    )
    return xgboost

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
    best_estimator = find_optimal_xgboost(X_train, y_train)

    best_estimator.fit(X_train, y_train)
    y_test_pred = best_estimator.predict(X_test)
    return accuracy_score(y_test, y_test_pred)

def cross_validation(dataset_name, target_feature):
    logging.basicConfig(filename = f'logs/{dataset_name}_xgboost.log', level = logging.INFO, force = True)
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
        best_estimator = find_optimal_xgboost(X_train, y_train)
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