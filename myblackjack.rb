# frozen_string_literal: true

# require 'curses'
require_relative './lib/disper'
require_relative './lib/gamer3'

if __FILE__ == $PROGRAM_NAME
  # 初期画面の表示
  disp = DispControl.new
  disp.show_char_like_hal(['....... SYSTEM ALL GREEN ', '........ ENJOY PLAY !!   '], 0.1, true)
  disp.show_ese_form
  # USERからの入力キーによって処理を振り分ける。
  loop do
    inputchar = disp.show_prompt('')
    rtnstr = disp.excute(inputchar)
    return if disp.CHAREXIT == rtnstr
  end
end
