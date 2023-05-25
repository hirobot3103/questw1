# frozen_string_literal: true

class GameControl

	def initialize
		@ROLE_DEALER = 0
		@ROLE_USER = 1
		@ROLE_OTHERPLAYER_A = 2
		@ROLE_OTHERPLAYER_B = 3

		# キャラ設定
		@participants_set = Array.new(4)
		@participants_set = [User.new(@ROLE_USER, 'あなた'),
			 										OtherPlayer.new(@ROLE_OTHERPLAYER_A, 'プレーヤー１'),
													OtherPlayer.new(@ROLE_OTHERPLAYER_B, 'プレーヤー２')].shuffle
		@participants_set.unshift(Dealer.new(@ROLE_DEALER, 'ディーラー'))
		@cd = Cards.new

	end

	def game_play
		puts '------------------------------'
		puts 'ブラックジャックはじりはじまり'
    
		dealnum = 0
		firstturn = 1
		rtncard = []
		crrntsum = 0
		gc = 0
		@card_deck = @cd.shuflfe_cards
		loop do
			break if @card_deck.length.to_i.zero?
			
			# ホールド、２１越えなどの確認
			count = 0
			@participants_set.each do |holdflg|
				flg = holdflg.mygame_stat[:stat_hold][0].to_i
				if flg == 1 || flg == -1 || flg == 2 
					count += 1
				end
			end
			if count == 4
				showdown(@participants_set)
				break
			end

			@participants_set.each do |part|
				sleep 0.1
				next unless part.mygame_stat[:stat_hold][0].to_i.zero?

				if part.mygame_stat[:mycardsum][0].zero?
					dealnum = 2
					firstturn = 1
				else
					dealnum = 1
					firstturn = 0
				end
				rtncard = part.get_card(0, @card_deck, dealnum)
				trumpinfo = ''
				rtncard.each do |carddata| 
					# puts carddata
					mark, val = @cd.devided_carddata(carddata)

					if part.mygame_stat[:roleid] == @ROLE_DEALER && firstturn == 1
						trumpinfo = @cd.exchage_cardtag(mark, val)
						break
					else
						trumpinfo += @cd.exchage_cardtag(mark, val)
					end
				end
				if part.mygame_stat[:roleid] == @ROLE_DEALER && firstturn == 1
					puts "#{part.mygame_stat[:nameid]}の最初の手札は、#{trumpinfo}　ともう一つは伏せてあります。"
					firstturn = 0
				else
					if part.mygame_stat[:roleid] == @ROLE_USER
						infostr = trumpinfo
					else
						infostr = '伏せてあります。'
						# infostr = trumpinfo
					end
					puts "受け取った#{part.mygame_stat[:nameid]}の手札は、#{infostr}　"
				end
				# 合計を出す。
				crrntsum = part.mygame_stat[:mycardsum][0]
				nowsum = cal_sum(part.mycards[0])
				diff = 21 - nowsum[0].to_i
				diff2 = 21 - nowsum[1].to_i
				if diff.to_i.zero? || diff2.to_i.zero?
					if dealnum == 2 
						part.mygame_stat[:stat_hold][0] = 2
					else
						part.mygame_stat[:stat_hold][0] = 1
					end
					if crrntsum.to_i + nowsum[0].to_i == 21
						part.mygame_stat[:mycardsum][0] += nowsum[0].to_i
					elsif crrntsum.to_i + nowsum[1].to_i == 21
						part.mygame_stat[:mycardsum][0] += nowsum[1].to_i
					end
					part.mygame_stat[:stat_hold][0] = 1
					puts "現在の合計は#{part.mygame_stat[:mycardsum][0]}です。" if part.mygame_stat[:roleid] == @ROLE_USER
					puts '２１となりましたので、他のプレーヤーが勝負するまでお待ちください。' if part.mygame_stat[:roleid] == @ROLE_USER
					next
				end
				if crrntsum.to_i + nowsum[0].to_i > 21 && crrntsum.to_i + nowsum[1].to_i < 21
					part.mygame_stat[:mycardsum][0] += nowsum[1].to_i
				elsif crrntsum.to_i + nowsum[1].to_i > 21 && crrntsum.to_i + nowsum[0].to_i < 21
					part.mygame_stat[:mycardsum][0] += nowsum[0].to_i
				else
					if diff <= diff2
						part.mygame_stat[:mycardsum][0] += nowsum[0].to_i
					elsif diff > diff2
						part.mygame_stat[:mycardsum][0] += nowsum[1].to_i
					end
				end
				puts "現在の合計は#{part.mygame_stat[:mycardsum][0]}です。" if part.mygame_stat[:roleid] == @ROLE_USER

				if part.mygame_stat[:mycardsum][0] > 17 && part.mygame_stat[:roleid] == @ROLE_DEALER
					part.mygame_stat[:stat_hold][0] = 1
					next
				end
				if part.mygame_stat[:mycardsum][0] > 21
					part.mygame_stat[:stat_hold][0] = -1
					puts "合計２１を超えましたので、#{part.mygame_stat[:nameid]}の負けです。"
          next
				end
				gc = 0
				if part.mygame_stat[:roleid] == @ROLE_USER
					while gc == 0
						print 'もう一枚手札を受け取りますか？(Y/N)'
						ichar = $stdin.gets.chomp
						# ichar = 'Y'
						if ichar.to_s == 'Y'
							gc = 1
							break
						elsif ichar.to_s == 'N'
              part.mygame_stat[:stat_hold] = 1
							puts '他のプレーヤーが勝負するまでお待ちください。'
							gc = 1
						end
					end
				else
					# カードを追加するかどうかの判断（CPU）
					unless part.mygame_stat[:roleid] == @ROLE_DEALER
						random = Random.new(164)
						if random.rand(12) > 9
  						part.mygame_stat[:stat_hold] = 1
							next
						end
						if (19 < part.mygame_stat[:mycardsum][0] && part.mygame_stat[:mycardsum][0] <= 21)
							part.mygame_stat[:stat_hold] = 1
							next
						end 
					end
				end
			end
		end
		puts 'ブラックジャックおしまい'
	end

	def cal_sum(mycarddeckes)
		sum = 0
		summax = 0
		mycarddeckes.each do |tmp|
    	_m, val = @cd.devided_carddata(tmp)
			if (val.to_i - 10) > 0 
				val = 10.to_i
			end
			sum += val.to_i
			if val.to_i == 1
				summax += val.to_i + 10
			else
				summax += val.to_i
			end
		end
		[sum, summax]
	end

	def showdown(scoredata)
		puts '　　　　'
		puts '全員、揃ったようです。'
		puts '-------------------------------------'
		puts 'デーラーとの勝負です。手札を確認します。'
		dealer_score =scoredata[0].mygame_stat[:mycardsum][0].to_i 
		scoredata.each.with_index do |part, index|
			sleep 0.1
			next if index.to_i.zero?
			myscore = part.mygame_stat[:mycardsum][0].to_i
			if myscore.to_i > 21
				puts "ディーラーの点数は#{dealer_score}："
				puts "#{part.mygame_stat[:nameid]}の点数#{myscore}：負けです。"
				puts '-------------------------------------'
				next
			end
			if myscore.to_i == 21 && part.mygame_stat[:stat_hold][0].to_i == 2
				puts "ディーラーの点数は#{dealer_score}："
				puts "#{part.mygame_stat[:nameid]}の点数#{myscore}ブラックジャックです：勝ちです。"
				puts '-------------------------------------'
				next
			end
			if myscore.to_i == dealer_score
				puts "ディーラーの点数は#{dealer_score}："
				puts "#{part.mygame_stat[:nameid]}の点数#{myscore}：引き分けです。"
				puts '-------------------------------------'
				next
			end
			diffdealer = 21 - dealer_score
			diffuser = 21 - myscore.to_i

			if diffdealer > diffuser && dealer_score <= 21
				puts "ディーラーの点数は#{dealer_score}："
				puts "#{part.mygame_stat[:nameid]}の点数#{myscore}：勝ちです。"
				puts '-------------------------------------'
				next
			elsif diffdealer < diffuser && dealer_score <= 21
				puts "ディーラーの点数は#{dealer_score}："
				puts "#{part.mygame_stat[:nameid]}の点数#{myscore}：負けです。"
				puts '-------------------------------------'
				next
			else
				puts "ディーラーの点数は#{dealer_score}："
				puts "#{part.mygame_stat[:nameid]}の点数#{myscore}：勝ちです。"
				puts '-------------------------------------'
				next
			end
		end
	end
