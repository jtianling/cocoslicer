require "cocoslicer/version"
require 'plist'

module Cocoslicer
  class Point
    attr_accessor :x, :y

    def initialize(x=0, y=0)
      @x = x
      @y = y
    end

    def import_from_str(str)
      match = @@re.match(str)
      @x = match[1].to_i
      @y = match[2].to_i
      return self
    end

    def to_cmd_str
      return "+#{@x}+#{@y}"
    end

    def to_s
      return "{x=#{@x},y=#{@y}}"
    end

    private
    @@re = /\{(-?\d+),(-?\d+)\}/

  end

  class Size
    attr_accessor :width, :height


    def initialize(width=0, height=0)
      @width = width
      @height = height
    end

    def import_from_str(str)
      match = @@re.match(str)
      @width = match[1].to_i
      @height = match[2].to_i
      return self
    end

    def to_cmd_str(rotated)
      if !rotated
        return "#{@width}x#{@height}"
      else
        return "#{@height}x#{@width}"
      end
    end

    def to_s
      return "{width=#{@width},height=#{@height}}"
    end

    private
    @@re = /\{(\d+),(\d+)\}/
  end

  class Rect
    attr_accessor :orig, :size


    def initialize(orig_point = Point.new, size = Size.new)
      @orig = orig_point
      @size = size
    end

    def import_from_str(str)
      match = @@re.match(str)

      @orig = Point.new( match[1].to_i, match[2].to_i )
      @size = Size.new( match[3].to_i, match[4].to_i )
      return self
    end

    def to_cmd_str(rotated)
      return @size.to_cmd_str(rotated) + @orig.to_cmd_str
    end

    def to_s
      return "{orig=#{@orig},size=#{@size}}"
    end

    private
    @@re = /\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\}/
  end

  class ImageInfo
    attr_accessor :name, :frame, :offset, :rotated, :source_color_rect, :source_size

    def slice_img(tex_name)
      cmd = "convert #{tex_name} -crop " + frame.to_cmd_str(@rotated) 
      if @rotated
        cmd += " -rotate -90"
      end

      border_size = Size.new()
      border_size.width = (@source_size.width - @frame.size.width) / 2 + @offset.x.abs;
      border_size.height = (@source_size.height - @frame.size.height) / 2 + @offset.y.abs;
      cmd += " -bordercolor none -border #{border_size.to_cmd_str(false)}"
      cmd += " -chop " + get_chop_offset_str()

      cmd += " #{@name}"
      puts cmd
      puts system cmd
    end

    def get_chop_offset_str
      str = "#{@offset.x.abs*2}x#{@offset.y.abs*2}"
      if @offset.x > 0
        str += "+#{@source_size.width}"
      else
        str += "+0"
      end

      if @offset.y > 0
        str += "+0"
      else
        str += "+#{@source_size.height}"
      end

    end

    def to_s
      return "name=#{@name},frame=#{@frame},offset=#{@offset},rotated=#{@rotated},source_color_rect=#{@source_color_rect},source_size=#{@source_size}"
    end
  end

  def self.main
    if ARGV[0] == nil
      puts 'Need a argv as plist filename'
      exit
    end

    doc = Plist::parse_xml(ARGV[0])
    if doc == nil
      puts ARGV[0] + ' is not a valid plist file.'
      exit
    end

      
    path = ARGV[0].gsub(/(.*)\/(.*)/, '\1/')

    metadata = doc['metadata']
    tex_name = metadata['realTextureFileName']
    if tex_name != nil then
      tex_name = path + tex_name
      if not FileTest::exist? tex_name then
        puts tex_name + ' is not exist.'
        exit
      end
    else
      tex_name = ARGV[0].gsub(/(.*)\.plist/, '\1.png')

      if not FileTest::exist? tex_name then
        puts tex_name + ' is not exist.'
        exit
      end

    end

    frames = doc['frames']

    if frames == nil
      puts ARGV[0] + ' is not a valid cocos2d resource plist file.'
      exit
    end

    infos = []
    frames.each { |key, value|
      puts "#{key} => #{value}"
      info = ImageInfo.new
      info.name = path + key

      info.frame = Rect.new.import_from_str(value['frame'])
      info.offset = Point.new.import_from_str(value['offset'])
      info.rotated = value['rotated']
      info.source_color_rect = Rect.new.import_from_str(value['sourceColorRect'])
      info.source_size = Size.new.import_from_str(value['sourceSize'])

      puts info

      info.slice_img(tex_name)
    }
  end
end
