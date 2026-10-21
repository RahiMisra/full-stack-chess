
:- consult('prolog_chess.pl').

% ============================================================
% TEST RUNNER
% ============================================================

% Run both suites.
run_all_tests :-
    run_movement_tests,
    run_apply_movement_tests,
	run_legal_tests,
	run_move_piece_tests,
	run_update_state_tests,
    run_play_move_tests,
	run_check_position_tests,
	run_check_material_tests.

% ============================================================
% CHECK MOVEMENT TESTS
% ============================================================

run_movement_tests :-
    writeln('========== KNIGHT TESTS =========='),
    test_success(knight_l_shape_1,
        (make_test_state([piece(g, 1, white(knight))], white, none, S1),
         check_movement(S1, move(knight, none, none, f, 3, none), g, 1, normal))),

    test_success(knight_l_shape_2,
        (make_test_state([piece(b, 1, white(knight))], white, none, S2),
         check_movement(S2, move(knight, none, none, d, 2, none), b, 1, normal))),

    test_success(knight_capture,
        (make_test_state([piece(g, 1, white(knight)),
                          piece(f, 3, black(pawn))], white, none, S3),
         check_movement(S3, move(knight, none, none, f, 3, none), g, 1, capture))),

    test_failure(knight_invalid_distance,
        (make_test_state([piece(g, 1, white(knight))], white, none, S4),
         check_movement(S4, move(knight, none, none, g, 3, none), g, 1, _))),

    test_failure(knight_friendly_piece,
        (make_test_state([piece(g, 1, white(knight)),
                          piece(f, 3, white(pawn))], white, none, S5),
         check_movement(S5, move(knight, none, none, f, 3, none), g, 1, _))),

    writeln('========== BISHOP TESTS =========='),

    test_success(bishop_diagonal,
        (make_test_state([piece(c, 1, white(bishop))], white, none, S6),
         check_movement(S6, move(bishop, none, none, f, 4, none), c, 1, normal))),

    test_success(bishop_capture,
        (make_test_state([piece(c, 1, white(bishop)),
                          piece(f, 4, black(rook))], white, none, S7),
         check_movement(S7, move(bishop, none, none, f, 4, none), c, 1, capture))),

    test_failure(bishop_not_diagonal,
        (make_test_state([piece(c, 1, white(bishop))], white, none, S8),
         check_movement(S8, move(bishop, none, none, c, 4, none), c, 1, _))),

    test_failure(bishop_blocked_path,
        (make_test_state([piece(c, 1, white(bishop)),
                          piece(d, 2, white(pawn))], white, none, S9),
         check_movement(S9, move(bishop, none, none, f, 4, none), c, 1, _))),

    writeln('========== ROOK TESTS ============'),

    test_success(rook_vertical,
        (make_test_state([piece(a, 1, white(rook))], white, none, S10),
         check_movement(S10, move(rook, none, none, a, 6, none), a, 1, normal))),

    test_success(rook_horizontal,
        (make_test_state([piece(a, 1, white(rook))], white, none, S11),
         check_movement(S11, move(rook, none, none, h, 1, none), a, 1, normal))),

    test_success(rook_capture,
        (make_test_state([piece(a, 1, white(rook)),
                          piece(a, 6, black(queen))], white, none, S12),
         check_movement(S12, move(rook, none, none, a, 6, none), a, 1, capture))),

    test_failure(rook_blocked_path,
        (make_test_state([piece(a, 1, white(rook)),
                          piece(a, 4, white(pawn))], white, none, S13),
         check_movement(S13, move(rook, none, none, a, 6, none), a, 1, _))),

    test_failure(rook_diagonal,
        (make_test_state([piece(a, 1, white(rook))], white, none, S14),
         check_movement(S14, move(rook, none, none, c, 3, none), a, 1, _))),

    writeln('========== QUEEN TESTS ==========='),

    test_success(queen_diagonal,
        (make_test_state([piece(d, 1, white(queen))], white, none, S15),
         check_movement(S15, move(queen, none, none, g, 4, none), d, 1, normal))),

    test_success(queen_horizontal,
        (make_test_state([piece(d, 1, white(queen))], white, none, S16),
         check_movement(S16, move(queen, none, none, h, 1, none), d, 1, normal))),

    test_success(queen_vertical,
        (make_test_state([piece(d, 1, white(queen))], white, none, S17),
         check_movement(S17, move(queen, none, none, d, 8, none), d, 1, normal))),

    test_failure(queen_blocked_path,
        (make_test_state([piece(d, 1, white(queen)),
                          piece(d, 4, black(pawn))], white, none, S18),
         check_movement(S18, move(queen, none, none, d, 8, none), d, 1, _))),

    writeln('========== KING TESTS ============'),

    test_success(king_one_square,
        (make_test_state([piece(e, 1, white(king))], white, none, S19),
         check_movement(S19, move(king, none, none, e, 2, none), e, 1, normal))),

    test_success(king_capture,
        (make_test_state([piece(e, 1, white(king)),
                          piece(f, 2, black(pawn))], white, none, S20),
         check_movement(S20, move(king, none, none, f, 2, none), e, 1, capture))),

    test_failure(king_too_far,
        (make_test_state([piece(e, 1, white(king))], white, none, S21),
         check_movement(S21, move(king, none, none, e, 3, none), e, 1, _))),

    writeln('========== PAWN TESTS ============'),

    test_success(pawn_one_square,
        (make_test_state([piece(e, 2, white(pawn))], white, none, S22),
         check_movement(S22, move(pawn, none, none, e, 3, none), e, 2, normal))),

    test_success(pawn_initial_double,
        (make_test_state([piece(e, 2, white(pawn))], white, none, S23),
         check_movement(S23, move(pawn, none, none, e, 4, none), e, 2, normal))),

    test_failure(pawn_double_not_initial,
        (make_test_state([piece(e, 3, white(pawn))], white, none, S24),
         check_movement(S24, move(pawn, none, none, e, 5, none), e, 3, _))),

    test_success(pawn_capture,
        (make_test_state([piece(e, 4, white(pawn)),
                          piece(f, 5, black(knight))], white, none, S25),
         check_movement(S25, move(pawn, none, none, f, 5, none), e, 4, capture))),

    test_failure(pawn_diagonal_empty,
        (make_test_state([piece(e, 4, white(pawn))], white, none, S26),
         check_movement(S26, move(pawn, none, none, f, 5, none), e, 4, _))),

    test_failure(pawn_forward_blocked,
        (make_test_state([piece(e, 2, white(pawn)),
                          piece(e, 3, black(knight))], white, none, S27),
         check_movement(S27, move(pawn, none, none, e, 3, none), e, 2, _))),

    test_failure(pawn_double_blocked,
        (make_test_state([piece(e, 2, white(pawn)),
                          piece(e, 3, black(knight))], white, none, S28),
         check_movement(S28, move(pawn, none, none, e, 4, none), e, 2, _))),

    test_success(black_pawn_one_square,
        (make_test_state([piece(e, 7, black(pawn))], black, none, S29),
         check_movement(S29, move(pawn, none, none, e, 6, none), e, 7, normal))),

    test_success(black_pawn_initial_double,
        (make_test_state([piece(e, 7, black(pawn))], black, none, S30),
         check_movement(S30, move(pawn, none, none, e, 5, none), e, 7, normal))),

    writeln('========== EN PASSANT TESTS ======'),

    test_success(en_passant_white,
        (make_test_state([piece(e, 5, white(pawn)),
                          piece(d, 5, black(pawn))],
                         white, square(d, 6), S31),
         check_movement(S31, move(pawn, none, none, d, 6, none), e, 5, en_passant))),

    test_success(en_passant_black,
        (make_test_state([piece(d, 4, black(pawn)),
                          piece(e, 4, white(pawn))],
                         black, square(e, 3), S32),
         check_movement(S32, move(pawn, none, none, e, 3, none), d, 4, en_passant))),

    test_failure(en_passant_wrong_target,
        (make_test_state([piece(e, 5, white(pawn)),
                          piece(d, 5, black(pawn))],
                         white, none, S33),
         check_movement(S33, move(pawn, none, none, d, 6, none), e, 5, _))),

    writeln('========== PROMOTION TESTS ======='),

    test_success(promotion_queen,
        (make_test_state([piece(e, 7, white(pawn))], white, none, S34),
         check_movement(S34, move(pawn, none, none, e, 8, queen), e, 7, normal))),

    test_success(promotion_knight_capture,
        (make_test_state([piece(e, 7, white(pawn)),
                          piece(f, 8, black(rook))], white, none, S35),
         check_movement(S35, move(pawn, none, none, f, 8, knight), e, 7, capture))),

    test_failure(promotion_missing,
        (make_test_state([piece(e, 7, white(pawn))], white, none, S36),
         check_movement(S36, move(pawn, none, none, e, 8, none), e, 7, _))),

    test_failure(promotion_invalid_piece,
        (make_test_state([piece(e, 7, white(pawn))], white, none, S37),
         check_movement(S37, move(pawn, none, none, e, 8, king), e, 7, _))),

    test_failure(promotion_too_early,
        (make_test_state([piece(e, 6, white(pawn))], white, none, S38),
         check_movement(S38, move(pawn, none, none, e, 7, queen), e, 6, _))),
		 
	
    writeln('========== CASTLING TESTS ============'),

    test_success(white_kingside_castle,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white, [kingside_white], S39),
         check_movement(
            S39, move(king, none, none, g, 1, none),
            e, 1, castle))),

    test_success(white_queenside_castle,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(a, 1, white(rook)),
             piece(e, 8, black(king))],
            white, [queenside_white], S40),
         check_movement(
            S40, move(king, none, none, c, 1, none),
            e, 1, castle))),

    test_success(black_kingside_castle,
        (make_castling_test_state(
            [piece(e, 8, black(king)),
             piece(h, 8, black(rook)),
             piece(e, 1, white(king))],
            black, [kingside_black], S41),
         check_movement(
            S41, move(king, none, none, g, 8, none),
            e, 8, castle))),

    test_success(black_queenside_castle,
        (make_castling_test_state(
            [piece(e, 8, black(king)),
             piece(a, 8, black(rook)),
             piece(e, 1, white(king))],
            black, [queenside_black], S42),
         check_movement(
            S42, move(king, none, none, c, 8, none),
            e, 8, castle))),

    test_failure(castle_blocked_path,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(f, 1, white(knight)),
             piece(e, 8, black(king))],
            white, [kingside_white], S43),
         check_movement(
            S43, move(king, none, none, g, 1, none),
            e, 1, _))),

    test_failure(castle_missing_rook,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king))],
            white, [kingside_white], S44),
         check_movement(
            S44, move(king, none, none, g, 1, none),
            e, 1, _))),

    test_failure(castle_while_in_check,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king)),
             piece(e, 7, black(rook))],
            white, [kingside_white], S45),
         check_movement(
            S45, move(king, none, none, g, 1, none),
            e, 1, _))),

    test_failure(castle_through_check,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king)),
             piece(f, 8, black(rook))],
            white, [kingside_white], S46),
         check_movement(
            S46, move(king, none, none, g, 1, none),
            e, 1, _))),

    test_failure(castle_into_check,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king)),
             piece(g, 8, black(rook))],
            white, [kingside_white], S47),
         check_movement(
            S47, move(king, none, none, g, 1, none),
            e, 1, _))),

    test_failure(castle_without_rights,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white, none, S48),
         check_movement(
            S48, move(king, none, none, g, 1, none),
            e, 1, _))),

    test_failure(castle_invalid_destination,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white, [kingside_white], S49),
         check_movement(
            S49, move(king, none, none, h, 1, none),
            e, 1, _))),

    writeln('========== MOVEMENT TESTS DONE ===').
	
