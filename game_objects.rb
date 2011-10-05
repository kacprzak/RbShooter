# -*- coding: utf-8 -*-

require 'gosu'
require 'chingu'

class Player < Chingu::GameObject
  attr_accessor :hull, :points
  traits :velocity, :collision_detection, :bounding_box

  def initialize(options={})
    super(options.merge(:image => Gosu::Image['player.png']))
    self.angle = 90
    self.hull = 100
    @points = 0
    cache_bounding_box
  end

  def update
    self.velocity_x *= 0.95
    self.velocity_y *= 0.95

    self.x %= $window.width
    self.y %= $window.height
  end

  def fire
    PlayerBullet.create(:x => x + 20, :y => y)
  end

  def move_left
    self.velocity_x -= 0.5
  end

  def move_right
    self.velocity_x += 0.5
  end

  def move_up
    self.velocity_y -= 0.5
  end

  def move_down
    self.velocity_y += 0.5
  end
end


class Bullet < Chingu::GameObject
  traits :velocity, :collision_detection, :bounding_box

  def initialize(options={})
    self.zorder = 99
    super(options)

    cache_bounding_box
  end

  def update
    destroy! if outside_window?
  end
end


class EnemyBullet < Bullet
  attr_reader :damage

  def setup
    self.image = Gosu::Image['bullet1.png']
    @damage = 5
  end
end


class PlayerBullet < Bullet
  attr_reader :damage

  def setup
    self.image = Gosu::Image['bullet2.png']
    self.angle = 90
    self.velocity_x = 5
    @damage = 25
  end
end


class Enemy < Chingu::GameObject
  attr_accessor :hull
  traits :velocity, :timer, :collision_detection, :bounding_box

  def initialize(options={})
    super(options.merge(:image => Gosu::Image['enemy1.png']))
    self.angle = -90
    self.velocity_x = -1
    @hull = 100
    @fire_rate = 2000 # 2 sekundy

    every(@fire_rate) do
      bullet = EnemyBullet.create(:x => x, :y => y)
      player = $window.current_game_state.player
      angle = Gosu::angle(x, y, player.x, player.y)
      bullet.angle = angle
      bullet.velocity_x = Gosu::offset_x(angle, 3)
      bullet.velocity_y = Gosu::offset_y(angle, 3)
    end

    cache_bounding_box
  end

  def update
    self.x %= $window.width
    self.y %= $window.height

    if @hull <= 0
      destroy!
      $window.current_game_state.player.points += 1
      Explosion.create(:x => x, :y => y, :factor => 2)
    end
  end

  def destroy
    stop_timers
    super
  end
end


class Explosion < Chingu::GameObject
  trait :animation, :delay => 25, :loop => false

  def setup
    @dead = false
  end

  def update
    if @dead
      destroy!
      return
    end

    self.image = animation.next if animation
    @dead = true if animation.last_frame?
  end
end
