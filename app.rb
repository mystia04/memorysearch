# coding: UTF-8

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sqlite3'

ActiveRecord::Base.configurations = YAML.load_file('db/database.yml')
ActiveRecord::Base.establish_connection(:development)

class Station < ActiveRecord::Base
end

get '/' do
    @stations = Station.all
    erb :index
end

get '/input_main' do
   erb :input 
end

post '/input_station' do
    $id_st = params[:id_st]
    checkid = Station.where("mem_id like ?", $id_st)
    checkid.each do |sta|
        @chkid = sta.mem_id
    end
    if @chkid == $id_st then
        redirect 'idError'
    end
    @num = 0
    number_st = params[:number_st]
    @numst = number_st.to_i
    $finst = @numst + 2
    $start_st = params[:start_st]
    $finish_st = params[:finish_st]
    if @numst > 1000 then
        redirect 'tooMuchStation'
    end
    erb :input_station
end

post '/input_station_test' do
    @num = params[:number_st]
    erb :test
end

post '/confirm_station' do
    stations = params[:st]
    station_in = stations.join(",")
    station_sf = $start_st + "," + $finish_st
    station = Station.new
    station.mem_id = $id_st
    station.sf_station = station_sf
    station.in_station = station_in
    station.save
    "ID:(#{$id_st})に#{$finst}駅登録しました。(開始終了駅[#{station_sf}],駅[#{station_in}])"
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

get '/searchtest' do
    first = params[:first]
    last = params[:last]
    st_first = first + "," + last
    st_last = last + "," + first
    @stations = Station.where("sf_station like ? or sf_station like ?", st_first, st_last)
    erb :index
end

get '/findtest' do
    @stations = Station.where("mem_id like ?", "12345678")
    erb :index
end
