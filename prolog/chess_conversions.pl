play_san_fen(FEN, SAN, NewFEN) :-
    fen_to_state(FEN, State),
    State = state(_, Side, _, _, _, _),
    san_to_move(SAN, Side, Move),
    play_move(State, Move, NewState, _Status, _Advantage),
    state_to_fen(NewState, NewFEN).

initial_fen(FEN) :-
    initial_state(State),
    state_to_fen(State, FEN).

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