% ============================================================
% APPLY MOVEMENT TESTS
% ============================================================

run_apply_movement_tests :-
    writeln('========== APPLY: NORMAL MOVES =========='),

    % Knight moves from g1 to f3.
    test_success(apply_knight_move,
        (make_test_state(
            [piece(g, 1, white(knight))],
            white, none, S1),
         apply_movement(
            S1, move(knight, none, none, f, 3, none),
            g, 1, normal, Board1),
         piece_at(Board1, g, 1, empty),
         piece_at(Board1, f, 3, white(knight)))),

    % White rook captures a black queen.
    test_success(apply_capture,
        (make_test_state(
            [piece(a, 1, white(rook)),
             piece(a, 6, black(queen))],
            white, none, S2),
         apply_movement(
            S2, move(rook, none, none, a, 6, none),
            a, 1, capture, Board2),
         piece_at(Board2, a, 1, empty),
         piece_at(Board2, a, 6, white(rook)))),

    % Unrelated pieces should remain unchanged.
    test_success(apply_preserves_other_pieces,
        (make_test_state(
            [piece(g, 1, white(knight)),
             piece(a, 8, black(rook))],
            white, none, S3),
         apply_movement(
            S3, move(knight, none, none, f, 3, none),
            g, 1, normal, Board3),
         piece_at(Board3, a, 8, black(rook)))),

    writeln('========== APPLY: PROMOTION =========='),

    % White pawn promotes to a queen.
    test_success(apply_promotion_queen,
        (make_test_state(
            [piece(e, 7, white(pawn))],
            white, none, S4),
         apply_movement(
            S4, move(pawn, none, none, e, 8, queen),
            e, 7, normal, Board4),
         piece_at(Board4, e, 7, empty),
         piece_at(Board4, e, 8, white(queen)))),

    % White pawn promotes to a knight while capturing.
    test_success(apply_promotion_capture,
        (make_test_state(
            [piece(e, 7, white(pawn)),
             piece(f, 8, black(rook))],
            white, none, S5),
         apply_movement(
            S5, move(pawn, none, none, f, 8, knight),
            e, 7, capture, Board5),
         piece_at(Board5, e, 7, empty),
         piece_at(Board5, f, 8, white(knight)))),

    writeln('========== APPLY: EN PASSANT =========='),

    % White pawn moves e5-d6 and removes the black pawn on d5.
    test_success(apply_en_passant_white,
        (make_test_state(
            [piece(e, 5, white(pawn)),
             piece(d, 5, black(pawn))],
            white, square(d, 6), S6),
         apply_movement(
            S6, move(pawn, none, none, d, 6, none),
            e, 5, en_passant, Board6),
         piece_at(Board6, e, 5, empty),
         piece_at(Board6, d, 5, empty),
         piece_at(Board6, d, 6, white(pawn)))),

    % Black pawn moves d4-e3 and removes the white pawn on e4.
    test_success(apply_en_passant_black,
        (make_test_state(
            [piece(d, 4, black(pawn)),
             piece(e, 4, white(pawn))],
            black, square(e, 3), S7),
         apply_movement(
            S7, move(pawn, none, none, e, 3, none),
            d, 4, en_passant, Board7),
         piece_at(Board7, d, 4, empty),
         piece_at(Board7, e, 4, empty),
         piece_at(Board7, e, 3, black(pawn)))),
		
	writeln('========== APPLY: CASTLING =========='),

    % White kingside: king e1-g1, rook h1-f1.
    test_success(apply_castling_white_kingside,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white, [kingside_white], S8),
         apply_movement(
            S8, move(king, none, none, g, 1, none),
            e, 1, castle, Board8),
         piece_at(Board8, e, 1, empty),
         piece_at(Board8, h, 1, empty),
         piece_at(Board8, g, 1, white(king)),
         piece_at(Board8, f, 1, white(rook)))),

    % White queenside: king e1-c1, rook a1-d1.
    test_success(apply_castling_white_queenside,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(a, 1, white(rook)),
             piece(e, 8, black(king))],
            white, [queenside_white], S9),
         apply_movement(
            S9, move(king, none, none, c, 1, none),
            e, 1, castle, Board9),
         piece_at(Board9, e, 1, empty),
         piece_at(Board9, a, 1, empty),
         piece_at(Board9, c, 1, white(king)),
         piece_at(Board9, d, 1, white(rook)))),

    % Black kingside: king e8-g8, rook h8-f8.
    test_success(apply_castling_black_kingside,
        (make_castling_test_state(
            [piece(e, 8, black(king)),
             piece(h, 8, black(rook)),
             piece(e, 1, white(king))],
            black, [kingside_black], S10),
         apply_movement(
            S10, move(king, none, none, g, 8, none),
            e, 8, castle, Board10),
         piece_at(Board10, e, 8, empty),
         piece_at(Board10, h, 8, empty),
         piece_at(Board10, g, 8, black(king)),
         piece_at(Board10, f, 8, black(rook)))),

    % Black queenside: king e8-c8, rook a8-d8.
    test_success(apply_castling_black_queenside,
        (make_castling_test_state(
            [piece(e, 8, black(king)),
             piece(a, 8, black(rook)),
             piece(e, 1, white(king))],
            black, [queenside_black], S11),
         apply_movement(
            S11, move(king, none, none, c, 8, none),
            e, 8, castle, Board11),
         piece_at(Board11, e, 8, empty),
         piece_at(Board11, a, 8, empty),
         piece_at(Board11, c, 8, black(king)),
         piece_at(Board11, d, 8, black(rook)))),

    writeln('========== APPLY TESTS DONE ==========').
	

