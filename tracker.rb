class Tracker
  DEBUG = false
  MIN_DETECTION_AREA = 15000
  MIN_DETECTION_TIME = 2
  MAX_FRAMES_TO_SKIP = 4
  MAX_DISTANCE_TOLERANCE = 150
  
  def initialize
    init_tracking
  end
  
  def track_object(contours, camera_feed)
    case @mode
    when :detect_main_object
      detect_main_object(contours)
      nil
    when :verify_main_object
      verify_main_object(contours)
      nil
    when :track_detected_object
      track_detected_object(contours, camera_feed)
      @detected_object
    end
  end

  private
  
  def init_tracking
    locked_lost_sound if @mode == :track_detected_object
    @mode = :detect_main_object
    @detected_object = nil
    @start_detection_time = nil
    @frames_skipped = 0
  end
  
  def detect_main_object(contours)
    contours.select! { |contour| contour.contour_area > MIN_DETECTION_AREA }
    puts "Number of objects in detection area: #{contours.size}" if DEBUG

    if contours.size == 1
      @detected_object = contours.first
      @start_detection_time = Time.now
      @mode = :verify_main_object
    end
  end
  
  def verify_main_object(contours)
    contours.select! { |contour| contour.contour_area > MIN_DETECTION_AREA }
    
    if (contours.size != 1 || distance_from_detected_object(contours.first) > MAX_DISTANCE_TOLERANCE)
      @frames_skipped += 1
      puts "Skiping frame!"
      init_tracking if @frames_skipped > MAX_FRAMES_TO_SKIP
    else 
      @frames_skipped = 0
      
      if (Time.now - @start_detection_time) > MIN_DETECTION_TIME
        @mode = :track_detected_object
        locked_sound
      end
    end
  end
  
  def track_detected_object(contours, camera_feed)
    nearest_contour = contours.min_by { |contour| distance_from_detected_object(contour) }
    
    if (nearest_contour && distance_from_detected_object(nearest_contour) <= MAX_DISTANCE_TOLERANCE)
      @frames_skipped = 0
      @detected_object = nearest_contour
    else
      @frames_skipped += 1
      puts "Skiping frame!"
      init_tracking if @frames_skipped > MAX_FRAMES_TO_SKIP
    end
  end
  
  def distance_from_detected_object(contour)
    point1 = @detected_object.rect.center
    point2 = contour.rect.center
    
    distance = Math.sqrt((point1.x - point2.x) ** 2 + (point1.y - point2.y) ** 2)
    puts "Distance from detected object: #{distance}" if DEBUG
    distance
  end
  
  def locked_sound
    `say -v Bubbles  "haa"`
  end
  
  def locked_lost_sound
    `say -v Bells "haa" `
  end
end
