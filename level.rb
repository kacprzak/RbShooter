# -*- coding: utf-8 -*-

require './game_objects'

class Level < Chingu::GameState
  attr_reader :player, :images

  def initialize(options = {})
    super
    self.input = { :p => :pause_level, :escape => :show_menu }

    @parallax = Chingu::Parallax.create(:x => 0, :y => 0,
                                        :rotation_center => :top_left)
    @parallax << {:image => Gosu::Image['starscape.png'],
      :repeat_y => true,
      :damping => 5, :zorder => 1}

    @player = Player.create(:x => 50, :y => $window.height / 2)
    @player.input = {:holding_left => :move_left,
      :holding_right => :move_right,
      :holding_up => :move_up,
      :holding_down => :move_down,
      :space => :fire}

    @number_of_enemies = 3

    @font = Gosu::Font.new($window, "verdana", 30)
  end

  def pause_level
    push_game_state(Chingu::GameStates::Pause, :finalize => false)
  end

  def show_menu
    push_game_state(Menu, :finalize => false)
  end

  def update
    @parallax.camera_x += 1 # * $window.dt/16.6

    PlayerBullet.each_collision(Enemy) do |b, e|
      Explosion.create(:x => b.x, :y => b.y)
      e.hull -= b.damage
      b.destroy!
    end

    PlayerBullet.each_collision(EnemyBullet) do |p, e|
      p.destroy!
      e.destroy!
    end

    EnemyBullet.each_collision(Player) do |b, p|
      Explosion.create(:x => b.x, :y => b.y)
      p.hull -= b.damage
      b.destroy!
    end

    if Enemy.size < @number_of_enemies
      Enemy.create(:x => $window.width, :y => rand($window.height - 60) + 30)
    end

    @number_of_enemies += 1 if player.points > @number_of_enemies * 5

    super

    if player.hull <= 0
      close # invokes pop_game_state
    end
  end

  def draw
    @font.draw("fps: #{$window.fps}", $window.width - 100, 10, 155, 1.0)
    @font.draw("Objects: #{game_objects.size}", 20, 10, 155, 1.0)
    @font.draw("Hull: #{@player.hull}", 20, 40, 155, 1.0)
    @font.draw("Points: #{@player.points}", 20, $window.height - 40, 155, 1.0)
    @font.draw("Enemies: #{@number_of_enemies}",
               $window.width - 150, $window.height - 40, 155, 1.0)
    super
  end

  def finalize
    game_objects.destroy_all
    Player.destroy_all
    Enemy.destroy_all
    PlayerBullet.destroy_all
    EnemyBullet.destroy_all
    puts "You're dead. Buahahahaha! Points: #{@player.points}"
  end
end
