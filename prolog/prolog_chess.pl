% chess_state.pl
% state(Board, SideToMove, CastlingRights, EnPassant, HalfmoveClock, FullmoveNumber)
% Represents the current state of a chess game.

% INITIAL STATE
initial_state(X) :-
    initial_board(Board),
    X = state(
        Board,
        white,
        [kingside_white, queenside_white,
         kingside_black, queenside_black],
        none,
        0,
        1
    ).

initial_board([
	% row 8
    black(rook), black(knight), black(bishop), black(queen),
    black(king), black(bishop), black(knight), black(rook),
	% row 7
    black(pawn), black(pawn), black(pawn), black(pawn),
    black(pawn), black(pawn), black(pawn), black(pawn),
	% rows 6, 5, 4, 3
    empty, empty, empty, empty, empty, empty, empty, empty,
    empty, empty, empty, empty, empty, empty, empty, empty,
    empty, empty, empty, empty, empty, empty, empty, empty,
	empty, empty, empty, empty, empty, empty, empty, empty,
	% row 2
    white(pawn), white(pawn), white(pawn), white(pawn),
    white(pawn), white(pawn), white(pawn), white(pawn),
	% row 1
    white(rook), white(knight), white(bishop), white(queen),
    white(king), white(bishop), white(knight), white(rook)
]).

% FIND PIECE
square_index(File, Rank, Index) :-
    file_index(File, FileIndex),
    between(1, 8, Rank),
    Index is (8 - Rank) * 8 + FileIndex.

file_index(a, 0).
file_index(b, 1).
file_index(c, 2).
file_index(d, 3).
file_index(e, 4).
file_index(f, 5).
file_index(g, 6).
file_index(h, 7).

piece_at(Board, File, Rank, Piece) :-
    square_index(File, Rank, Index),
    nth0(Index, Board, Piece).	
	
find_piece(state(Board, Side, _, _, _, _), move(PieceType, FromFileHint, FromRankHint, _, _, _), FromFile, FromRank) :-
	file_index(FromFile, _),
	between(1, 8, FromRank),
	origin_matches(FromFileHint, FromFile),
    origin_matches(FromRankHint, FromRank),
	square_index(FromFile, FromRank, Index),
    nth0(Index, Board, Piece),
	Piece =.. [Side, PieceType].
	
	
origin_matches(none, _).

origin_matches(Hint, Value) :-
    Hint \= none,
    Hint = Value.
	
opposite_side(white, black).
opposite_side(black, white).
	
% MOVE PIECE
replace_at([_|Tail], 0, NewValue, [NewValue|Tail]).

replace_at([Head|Tail], Index, NewValue, [Head|NewTail]) :-
    Index > 0,
    NextIndex is Index - 1,
    replace_at(Tail, NextIndex, NewValue, NewTail).

play_move(State, Move, NewState, Status, Advantage) :-
	find_piece(State, Move, FromFile, FromRank),
    move_piece(State, Move, FromFile, FromRank, MoveType, NewBoard),
    update_state(State, Move, FromFile, FromRank, MoveType, NewBoard, NewState),
	evaluate_position(NewState, Status, Advantage).
	
move_piece(State, Move, FromFile, FromRank, MoveType, NewBoard) :-
    check_movement(State, Move, FromFile, FromRank, MoveType),
    apply_movement(State, Move, FromFile, FromRank, MoveType, NewBoard),
    check_legal(State, NewBoard).
	
update_state(state(Board, Side, CastlingRights, _, HalfmoveClock, FullmoveNumber), Move, FromFile, FromRank, MoveType, NewBoard, state(NewBoard, NextSide, NewCastlingRights, NewEnPassant, NewHalfmoveClock, NewFullmoveNumber)) :-
    opposite_side(Side, NextSide),
    update_castling_rights(Board, Side, Move, FromFile, FromRank, NewBoard, CastlingRights, NewCastlingRights),
    update_en_passant(Side, Move, FromFile, FromRank, NewEnPassant),
    update_halfmove_clock(Board, FromFile, FromRank, MoveType, HalfmoveClock, NewHalfmoveClock),
    update_fullmove_number(Side, FullmoveNumber, NewFullmoveNumber).
	
