require 'ruby2d'
require 'gosu'

ball_bounce_sound = Gosu::Sample.new("ball_bounce.mp3")

set title: "Break Out", background: 'navy'
set width: 680

def initialize_game
  @bullet_speed = 10
  @bullet_angle = 15
  @planex_speed = 0
  @game_over = false

  @blocks = []
  width = get :width
  height = get :height

  @plane = Rectangle.new(
    x: width / 2 - 50, y: 400,
    width: 100, height: 10,
    color: 'teal',
    z: 1
  )

  @circle_edge_1 = Circle.new(
    x: width / 2 - 50, y: 405,
    radius: 5,
    sectors: 32,
    color: 'teal',
    z: 0
  )
  
  @circle_edge_2 = Circle.new(
    x: width / 2 + @plane.width - 50, y: 405,
    radius: 5,
    sectors: 32,
    color: 'teal',
    z: 0
  )
  
  for i in 0..3
    for j in 0..10
      block = Rectangle.new(
        x: 10 + j * 60, y: 10 + i * 30,
        width: 50, height: 20,
        color: 'lime',
        z: 1
      )
      @blocks << block
    end
  end

  @bullet = Circle.new(
    x: width / 2, y: 380,
    radius: 9,
    sectors: 32,
    color: 'red',
    z: 10
  )

  @triangles = []
  rightmostangle = 0
  index = 0
  while rightmostangle < width
    triangle = Triangle.new(
      x1: 0 + (index * 50), y1: 480,
      x2: 50 + (index * 50), y2: 480,
      x3: 25 + (index * 50), y3: 430,
      color: 'gray',
      z: 10
    )
    @triangles << triangle
    rightmostangle = 50 + (index * 50)
    index += 1
  end
end

def reset_game
  @game_objects.each { |obj| obj.remove }
  @game_over_text.remove if @game_over_text
  initialize_game
end

initialize_game

on :key_held do |event|
  if event.key == 'a'
    @planex_speed = -9
  elsif event.key == 'd'
    @planex_speed = 9
  end
end

on :key_up do |event|
  if ['a', 'd'].include?(event.key)
    @planex_speed = 0
  end
end

update do
  @game_objects = [@bullet, @plane, @circle_edge_1, @circle_edge_2] + @blocks + @triangles

  @blocks.each do |block|
    if @bullet.x >= block.x && @bullet.x <= block.x + block.width && @bullet.y >= block.y && @bullet.y <= block.y + block.height
      ball_bounce_sound.play
      block.remove
      @blocks.delete(block)
      @bullet_angle = -@bullet_angle
      break
    end
  end

  if @plane.x + @planex_speed < 0 || @plane.x + @planex_speed + @plane.width > get(:width)
    @planex_speed = 0
  else
    @plane.x += @planex_speed
    @circle_edge_1.x += @planex_speed
    @circle_edge_2.x += @planex_speed
  end

  unless @game_over
    @bullet.x += @bullet_speed * Math.cos(@bullet_angle * Math::PI / 180)
    @bullet.y -= @bullet_speed * Math.sin(@bullet_angle * Math::PI / 180)

    if @bullet.x <= 0 || @bullet.x >= get(:width)
      ball_bounce_sound.play
      @bullet_angle = 180 - @bullet_angle
    end

    if @bullet.y <= 0
      ball_bounce_sound.play
      @bullet_angle = -@bullet_angle
    end

    if @bullet.x >= @plane.x && @bullet.x <= @plane.x + @plane.width && @bullet.y >= @plane.y
      ball_bounce_sound.play
      @bullet_angle = -@bullet_angle
    end

    @triangles.each do |triangle|
      if @bullet.x >= triangle.x1 && @bullet.x <= triangle.x2 && @bullet.y >= triangle.y3 && @bullet.y <= triangle.y1
        @game_over = true
        @game_objects.each { |obj| obj.remove }
        @game_over_text = Text.new('You lost! Click to restart.(Press "r")', x: get(:width) / 2 - 100, y: 20, size: 20, z: 20, color: 'red')
        break
      end
    end
  end
end

on :key_down do |_event|
  if _event.key == 'r'
    if @game_over
      reset_game
    end
  end
end

show
