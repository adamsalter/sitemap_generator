module FileMacros
  module ExampleMethods

    def files_should_be_identical(first, second)
      identical_files?(first, second).should be(true)
    end

    def files_should_not_be_identical(first, second)
      identical_files?(first, second).should be(false)
    end

    def file_should_exist(file)
      File.exists?(file).should be(true), "File #{file} should exist"
    end

    def directory_should_exist(dir)
      File.exists?(dir).should be(true), "Directory #{dir} should exist"
      File.directory?(dir).should be(true), "#{dir} should be a directory"
    end

    def directory_should_not_exist(dir)
      File.exists?(dir).should be(false), "Directory #{dir} should not exist"
    end

    def file_should_not_exist(file)
      File.exists?(file).should be(false), "File #{file} should not exist"
    end

    def identical_files?(first, second)
      file_should_exist(first)
      file_should_exist(second)
      open(second, 'r').read.should == open(first, 'r').read
    end
  end

  def self.included(receiver)
    receiver.send :include, ExampleMethods
  end
end
