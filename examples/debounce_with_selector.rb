require 'rx'

array = [
    0.8,
    0.7,
    0.6,
    0.5
]

source = RX::Observable.for(
    array,
    lambda {|x|
        return RX::Observable.timer(x)
    })
    .map {|x, i| i }
    .debounce_with_selector(lambda {|x|
        RX::Observable.timer(0.7)
    })

subscription = source.subscribe(
    lambda {|x|
        puts 'Next: ' + x.to_s
    },
    lambda {|err|
        puts 'Error: ' + err.to_s
    },
    lambda {
        puts 'Completed'
    })

# => Next: 0
# => Next: 3
# => Completed

while Thread.list.size > 1
  (Thread.list - [Thread.current]).each &:join
end
