require "bundler/setup"
require "OBD"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

def debug(message, indent)
  indent.times {print "\s"}
  puts "#{message}".blue
end

def test_single_value(amount)
  l, h, t = 0, 0, 0
  amount.times do
    v = yield
    t += v
    l = v if v < l
    h = v if v > h
  end
  {:LOW => l, :HIGH => h, :AVERAGE => t / amount}
end

def test_multiple_values(amount)
  store = {}
  amount.times do
    yield_hash = yield
    yield_hash.each_pair do |key, value|
      value = value.round(2)
      if store[key].nil?
        store[key] = {:LOW => 0, :HIGH => 0, :TOTAL => 0, :AVERAGE => 0, }
      end
      store[key][:TOTAL] += value
      store[key][:LOW] = value if value < store[key][:LOW]
      store[key][:HIGH] = value if value > store[key][:HIGH]
    end
  end
  store.each_key {|key| store[key][:AVERAGE] = (store[key][:TOTAL] / amount).round(1)}
end

def test_array_value(amount)
  store = []
  amount.times do
    store << yield
  end
  return store
end