% ============================================================
% CHECK LEGAL TESTS
% ============================================================

run_legal_tests :-
    writeln('========== FIND KING TESTS =========='),

    % Find the white king.
    test_success(find_white_king,
        (make_test_state(
            [piece(e, 1, white(king))],
            white, none, state(Board1, _, _, _, _, _)),
         find_king(Board1, white, e, 1))),

    % Find the black king.
    test_success(find_black_king,
        (make_test_state(
            [piece(e, 8, black(king))],
            black, none, state(Board2, _, _, _, _, _)),
         find_king(Board2, black, e, 8))),

    % Fail if the requested king is missing.
    test_failure(missing_king,
        (make_test_state(
            [piece(e, 1, white(rook))],
            white, none, state(Board3, _, _, _, _, _)),
         find_king(Board3, white, _, _))),

    writeln('========== ATTACK DETECTION TESTS =========='),

    % A rook attacks along a clear file.
    test_success(rook_attack,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(rook))],
            white, none, state(Board4, _, _, _, _, _)),
         is_square_attacked(Board4, e, 1, black))),

    % A piece blocks the rook's attack.
    test_failure(blocked_rook_attack,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 4, white(pawn)),
             piece(e, 8, black(rook))],
            white, none, state(Board5, _, _, _, _, _)),
         is_square_attacked(Board5, e, 1, black))),

    % A knight attacks in an L-shape.
    test_success(knight_attack,
        (make_test_state(
            [piece(e, 4, white(king)),
             piece(f, 6, black(knight))],
            white, none, state(Board6, _, _, _, _, _)),
         is_square_attacked(Board6, e, 4, black))),

    % A bishop attacks diagonally.
    test_success(bishop_attack,
        (make_test_state(
            [piece(c, 1, white(king)),
             piece(g, 5, black(bishop))],
            white, none, state(Board7, _, _, _, _, _)),
         is_square_attacked(Board7, c, 1, black))),

    % A queen attacks horizontally.
    test_success(queen_attack,
        (make_test_state(
            [piece(a, 4, white(king)),
             piece(h, 4, black(queen))],
            white, none, state(Board8, _, _, _, _, _)),
         is_square_attacked(Board8, a, 4, black))),

    % A king attacks an adjacent square.
    test_success(king_attack,
        (make_test_state(
            [piece(e, 4, white(king)),
             piece(f, 5, black(king))],
            white, none, state(Board9, _, _, _, _, _)),
         is_square_attacked(Board9, e, 4, black))),

    % Black pawns attack diagonally downward.
    test_success(black_pawn_attack,
        (make_test_state(
            [piece(e, 4, white(king)),
             piece(d, 5, black(pawn))],
            white, none, state(Board10, _, _, _, _, _)),
         is_square_attacked(Board10, e, 4, black))),

    % White pawns attack diagonally upward.
    test_success(white_pawn_attack,
        (make_test_state(
            [piece(e, 5, black(king)),
             piece(d, 4, white(pawn))],
            black, none, state(Board11, _, _, _, _, _)),
         is_square_attacked(Board11, e, 5, white))),

    writeln('========== KING SAFETY TESTS =========='),

    % The white king is safe.
    test_success(white_king_safe,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king))],
            white, none, State12),
		 State12 = state(Board12, white, _, _, _, _),
         check_legal(State12, Board12),
         find_king(Board12, white, e, 1),
         \+ is_square_attacked(Board12, e, 1, black))),

    % The white king is in check from a black rook.
    test_failure(white_king_in_check,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(rook)),
             piece(a, 8, black(king))],
            white, none, State13),
         State13 = state(_, white, _, _, _, _),
         check_legal(
             State13,
             [empty, empty, empty, empty, black(rook), empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              black(king), empty, empty, empty, white(king), empty, empty, empty]))),

    % The black king is in check from a white rook.
    test_failure(black_king_in_check,
        (make_test_state(
            [piece(e, 8, black(king)),
             piece(e, 1, white(rook)),
             piece(a, 1, white(king))],
            black, none, State14),
         State14 = state(_, black, _, _, _, _),
         check_legal(
             State14,
             [empty, empty, empty, empty, white(rook), empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              empty, empty, empty, empty, empty, empty, empty, empty,
              white(king), empty, empty, empty, black(king), empty, empty, empty]))),

    writeln('========== CHECK LEGAL TESTS DONE ==========').

