# frozen_string_literal: true

require_relative './lib/reversi_methods'

class Reversi
  include ReversiMethods

  QUIT_COMMANDS = %w[quit exit q].freeze

  def initialize
    # boardは盤面を示す二次元配列
    @board = Array.new(8) { Array.new(8, BLANK_CELL) }
    @board[3][3] = WHITE_STONE # d4
    @board[4][4] = WHITE_STONE # e5
    @board[3][4] = BLACK_STONE # d5
    @board[4][3] = BLACK_STONE # e4

    @current_stone = BLACK_STONE
  end

  def run # rubocop:disable Metrics/MethodLength
    loop do
      output(@board)

      if finished?(@board)
        puts '試合終了'
        puts "白○:#{count_stone(@board, WHITE_STONE)}"
        puts "黒●:#{count_stone(@board, BLACK_STONE)}"
        break
      end

      unless placeable?(@board, @current_stone)
        puts '詰みのためターンを切り替えます'
        toggle_stone
        next
      end

      print "command? (#{@current_stone == WHITE_STONE ? '白○' : '黒●'}) > "
      command = gets.chomp
      break if QUIT_COMMANDS.include?(command)

      begin
        if put_stone(@board, command, @current_stone)
          puts '配置成功、次のターン'
          toggle_stone
        else
          puts '配置失敗、ターン据え置き'
        end
      rescue StandardError => e
        puts "ERROR: #{e.message}"
      end
    end

    puts 'finished!'
  end

  private

  def toggle_stone
    @current_stone = @current_stone == WHITE_STONE ? BLACK_STONE : WHITE_STONE
  end
end

Reversi.new.run if __FILE__ == $PROGRAM_NAME