evaluate_position(State, Status, Advantage) :-
	State = state(Board, _, _, _, _, _),
	check_position(State, Status),
	check_material(Board, Advantage).
	
% CHECK MOVEMENT
check_movement(State, Move, FromFile, FromRank, MoveType) :-
    Move = move(PieceType, _, _, _, _, _),
    check_piece_movement(PieceType, State, Move, FromFile, FromRank, MoveType).

check_piece_movement(pawn, State, Move, FromFile, FromRank, MoveType) :-
    check_pawn_move(State, Move, FromFile, FromRank, MoveType).

check_piece_movement(knight, State, Move, FromFile, FromRank, MoveType) :-
    check_knight_move(State, Move, FromFile, FromRank, MoveType).

check_piece_movement(bishop, State, Move, FromFile, FromRank, MoveType) :-
    check_bishop_move(State, Move, FromFile, FromRank, MoveType).

check_piece_movement(rook, State, Move, FromFile, FromRank, MoveType) :-
    check_rook_move(State, Move, FromFile, FromRank, MoveType).

check_piece_movement(queen, State, Move, FromFile, FromRank, MoveType) :-
    check_queen_move(State, Move, FromFile, FromRank, MoveType).

check_piece_movement(king, State, Move, FromFile, FromRank, MoveType) :-
    check_king_move(State, Move, FromFile, FromRank, MoveType).
	
% TARGET SQUARES
valid_target(_, empty, normal).
valid_target(white, black(_), capture).
valid_target(black, white(_), capture).

% CLEAR PATH
clear_path(Board, FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    FileStep is sign(ToFileIndex - FromFileIndex),
    RankStep is sign(ToRank - FromRank),
    NextFileIndex is FromFileIndex + FileStep,
    NextRank is FromRank + RankStep,
    clear_path_recurse(Board, NextFileIndex, NextRank, ToFileIndex, ToRank).
	
clear_path_recurse(_Board, FileIndex, Rank, ToFileIndex, ToRank) :-
    FileIndex =:= ToFileIndex,
    Rank =:= ToRank.
	
clear_path_recurse(Board, FileIndex, Rank, ToFileIndex, ToRank) :-
    (FileIndex =\= ToFileIndex ; Rank =\= ToRank),
    file_index(File, FileIndex),
    piece_at(Board, File, Rank, empty),
    NextFileIndex is FileIndex + sign(ToFileIndex - FileIndex),
    NextRank is Rank + sign(ToRank - Rank),
    clear_path_recurse(Board, NextFileIndex, NextRank, ToFileIndex, ToRank).
	
% KNIGHT
check_knight_move(state(Board, Side, _, _, _, _), move(knight, _, _, ToFile, ToRank, _), FromFile, FromRank, MoveType) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, knight],
	knight_distance(FromFile, FromRank, ToFile, ToRank),
    piece_at(Board, ToFile, ToRank, Target),
    valid_target(Side, Target, MoveType).
	
knight_distance(FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    FileDifference is abs(FromFileIndex - ToFileIndex),
    RankDifference is abs(FromRank - ToRank),
    ((FileDifference =:= 1, RankDifference =:= 2) ; (FileDifference =:= 2, RankDifference =:= 1)).
	
% BISHOP
check_bishop_move(state(Board, Side, _, _, _, _), move(bishop, _, _, ToFile, ToRank, _), FromFile, FromRank, MoveType) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, bishop],
    bishop_distance(FromFile, FromRank, ToFile, ToRank),
    clear_path(Board, FromFile, FromRank, ToFile, ToRank),
    piece_at(Board, ToFile, ToRank, Target),
    valid_target(Side, Target, MoveType).
	
bishop_distance(FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    FileDifference is abs(FromFileIndex - ToFileIndex),
    RankDifference is abs(FromRank - ToRank),
    FileDifference =:= RankDifference,
    FileDifference > 0.
	
% ROOK
check_rook_move(state(Board, Side, _, _, _, _), move(rook, _, _, ToFile, ToRank, _), FromFile, FromRank, MoveType) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, rook],
    rook_distance(FromFile, FromRank, ToFile, ToRank),
    clear_path(Board, FromFile, FromRank, ToFile, ToRank),
    piece_at(Board, ToFile, ToRank, Target),
    valid_target(Side, Target, MoveType).

