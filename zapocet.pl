% sudoku(?Rows) 
sudoku(Rows) :-
        first(Rows, F), 
        all_same_lenght(F, Rows, F), % checks the sudoku if squared 
        fillWithPosRows(Rows, NRows),
        iterate(NRows, Result, 0),
        prints(Result).



iterate(Rows, Result, N):- 
        (all_atomic(Rows), Rows = Result, !);
        all_distinct2D(Rows, NRows),
        transpose(NRows, Columns),
        all_distinct2D(Columns, NColumns),
        NColumns = [As,Bs,Cs,Ds,Es,Fs,Gs,Hs,Is],
        blocks(As, Bs, Cs, Ar, Br, Cr), % first 3 rows
        blocks(Ds, Es, Fs, Dr, Er, Fr),
        blocks(Gs, Hs, Is, Gr, Hr, Ir),
        transpose([Ar,Br,Cr,Dr,Er,Fr,Gr,Hr,Ir], Res),
        next_iteration(Rows, Res, Result, N).

next_iteration(Rows, Res, Result, _):- Res \= Rows, iterate(Res, Result, 0), !.
next_iteration(_, _, Result, N):- N >= 8, Result = [], !.
next_iteration(_, Res, Result, N):- randomAtomize(Res, R), Nn is N+1, iterate(R, Result, Nn), !.
        

blocks([], [], [], [], [], []):- !.
blocks([N1,N2,N3|Ns1], [N4,N5,N6|Ns2], [N7,N8,N9|Ns3], [R1,R2,R3|Rs1], [R4,R5,R6|Rs2], [R7,R8,R9|Rs3]) :-
        all_distinct([N1,N2,N3,N4,N5,N6,N7,N8,N9], [R1,R2,R3,R4,R5,R6,R7,R8,R9]),
        blocks(Ns1, Ns2, Ns3, Rs1, Rs2, Rs3).

%%%
%%% NONDeterministic part of code !!!
%%%
randomAtomize(Res, R):- member(X, [1,2,3,4,5,6,7,8,9]), randomAtomize(Res, R, X).
randomAtomize([R|Rs], [R|RRs], X):- X > 1, Xs is X-1, randomAtomize(Rs, RRs, Xs).
randomAtomize([R|Rs], [NR|Rs], 1):- member(X, [1,2,3,4,5,6,7,8,9]), randomAtomizeRow(R,NR,X).

% randomAtomizeRow([R|_], _, 1):- atomic(R), fail, !. %% if atomic then fail and look for list
randomAtomizeRow([R|Rs], [R|RRs], X):- X > 1, Xs is X-1, randomAtomizeRow(Rs, RRs, Xs).
randomAtomizeRow([R|Rs], [NR|Rs], 1):- \+atomic(R), member(NR, R).
%%% !!!

all_atomic([]).
all_atomic([R|Rs]):- all_atomicRow(R), all_atomic(Rs).
all_atomicRow([]):- !.
all_atomicRow(X):- atomic(X), !.
all_atomicRow([R|Rs]):- atomic(R), all_atomicRow(Rs).

%fills all Rows
fillWithPosRows([],[]):- !.
fillWithPosRows([Row|Rows], [F|Fs]):- fillWithPosRow(Row,F), fillWithPosRows(Rows, Fs).

%fills row with all posibilities [1..9] if not atomic
fillWithPosRow([X], [X]):- atomic(X), !.
fillWithPosRow([_], [[1,2,3,4,5,6,7,8,9]]):-!.
fillWithPosRow([X|Xs], [X|Ys]) :- atomic(X), fillWithPosRow(Xs, Ys), !.
fillWithPosRow([_|Xs], [[1,2,3,4,5,6,7,8,9]|Ys]) :- fillWithPosRow(Xs, Ys).

% all_distinct2D(+In, -Out) 
% checks if there is list with value same as atomic value in row and delete it from list 
% and check if there is only one value and change it in list to atom
all_distinct2D([], []).
all_distinct2D([X|Xs], [Y|Ys]):- all_distinct(X, Y), all_distinct2D(Xs, Ys).

%%%%
%%%% MAIN LOGIC 
%%%%
all_distinct(In, Out):- get_atomic(In, Atoms), delete_all(In, Atoms, O), atomize(O, Out), distin(Out).

get_atomic([X], [X]):- atomic(X), !.
get_atomic([], []):- !.
get_atomic([X|Xs], [X|Ys]):- atomic(X), get_atomic(Xs, Ys), !.
get_atomic([_|Xs], Ys):- get_atomic(Xs, Ys).