% ==========================================
% MOVE PIECE TESTS
% ==========================================

run_move_piece_tests :-
    writeln('========== MOVE PIECE TESTS ============'),

    test_success(move_piece_white_pawn_advance,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 2, white(pawn)),
             piece(e, 8, black(king))],
            white, none, State1),
         move_piece(
            State1, move(pawn, none, none, e, 4, none),
            e, 2, normal, Board1),
         piece_at(Board1, e, 2, empty),
         piece_at(Board1, e, 4, white(pawn)))),

    test_success(move_piece_white_knight,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(g, 1, white(knight)),
             piece(e, 8, black(king))],
            white, none, State2),
         move_piece(
            State2, move(knight, none, none, f, 3, none),
            g, 1, normal, Board2),
         piece_at(Board2, g, 1, empty),
         piece_at(Board2, f, 3, white(knight)))),

    test_success(move_piece_capture,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(c, 4, white(bishop)),
             piece(f, 7, black(knight)),
             piece(a, 8, black(king))],
            white, none, State3),
         move_piece(
            State3, move(bishop, none, none, f, 7, none),
            c, 4, capture, Board3),
         piece_at(Board3, c, 4, empty),
         piece_at(Board3, f, 7, white(bishop)))),

    test_success(move_piece_pawn_capture,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 4, white(pawn)),
             piece(d, 5, black(pawn)),
             piece(e, 8, black(king))],
            white, none, State4),
         move_piece(
            State4, move(pawn, none, none, d, 5, none),
            e, 4, capture, Board4),
         piece_at(Board4, e, 4, empty),
         piece_at(Board4, d, 5, white(pawn)))),

    test_success(move_piece_en_passant,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 5, white(pawn)),
             piece(d, 5, black(pawn)),
             piece(e, 8, black(king))],
            white, square(d, 6), State5),
         move_piece(
            State5, move(pawn, none, none, d, 6, none),
            e, 5, en_passant, Board5),
         piece_at(Board5, e, 5, empty),
         piece_at(Board5, d, 5, empty),
         piece_at(Board5, d, 6, white(pawn)))),

    test_success(move_piece_promotion,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(a, 7, white(pawn)),
             piece(e, 8, black(king))],
            white, none, State6),
         move_piece(
            State6, move(pawn, none, none, a, 8, queen),
            a, 7, normal, Board6),
         piece_at(Board6, a, 7, empty),
         piece_at(Board6, a, 8, white(queen)))),

    test_success(move_piece_king,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king))],
            white, none, State7),
         move_piece(
            State7, move(king, none, none, f, 1, none),
            e, 1, normal, Board7),
         piece_at(Board7, e, 1, empty),
         piece_at(Board7, f, 1, white(king)))),

    test_success(move_piece_castling,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white, [kingside_white], State8),
         move_piece(
            State8, move(king, none, none, g, 1, none),
            e, 1, castle, Board8),
         piece_at(Board8, e, 1, empty),
         piece_at(Board8, h, 1, empty),
         piece_at(Board8, g, 1, white(king)),
         piece_at(Board8, f, 1, white(rook)))),

    test_failure(move_piece_invalid_king_move,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king))],
            white, none, State9),
         move_piece(
            State9, move(king, none, none, e, 3, none),
            e, 1, _, _))),

    test_failure(move_piece_leaves_king_in_check,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 2, white(rook)),
             piece(e, 8, black(rook)),
             piece(a, 8, black(king))],
            white, none, State10),
         move_piece(
            State10, move(rook, none, none, d, 2, none),
            e, 2, _, _))),

    writeln('========== END MOVE PIECE TESTS =========').


