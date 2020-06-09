actor Main
  new create(env: Env) =>
    try
      will_error(3)?
    else
      env.out.print("Error handled")
    then
      env.out.print("Hello, world!")
    end
  fun will_error(x: I32) ? =>
    x /? 0
