% FEN TO STATE
fen_to_state(FEN, State) :-
    split_string(FEN, " ", " \t\n", Fields),
    Fields = [BoardText, SideText, CastlingText, EnPassantText, HalfmoveText, FullmoveText],
    fen_board(BoardText, Board),
    fen_side(SideText, Side),
    fen_castling(CastlingText, CastlingRights),
    fen_en_passant(EnPassantText, EnPassant),
    number_string(HalfmoveClock, HalfmoveText),
    number_string(FullmoveNumber, FullmoveText),
    HalfmoveClock >= 0,
    FullmoveNumber >= 1,
    State = state(Board, Side, CastlingRights, EnPassant, HalfmoveClock, FullmoveNumber).

% board
fen_board(BoardText, Board) :-
    split_string(BoardText, "/", "", RankStrings),
    length(RankStrings, 8),
    maplist(fen_rank, RankStrings, Ranks),
    append(Ranks, Board),
    length(Board, 64).

fen_rank(RankText, Squares) :-
    string_chars(RankText, Chars),
    fen_rank_chars(Chars, Squares),
    length(Squares, 8).

fen_rank_chars([], []).

fen_rank_chars([Char | Rest], Squares) :-
    char_type(Char, digit),
    !,
    atom_number(Char, Count),
    Count >= 1,
    Count =< 8,
    length(EmptySquares, Count),
    maplist(=(empty), EmptySquares),
    fen_rank_chars(Rest, RemainingSquares),
    append(EmptySquares, RemainingSquares, Squares).

fen_rank_chars([Char | Rest], [Piece | RemainingSquares]) :-
    fen_piece(Char, Piece),
    fen_rank_chars(Rest, RemainingSquares).

fen_piece('K', white(king)).
fen_piece('Q', white(queen)).
fen_piece('R', white(rook)).
fen_piece('B', white(bishop)).
fen_piece('N', white(knight)).
fen_piece('P', white(pawn)).
fen_piece('k', black(king)).
fen_piece('q', black(queen)).
fen_piece('r', black(rook)).
fen_piece('b', black(bishop)).
fen_piece('n', black(knight)).
fen_piece('p', black(pawn)).

% side
fen_side("w", white).
fen_side("b", black).

% castling rights
fen_castling("-", []) :- !.

fen_castling(CastlingText, CastlingRights) :-
    string_chars(CastlingText, Chars),
    Chars \= [],
    maplist(valid_castling_char, Chars),
    castling_rights_from_chars(Chars, CastlingRights).

valid_castling_char('K').
valid_castling_char('Q').
valid_castling_char('k').
valid_castling_char('q').

castling_rights_from_chars(Chars, Rights) :-
    findall(
        Right,
        (
            member(Char-Right, [
                'K'-kingside_white,
                'Q'-queenside_white,
                'k'-kingside_black,
                'q'-queenside_black
            ]),
            member(Char, Chars)
        ),
        Rights
    ).

% en passant
fen_en_passant("-", none) :- !.

fen_en_passant(Text, square(File, Rank)) :-
    string_chars(Text, [File, RankChar]),
    member(File, [a, b, c, d, e, f, g, h]),
    atom_number(RankChar, Rank),
    between(1, 8, Rank).
	
% STATE TO FEN
state_to_fen(state(Board, Side, CastlingRights, EnPassant, HalfmoveClock, FullmoveNumber), FEN) :-
    board_to_fen(Board, BoardText),
    fen_side(SideText, Side),
    castling_to_fen(CastlingRights, CastlingText),
    en_passant_to_fen(EnPassant, EnPassantText),
    number_string(HalfmoveClock, HalfmoveText),
    number_string(FullmoveNumber, FullmoveText),
    atomic_list_concat([BoardText, SideText, CastlingText, EnPassantText, HalfmoveText, FullmoveText], ' ', FENAtom),
    atom_string(FENAtom, FEN).

% board
board_to_fen(Board, BoardText) :-
    length(Board, 64),
    split_board_ranks(Board, Ranks),
    maplist(rank_to_fen, Ranks, RankTexts),
    atomic_list_concat(RankTexts, '/', BoardText).

split_board_ranks([], []).

split_board_ranks(Board, [Rank | RemainingRanks]) :-
    length(Rank, 8),
    append(Rank, Rest, Board),
    split_board_ranks(Rest, RemainingRanks).

