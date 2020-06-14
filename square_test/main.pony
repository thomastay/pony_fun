use "collections" // for range
actor Main
  let _env: Env
  new create(env: Env) =>
    _env = env
    directCallback()
    //asyncCallback()
  
  be directCallback() =>
    Worker.work(_env.out, {() => 
      let s = recover iso String end
      for i in Range(1, 1000000) do 
        s.append(i.string())
      end
      // slice out first 5 elements
      let s' = (consume s).trim(0, 5)
      _env.out.print(s')
    })

  be asyncCallback() =>
    Worker.work(_env.out, recover this~spin() end)
  
  // simulate work to spin the CPU
  be spin() =>
    let s = recover iso String end
    for i in Range(1, 1000000) do 
      s.append(i.string())
    end
    // slice out first 5 elements
    let s' = (consume s).trim(0, 5)
    _env.out.print(s')


actor Worker
  be work(out: OutStream, callback: {(): None} val) =>
    callback()
    out.print("Squaring complete!")