% ==========================================
% UPDATE STATE TESTS
% ==========================================

run_update_state_tests :-
    writeln('========== UPDATE STATE TESTS ==========='),

    % White pawn advances two squares.
    test_success(update_state_white_pawn_double_step,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 2, white(pawn)),
             piece(e, 8, black(king))],
            white, none,
            state(Board1, white, [], none, 0, 1)),
         make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 4, white(pawn)),
             piece(e, 8, black(king))],
            white, none,
            state(NewBoard1, _, _, _, _, _)),
         update_state(
            state(Board1, white, [], none, 0, 1),
            move(pawn, none, none, e, 4, none),
            e, 2, normal, NewBoard1, NewState1),
         NewState1 =
            state(NewBoard1, black, [], square(e, 3), 0, 1))),

    % Black makes a quiet knight move.
    test_success(update_state_black_quiet_move,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(g, 8, black(knight)),
             piece(e, 8, black(king))],
            black, none,
            state(Board2, black, [], none, 0, 1)),
         make_test_state(
            [piece(e, 1, white(king)),
             piece(f, 6, black(knight)),
             piece(e, 8, black(king))],
            black, none,
            state(NewBoard2, _, _, _, _, _)),
         update_state(
            state(Board2, black, [], none, 7, 3),
            move(knight, none, none, f, 6, none),
            g, 8, normal, NewBoard2, NewState2),
         NewState2 =
            state(NewBoard2, white, [], none, 8, 4))),

    % Moving the white king removes both white castling rights.
    test_success(update_state_king_moves,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(a, 1, white(rook)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white,
            [kingside_white, queenside_white,
             kingside_black, queenside_black],
            state(Board3, white, Rights, none, 0, 1)),
         make_test_state(
            [piece(e, 2, white(king)),
             piece(a, 1, white(rook)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white, none,
            state(NewBoard3, _, _, _, _, _)),
         update_state(
            state(Board3, white, Rights, none, 0, 1),
            move(king, none, none, e, 2, none),
            e, 1, normal, NewBoard3, NewState3),
         NewState3 =
            state(NewBoard3, black,
                  [kingside_black, queenside_black],
                  none, 1, 1))),

    % Moving the white kingside rook removes that right only.
    test_success(update_state_rook_moves,
        (make_castling_test_state(
            [piece(e, 1, white(king)),
             piece(a, 1, white(rook)),
             piece(h, 1, white(rook)),
             piece(e, 8, black(king))],
            white,
            [kingside_white, queenside_white,
             kingside_black, queenside_black],
            state(Board4, white, Rights, none, 0, 1)),
         make_test_state(
            [piece(e, 1, white(king)),
             piece(a, 1, white(rook)),
             piece(h, 2, white(rook)),
             piece(e, 8, black(king))],
            white, none,
            state(NewBoard4, _, _, _, _, _)),
         update_state(
            state(Board4, white, Rights, none, 0, 1),
            move(rook, none, none, h, 2, none),
            h, 1, normal, NewBoard4, NewState4),
         NewState4 =
            state(NewBoard4, black,
                  [queenside_white, kingside_black,
                   queenside_black],
                  none, 1, 1))),

    writeln('========== END UPDATE STATE TESTS =======').


% ==========================================
% PLAY MOVE TESTS
% ==========================================

run_play_move_tests :-
    writeln('========== PLAY MOVE TESTS =============='),

    % A white pawn advances two squares.
    test_success(play_move_white_pawn_double_step,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 2, white(pawn)),
             piece(e, 8, black(king))],
            white, none, State1),
         play_move(
            State1,
            move(pawn, none, none, e, 4, none),
            NewState1,
			Status1,
			Advantage1),
         NewState1 =
            state(NewBoard1, black, [], square(e, 3), 0, 1),
         piece_at(NewBoard1, e, 2, empty),
         piece_at(NewBoard1, e, 4, white(pawn)))),

    % A quiet knight move updates the board and clock.
    test_success(play_move_white_knight,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(g, 1, white(knight)),
             piece(e, 8, black(king))],
            white, none, State2),
         play_move(
            State2,
            move(knight, none, none, f, 3, none),
            NewState2,
			Status2,
			Advantage2),
         NewState2 =
            state(NewBoard2, black, [], none, 1, 1),
         piece_at(NewBoard2, g, 1, empty),
         piece_at(NewBoard2, f, 3, white(knight)))),

    writeln('========== END PLAY MOVE TESTS =========').