rook_distance(FromFile, FromRank, ToFile, ToRank) :-
    FromFile = ToFile,
    FromRank =\= ToRank.
	
rook_distance(FromFile, FromRank, ToFile, ToRank) :-
    FromFile \= ToFile,
    FromRank =:= ToRank.
	
% QUEEN
check_queen_move(state(Board, Side, _, _, _, _), move(queen, _, _, ToFile, ToRank, _), FromFile, FromRank, MoveType) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, queen],
    queen_distance(FromFile, FromRank, ToFile, ToRank),
    clear_path(Board, FromFile, FromRank, ToFile, ToRank),
    piece_at(Board, ToFile, ToRank, Target),
    valid_target(Side, Target, MoveType).
	
queen_distance(FromFile, FromRank, ToFile, ToRank) :-
    bishop_distance(FromFile, FromRank, ToFile, ToRank).

queen_distance(FromFile, FromRank, ToFile, ToRank) :-
    rook_distance(FromFile, FromRank, ToFile, ToRank).
	
% PAWN
check_pawn_move(state(Board, Side, _, EnPassant, _, _), move(pawn, _, _, ToFile, ToRank, Promotion), FromFile, FromRank, MoveType) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, pawn],
    pawn_distance(Side, FromFile, FromRank, ToFile, ToRank),
    pawn_target(Board, Side, EnPassant, FromFile, FromRank, ToFile, ToRank, MoveType),
    check_promotion(Side, ToRank, Promotion).

pawn_distance(white, FromFile, FromRank, ToFile, ToRank) :-
    FromFile = ToFile,
    ToRank is FromRank + 1.

pawn_distance(black, FromFile, FromRank, ToFile, ToRank) :-
    FromFile = ToFile,
    ToRank is FromRank - 1.
	
pawn_distance(white, FromFile, 2, ToFile, ToRank) :-
    FromFile = ToFile,
    ToRank is 4.

pawn_distance(black, FromFile, 7, ToFile, ToRank) :-
    FromFile = ToFile,
    ToRank is 5.
	
