guard :rspec, cmd: "RACK_ENV=test bundle exec rspec --color" do
   watch(/^(.+)\.rb$/)           { |m| "spec/#{m[1]}_spec.rb" }
   watch(%r{^app/models/(.+)\.rb$})  { |m| "spec/models/#{m[1]}_spec.rb" }
   watch(%r{^app/helpers/(.+)\.rb$})  { |m| "spec/helpers/#{m[1]}_spec.rb" }
   watch(%r{^app/routes/(.+)\.rb$})  { |m| "spec/routes/#{m[1]}_spec.rb" }
   watch(%r{^spec/(.+)_spec\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
   watch('spec/spec_helper.rb')  { "spec/" }
end
