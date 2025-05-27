import pandas as pd
from sympy import sympify, And, Or, Not
from sympy.logic import simplify_logic

class EmpiricalIdealClassifier:
    def __init__(self):
        self.features = None
        self.formula = None

    def get_type(self, features, vector):
        type = sympify(True)
        for feature in features:
            if vector[feature] == True:
                type = And(type, sympify(feature))
            else:
                type = And(type, Not(sympify(feature)))
        return type

    def fit(self, X, y, features):
        self.features = features
        type_scores = {}
        type_sizes = {}
        for index, row in X.iterrows():
            type = self.get_type(features, row)
            type_code = str(type)
            if not type_code in type_sizes:
                type_scores[type_code] = 0
                type_sizes[type_code] = 0
            type_sizes[type_code] += 1
            if y.loc[index] == True:
                type_scores[type_code] += 1
        formula = sympify(False)
        for type_code in type_scores.keys():
            type_size = type_sizes[type_code]
            accuracy = type_scores[type_code] / type_size
            if accuracy > 0.5:
                formula = Or(sympify(type_code), formula)
        self.formula = simplify_logic(expr = formula, form = 'dnf', force = True)

    def predict(self, X):
        predictions = []
        local_X = X.drop(columns = X.columns.difference(self.features), axis = 1)
        for _, row in local_X.iterrows():
            assignment = row.to_dict()
            prediction = self.formula.subs(assignment)
            predictions.append(prediction)
        return pd.Series(predictions, dtype = 'bool')

    def __str__(self):
        return str(self.formula)