#!/usr/bin/env python3

import re
import sys

problem_dir, analysis = sys.argv[1:]

def generate_buffer_overflow(name, line):
    line = line.strip()
    nodes = [ literal.strip() for literal in re.split('\t', line) ]

    if name == 'DUPath0':
        a, b = nodes
        cons = f'DUPath0: NOT DUEdge({a},{b}), DUPath({a},{b})'
    elif name == 'DUPath1':
        a, b = nodes
        cons = f'DUPath1: NOT TrueBranch({a},{b}), DUPath({a},{b})'
    elif name == 'DUPath2':
        a, b = nodes
        cons = f'DUPath2: NOT FalseBranch({a},{b}), DUPath({a},{b})'
    elif name == 'DUPath3':
        a, b, c = nodes
        cons = f'DUPath3: NOT DUPath({a},{b}), NOT DUEdge({b},{c}), DUPath({a},{c})'
    elif name == 'DUPath4':
        a, b, c = nodes
        cons = f'DUPath4: NOT DUPath({a},{b}), NOT TrueCond({b}), NOT TrueBranch({b},{c}), DUPath({a},{c})'
    elif name == 'DUPath5':
        a, b, c = nodes
        cons = f'DUPath5: NOT DUPath({a},{b}), NOT FalseCond({b}), NOT FalseBranch({b},{c}), DUPath({a},{c})'

    elif name == 'TDUPath0':
        a, b = nodes
        cons = f'TDUPath0: NOT DUPath({a},{b}), NOT DUEdge({a},{b}), TDUPath({a},{b})'
    elif name == 'TDUPath1':
        a, b = nodes
        cons = f'TDUPath1: NOT DUPath({a},{b}), NOT TrueBranch({a},{b}), TDUPath({a},{b})'
    elif name == 'TDUPath2':
        a, b = nodes
        cons = f'TDUPath2: NOT DUPath({a},{b}), NOT FalseBranch({a},{b}), TDUPath({a},{b})'
    elif name == 'TDUPath3':
        a, b, c = nodes
        cons = f'TDUPath3: NOT DUPath({a},{c}), NOT TDUPath({a},{b}), NOT DUEdge({b},{c}), TDUPath({a},{c})'
    elif name == 'TDUPath4':
        a, b, c = nodes
        cons = f'TDUPath4: NOT DUPath({a},{c}), NOT TDUPath({a},{b}), NOT TrueCond({b}), NOT TrueBranch({b},{c}), TDUPath({a},{c})'
    elif name == 'TDUPath5':
        a, b, c = nodes 
        cons = f'TDUPath5: NOT DUPath({a},{c}), NOT TDUPath({a},{b}), NOT FalseCond({b}), NOT FalseBranch({b},{c}), TDUPath({a},{c})'

    else: assert False
    return cons

def generate_integer_overflow(name, line):
    line = line.strip()
    nodes = [ literal.strip() for literal in re.split('\t', line) ]

    if name == 'DUPath0':
        a, b = nodes
        cons = f'DUPath0: NOT DUEdge({a},{b}), DUPath({a},{b})'
    elif name == 'DUPath1':
        a, b = nodes
        cons = f'DUPath1: NOT TrueBranch({a},{b}), DUPath({a},{b})'
    elif name == 'DUPath2':
        a, b = nodes
        cons = f'DUPath2: NOT FalseBranch({a},{b}), DUPath({a},{b})'
    elif name == 'DUPath3':
        a, b, c = nodes
        cons = f'DUPath3: NOT DUEdge({a},{b}), NOT DUPath({b},{c}), DUPath({a},{c})'
    elif name == 'DUPath4':
        a, b, c = nodes
        cons = f'DUPath4: NOT TrueCond({a}), NOT TrueBranch({a},{b}), NOT DUPath({b},{c}), DUPath({a},{c})'
    elif name == 'DUPath5':
        a, b, c = nodes
        cons = f'DUPath5: NOT FalseCond({a}), NOT FalseBranch({a},{b}), NOT DUPath({b},{c}), DUPath({a},{c})'

    elif name == 'TDUPath0':
        # TDUPath(x, y) :- DUPath(x, y), DUEdge(x, y).
        x, y = nodes
        cons = f'TDUPath0: NOT DUPath({x},{y}), NOT DUEdge({x},{y}), TDUPath({x},{y})'
    elif name == 'TDUPath1':
        # TDUPath(x, y) :- DUPath(x, y), TrueBranch(x, y).
        x, y = nodes
        cons = f'TDUPath1: NOT DUPath({x},{y}), NOT TrueBranch({x},{y}), TDUPath({x},{y})'
    elif name == 'TDUPath2':
        # TDUPath(x, y) :- DUPath(x, y), FalseBranch(x, y).
        x, y = nodes
        cons = f'TDUPath2: NOT DUPath({x},{y}), NOT FalseBranch({x},{y}), TDUPath({x},{y})'
    elif name == 'TDUPath3':
        # TDUPath(x, y) :- DUPath(x, y), DUEdge(x, z), TDUPath(z, y), Alarm(_, y).
        x, z, y = nodes
        cons = f'TDUPath3: NOT DUPath({x},{y}), NOT DUEdge({x},{z}), NOT TDUPath({z},{y}), TDUPath({x},{y})'
    elif name == 'TDUPath4':
        # TDUPath(x, y) :- DUPath(x, y), TrueCond(x), TrueBranch(x, z), TDUPath(z, y).
        x, z, y = nodes
        cons = f'TDUPath4: NOT DUPath({x},{y}), NOT TrueCond({x}), NOT TrueBranch({x},{z}), NOT TDUPath({z},{y}), TDUPath({x},{y})'
    elif name == 'TDUPath5':
        # TDUPath(x, y) :- DUPath(x, y), FalseCond(x), FalseBranch(x, z), TDUPath(z, y).
        x, z, y = nodes
        cons = f'TDUPath5: NOT DUPath({x},{y}), NOT FalseCond({x}), NOT FalseBranch({x},{z}), NOT TDUPath({z},{y}), TDUPath({x},{y})'

    else: assert False

    return cons

def generate_alarm(line):
    line = line.strip()
    nodes = [ literal.strip() for literal in re.split('\t', line) ]
    cons = f'Alarm: NOT TDUPath({nodes[0]},{nodes[1]}), Alarm({nodes[0]},{nodes[1]})'
    return cons

assert analysis == 'interval' or analysis == 'taint'
generate = generate_buffer_overflow if analysis == 'interval' else generate_integer_overflow
with open(problem_dir + '/' + analysis + '/bnet/named_cons_all.txt', 'w') as output_file:
    for relName in [ 'DUPath0', 'DUPath1', 'DUPath2', 'DUPath3', 'DUPath4', 'DUPath5', \
                     'TDUPath0', 'TDUPath1', 'TDUPath2', 'TDUPath3', 'TDUPath4', 'TDUPath5' ]:
        for line in open(f'{problem_dir}/{analysis}/datalog/Deriv_{relName}.csv'):
            cons = generate(relName, line)
            print(cons, file=output_file)
    for line in open(f'{problem_dir}/{analysis}/datalog/Alarm.facts'):
        cons = generate_alarm(line)
        print(cons, file=output_file)
