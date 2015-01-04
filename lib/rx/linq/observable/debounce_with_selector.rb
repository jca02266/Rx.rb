module RX
  module Observable
    def debounce_with_selector(duration_selector)
      AnonymousObservable.new do |observer|
        value = nil
        has_value = false
        cancelable = SerialSubscription.new
        id = 0
        subscription = subscribe(
          lambda {|x|
            begin
              throttle = duration_selector.call(x)
            rescue => e
              observer.on_error e
              return
            end

            has_value = true
            value = x
            id += 1
            current_id = id
            d = SingleAssignmentSubscription.new
            cancelable.subscription = d
            d.subscription = throttle.subscribe(
              lambda {
                observer.on_next value if has_value && id == current_id
                has_value = false
                d.dispose
              },
              observer.method(:on_error),
              lambda {
                observer.on_next value if has_value && id == current_id
                has_value = false
                d.dispose
              })
          },
          lambda {|e|
            cancelable.dispose
            observer.on_error e
            has_value = false
            id += 1
          },
          lambda {
            cancelable.dispose
            observer.on_next value if has_value
            observer.on_completed
            has_value = false
            id += 1
          })

        CompositeSubscription.new [subscription, cancelable]
      end
    end
  end
end
