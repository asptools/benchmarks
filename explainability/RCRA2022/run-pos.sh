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

# USAGE: run-pos.sh <positive instance>

source path.sh

# Optimize

$BIN/gringo -Wnone $ENC/minimize.lp $ENC/oracle-pos.lp $* \
| $BIN/clasp --opt-strat=usc
