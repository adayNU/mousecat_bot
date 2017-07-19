require 'selenium-webdriver'
require 'oily_png'

class PlayMouseCat
  MOUSECAT_URL = 'https://www.playmousecat.com/'
  
  CHEESE_COLORS = {
    :cheese_one => [3432579327, 4291559679, 4291572735, 4294928127, 3429236991, 4288217343],
    :cheese_two => [3432579327, 4291559679, 4291572735, 4294928127, 3429236991, 4288217343, 4071959807, 4173737727, 4241502463, 4258542079, 4275450367, 4258476287, 4224528383, 4207554559, 4258410751, 4275384831, 4258541823, 4140314367, 3903990527, 3785763071, 3785631999, 3836488191, 3938331903, 4006030847, 4006096639, 3316066303, 4122684927, 4156698367, 4207489023, 4258345215, 4105972991, 4055051263, 4054985727, 4105841919, 4207620095, 4224790783, 4089654783, 4106628863, 4157419519, 4191236351, 3905170943, 4139659007, 4156567295, 4173606911, 4224463103, 4241567999, 4224528639, 4173803519, 4105973247, 4021103359, 3970247167, 3970181631, 4122947071, 4241633535, 4207685631, 4241699071, 4208144639, 4156501759, 4173410047, 4190384127, 4190515199, 4122750463, 3987221247, 3919522047, 3936430335, 3936495871, 3970312703, 4088999167, 4258607615, 4173344511, 4071828735, 3885508607, 3817743871, 3851757311, 3885639679, 3919456511, 3953338879, 4038077439, 4190580479, 4071697663, 3868534783, 3783795967, 3783861503, 3817809407, 3936364799, 4021168895, 4173803263, 4190777343, 4038142975, 3953404415, 3953338623, 4054854655, 3868403455, 3766756607, 3749913599, 3851626239, 4021234687, 4072090879, 3749848063, 3749979135, 4004260607, 3749979391, 3733070847, 3733005311, 3800770047, 3902613759, 4173606655, 3970312959, 4088868095, 4156632831, 4088671487, 3936168191, 3851495167, 3834652415, 3834586623, 3902416895, 4139724543, 4241436927, 4139855359, 4038011647, 3953404159, 3936299263, 3953273087, 4122619391, 4037815295, 4021038079, 4021037823, 4105776639, 4088933631, 4038208511, 3919390719, 3851560703, 3902547967, 4156436223, 4139527679, 4054920191, 4004195071, 3902482431, 3834717951, 3885836287, 4139593471, 4088868351, 4021103615, 3885574143, 3801622271, 3868468991, 3800901119, 3919587583, 3767936767, 3800835583, 3751094015, 4088737023, 4054920447, 3784845055, 3936233727, 4071763199, 4139593215, 3953207807, 3868600319, 3869059071, 4037880831, 3767018751, 3766887679, 3953469951, 3733726719, 3666158591, 3717146111, 3784779519, 3868469247, 3766822143, 3733792255, 3481149951, 3363315967, 3380289791, 3515228927, 3902744575, 3615499007, 3346407423, 3211861759, 3195084543, 3329826815, 3582600191, 3767936511, 4122553855, 3598590719, 3329499135, 3178175999, 3161398783, 3211927295, 3515163391, 3598459391, 3312656127, 3195018751, 3245416191, 3279101695, 3312721919, 3464503807, 3751028223, 3885901823, 3262258943, 3430359295, 3531219455, 3548062207, 3649315839, 3818268415, 3801687807, 3432851199, 3870436351, 4106038783, 3598525183, 3295878911, 3665765119, 3682542591, 3750175999, 3868665855]
  }
  MOUSE_COLORS = [134744319, 4173396223, 2966483199, 3499161855, 2427504895, 3371759871, 1077952767]
  MIN_DISTANCE = 25

  def self.game_over?(driver)
    driver.find_element(id: 'submitname').displayed?
  end

  def self.find_objects(picture, colors)
    object_locations = {}
    picture.height.times do |y|
      picture.row(y).each_with_index do |pixel, x|
        object_locations[pixel] = {:x => x, :y => y} if colors.include? pixel
      end
    end
    object_locations
  end

  def self.calculate_move(mouse_location, cheese_location)
    move = {}
    if mouse_location[:x] - cheese_location[:x] > MIN_DISTANCE
      move[:move] = :arrow_left
      move[:distance] = (mouse_location[:x] - cheese_location[:x]).abs
    elsif mouse_location[:x] - cheese_location[:x] < -MIN_DISTANCE
      move[:move] = :arrow_right
      move[:distance] = (mouse_location[:x] - cheese_location[:x]).abs
    elsif mouse_location[:y] - cheese_location[:y] < -MIN_DISTANCE
      move[:move] = :arrow_down
      move[:distance] = (mouse_location[:y] - cheese_location[:y]).abs
    elsif mouse_location[:y] - cheese_location[:y] > MIN_DISTANCE
      move[:move] = :arrow_up
      move[:distance] = (mouse_location[:y] - cheese_location[:y]).abs
    end
    move
  end

  def self.run(speed = 12.5)
    driver = Selenium::WebDriver.for(:chrome)

    driver.get(MOUSECAT_URL)

    sleep(2)

    location = {:x => 0, :y => 0}

    game_board = driver.find_element(:id => 'background')
    picture = ChunkyPNG::Image.from_string(driver.screenshot_as(:png))

    cheese_coordinates = find_objects(picture, CHEESE_COLORS.values.map{|e| e.sample(5)}.flatten)
    mouse_coordinates = find_objects(picture, MOUSE_COLORS)

    current_cheese_target = cheese_coordinates.keys.first

    while !game_over?(driver) do
      current_cheese_target = cheese_coordinates.keys.first if !(cheese_coordinates.keys.include? current_cheese_target)
      next_move = calculate_move(mouse_coordinates.values.first, cheese_coordinates[current_cheese_target])
      (next_move[:distance] / speed).to_i.times{game_board.send_keys(Array.new(20, next_move[:move]))}

      picture = ChunkyPNG::Image.from_string(driver.screenshot_as(:png))
      
      new_cheese_coordinates = find_objects(picture, CHEESE_COLORS.values.map{|e| e.sample(5)}.flatten)
      cheese_coordinates = new_cheese_coordinates if !new_cheese_coordinates.empty?
      new_mouse_coordinates = find_objects(picture, MOUSE_COLORS) 
      mouse_coordinates = new_mouse_coordinates if !new_mouse_coordinates.empty?
    end

    text_box = driver.find_element(id: 'submitname')
    text_box.send_keys("Andy's Bot")
    submit = driver.find_element(id: 'playagain')
    submit.click

    sleep(5)

    driver.close
  end
end