% take each list and delete in them all Atoms
delete_all(_,[],_):- !.
delete_all([], _, []):- !.
delete_all(I, _,I):- atomic(I), !.
delete_all([I|Is], Atoms, [O|Os]):- delete_elements(I, Atoms, O), delete_all(Is, Atoms, Os).

% in list delete all Atoms
delete_elements(I, [], I):- !.
delete_elements(I, _, I):- atomic(I), !.
delete_elements(I, [A|As], O):- delete_elements(I, As, Os), delete(Os, A, O).

% transform [1,2,[X],...] to [1,2,X,...] so itsimplifies list to atom
atomize([], []).
atomize([X], [X]):- atomic(X), !.
atomize([X], [Xh]):- length(X, 1), first(X, Xh), !.
atomize([X], [X]).
atomize([X|Xs], [X|Os]):- atomic(X), atomize(Xs, Os), !.
atomize([[X]|Xs], [X|Os]):- atomize(Xs, Os), !.
atomize([X|Xs], [X|Os]):- atomize(Xs, Os).

% fails when there are 2 same atoms in list or there is empty list []
distin([X]):- X\= [], !.
distin([X|Xs]):- X \= [], atomic(X), \+member(X,Xs), distin(Xs), !.
distin([X|Xs]):- \+atomic(X), distin(Xs).
%%%%
%%%% END OF MAIN LOGIC 
%%%%


first([X|_], X).

% check if dimensions of 2D array are square (n*n)
all_same_lenght(F, [X], [_]):- same_len(F,X), !.
all_same_lenght(First, [X|Xs], [_|Rows]):- same_len(First, X), all_same_lenght(First, Xs, Rows).

same_len([], []).
same_len([_|Xs], [_|Ys]):- same_len(Xs,Ys).  

range([From],From,From):- !.
range([From|X], From, To):- N is From + 1, range(X, N, To).


%%%
%%% TRANSPONE
%%%
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).
%%%
%%% 
%%% 

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

 

problem(0):- sudoku([
        [8,6,3,9,2,5,7,4,1],
        [4,1,2,7,8,6,3,5,9],
        [7,5,9,4,1,3,2,8,6],
        [9,7,1,2,6,4,8,3,5],
        [3,4,6,8,5,7,9,1,2],
        [2,8,5,3,9,1,4,6,7],
        [1,9,8,6,3,2,5,7,4],
        [5,2,4,1,7,8,6,9,3],
        [6,3,7,5,4,9,1,2,8]]).

%problem 1
problem(1) :- sudoku([
        [1,_,_,8,_,4,_,_,_],
        [_,2,_,_,_,_,4,5,6],
        [_,_,3,2,_,5,_,_,_],
        [_,_,_,4,_,_,8,_,5],
        [7,8,9,_,5,_,_,_,_],
        [_,_,_,_,_,6,2,_,3],
        [8,_,1,_,_,_,7,_,_],
        [_,_,_,1,2,3,_,8,_],
        [2,_,5,_,_,_,_,_,9]]).

%problem 2
problem(2) :- sudoku([
        [_,_,2,_,3,_,1,_,_],
        [_,4,_,_,_,_,_,3,_],
        [1,_,5,_,_,_,_,8,2],
        [_,_,_,2,_,_,6,5,_],
        [9,_,_,_,8,7,_,_,3],
        [_,_,_,_,4,_,_,_,_],
        [8,_,_,_,7,_,_,_,4],
        [_,9,3,1,_,_,_,6,_],
        [_,_,7,_,6,_,5,_,_]]).

%problem 3 non solvable in normal time 
problem(3) :- sudoku([
        [1,_,_,_,_,_,_,_,_],
        [_,_,2,7,4,_,_,_,_],
        [_,_,_,5,_,_,_,_,4],
        [_,3,_,_,_,_,_,_,_],
        [7,5,_,_,_,_,_,_,_],
        [_,_,_,_,_,9,6,_,_],
        [_,4,_,_,_,6,_,_,_],
        [_,_,_,_,_,_,_,7,1],
        [_,_,_,_,_,1,_,3,_]]).

%problem 3 s extra 1, takže nemá reseni
problem(4) :-sudoku(
            [[1,_,_,_,_,_,_,_,1],
             [_,_,2,7,4,_,_,_,_],
             [_,_,_,5,_,_,_,_,4],
             [_,3,_,_,_,_,_,_,_],
             [7,5,_,_,_,_,_,_,_],
             [_,_,_,_,_,9,6,_,_],
             [_,4,_,_,_,6,_,_,_],
             [_,_,_,_,_,_,_,7,1],
             [_,_,_,_,_,1,_,3,_]]).