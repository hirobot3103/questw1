# frozen_string_literal: true

# メニュー画面表示、入力受付関連
class DispControl
  attr_accessor :ONELINEMAXLEN, :DISPHEADERROW, :DISPHEADER, :DISPMYLISTROW, :DISPMYLIST, :currentversion
  attr_reader :CAHRGAMESTART, :CHARVERSIONINFO, :CHAREXIT

  def initialize
    @CAHRGAMESTART = 's'
    @CHARVERSIONINFO = 'v'
    @CHAREXIT = 'q'

    @ONELINEMAXLEN = 55

    @DISPHEADERROW = 15
    @DISPHEADER = <<EOP
++++++++++++++++++++++++++++++++++++++++++++++++++++++

^==\\ |           ==      //====\\   |    //
|  |  |          / \\     |          |   //
|==/  |         /   \\   |           |====
|  \\ |        /=====\\   |          |   \\
===/  \\==== \/       \\  \\====/    |    \\
              ===     ==      //====\\    |    //
               |     / \\     |           |   //
               |    /   \\   |            |====
          |    |   /=====\\   |           |   \\
          \\===/  /       \\  \\====/     |    \\


++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOP

    @DISPMYLISTROW = 8
    @DISPMYLIST = <<EOP

  < MENU: >

    1) \'s\' ....... STARTTING GAME \'BLACK JACK\'
    2) \'v\' ....... VERSION INFOMATION
    3) \'q\' ....... QUITE GAME \'BLACK JACK\'

------------------------------------------------------

EOP
    @currentversion = 'ver0.0.1 BLACK JACK'
  end

  def show_char_like_hal(str, speed = 0.1, ry = true)
    if str.class == Array
      work = str
    else
      work = [str]
    end
    work.each do |tmp|
      icount = 0
      tmp += "\r" if ry.is_a?(TrueClass)
      tmp.length.times do
        print tmp.slice(icount, 1)
        sleep speed.to_f
        icount += 1
      end
    end
  end

  def show_prompt(msg, inputmode = 1)
    if msg.empty?
      msg = 'PLEASE INPUT CHAR '
      # return self.class.show_prompt(msg,1)
    end
    print "GAME MASTER >> #{msg}\n"
    if inputmode == 1
      print 'USER        >> '
      $stdin.gets.chomp
    end
  end

  def show_ese_form
    puts("#{@DISPHEADER}")
    puts("#{@DISPMYLIST}")
  end

  def excute(action)
    case action
    when @CAHRGAMESTART
      show_prompt('START GAME!!', 0)
      show_char_like_hal(['NOW ROADING  ........'], 0.1, true)
      # self.disp_cursesmode
      start_game
    when @CHARVERSIONINFO
      show_prompt("CURRENT VERISION: #{@currentversion}", 0)
    when @CHAREXIT
      show_prompt('SELECT EXIT', 0)
      show_char_like_hal(['SHUTDOWN  ........done'], 0.1, true)
      return action
    end
    action
  end

  def start_game
    gmobj = GameControl.new
    gmobj.game_play
  end

  def disp_cursesmode
    # 	# cursesを使ったゲーム画面表示、ゲーム実行クラス関連
    # 	# gamer = Game_Control.new

    #   winobj = Curses.init_screen
    #   winobj.box(?|, ?-, ?*)
    #   winobj.refresh         # リフレッシュしないとメインウィンドウの描画がうまく行かない

    #   begin
    #     s = "ブラックジャック"
    #     # win = Curses::Window.new(50, 80, 1, 1)
    #     # win.box(?|,?-,?*)
    #     swin1 = winobj.subwin(5, Curses.cols, 0, 0)
    #     swin1.box(?|, ?-, ?+)
    # #    win.setpos(win.maxy / 2, win.maxx / 2 - (s.length / 2))
    #     swin1.setpos(1, 1)
    #     swin1.addstr(s)
    #     swin1.refresh

    #     swin2 = winobj.subwin(5, Curses.cols, Curses.lines - 5, 0)
    #     swin2.box(?|, ?-, ?+)
    # #    win.setpos(win.maxy / 2, win.maxx / 2 - (s.length / 2))
    #     swin2.setpos(1, 1)
    #     swin2.addstr("")
    #     swin2.refresh

    #     loop do
    #       if swin2.getch =~ /^[a-z,A-Z,0-9]$/  # 空文字、マウスでのクリックやFキー等は受け付けない。
    #         swin2.setpos(1, 1)
    #         swin2.addstr("XXXX")
    #         swin2.refresh
    #         sleep 1
    #         break
    #       end
    #     end
    # 		Curses.refresh
    # 	ensure
    #     Curses.close_screen
    #   end
    # end

    # def testtest
    #   puts("#{@DISPHEADER}")
    #   puts("#{@DISPMYLIST}")
  end
end