pawn_distance(white, FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    abs(ToFileIndex - FromFileIndex) =:= 1,
    ToRank is FromRank + 1.
	
pawn_distance(black, FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    abs(ToFileIndex - FromFileIndex) =:= 1,
    ToRank is FromRank - 1.
	
pawn_path_clear(_Board, _FromFile, FromRank, _ToFile, ToRank) :-
    abs(ToRank - FromRank) =:= 1.
	
pawn_path_clear(Board, FromFile, FromRank, ToFile, ToRank) :-
    abs(ToRank - FromRank) =:= 2,
    MiddleRank is (FromRank + ToRank) // 2,
    piece_at(Board, FromFile, MiddleRank, empty).

pawn_target(Board, _Side, _EnPassant, FromFile, FromRank, ToFile, ToRank, normal) :-
    FromFile = ToFile,
    ToRank =\= FromRank,
    piece_at(Board, ToFile, ToRank, empty),
    pawn_path_clear(Board, FromFile, FromRank, ToFile, ToRank).
	
pawn_target(Board, Side, _EnPassant, FromFile, FromRank, ToFile, ToRank, capture) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    abs(ToFileIndex - FromFileIndex) =:= 1,
    piece_at(Board, ToFile, ToRank, Target),
    valid_target(Side, Target, capture).
	
pawn_target(Board, Side, EnPassant, _FromFile, FromRank, ToFile, ToRank, en_passant) :-
	EnPassant = square(ToFile, ToRank),
	piece_at(Board, ToFile, ToRank, empty),
    piece_at(Board, ToFile, FromRank, CapturedPawn),
    opposite_side(Side, EnemySide),
    CapturedPawn =.. [EnemySide, pawn].
	
valid_promotion_piece(queen).
valid_promotion_piece(rook).
valid_promotion_piece(bishop).
valid_promotion_piece(knight).
	
check_promotion(white, 8, Promotion) :-
    valid_promotion_piece(Promotion).

check_promotion(black, 1, Promotion) :-
    valid_promotion_piece(Promotion).

check_promotion(white, Rank, none) :-
    Rank < 8.

check_promotion(black, Rank, none) :-
    Rank > 1.
	
% KING
check_king_move(state(Board, Side, _, _, _, _), move(king, _, _, ToFile, ToRank, _), FromFile, FromRank, MoveType) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, king],
    king_distance(FromFile, FromRank, ToFile, ToRank),
    piece_at(Board, ToFile, ToRank, Target),
    valid_target(Side, Target, MoveType).
	
check_king_move(State, move(king, _, _, ToFile, ToRank, none), FromFile, FromRank, castle) :-
    check_castling(State, FromFile, FromRank, ToFile, ToRank).
	
king_distance(FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    FileDifference is abs(ToFileIndex - FromFileIndex),
    RankDifference is abs(ToRank - FromRank),
    FileDifference =< 1,
    RankDifference =< 1,
    (FileDifference > 0 ; RankDifference > 0).
	
% CASTLING VALIDATION
check_castling(state(Board, Side, CastlingRights, _, _, _), FromFile, FromRank, ToFile, ToRank) :-
    FromFile = e,
    castling_rank(Side, Rank),
    FromRank = Rank,
    ToRank = Rank,
    castling_destination(ToFile, CastleSide, RookFile),
	piece_at(Board, RookFile, Rank, Rook),
    Rook =.. [Side, rook],
    castling_right(Side, CastleSide, Right),
    member(Right, CastlingRights),
    clear_path(Board, e, Rank, RookFile, Rank),
    castling_squares_safe(Board, Side, CastleSide, Rank).

castling_rank(white, 1).
castling_rank(black, 8).

castling_destination(g, kingside, h).
castling_destination(c, queenside, a).

castling_right(white, kingside, kingside_white).
castling_right(white, queenside, queenside_white).
castling_right(black, kingside, kingside_black).
castling_right(black, queenside, queenside_black).

% CASTLING SAFETY
castling_squares_safe(Board, Side, CastleSide, Rank) :-
    opposite_side(Side, EnemySide),
    \+ is_square_attacked(Board, e, Rank, EnemySide),
    square_index(e, Rank, KingIndex),
    replace_at(Board, KingIndex, empty, BoardWithoutKing),
    castling_transit_square(CastleSide, TransitFile),
    castling_destination_file(CastleSide, DestinationFile),
    \+ is_square_attacked(BoardWithoutKing, TransitFile, Rank, EnemySide),
    \+ is_square_attacked(BoardWithoutKing, DestinationFile, Rank, EnemySide).

castling_transit_square(kingside, f).
castling_transit_square(queenside, d).

castling_destination_file(kingside, g).
castling_destination_file(queenside, c).

castling_rook_destination(kingside, f).
castling_rook_destination(queenside, d).

% APPLY MOVMENT
apply_movement(state(Board, _, _, _, _, _), move(_, _, _, ToFile, ToRank, none), FromFile, FromRank, MoveType, NewBoard) :-
	member(MoveType, [normal, capture]),
    square_index(FromFile, FromRank, FromIndex),
    square_index(ToFile, ToRank, ToIndex),
    nth0(FromIndex, Board, Piece),
    replace_at(Board, FromIndex, empty, BoardWithoutPiece),
    replace_at(BoardWithoutPiece, ToIndex, Piece, NewBoard).

apply_movement(state(Board, Side, _, _, _, _), move(pawn, _, _, ToFile, ToRank, Promotion), FromFile, FromRank, MoveType, NewBoard) :-
    Promotion \= none,
    member(MoveType, [normal, capture]),
    square_index(FromFile, FromRank, FromIndex),
    square_index(ToFile, ToRank, ToIndex),
    Piece =.. [Side, Promotion],
    replace_at(Board, FromIndex, empty, BoardWithoutPawn),
    replace_at(BoardWithoutPawn, ToIndex, Piece, NewBoard).
	
apply_movement(state(Board, Side, _, _, _, _), move(pawn, _, _, ToFile, ToRank, none), FromFile, FromRank, en_passant, NewBoard) :-
    square_index(FromFile, FromRank, FromIndex),
    square_index(ToFile, ToRank, ToIndex),
    square_index(ToFile, FromRank, CapturedIndex),
    Piece =.. [Side, pawn],
    replace_at(Board, FromIndex, empty, BoardWithoutPawn),
    replace_at(BoardWithoutPawn, CapturedIndex, empty, BoardWithoutCapturedPawn),
    replace_at(BoardWithoutCapturedPawn, ToIndex, Piece, NewBoard).
	
apply_movement(state(Board, _, _, _, _, _), move(king, _, _, ToFile, ToRank, none), FromFile, FromRank, castle, NewBoard) :-
	castling_destination(ToFile, CastleSide, RookFromFile),
	castling_rook_destination(CastleSide, RookToFile),
	square_index(FromFile, FromRank, KingFromIndex),
    square_index(ToFile, ToRank, KingToIndex),
    square_index(RookFromFile, FromRank, RookFromIndex),
    square_index(RookToFile, FromRank, RookToIndex),
	replace_at(Board, KingFromIndex, empty, BoardWithoutKing),
	replace_at(BoardWithoutKing, RookFromIndex, empty, BoardWithoutRook),
	piece_at(Board, FromFile, FromRank, King),
    replace_at(BoardWithoutRook, KingToIndex, King, BoardWithKing),
	piece_at(Board, RookFromFile, FromRank, Rook),
    replace_at(BoardWithKing, RookToIndex, Rook, NewBoard).
	
% CHECK LEGAL
check_legal(state(_, Side, _, _, _, _), NewBoard) :-
    find_king(NewBoard, Side, KingFile, KingRank),
    opposite_side(Side, EnemySide),
    \+ is_square_attacked(NewBoard, KingFile, KingRank, EnemySide).

find_king(Board, Side, KingFile, KingRank) :-
    file_index(KingFile, _),
    between(1, 8, KingRank),
    piece_at(Board, KingFile, KingRank, Piece),
    Piece =.. [Side, king].

is_square_attacked(Board, ToFile, ToRank, AttackingSide) :-
    file_index(FromFile, _),
    between(1, 8, FromRank),
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [AttackingSide, PieceType],
    attacks_square(Board, AttackingSide, PieceType, FromFile, FromRank, ToFile, ToRank).

attacks_square(_, _, knight, FromFile, FromRank, ToFile, ToRank) :-
    knight_distance(FromFile, FromRank, ToFile, ToRank).

attacks_square(Board, _, bishop, FromFile, FromRank, ToFile, ToRank) :-
    bishop_distance(FromFile, FromRank, ToFile, ToRank),
    clear_path(Board, FromFile, FromRank, ToFile, ToRank).

attacks_square(Board, _, rook, FromFile, FromRank, ToFile, ToRank) :-
    rook_distance(FromFile, FromRank, ToFile, ToRank),
    clear_path(Board, FromFile, FromRank, ToFile, ToRank).

attacks_square(Board, _, queen, FromFile, FromRank, ToFile, ToRank) :-
    queen_distance(FromFile, FromRank, ToFile, ToRank),
    clear_path(Board, FromFile, FromRank, ToFile, ToRank).
	
attacks_square(_, _, king, FromFile, FromRank, ToFile, ToRank) :-
    king_distance(FromFile, FromRank, ToFile, ToRank).
	
attacks_square(Board, Side, pawn, FromFile, FromRank, ToFile, ToRank) :-
    pawn_attack_distance(Side, FromFile, FromRank, ToFile, ToRank).

pawn_attack_distance(white, FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    abs(ToFileIndex - FromFileIndex) =:= 1,
    ToRank is FromRank + 1.

pawn_attack_distance(black, FromFile, FromRank, ToFile, ToRank) :-
    file_index(FromFile, FromFileIndex),
    file_index(ToFile, ToFileIndex),
    abs(ToFileIndex - FromFileIndex) =:= 1,
    ToRank is FromRank - 1.
	
% UPDATE CASTLING RIGHTS
update_castling_rights(Board, Side, Move, FromFile, FromRank, NewBoard, CastlingRights, NewCastlingRights) :-
    findall(Right, (member(Right, CastlingRights), \+ castling_right_lost(Board, Side, Move, FromFile, FromRank, NewBoard, Right)), NewCastlingRights).

castling_right_lost(_, Side, move(king, _, _, _, _, _), _, _, _, Right) :-
    castling_right(Side, _, Right).

castling_right_lost(Board, Side, move(rook, _, _, _, _, _), FromFile, FromRank, _, Right) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, rook],
    rook_castling_corner(Side, FromFile, FromRank, Right).

castling_right_lost(Board, _, move(_, _, _, ToFile, ToRank, _), _, _, NewBoard, Right) :-
    piece_at(Board, ToFile, ToRank, Piece),
    Piece =.. [Side, rook],
	rook_castling_corner(Side, File, Rank, Right).
	
rook_castling_corner(white, a, 1, queenside_white).
rook_castling_corner(white, h, 1, kingside_white).
rook_castling_corner(black, a, 8, queenside_black).
rook_castling_corner(black, h, 8, kingside_black).


% UPDATE EN PASSANT
update_en_passant(white, move(pawn, _, _, ToFile, ToRank, _), FromFile, FromRank, EnPassant) :-
    FromFile = ToFile,
    RankDifference is ToRank - FromRank,
    RankDifference =:= 2,
    !,
    EnPassant = square(ToFile, 3).

update_en_passant(black, move(pawn, _, _, ToFile, ToRank, _), FromFile, FromRank, EnPassant) :-
    FromFile = ToFile,
    RankDifference is FromRank - ToRank,
    RankDifference =:= 2,
    !,
    EnPassant = square(ToFile, 6).

update_en_passant(_, _, _, _, none).
	
% UPDATE HALFMOVE CLOCK
update_halfmove_clock(Board, FromFile, FromRank, MoveType,_, 0) :-
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [_, pawn],
    !.

update_halfmove_clock(_, _, _, MoveType, _, 0) :-
    member(MoveType, [capture, en_passant]),
    !.

update_halfmove_clock(_, _, _, _, HalfmoveClock, NewHalfmoveClock) :-
    NewHalfmoveClock is HalfmoveClock + 1.
	
% UPDATE MOVE NUMBER
update_fullmove_number(white, FullmoveNumber, FullmoveNumber).
update_fullmove_number(black, FullmoveNumber, NewFullmoveNumber) :-
    NewFullmoveNumber is FullmoveNumber + 1.
	
% FIND GAMESTATE
check_position(State, Status) :-
    State = state(Board, Side, _, _, HalfmoveClock, _),
    (   king_in_check(Board, Side)
    ->  (   has_legal_move(State)
        ->  (   HalfmoveClock >= 100
            ->  Status = draw_50_move
            ;   Status = check
            )
        ;   Status = checkmate
        )
    ;   (   has_legal_move(State)
        ->  (   HalfmoveClock >= 100
            ->  Status = draw_50_move
            ;   Status = normal
            )
        ;   Status = stalemate
        )
    ).

king_in_check(Board, Side) :-
    find_king(Board, Side, KingFile, KingRank),
    opposite_side(Side, EnemySide),
    is_square_attacked(Board, KingFile, KingRank, EnemySide).

candidate_promotion(pawn, Side, ToRank, Promotion) :-
    check_promotion(Side, ToRank, Promotion).

candidate_promotion(PieceType, _, _, none) :-
    PieceType \= pawn.
	
has_legal_move(State) :-
    State = state(Board, Side, _, _, _, _),
    file_index(FromFile, _),
    between(1, 8, FromRank),
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, PieceType],
    file_index(ToFile, _),
    between(1, 8, ToRank),
    candidate_promotion(PieceType, Side, ToRank, Promotion),
    Move = move(PieceType, none, none, ToFile, ToRank, Promotion),
    move_piece(State, Move, FromFile, FromRank, _, _),
	!.
	
% COUNT MATERIAL
check_material(Board, Advantage) :-
    count_material(Board, white, WhiteMaterial),
    count_material(Board, black, BlackMaterial),
    Advantage is WhiteMaterial - BlackMaterial.

count_material(Board, Side, Total) :-
    findall(Value, (member(Piece, Board), Piece =.. [Side, PieceType], piece_value(PieceType, Value)), Values),
    sum_list(Values, Total).

piece_value(pawn, 1).
piece_value(knight, 3).
piece_value(bishop, 3).
piece_value(rook, 5).
piece_value(queen, 9).
piece_value(king, 0).