% ==========================================
% CHECK POSITION TESTS
% ==========================================

run_check_position_tests :-
    writeln('========== CHECK POSITION TESTS ========='),

    % White is not in check and has legal moves.
    test_success(check_position_normal,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king))],
            white, none, State1),
         check_position(State1, normal))),

    % White is in check from the black rook,
    % but can escape the check.
    test_success(check_position_check,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(rook)),
             piece(a, 8, black(king))],
            white, none, State2),
         check_position(State2, check))),

    % White is checkmated.
    % The black queen checks the white king on h1.
    % The black king protects the queen on g2,
    % and the white king has no legal escape.
    test_success(check_position_checkmate,
        (make_test_state(
            [piece(h, 1, white(king)),
             piece(g, 2, black(queen)),
             piece(f, 2, black(king))],
            white, none, State3),
         check_position(State3, checkmate))),

    % White is stalemated.
    % The white king on a1 is not in check,
    % but every possible king move is illegal.
    test_success(check_position_stalemate,
        (make_test_state(
            [piece(a, 1, white(king)),
             piece(c, 2, black(king)),
             piece(b, 3, black(queen))],
            white, none, State4),
         check_position(State4, stalemate))),

    % The halfmove clock is 100.
    % The kings are not in check and legal moves exist.
    test_success(check_position_draw_50_move,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king))],
            white, none, State5Base),
         State5Base =
            state(Board5, white, Rights5, EP5, _, Fullmove5),
         State5 =
            state(Board5, white, Rights5, EP5, 100, Fullmove5),
         check_position(State5, draw_50_move))),

    writeln('========== END CHECK POSITION TESTS ======').