rank_to_fen(Squares, RankText) :-
    rank_chars(Squares, Chars),
    atom_chars(RankText, Chars).

rank_chars([], []).

rank_chars([empty | Rest], Chars) :-
    !,
    count_empty_squares([empty | Rest], Count, RemainingSquares),
    number_chars(Count, CountChars),
    rank_chars(RemainingSquares, RemainingChars),
    append(CountChars, RemainingChars, Chars).

rank_chars([Piece | Rest], [Char | RemainingChars]) :-
    fen_piece_char(Piece, Char),
    rank_chars(Rest, RemainingChars).

fen_piece_char(Piece, Char) :-
    fen_piece(Char, Piece).

count_empty_squares([empty | Rest], Count, Remaining) :-
    !,
    count_empty_squares(Rest, RemainingCount, Remaining),
    Count is RemainingCount + 1.

count_empty_squares(Squares, 0, Squares).

% castling rights
castling_to_fen(Rights, CastlingText) :-
    findall(
        Char,
        (
            member(Char-Right, [
                'K'-kingside_white,
                'Q'-queenside_white,
                'k'-kingside_black,
                'q'-queenside_black
            ]),
            memberchk(Right, Rights)
        ),
        Chars
    ),
    (   Chars = []
    ->  CastlingText = "-"
    ;   atom_chars(CastlingAtom, Chars),
        atom_string(CastlingAtom, CastlingText)
    ).

% en passant
en_passant_to_fen(none, "-") :- !.

en_passant_to_fen(square(File, Rank), Text) :-
    number_chars(Rank, RankChars),
    atom_chars(RankAtom, RankChars),
    atom_concat(File, RankAtom, EnPassantAtom),
    atom_string(EnPassantAtom, Text).

% FEN POSITION KEY
fen_position_key(FEN, PositionKey) :-
    split_string(FEN, " ", " \t\n", Fields),
    Fields = [BoardText, SideText, CastlingText, EnPassantText, _HalfmoveText, _FullmoveText],
    atomic_list_concat([BoardText, SideText, CastlingText, EnPassantText], ' ', KeyAtom),
    atom_string(KeyAtom, PositionKey).

% SAN PARSING
san_to_move(SAN, Side, Move) :-
    san_chars(SAN, Chars),
    strip_san_suffixes(Chars, CoreChars),
    parse_san(CoreChars, Side, Move).
	
% formatting
san_chars(SAN, Chars) :-
    string(SAN),
    !,
    string_chars(SAN, Chars).

san_chars(SAN, Chars) :-
    atom(SAN),
    atom_chars(SAN, Chars).

strip_san_suffixes(Chars, CoreChars) :-
    reverse(Chars, Reversed),
    drop_san_suffixes(Reversed, Remaining),
    reverse(Remaining, CoreChars).

drop_san_suffixes([Char | Rest], Remaining) :-
    memberchk(Char, ['+', '#', '!', '?']),
    !,
    drop_san_suffixes(Rest, Remaining).

drop_san_suffixes(Chars, Chars).

% parsing
parse_san(Chars, Side, Move) :-
    castling_move(Chars, Side, Move),
    !.

parse_san(Chars, _, Move) :-
    extract_promotion(Chars, MoveChars, Promotion),
    append(Prefix, [ToFile, ToRankChar], MoveChars),
    valid_file(ToFile),
    atom_number(ToRankChar, ToRank),
    between(1, 8, ToRank),
    parse_prefix(Prefix, PieceType, Disambiguation, _CaptureMarker),
    parse_disambiguation(Disambiguation, FromFileHint, FromRankHint),
    Move = move(PieceType, FromFileHint, FromRankHint, ToFile, ToRank, Promotion).

% castling
castling_move(['O', '-', 'O'], white, move(king, none, none, g, 1, none)).
castling_move(['O', '-', 'O'], black, move(king, none, none, g, 8, none)).
castling_move(['O', '-', 'O', '-', 'O'], white, move(king, none, none, c, 1, none)).
castling_move(['O', '-', 'O', '-', 'O'], black, move(king, none, none, c, 8, none)).
castling_move(['0', '-', '0'], white, move(king, none, none, g, 1, none)).
castling_move(['0', '-', '0'], black, move(king, none, none, g, 8, none)).
castling_move(['0', '-', '0', '-', '0'], white, move(king, none, none, c, 1, none)).
castling_move(['0', '-', '0', '-', '0'], black, move(king, none, none, c, 8, none)).

