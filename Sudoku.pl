first_empty([0|_],0) :- !.
first_empty([_|T],C) :- 
                        first_empty(T,C1),
                        C is C1+1. 

place([0|T],0,Digit,[Digit|T]) :- !.
place([H|T],Index,Digit,[H|R]) :- 
                                 Index > 0,
                                 Index1 is Index-1, 
                                 place(T,Index1,Digit,R),
                                 !.
place(L,Index,_,L):- Index<16.

split(L,A,B,A1,A2,B1,B2) :- 
                           append(A,B,L),length(A,N),length(B,N),
                           append(A1,A2,A),length(A1,N1),length(A2,N1),
                           append(B1,B2,B),length(B1,N1),length(B2,N1).

distinct([]).
distinct([H|T]) :-
                  ((\+member(H,T));H=0),
                  distinct(T).

list_to_matrix([],_,[]).
list_to_matrix(L,Size,[R|M]) :-
                               list_to_matrix_row(L,Size,R,T), 
                               list_to_matrix(T,Size,M).

list_to_matrix_row(T,0,[],T).
list_to_matrix_row([Item|L],Size,[Item|R],T) :- 
                                               Size1 is Size-1,
                                               list_to_matrix_row(L,Size1,R,T).

matrix_to_list([],[]).
matrix_to_list([H|T],L) :-
                          matrix_to_list(T, L1),
                          append(L1, H, L).

:- use_module(library(clpfd)).

replace(_,_,[],[]).
replace(Element,Sub,[Element|T1],[Sub|T2]) :- replace(Element,Sub,T1,T2).
replace(Element,Sub,[H|T1],[H|T2]) :- 
                                     Element\=H,
                                     replace(Element,Sub,T1,T2).

valid(Board) :-
               replace(0,0,Board,Board1),
               split(Board1,_,_,A1,A2,B1,B2),
               distinct(A1),distinct(A2),distinct(B1),distinct(B2),
               list_to_matrix(Board1,4,BoardR),
               transpose(BoardR,BoardC),
               matrix_to_list(BoardC,Board2),
               split(Board2,_,_,C1,C2,D1,D2),
               distinct(C1),distinct(C2),distinct(D1),distinct(D2),
               !.

next_move(Board,Moves) :-
                         (first_empty(Board,C),
                         place(Board,C,1,Moves),
                         valid(Moves));
                         (first_empty(Board,C),
                         place(Board,C,2,Moves),
                         valid(Moves));
                         (first_empty(Board,C),
                         place(Board,C,3,Moves),
                         valid(Moves));
                         (first_empty(Board,C),
                         place(Board,C,4,Moves),
                         valid(Moves)),
                         !.

goal_heuristic(Board,Answer) :- 
                         \+member(0,Board),
                         !,
                         list_to_matrix(Board,4,Answer).
goal_heuristic(Board,Solved) :- 
                         next_move(Board,Newboard),
                         goal_heuristic(Newboard,Solved),
                         !.

goal_dfs(Board,Answer) :- 
                         (\+member(0,Board)),
                         !,
                         list_to_matrix(Board,4,Answer).
goal_dfs(Board,Solved) :- 
                         (first_empty(Board,C),
                         place(Board,C,1,Moves),
                         valid(Moves),
                         goal_dfs(Moves,Solved));
                         (first_empty(Board,C),
                         place(Board,C,2,Moves),
                         valid(Moves),
                         goal_dfs(Moves,Solved));
                         (first_empty(Board,C),
                         place(Board,C,3,Moves),
                         valid(Moves),
                         goal_dfs(Moves,Solved));
                         (first_empty(Board,C),
                         place(Board,C,4,Moves),
                         valid(Moves),
                         goal_dfs(Moves,Solved)).

goal_bfs(Board,Answer) :- 
                         (\+member(0,Board)),
                         !,
                         list_to_matrix(Board,4,Answer).
goal_bfs(Board,Solved) :- 
                         ((first_empty(Board,C),
                         place(Board,C,1,Moves1)),
                         (first_empty(Board,C),
                         place(Board,C,2,Moves2)),
                         (first_empty(Board,C),
                         place(Board,C,3,Moves3)),
                         (first_empty(Board,C),
                         place(Board,C,4,Moves4))),
                         ((valid(Moves1),
                         goal_bfs(Moves1,Solved));
                         (valid(Moves2),
                         goal_bfs(Moves2,Solved));
                         (valid(Moves3),
                         goal_bfs(Moves3,Solved));
                         (valid(Moves4),
                         goal_bfs(Moves4,Solved))).

%[_,_,1,_,3,_,_,2,_,_,2,4,2,4,_,_]
%IN211 – Sudoku - 211000411 - Belal Sameh