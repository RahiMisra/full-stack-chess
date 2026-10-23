:- module(chess_api, [
    initial_fen/1,
    play_san_fen/6,
    get_position_info/4
]).

:- consult('prolog_chess.pl').
:- consult('chess_conversions.pl').


% Return the standard starting position as FEN.
initial_fen(FEN) :-
    initial_state(State),
    state_to_fen(State, FEN).

play_san_fen(FEN, SAN, NewFEN, PositionKey, Status, Advantage) :-
    fen_to_state(FEN, State),
    State = state(_, Side, _, _, _, _),
    san_to_move(SAN, Side, Move),
    play_move(State, Move, NewState, Status, Advantage),
    state_to_fen(NewState, NewFEN),
    fen_position_key(NewFEN, PositionKey).

get_position_info(FEN, PositionKey, Status, Advantage) :-
    fen_to_state(FEN, State),
    fen_position_key(FEN, PositionKey),
    evaluate_position(State, Status, Advantage).