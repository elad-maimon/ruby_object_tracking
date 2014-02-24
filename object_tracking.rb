#!/usr/bin/env ruby
require 'opencv'
include OpenCV

require_relative 'filtered_window'
require_relative 'tracker'

FRAME_WIDTH = 640
FRAME_HEIGHT = 480
MAX_NUM_OBJECTS = 50
MIN_OBJECT_AREA = 600
MAX_OBJECT_AREA = FRAME_HEIGHT * FRAME_WIDTH / 1.5

def erode_delate_noise_reduction(image)
  repeats = 2
  repeats.times { image.erode! }
  repeats.times { image.dilate! }
end

def median_noise_reduction(image)
  2.times { image = image.smooth(CV_MEDIAN, 9, 9) }
  image
end

def detect_objects(image)
  contours = image.find_contours mode: OpenCV::CV_RETR_CCOMP, method: OpenCV::CV_CHAIN_APPROX_SIMPLE
  return [] unless contours && contours.size > 0

  if contours.size > MAX_NUM_OBJECTS
    image.put_text("TOO MUCH NOISE! ADJUST FILTER", CvPoint.new(0,50), CvFont.new(:simplex), CvScalar.new(0,0,255))
  end

  contours_array = []

  while contours
    # result = contours.approx_poly :accuracy => 6.0 #(contour, sizeof(CvContour), storage, CV_POLY_APPROX_DP, cvContourPerimeter(contour)*0.02, 0)
    # puts result.total
    
    # unless contour.hole?
    contours_array << contours if contours.contour_area > MIN_OBJECT_AREA
    contours = contours.h_next
  end 

  contours_array
end

def detect_circles(image)
  # Params: method, dp, min distance between centers, threshold for edge detection, threshold for center, min_radius, max_radius, storage
  image.hough_circles(CV_HOUGH_GRADIENT, 2.0, 40, 200, 50, 10)
end

def draw_objects(image, contours)
  contours.each do |contour|
    # image.rectangle! contour.rect.top_left, contour.rect.bottom_right, :color => CvColor::White

    points = contour.min_area_rect2.points.map { |point| CvPoint.new(point.x, point.y) }
    image.poly_line! [points], :color => CvColor::White, :is_closed => true
  end
end

if __FILE__ == $0
  original_window = GUI::Window.new("Original Image")
  filtered_window = FilteredWindow.new(FilteredWindow::BLUE)

  tracker = Tracker.new
  capture = CvCapture.open 0
  capture.size = CvSize.new(FRAME_WIDTH, FRAME_HEIGHT)

  loop do
    camera_feed = capture.query
    
    blue_filtered_image = filtered_window.filter_in_range(camera_feed)
    blue_filtered_image = median_noise_reduction(blue_filtered_image)
    
    contours = detect_objects(blue_filtered_image)
    draw_objects(camera_feed, contours)
    # require 'pry'
    # binding.pry
    
    tracked_object = tracker.track_object(contours, camera_feed)
    camera_feed.rectangle! tracked_object.rect.top_left, tracked_object.rect.bottom_right, :color => CvColor::Red, :thickness => 2 if tracked_object
    
    # circles = detect_circles(blue_filtered_image)
    # circles.each { |circle| camera_feed.circle! circle.center, circle.radius, :color => CvColor::Blue, :thickness => 2 }

    filtered_window.show(blue_filtered_image)
    original_window.show(camera_feed)

    GUI::wait_key(30)
  end
end
