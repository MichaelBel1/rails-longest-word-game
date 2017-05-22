require 'open-uri'
class GameController < ApplicationController
  def score
    @end_time = Time.now.to_i
    @attempt = params[:word]
    @translation = translate(@attempt)
    @start = params[:start_time].to_i
    @score = run_game(@attempt, params[:grid], @start, @end_time)
  end

  def game
    @grid = generate_grid(10).join(" ")
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def translate(attempt)
    key = "5d237139-27f2-4965-b439-a521d303a27c"
    yo = "/translation/text/translate?source=en&target=fr&key=#{key}&input=#{attempt}"
    response = open("https://api-platform.systran.net" + yo)
    json = JSON.parse(response.read.to_s)
    if attempt == json["outputs"][0]["output"]
      return nil
    else
      return json["outputs"][0]["output"]
    end
  end

  def correct_attempt?(attempt, grid)
    attempt.split("").all? { |letter| attempt.count(letter) <= grid.count(letter) }
  end

  def run_game(attempt, grid, start_time, end_time)
    @results = {}
    @results[:time] = end_time - start_time
    @results[:translation] = translate(attempt)
    @results[:score] = 0
    if !correct_attempt?(attempt.upcase, grid.split)
      @results[:message] = "not in the grid"
    elsif translate(attempt) == nil
      @results[:message] = "not an english word"
    else
      @results[:message] = "well done"
      @results[:score] = (attempt.length*10) - @results[:time].to_i
    end
    return @results
  end


end