% ==========================================
% CHECK MATERIAL TESTS
% ==========================================

run_check_material_tests :-
    writeln('========== CHECK MATERIAL TESTS ========='),

    % Equal material.
    test_success(check_material_equal,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king)),
             piece(a, 1, white(rook)),
             piece(a, 8, black(rook))],
            white, none, State1),
         State1 = state(Board1, _, _, _, _, _),
         check_material(Board1, 0))),

    % White has a queen; Black has a rook.
    test_success(check_material_white_ahead,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king)),
             piece(a, 1, white(queen)),
             piece(a, 8, black(rook))],
            white, none, State2),
         State2 = state(Board2, _, _, _, _, _),
         check_material(Board2, 4))),

    % Black has a queen; White has a rook.
    test_success(check_material_black_ahead,
        (make_test_state(
            [piece(e, 1, white(king)),
             piece(e, 8, black(king)),
             piece(a, 1, white(rook)),
             piece(a, 8, black(queen))],
            white, none, State3),
         State3 = state(Board3, _, _, _, _, _),
         check_material(Board3, -4))),

    writeln('========== END CHECK MATERIAL TESTS ======').


% ============================================================
% TEST HELPERS
% ============================================================

% Report a test that is expected to succeed.
test_success(Name, Goal) :-
    (   call(Goal)
    ->  format('PASS: ~w~n', [Name])
    ;   format('FAIL: ~w (expected success)~n', [Name])
    ).

