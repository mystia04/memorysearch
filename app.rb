# coding: UTF-8

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sqlite3'
require 'erubis'

ActiveRecord::Base.configurations = YAML.load_file('db/database.yml')
ActiveRecord::Base.establish_connection(:development)

class Station < ActiveRecord::Base
end

# XSS対策のエスケープ
set :erb, :escape_html => true

get '/' do
    erb :mainpage    
end

get '/alldatadebugapp' do
    # デバッグ用データベース全表示
    @stations = Station.all
    erb :searchResult
end

get '/input_main' do
   erb :input 
end

post '/input_station' do
    
    # IDのパラメータをサニタイズして小文字化して取得
    tmpStr = ERB::Util.html_escape(params[:id_st]).downcase
    
    # IDパラメータの検証
    if tmpStr !~ /^[0-9a-z]+$/
        redirect 'idError'
    end
    
    # IDのパラメーター受け取り(@id_st)
    @id_st = tmpStr
    
    # ID重複チェック
    #checkid = Station.where("mem_id like ?", @id_st)
    
    #checkid.each do |sta|
    #    @chkid = sta.mem_id
    #end
    
    #if @chkid == @id_st then
    
    # ID重複チェック
    # existsを使うとキレイにかける
    if Station.exists?(:mem_id => @id_st)
        # 重複時処理
        redirect 'idError'
    end
    
    # 繰り返し用変数
    @num = 0
    
    # 駅数
    # 各パラメータをサニタイズして取得
    number_st = ERB::Util.html_escape(params[:number_st])
    @numst = number_st.to_i
    @start_st = ERB::Util.html_escape(params[:start_st])
    @finish_st = ERB::Util.html_escape(params[:finish_st])
    
    # いたずら防止(流石に1000駅以上のメモリールートはない)
    if @numst > 1000 then
        redirect 'tooMuchStation'
    end
    
    
    erb :input_station
end

post '/confirm_station' do
    # パラメータ受け取り
    stations = params[:st]
    @id_st = params[:id_st]
    
    # 空欄チェック
    checknull = stations.any?{|w| w.empty?}
    if checknull == true then
        redirect 'emptyError'
    end
    
    # 開始終了駅抽出
    @start_st = ERB::Util.html_escape(params[:start_st])
    @finish_st = ERB::Util.html_escape(params[:finish_st])
    @numst = stations.length
    @num = 0
    
    
    # データベース記録用に記録駅の文字列化
    @station_in = stations.join(",")
    
    # 記号を削除
    @station_in = @station_in.gsub(/[!"#$%&'()\*\+\-\.\/:;<=>?@\[\\\]^_`{|}~]/,"")
    
    # 前構成の残骸(デバッグ用)
    # station_sf = $start_st + "," + $finish_st
    # station = Station.new
    # station.mem_id = $id_st
    # station.sf_station = station_sf
    # station.in_station = @station_in
    # station.save
    erb :addResult
end

post '/addFinish' do
    # パラメータ受け取り
    id = ERB::Util.html_escape(params[:id_st])
    start_st = ERB::Util.html_escape(params[:start_st])
    finish_st = ERB::Util.html_escape(params[:finish_st])
    station_in = ERB::Util.html_escape(params[:station_in])
    
    # 一応再度記号を削除
    station_in = station_in.gsub(/[!"#$%&'()\*\+\-\.\/:;<=>?@\[\\\]^_`{|}~]/,"")
    
    # DB記録前処理
    sf_station = start_st + "," + finish_st
    station = Station.new
    station.mem_id = id
    station.sf_station = sf_station
    station.in_station = station_in
    station.save
    
    erb :addCompleate
end


get '/emptyError' do
    "駅名に空白があります"
end

get '/error' do
    "なにかがおかしいよ"
end

get '/tooMuchStation' do
    "駅数が多すぎます"
end

get '/idError' do
    "ID重複 : 既に同じIDのルートが登録されています"
end

# 検索のとこ
get '/search' do
    erb :search
end 

# 検索結果表示
post '/searchResult' do
    first = params[:first]
    last = params[:last]
    st_first = first + "," + last
    st_last = last + "," + first
    @stations = Station.where("sf_station like ? or sf_station like ?", st_first, st_last)
    erb :searchResult
end

get '/findtest' do
    @stations = Station.where("mem_id like ?", "12345678")
    erb :index
end