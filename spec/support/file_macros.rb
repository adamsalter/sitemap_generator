module FileMacros
  module ExampleMethods
    
    def files_should_be_identical(first, second)
      identical_files?(first, second).should be(true)
    end

    def files_should_not_be_identical(first, second)
      identical_files?(first, second).should be(false)
    end
    
    def file_should_exist(file)
      File.exists?(file).should be(true)
    end

    def file_should_not_exist(file)
      File.exists?(file).should be(false)
    end
        
    def identical_files?(first, second)
      open(second, 'r').read.should == open(first, 'r').read
    end
  end  
  
  def self.included(receiver)
    receiver.send :include, ExampleMethods  
  end  
end