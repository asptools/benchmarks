import pandas as pd
import numpy as np
from tqdm import tqdm
from erm import EmpiricalIdealClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import LeaveOneOut
from sklearn.feature_selection import SelectKBest, f_classif, mutual_info_classif, chi2
from joblib import Parallel, delayed

FILE_PATH = str()

def custom_mutual_info_classif(X, y):
    return mutual_info_classif(X, y, random_state = 42)

def train_erm(X_train, y_train, X_test, y_test, features):
    clf = EmpiricalIdealClassifier()
    clf.fit(X_train, y_train, features)
    
    y_overfitter_train_pred = clf.predict(X_train)
    y_overfitter_test_pred = clf.predict(X_test)
    
    train_accuracy = accuracy_score(y_train, y_overfitter_train_pred)
    test_accuracy = accuracy_score(y_test, y_overfitter_test_pred)
    
    return [str(clf), train_accuracy, test_accuracy]

def train_erm_with_feature_selection(X_train, y_train, X_test, y_test, k_param, score_func):
    k_best = SelectKBest(score_func = score_func, k = k_param)
    k_best.fit_transform(X_train,y_train)
    relevant_features = k_best.get_feature_names_out()
    result = train_erm(X_train, y_train, X_test, y_test, relevant_features)
    result = result + [relevant_features]
    return result

def find_optimal_k_features(X_train, y_train, X_test, y_test, k):
    result_f = train_erm_with_feature_selection(X_train, y_train, X_test, y_test, k, f_classif)
    result_info = train_erm_with_feature_selection(X_train, y_train, X_test, y_test, k, custom_mutual_info_classif)
    result_chi2 = train_erm_with_feature_selection(X_train, y_train, X_test, y_test, k, chi2)
    result = sorted([result_f, result_info, result_chi2], key = lambda x : x[2], reverse = True)[0]
    return k, result

def find_optimal_features(X_train, y_train, X_test, y_test):
    global FILE_PATH

    _ = Parallel(n_jobs = -1)(
        delayed(find_optimal_k_features)(X_train, y_train, X_test, y_test, k) for k in range(1,min(11,len(X_train.columns) + 1))
    )
    results = dict(_)

    training_accuracies = []
    test_accuracies = []
    feature_combinations = []

    for k in results.keys():
        result = results[k]
        training_accuracy = result[1]
        test_accuracy = result[2]
        features = result[3]

        training_accuracies.append(training_accuracy)
        test_accuracies.append(test_accuracy)
        feature_combinations.append(features)

    index = None
    for i in range(len(test_accuracies)):
        good = True
        for j in range(len(test_accuracies)):
            if int((test_accuracies[j] * 100) - (test_accuracies[i] * 100)) > 0:
                good = False
                break
        if good:
            index = i
            break
    best_features = feature_combinations[index]
    
    with open(FILE_PATH, 'a') as f:
        f.write('Training accuracies : ' + str(training_accuracies) + '\n')
        f.write('Test accuracies : ' + str(test_accuracies) + '\n\n')

    return best_features

def cross_validation_one_split(dataset_name, target_feature, i):
    df_valid_train = pd.read_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i}_valid_train.csv')
    X_valid_train = df_valid_train.drop(columns = [target_feature])
    y_valid_train = df_valid_train[target_feature]

    df_valid_test = pd.read_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i}_valid_test.csv')
    X_valid_test = df_valid_test.drop(columns = [target_feature])
    y_valid_test = df_valid_test[target_feature]
        
    df_train = pd.read_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i}_train.csv')
    X_train = df_train.drop(columns = [target_feature])
    y_train = df_train[target_feature]

    df_test = pd.read_csv(f'../cv_splits_10/{dataset_name}/{dataset_name}_split_{i}_test.csv')
    X_test = df_test.drop(columns = [target_feature])
    y_test = df_test[target_feature]

    # Drop constant columns.
    constant_columns = X_valid_train.columns[X_valid_train.nunique() == 1]
    X_valid_train.drop(columns = constant_columns, inplace = True)
    X_valid_test.drop(columns = constant_columns, inplace = True)

    constant_columns = X_train.columns[X_train.nunique() == 1]
    X_train.drop(columns = constant_columns, inplace = True)
    X_test.drop(columns = constant_columns, inplace = True)

    # Hyperparameter tuning.
    print(f'Finding features for the {i}th split...')
    best_features = find_optimal_features(X_valid_train, y_valid_train, X_valid_test, y_valid_test)
        
    result = train_erm(X_train, y_train, X_test, y_test, best_features)
    return best_features, result[0], result[2]

