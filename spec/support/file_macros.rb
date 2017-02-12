module FileMacros
  module ExampleMethods

    def files_should_be_identical(first, second)
      expect(identical_files?(first, second)).to be(true)
    end

    def files_should_not_be_identical(first, second)
      expect(identical_files?(first, second)).to be(false)
    end

    def file_should_exist(file)
      expect(File.exists?(file)).to be(true), "File #{file} should exist"
    end

    def directory_should_exist(dir)
      expect(File.exists?(dir)).to be(true), "Directory #{dir} should exist"
      expect(File.directory?(dir)).to be(true), "#{dir} should be a directory"
    end

    def directory_should_not_exist(dir)
      expect(File.exists?(dir)).to be(false), "Directory #{dir} should not exist"
    end

    def file_should_not_exist(file)
      expect(File.exists?(file)).to be(false), "File #{file} should not exist"
    end

    def identical_files?(first, second)
      file_should_exist(first)
      file_should_exist(second)
      expect(open(second, 'r').read).to eq(open(first, 'r').read)
    end
  end

  def self.included(receiver)
    receiver.send :include, ExampleMethods
  end
end
