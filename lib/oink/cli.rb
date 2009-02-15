def get_file_listing(args)
  listing = []
  args.each do |file|
    unless File.exist?(file)
      raise "Could not find \"#{file}\""
    end
    if File.directory?(file)
      listing += Dir.glob("#{file}/**")
    else
      listing << file
    end
  end
  listing
end