def cross_validation(dataset_name, target_feature):
    feature_numbers = []
    classifiers = []
    accuracies = []

    for i in range(1,11):
        features, classifier, accuracy = cross_validation_one_split(dataset_name, target_feature, i)
        feature_numbers.append(len(features))
        classifiers.append(str(classifier))
        accuracies.append(accuracy)

    return feature_numbers, accuracies, classifiers

def leave_one_out(dataset_name, target_feature):
    global FILE_PATH

    feature_numbers = []
    classifiers = []
    accuracies = []

    df = pd.read_csv(f'../original_data_sets/{dataset_name}/{dataset_name}_bool.csv')

    loo = LeaveOneOut()
    pbar = tqdm(total = len(df), desc = 'Performing leave one out cross validation...')
    for i, (train_index, test_index) in enumerate(loo.split(df)):
        df_train = df.iloc[train_index]
        df_test = df.iloc[test_index]
        df_train = df_train.sample(frac = 1, random_state = 42)

        X_train = df_train.drop(columns = [target_feature])
        y_train = df_train[target_feature]
        X_test = df_test.drop(columns = [target_feature])
        y_test = df_test[target_feature]

        index = int(len(X_train) * 0.7)
        X_valid_train = X_train.iloc[:index].copy()
        X_valid_test = X_train.iloc[index:].copy()
        y_valid_train = y_train.iloc[:index].copy()
        y_valid_test = y_train.iloc[index:].copy()
        
        # Drop constant columns.
        constant_columns = X_valid_train.columns[X_valid_train.nunique() == 1]
        X_valid_train.drop(columns = constant_columns, inplace = True)
        X_valid_test.drop(columns = constant_columns, inplace = True)

        constant_columns = X_train.columns[X_train.nunique() == 1]
        X_train.drop(columns = constant_columns, inplace = True)
        X_test.drop(columns = constant_columns, inplace = True)

        # Hyperparameter tuning.
        best_features = find_optimal_features(X_valid_train, y_valid_train, X_valid_test, y_valid_test)
            
        result = train_erm(X_train, y_train, X_test, y_test, best_features)
        feature_numbers.append(len(best_features))
        accuracies.append(result[2])
        classifiers.append(str(result[0]))
        pbar.update(1)
    pbar.close()
    return feature_numbers, accuracies, classifiers

def run_cv_experiments(dataset_name, target_feature, file_path):
    global FILE_PATH
    FILE_PATH = file_path

    with open(FILE_PATH, 'a') as f:
        f.write(f'\n{dataset_name}:\n\n')

    print(f'Cross validation...')
    feature_numbers, accuracies, classifiers = cross_validation(dataset_name, target_feature)
    
    output = str()
    output += f'\nResults:\n'
    output += f'Average number of features used: {np.mean(feature_numbers)}\n'
    output += f'Average test accuracy: {np.mean(accuracies)}\n'
    output += f'Standard deviation for test accuracy: {np.std(accuracies)}\n'
    print(output)

    output += str('\nClassifiers obtained:\n')
    for i in range(len(accuracies)):
        output += f'Test accuracy : {accuracies[i]} | Classifier : ' + classifiers[i] + '\n\n' 
    output += '\n\n'

    with open(FILE_PATH, 'a') as f:
        f.write(output)

def run_loocv_experiment(dataset_name, target_feature, file_path):
    global FILE_PATH
    FILE_PATH = file_path

    with open(FILE_PATH, 'a') as f:
        f.write(f'\n{dataset_name}:\n\n')

    feature_numbers, accuracies, classifiers = leave_one_out(dataset_name, target_feature)
    
    output = str()
    output += f'\nResults:\n'
    output += f'Average number of features used: {np.mean(feature_numbers)}\n'
    output += f'Average test accuracy: {np.mean(accuracies)}\n'
    output += f'Standard deviation for test accuracy: {np.std(accuracies)}\n'
    print(output)

    output += str('\nClassifiers obtained:\n')
    for i in range(len(accuracies)):
        output += f'Test accuracy : {accuracies[i]} | Classifier : ' + classifiers[i] + '\n\n' 
    output += '\n\n'

    with open(FILE_PATH, 'a') as f:
        f.write(output)

def run_one_cv_experiment(dataset_name, target_feature, i, file_path):
    global FILE_PATH
    FILE_PATH = file_path

    features, classifier, accuracy = cross_validation_one_split(dataset_name, target_feature, i)
    
    output = str()
    output += f'Number of features used: {len(features)}\n'
    output += f'Test accuracy: {accuracy}\n'
    output += f'Classifier: {str(classifier)}\n'
    print(output)

    output = f'\nSplit : {i} \n\n' + output
    with open(FILE_PATH, 'a') as f:
        f.write(output)