% Report a test that is expected to fail.
test_failure(Name, Goal) :-
    (   \+ call(Goal)
    ->  format('PASS: ~w~n', [Name])
    ;   format('FAIL: ~w (expected failure)~n', [Name])
    ).


% ============================================================
% CUSTOM TEST BOARD HELPERS
% ============================================================

% Each piece is written as piece(File, Rank, PieceTerm).
% Example: piece(e, 2, white(pawn)).

make_test_state(Pieces, Side, EnPassant, state(Board, Side, [], EnPassant, 0, 1)) :-
    empty_test_board(EmptyBoard),
    place_test_pieces(Pieces, EmptyBoard, Board).
	
make_castling_test_state(Pieces, Side, Rights, State) :-
    make_test_state(Pieces, Side, none, state(Board, Side, _, none, 0, 1)),
    State = state(Board, Side, Rights, none, 0, 1).

empty_test_board(Board) :-
    length(Board, 64),
    fill_empty(Board).

fill_empty([]).
fill_empty([empty | Rest]) :-
    fill_empty(Rest).

place_test_pieces([], Board, Board).

place_test_pieces([piece(File, Rank, Piece) | Rest], Board0, Board) :-
    square_index(File, Rank, Index),
    replace_at(Board0, Index, Piece, Board1),
    place_test_pieces(Rest, Board1, Board).
