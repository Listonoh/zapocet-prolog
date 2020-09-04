# Sudoku solving program (zapocet)

This program solve sudoku in this format:

``` prolog
sudoku([
        [1,_,_,8,_,4,_,_,_],
        [_,2,_,_,_,_,4,5,6],
        [_,_,3,2,_,5,_,_,_],
        [_,_,_,4,_,_,8,_,5],
        [7,8,9,_,5,_,_,_,_],
        [_,_,_,_,_,6,2,_,3],
        [8,_,1,_,_,_,7,_,_],
        [_,_,_,1,2,3,_,8,_],
        [2,_,5,_,_,_,_,_,9]]).
```

This program can solve all sudoku problems, but for harder it might take a while.

## Structure

At first the empty variables are replaced with lists of numbers from 1 to 9 \[1,2,3,4,5,6,7,8,9\].
After the new sudoku (3D array) is passed to cycle of iterations until there is solution, the branching couldn't find solution or there is no solution.
And then it is printed on standart output with print method.

### Iterations (recursive)

This is recursive function which terminate when all variables in sudoku are atomic or the branching exceed some value (in this case 2).
It starts with checking each line and removing all atomic values from lists in that row.
Then it transpose the sudoku matrix and checks each line again (of the transposed matrix).
Next are checked blocks of sudoku (the little squares).

### next iteration

#### had changed

Branching value N is set to 0 and recursion is called again.

#### exceed branching max value

Then the branch is failed and the prolog starts to look for solution from last nondeterministic point in code (which should be only `randomAtomize()`)

#### no change

If there is no change the procedure `randomAtomize(+R, -O)` change 1 list to atom at random (there is branch for all possibilities) and increase N value (the branching value which determine how much it can branch).

### Main Logic (`all_distinct`)

`all_distinct(+Row, -OutRow)`

gets all atom values from the row and delete them from all non atomic values in that row (in list of 9 values because row can be block).
Atomize row, take all non atomic values (lists) which length is exactly one and make them atomic.  
And check if all atomic variables are distinct.

### Printing

``` prolog
prints([X1, X2, X3, X4, X5, X6, X7, X8, X9]):-
        write('Solved sudoku: '), nl(),
        print(X1), sum_list(X1, SX1), print(SX1), nl(),
        print(X2), sum_list(X2, SX2), print(SX2), nl(),
        print(X3), sum_list(X3, SX3), print(SX3), nl(),
        print(X4), sum_list(X4, SX4), print(SX4), nl(),
        print(X5), sum_list(X5, SX5), print(SX5), nl(),
        print(X6), sum_list(X6, SX6), print(SX6), nl(),
        print(X7), sum_list(X7, SX7), print(SX7), nl(),
        print(X8), sum_list(X8, SX8), print(SX8), nl(),
        print(X9), sum_list(X9, SX9), print(SX9), nl(),nl().
```

prints sudoku in some format with check sum for every row.