% promotion
extract_promotion(Chars, MoveChars, Promotion) :-
    append(MoveChars, ['=', PromotionChar], Chars),
    !,
    promotion_piece(PromotionChar, Promotion).

extract_promotion(Chars, Chars, none).

promotion_piece('Q', queen).
promotion_piece('R', rook).
promotion_piece('B', bishop).
promotion_piece('N', knight).

% piece type
parse_prefix([First | Rest], PieceType, Disambiguation, CaptureMarker) :-
    san_piece_letter(First, PieceType),
    !,
    parse_capture_prefix(Rest, Disambiguation, CaptureMarker).

parse_prefix(Prefix, pawn, Disambiguation, CaptureMarker) :-
    parse_capture_prefix(Prefix, Disambiguation, CaptureMarker).

san_piece_letter('K', king).
san_piece_letter('Q', queen).
san_piece_letter('R', rook).
san_piece_letter('B', bishop).
san_piece_letter('N', knight).

parse_capture_prefix(Prefix, Disambiguation, capture) :-
    select('x', Prefix, Disambiguation),
    !,
    \+ memberchk('x', Disambiguation).

parse_capture_prefix(Prefix, Prefix, quiet).

% from hints
parse_disambiguation([], none, none).

parse_disambiguation([File], File, none) :-
    valid_file(File).
	
parse_disambiguation([RankChar], none, Rank) :-
    atom_number(RankChar, Rank),
    between(1, 8, Rank).

parse_disambiguation([File, RankChar], File, Rank) :-
    valid_file(File),
    atom_number(RankChar, Rank),
    between(1, 8, Rank).

valid_file(a).
valid_file(b).
valid_file(c).
valid_file(d).
valid_file(e).
valid_file(f).
valid_file(g).
valid_file(h).

% COORDINATE PARSING
coordinates_to_move(Board, Side, From, To, Promotion, Move) :-
    coordinate_square(From, FromFile, FromRank),
    coordinate_square(To, ToFile, ToRank),
    coordinate_promotion(Promotion, PromotionPiece),
    piece_at(Board, FromFile, FromRank, Piece),
    Piece =.. [Side, PieceType],
    Move = move(PieceType, FromFile, FromRank, ToFile, ToRank, PromotionPiece).

% square parsing
coordinate_square(Square, File, Rank) :-
    string(Square),
    string_chars(Square, [File, RankChar]),
    valid_file(File),
    atom_number(RankChar, Rank),
    between(1, 8, Rank).

% promotion parsing
coordinate_promotion(null, none) :- !.
coordinate_promotion(none, none) :- !.
coordinate_promotion("queen", queen) :- !.
coordinate_promotion("rook", rook) :- !.
coordinate_promotion("bishop", bishop) :- !.
coordinate_promotion("knight", knight) :- !.

% SAN CREATION
% Convert an internal move into SAN.
move_to_san(State, Move, MoveType, Status, SAN) :-
    Move = move(PieceType, _, _, ToFile, ToRank, Promotion),
    (   MoveType = castle
    ->  castle_san(ToFile, SANCore)
    ;   find_piece(State, Move, FromFile, FromRank),
        piece_san(PieceType, PieceChars),
        san_disambiguation(
            State, PieceType, ToFile, ToRank,
            FromFile, FromRank, Disambiguation
        ),
        san_capture_marker(MoveType, CaptureMarker),
        san_pawn_capture_prefix(
            PieceType, MoveType, FromFile, PawnCapturePrefix
        ),
        san_destination(ToFile, ToRank, Destination),
        san_promotion(Promotion, PromotionChars),
        append([
            PieceChars,
            PawnCapturePrefix,
            Disambiguation,
            CaptureMarker,
            Destination,
            PromotionChars
        ], SANCore)
    ),
    san_status(Status, StatusSuffix),
    append(SANCore, StatusSuffix, SANChars),
    atom_chars(SAN, SANChars).

% Include the source file for pawn captures.
san_pawn_capture_prefix(pawn, MoveType, FromFile, Prefix) :-
    memberchk(MoveType, [capture, en_passant]),
    !,
    atom_chars(FromFile, Prefix).

