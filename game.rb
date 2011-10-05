#!/usr/bin/env ruby1.9.1
# -*- coding: utf-8 -*-

# A simpe space shooter game written to play with gosu and chingu libs.
#
# by Marcin Kacprzak

ROOT_PATH = File.dirname(File.expand_path(__FILE__))

require 'gosu'
require 'chingu'
require './level'

class Game < Chingu::Window
  def initialize(fullscreen = false)
    super(800, 600, fullscreen)
    self.caption = "RbShooter"

    retrofy
    push_game_state(Chingu::GameStates::FadeTo.new(Intro), :speed => 10)
  end
end


class Chingu::GameState
  def draw_on_center(font, text, y_offset = 0, z_order = 0)
    return if $window.nil?
    font.draw(text,
              ($window.width/2 - font.text_width(text)/2),
              $window.height/2 - font.height + y_offset,
              z_order)
  end

  def draw_fog
    return if $window.nil?
    color = Gosu::Color.new(200,0,0,0)
    $window.draw_quad(0, 0, color,
                      $window.width, 0, color,
                      $window.width, $window.height, color,
                      0, $window.height, color, Chingu::DEBUG_ZORDER)
  end
end


class Intro < Chingu::GameState
  def initialize(options = {})
    super
    @big_font = Gosu::Font.new($window, "verdana", 50)
    @small_font = Gosu::Font.new($window, "verdana", 20)
    @title = $window.caption
    @author = "by yattering"
    self.input = {:space => :go_to_menu, :escape => :close_game}
  end

  def go_to_menu
    push_game_state(Chingu::GameStates::FadeTo.new(Menu), :speed => 20)
  end

  def draw
    draw_on_center(@big_font, @title)
    draw_on_center(@small_font, @author, 20)
  end
end


class Menu < Chingu::GameState
  def initialize(options = {})
    super
    @menu_items = [:start,
                   :settings,
                   :exit]
    @current_item = @menu_items.first

    @big_font = Gosu::Font.new($window, "verdana", 50)
    @small_font = Gosu::Font.new($window, "verdana", 40)

    self.input = { :return => :item_selected,
      :down => :next_item,
      :up => :previous_item,
      :escape => :close }
  end

  def item_selected
    case @current_item
    when :start
      if above_level?
        pop_game_state(:setup => false)
      else
        push_game_state(Level)
      end
    when :settings
      puts "not implemented"
    when :exit
      if above_level?
        #game_state_manager.pop_until_game_state(previous_game_state)
        pop_game_state(:setup => false)
        pop_game_state
      else
        close_game
      end
    end
  end

  def above_level?
    previous_game_state.is_a? Level
  end

  def next_item
    index = @menu_items.index(@current_item)
    @current_item = @menu_items[index + 1] if index + 1 < @menu_items.size
  end

  def previous_item
    index = @menu_items.index(@current_item)
    @current_item = @menu_items[index - 1] if index - 1 >= 0
  end

  def draw
    if above_level?
      previous_game_state.draw
      draw_fog
    end
    draw_menu
  end

  private

  def draw_menu
    height = @small_font.height
    offset = 0 - height * (@menu_items.size / 2)
    @menu_items.each do |item|
      font = (item == @current_item) ? @big_font : @small_font
      text = case item
             when :start
               above_level? ? "Resume Level" : "Start Level"
             when :settings
               "Settings"
             when :exit
               above_level? ? "Exit Level" : "Exit"
             end
      draw_on_center(font, text, offset, Chingu::DEBUG_ZORDER + 1001)
      offset += height
    end
  end
end


fullscreen = ARGV.include? "-f"
Game.new(fullscreen).show   # Start the Game update/draw loop!

