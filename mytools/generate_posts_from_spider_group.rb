# encoding: utf-8

require "active_record"

SPIDERGROUP_PATH="/Users/zhaowu/RubymineProjects/SpiderGroup"
IMG_PATH=File.expand_path(File.join(File.dirname(__FILE__), '../imgs'))
FileUtils.mkdir_p IMG_PATH

imgs_src = SPIDERGROUP_PATH+'/lib/imgs/*'
FileUtils.cp_r Dir.glob(imgs_src), IMG_PATH

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database  => SPIDERGROUP_PATH+"/content.s3db")
class Content < ActiveRecord::Base
end

def write_file(filename, content)
  begin
    File.open(filename,"w"){|file|     # "w"不能少第二个参数
    	file.puts(content)
    	file.close
    }
  rescue => e
    puts e.to_s
  ensure

  end
end

Content.order(created_at: :desc).all.each{|c|
	filename = File.expand_path(File.join(File.dirname(__FILE__), "../_posts/#{c.created_at.strftime('%Y-%m-%d').to_s  }-#{c.id}.text"))
	post  = <<DOCUMENT
---
layout: post
title:  "#{c.title}"
date:   #{c.created_at}
categories: #{c.source}
description: "#{c.description.strip}"
cover: #{c.cover}
---
#{c.content}
DOCUMENT
=begin  
  if c.cover
    img_src_file = SPIDERGROUP_PATH+"/lib/"+c.cover 
    img_dst_file = File.expand_path(File.join(IMG_PATH, File.basename(c.cover)))
    if File.exists? img_src_file
      puts "cp #{img_src_file} #{img_dst_file}"
      FileUtils.copy_file(img_src_file, img_dst_file) 
    end
	end
=end
  write_file(filename, post) unless File.exists?(filename)
}

