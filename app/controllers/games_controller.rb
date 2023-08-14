# class GamesController < ApplicationController
#   def new
#     @letters = Array.new(10) { ('A'..'Z').to_a.sample }
#   end

#   def score
#   end
# end



# require 'json'
# require 'open-uri'

# class GamesController < ApplicationController
#   def new
#     @letters = Array.new(10) { ('A'..'Z').to_a.sample }
#     session[:letters] = @letters
#   end

#   def score
#     @word = params[:word].upcase
#     @letters = session[:letters]
#     if !word_from_grid?(@word, @letters)
#       @message = '💀 ya pas ces lettres dans la grille'
#     elsif !english_word?(@word)
#       @message = "🤬Ya les lettres mais c'est ps un mot english"
#     else
#       @message = '🤩 Congrats bitch ! 🎉'
#       update_score(@word.length * 2)
#     end
#   end

#   # private

#   def word_from_grid?(word, letters)
#     word.chars.all? { |char| word.count(char) <= letters.count(char) }
#   end

#   def english_word?(word)
#     return false if word.blank?

#     begin
#       response = open("https://wagon-dictionary.herokuapp.com/#{word}")
#       json = JSON.parse(response.read)
#       puts json.inspect  # Pour voir la réponse de l'API
#       json['found']
#     rescue => e
#       puts e.message     # Pour voir les erreurs, le cas échéant
#       false
#     end
#   end

#   def update_score(points)
#     session[:score] ||= 0
#     session[:score] += points
#   end
# end



require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    session[:letters] = @letters
  end

  def score
    @word = params[:word].upcase
    @letters = session[:letters]
    result = run_game(@word, @letters)
    @message = result[:message]
    update_score(result[:score])
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def word_from_grid?(word, grid)
    word.chars.all? { |char| word.count(char) <= grid.count(char) }
  end

  def run_game(attempt, grid)
    result = {}
    score_and_message = score_and_message(attempt, grid)
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    result
  end

  def score_and_message(attempt, grid)
    if word_from_grid?(attempt, grid)
      if english_word?(attempt)
        score = attempt.length * 2
        [score, '🤩 Congrats bitch ! 🎉']
      else
        [0, "🤬Ya les lettres mais c'est ps un mot english"]
      end
    else
      [0, '💀 ya pas ces lettres dans la grille']
    end
  end

  def english_word?(word)
    puts "Verifying word: #{word}"
    return false if word.blank?

    begin
      response = open("https://wagon-dictionary.herokuapp.com/#{word}")
      json = JSON.parse(response.read)
      puts "API Response: #{json.inspect}"  # Pour voir la réponse de l'API
      json['found']
    rescue => e
      puts "Error: #{e.message}"     # Pour voir les erreurs, le cas échéant
      false
    end
end


  def update_score(points)
    session[:score] ||= 0
    session[:score] += points
  end
end
