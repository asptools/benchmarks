#!/bin/bash

# Explain-with-Short-Formulas - An Implementation in Answer Set Programming
# Copyright (C) 2025 Tomi Janhunen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# USAGE: check-neg.sh <negative instance>

source path.sh

$BIN/gringo -Wnone $ENC/check-neg.lp $* | $BIN/clasp | grep -F SAT

# The negative test is passed if clasp returns "UNSATISFIABLE"
