# frozen_string_literal: true

require_relative './position'

WHITE_STONE = 'W'
BLACK_STONE = 'B'
BLANK_CELL = '-'

def output(board)
  puts "  #{Position::COL.join(' ')}"
  board.each.with_index do |row, i|
    print Position::ROW[i]
    row.each do |cell|
      case cell
      when WHITE_STONE then print ' ○'
      when BLACK_STONE then print ' ●'
      else print ' -'
      end
    end
    print "\n"
  end
end

def copy_board(to_board, from_board)
  from_board.each.with_index do |cols, row|
    cols.each.with_index do |cell, col|
      to_board[row][col] = cell
    end
  end
end

def put_stone!(board, cell_ref, stone_color, execute = true) # rubocop:disable Style/OptionalBooleanParameter
  pos = Position.new(cell_ref)
  raise '無効なポジションです' if pos.invalid?
  raise 'すでに石が置かれています' unless pos.stone_color(board) == BLANK_CELL

  # コピーした盤面にて石の配置を試みて、成功すれば反映する
  copied_board = Marshal.load(Marshal.dump(board))
  copied_board[pos.row][pos.col] = stone_color

  turn_succeed = false
  Position::DIRECTIONS.each do |direction|
    next_pos = pos.next_position(direction)
    turn_succeed = true if turn!(copied_board, next_pos, stone_color, direction)
  end

  copy_board(board, copied_board) if execute && turn_succeed

  turn_succeed
end

# target_posはひっくり返す対象セル
def turn!(board, target_pos, attack_stone_color, direction)
  return false if target_pos.out_of_board?
  return false if target_pos.stone_color(board) == attack_stone_color
  return false if target_pos.stone_color(board) == BLANK_CELL

  next_pos = target_pos.next_position(direction)
  if (next_pos.stone_color(board) == attack_stone_color) || turn!(board, next_pos, attack_stone_color, direction)
    board[target_pos.row][target_pos.col] = attack_stone_color
    true
  else
    false
  end
end

def finished?(board)
  !placeable?(board, WHITE_STONE) && !placeable?(board, BLACK_STONE)
end

def placeable?(board, attack_stone_color)
  board.each.with_index do |cols, row|
    cols.each.with_index do |cell, col|
      next unless cell == BLANK_CELL # 空セルでなければ判定skip

      position = Position.new(row, col)
      return true if put_stone!(board, position.to_cell_ref, attack_stone_color, false)
    end
  end
  false
end

def count_stone(board, stone_color)
  board.flatten.count { |n| n == stone_color }
end