san_pawn_capture_prefix(_, _, _, []).

% Piece notation.
piece_san(king, ['K']).
piece_san(queen, ['Q']).
piece_san(rook, ['R']).
piece_san(bishop, ['B']).
piece_san(knight, ['N']).
piece_san(pawn, []).


% Castling notation.
castle_san(g, ['O', '-', 'O']).
castle_san(c, ['O', '-', 'O', '-', 'O']).


% Capture notation.
san_capture_marker(capture, ['x']).
san_capture_marker(en_passant, ['x']).
san_capture_marker(_, []).


% Destination square.
san_destination(File, Rank, Chars) :-
    atom_chars(File, FileChars),
    number_chars(Rank, RankChars),
    append(FileChars, RankChars, Chars).


% Promotion notation.
san_promotion(none, []).
san_promotion(queen, ['=', 'Q']).
san_promotion(rook, ['=', 'R']).
san_promotion(bishop, ['=', 'B']).
san_promotion(knight, ['=', 'N']).


% Check and checkmate suffixes.
san_status(check, ['+']).
san_status(checkmate, ['#']).
san_status(_, []).


% Determine whether source disambiguation is needed.
san_disambiguation(
    State, PieceType, ToFile, ToRank,
    FromFile, FromRank, Disambiguation
) :-
    findall(
        candidate(File, Rank),
        legal_alternative(
            State, PieceType, ToFile, ToRank,
            FromFile, FromRank, File, Rank
        ),
        Alternatives
    ),
    (   Alternatives = []
    ->  Disambiguation = []
    ;   \+ member(candidate(FromFile, _), Alternatives)
    ->  atom_chars(FromFile, Disambiguation)
    ;   \+ member(candidate(_, FromRank), Alternatives)
    ->  number_chars(FromRank, Disambiguation)
    ;   atom_chars(FromFile, FileChars),
        number_chars(FromRank, RankChars),
        append(FileChars, RankChars, Disambiguation)
    ).


% Find another identical piece that can legally reach the destination.
legal_alternative(
    State, PieceType, ToFile, ToRank,
    FromFile, FromRank, CandidateFile, CandidateRank
) :-
    State = state(Board, Side, _, _, _, _),
    file_index(CandidateFile, _),
    between(1, 8, CandidateRank),

    \+ (CandidateFile = FromFile, CandidateRank = FromRank),

    piece_at(Board, CandidateFile, CandidateRank, Piece),
    Piece =.. [Side, PieceType],

    CandidateMove = move(
        PieceType,
        CandidateFile,
        CandidateRank,
        ToFile,
        ToRank,
        none
    ),

    move_piece(
        State, CandidateMove,
        CandidateFile, CandidateRank, _, _
    ).
	
% CONVERT ATOMS TO STRING
convert_position_outputs(CastlingRights, EnPassant, ApiCastlingRights, ApiEnPassant) :-
    castling_rights_to_api(CastlingRights, ApiCastlingRights),
    en_passant_to_api(EnPassant, ApiEnPassant).
	
% Convert en passant target to a string.
en_passant_to_api(none, null) :- !.

en_passant_to_api(square(File, Rank), SquareString) :-
    number_string(Rank, RankString),
    atom_string(File, FileString),
    string_concat(FileString, RankString, SquareString).

% Convert castling rights to strings.
castling_rights_to_api(Rights, StringRights) :-
    maplist(atom_string, Rights, StringRights).
	
% CONVERT MOVES TO SQUARES
convert_legal_moves(InternalMoves, ApiMoves) :-
    maplist(convert_legal_move, InternalMoves, ApiMoves).

convert_legal_move(
    legal_move(FromFile, FromRank, ToFile, ToRank, MoveType, Promotion),
    _{
        from: From,
        to: To,
        moveType: MoveTypeString,
        promotion: JsonPromotion
    }
):-
    square_to_string(FromFile, FromRank, From),
    square_to_string(ToFile, ToRank, To),
    atom_string(MoveType, MoveTypeString),
    promotion_to_json(Promotion, JsonPromotion).
	
promotion_to_json(none, null) :- !.
promotion_to_json(Promotion, PromotionString) :-
    atom_string(Promotion, PromotionString).

square_to_string(File, Rank, Square) :-
    atom_string(File, FileString),
    number_string(Rank, RankString),
    string_concat(FileString, RankString, Square).