end

class Participants2

	attr_accessor :mygame_stat, :mycards, :currentcard

	def initialize(role, name)
		@mygame_stat = {
		roleid: role,   # ゲーム参加者の役割
		nameid: name,   # ゲーム参加者の名前
		stat_hold: [0, -1],  # ホールド状態 (1　勝負まち、0　ゲーム中、-1　21を超えている)
		stat_dbl: [0, -1],   # ダブル
		stat_split: [0, -1], # スプリット
		stat_srnd: [0, -1],  # サレンダー
		mycardsum: [0, -1]   # 手札の合計
		}
		@mycardsum = 0 # 合計値
		@mycards = [[], []] # 自身の手札 index:0 スプリットなしの状態 index:1 スプリット後のもう一つの手札
		@currentcard = []
	end

	# 手札を受け取る
	def get_card(type_card, cards, deal_cards_count)
		@currentcard = cards.shift(deal_cards_count)
		@mycards[type_card] = @currentcard
		@currentcard
	end
end

class Dealer < Participants2
end

class User < Participants2
end

class OtherPlayer < Participants2
end

class Cards

	def initialize
		@TRUMPCARDS = [
			11, 12, 13, 14, 15, 16, 17, 18, 19, 110, 111, 112, 113,
			21, 22, 23, 24, 25, 26, 27, 28, 29, 210, 211, 212, 213,
			31, 32, 33, 34, 35, 36, 37, 38, 39, 310, 311, 312, 313,
			41, 42, 43, 44, 45, 46, 47, 48, 49, 410, 411, 412, 413
		]
	end

	def devided_carddata(datas)
		lens = datas.to_s.length
		marks = datas.to_s.slice(0, 1)
		vals = datas.to_s.slice(1, lens - 1)
		[marks, vals]
	end

	# カードの絵柄、値を示す文字列を取得
	def exchage_cardtag(marks, vals)

		# marks,vals = self::devided_carddata(kalta_val)
		if marks == '1'
			cardstring = 'スペード'
		elsif marks == '2'
			cardstring = 'ダイヤ'
		elsif marks == '3'
			cardstring = 'クラブ'
		elsif marks == '4'
			cardstring = 'ハート'
		else
			cardstring = '------'
		end
		cardstring += ' '
		if vals == '1'
			cardstring  += 'A'
		elsif vals == '11'
			cardstring  += 'J'
		elsif vals == '12'
			cardstring  += 'Q'
		elsif vals == '13'
			cardstring  += 'K'
		else
			cardstring  += "#{vals}"
		end
	end

	def card_info(carddeck)

	end 
	# カードをシャッフルする
	def shuflfe_cards
		@TRUMPCARDS.shuffle
	end

	# カードを配る
	def deal_cards(cards, dealnum)
		cards.shift(dealnum)
	end
end

if __FILE__ == $PROGRAM_NAME
	gmobj = GameControl.new
	gmobj.game_play
end