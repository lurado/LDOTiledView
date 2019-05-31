#!/usr/bin/env ruby

require "fileutils"
require "optparse"
require "ostruct"

def command_exists?(name)
  `which #{name}`
  $?.success?
end

abort("libvips not found. Please run `brew install vips`") unless command_exists? "vips" and command_exists? "sips"

def parse_arguments!(args)
  options = OpenStruct.new
  options.tile_size = 256
  options.scales = []
  options.format = "jpeg[Q=90]"
  options.force = false

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: gen_tiles.rb <input_image> [options]"

    opts.separator ""
    opts.separator "Options:"

    opts.on("-t", "--tile-size [SIZE]", Integer, "Tile size in points. Default value 256.") do |size|
      options.tile_size = size
    end

    opts.on("-s", "--scale SCALE", Integer, "Scale that should be created. Pass `2` for Retina, `3` for High Retina. Can be passed multiple times.") do |scale|
      options.scales << scale
    end

    opts.on("-l", "--levels LEVELS", Integer, "Number of zoom levels to create.") do |levels|
      options.levels = levels
    end

    opts.on("-f", "--format [FORMAT]", "The image format to generate, like `png`, `jpeg` or `jpeg[Q=x]` where x specifies the JPEG quality. Default: jpeg[Q=90].") do |format|
      options.format = format
    end

    opts.on("-c", "--force", "Destructive: Delete and re-create the output folder if it already exists") do |f|
      options.force = f
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end

  options.input_file = args.reject { |a| a[0] == '-' }.first

  opt_parser.parse!(args)
  options.scales.sort!
  options.output_folder = File.basename(options.input_file, ".*")

  abort "Error: Can't find input image #{options.input_file}." if not File.exist? options.input_file
  abort "Error: No scale defined." if options.scales.empty?
  abort "Error: Number of levels not defined." if not options.levels
  abort "Error: Output path `#{options.output_folder}` already exists." if File.exist? options.output_folder and not options.force

  options.input_file = File.expand_path options.input_file

  options
end

def generate_tiles(source_file, levels:, tile_size:, format:)
  output_name = File.basename source_file, ".*"
  `vips dzsave "#{source_file}" #{output_name} --depth onetile --tile-size #{tile_size} --overlap 0 --suffix .#{format}`

  FileUtils.rm "#{output_name}.dzi"

  output_folder = "#{output_name}_files"

  # delete the levels that have been generated but are not wanted and rename the rest to start with "1"
  Dir.chdir output_folder do
    folders = Dir.glob('*').select {|f| File.directory? f }.sort
    folders[0...-levels].each { |f| FileUtils.rm_r f }

    folders = Dir.glob('*').select {|f| File.directory? f }.sort
    if folders != (1..levels).to_a.map(&:to_s)
      folders.each_with_index { |f, index|  FileUtils.mv f, (index + 1).to_s }
    end
  end

  output_folder
end

def scale_image(input_file, scale)
  scaled_filename = File.basename input_file
  if scale == 1
    FileUtils.cp input_file, scaled_filename
  else
    `vips resize "#{input_file}" "#{scaled_filename}" #{scale}`
  end
  scaled_filename
end

def print_level_1_image_size(input_file, levels:, tile_size:, max_scale:)
  output = `sips -g pixelWidth -g pixelHeight "#{input_file}"`
  width = output.match(/pixelWidth: (\d+)/)[1].to_f
  height = output.match(/pixelHeight: (\d+)/)[1].to_f

  scaled_tile_size = tile_size * max_scale
  width = width / (2**(levels - 1)) / scaled_tile_size * tile_size
  height = height / (2**(levels - 1)) / scaled_tile_size * tile_size

  puts "Level 1 image size: #{width.to_i} x #{height.to_i}"
end

options = parse_arguments!(ARGV)

FileUtils.rm_r options.output_folder if File.exist? options.output_folder and options.force

FileUtils.mkdir options.output_folder

Dir.chdir options.output_folder do
  options.scales.each do |scale|
    scale_factor = (scale.to_f / options.scales.max).round(5)
    scaled_filename = scale_image(options.input_file, scale_factor)
    
    scaled_tile_size = options.tile_size * scale

    tiles_folder = generate_tiles(scaled_filename, levels: options.levels, tile_size: scaled_tile_size, format: options.format)

    # move generated files to output folder
    destination_folder = "#{scale}x"
    FileUtils.mkdir destination_folder
    FileUtils.mv Dir.glob(File.join(tiles_folder, "*")), destination_folder
    FileUtils.rm_r tiles_folder
    FileUtils.rm scaled_filename
  end

  print_level_1_image_size(options.input_file, levels: options.levels, tile_size: options.tile_size, max_scale: options.scales.max)
end
