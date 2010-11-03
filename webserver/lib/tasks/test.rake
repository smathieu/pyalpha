namespace :test do

  desc "Test lib source"
  Rake::TestTask.new(:lib) do |t|    
    t.libs << "test"
    t.libs << "lib"
    t.pattern = 'test/lib/**/*_test.rb'
    t.verbose = true    
  end

  lib_task = Rake::Task["test:lib"]
  test_task = Rake::Task[:test]
  test_task.enhance { lib_task.invoke }
  
end

