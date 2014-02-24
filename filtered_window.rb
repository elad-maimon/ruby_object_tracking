class FilteredWindow
  BLUE = [95, 110, 131, 315, 114, 250]
  YELLOW = [10, 33, 116, 235, 154, 229]
  GREEN = [49, 82, 72, 168, 107, 224]
  BLUE_USB = [95, 145, 145, 315, 35, 195]
  
  def initialize(color)
    @h_min = color[0]
    @h_max = color[1]
    @s_min = color[2]
    @s_max = color[3]
    @v_min = color[4]
    @v_max = color[5]

    @filtered_window = GUI::Window.new("Filtered Image")
    @filtered_window.move(FRAME_WIDTH, 0)

    @h_min_trackbar = @filtered_window.set_trackbar("Hue min", 256, @h_min)        { |v| @h_min = v; print_values }
    @h_max_trackbar = @filtered_window.set_trackbar("Hue max", 256, @h_max)        { |v| @h_max = v; print_values }
    @s_min_trackbar = @filtered_window.set_trackbar("Saturation min", 256, @s_min) { |v| @s_min = v; print_values }
    @s_max_trackbar = @filtered_window.set_trackbar("Saturation max", 256, @s_max) { |v| @s_max = v; print_values }
    @v_min_trackbar = @filtered_window.set_trackbar("Value min", 256, @v_min)      { |v| @v_min = v; print_values }
    @v_max_trackbar = @filtered_window.set_trackbar("Value max", 256, @v_max)      { |v| @v_max = v; print_values }
  end

  def filter_in_range(rgb_image)
    hsv_image = rgb_image.BGR2HSV
    hsv_image.in_range(CvScalar.new(@h_min, @s_min, @v_min), CvScalar.new(@h_max, @s_max, @v_max))
  end
  
  def show(image)
    @filtered_window.show(image)
  end
    
  def print_values
    puts "#{@h_min} #{@s_min} #{@v_min} => #{@h_max} #{@s_max} #{@v_max}"
  end
end
