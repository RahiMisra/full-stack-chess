:- module(chess_api, [
    initial_fen/1,
    play_san_fen/10,
    play_coordinates_fen/13,
    get_position_info/7,
	get_piece_legal_moves/3
]).

:- consult('prolog_chess.pl').
:- consult('chess_conversions.pl').


% Return the standard starting position as FEN.
initial_fen(FEN) :-
    initial_state(State),
    state_to_fen(State, FEN).


% Play a move using SAN notation.
play_san_fen(FEN, SAN, NewFEN, PositionKey, Status, Advantage, MoveType, SideToMove, CastlingRights, EnPassant) :-
    fen_to_state(FEN, State),
    State = state(_, Side, _, _, _, _),
    san_to_move(SAN, Side, Move),
    play_move(State, Move, NewState, Status, Advantage, MoveType),
    NewState = state(_, SideToMove, InternalCastlingRights, InternalEnPassant, _, _),
	convert_position_outputs(InternalCastlingRights, InternalEnPassant, CastlingRights, EnPassant),
    state_to_fen(NewState, NewFEN),
    fen_position_key(NewFEN, PositionKey).


% Play a move using board coordinates.
play_coordinates_fen(FEN, From, To, Promotion, NewFEN, PositionKey, Status, Advantage, SAN, MoveType, SideToMove, CastlingRights, EnPassant) :-
    fen_to_state(FEN, State),
    State = state(Board, Side, _, _, _, _),
    coordinates_to_move(Board, Side, From, To, Promotion, Move),
    play_move(State, Move, NewState, Status, Advantage, MoveType),
    move_to_san(State, Move, MoveType, Status, SAN),
    NewState = state(_, SideToMove, InternalCastlingRights, InternalEnPassant, _, _),
	convert_position_outputs(InternalCastlingRights, InternalEnPassant, CastlingRights, EnPassant),
    state_to_fen(NewState, NewFEN),
    fen_position_key(NewFEN, PositionKey).


% Retrieve information about a position.
get_position_info(FEN, PositionKey, Status, Advantage, SideToMove, CastlingRights, EnPassant) :-
    fen_to_state(FEN, State),
    State = state(_, SideToMove, InternalCastlingRights, InternalEnPassant, _, _),
	convert_position_outputs(InternalCastlingRights, InternalEnPassant, CastlingRights, EnPassant),
    fen_position_key(FEN, PositionKey),
    evaluate_position(State, Status, Advantage).
	
get_piece_legal_moves(FEN, Square, LegalMoves) :-
    fen_to_state(FEN, State),
    coordinate_square(Square, FromFile, FromRank),
    get_legal_moves(State, FromFile, FromRank, InternalMoves),
    convert_legal_moves(InternalMoves, LegalMoves).