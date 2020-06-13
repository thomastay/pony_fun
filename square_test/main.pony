use "collections"  // for the Range operator
use "promises" 

actor Main
  new create(env: Env) =>
    var x: USize = 0
    for i in Range(1, 11) do
      x = x + i  // sum 1 to 10 in x, a member variable
    end

    // create a promise that takes as input the squared num
    // then will print to stdout
    let p = Promise[USize]
    p.next[None](recover this~printResult(env, x) end)

    // spawn a squarer actor,
    // and then call the square behavior on it
    Squarer.square(x, p)

  be printResult(env: Env, x: USize, newVal: USize) =>
    env.out.print("Original: " + x.string() 
                  + ", New: " + newVal.string())

actor Squarer
  be square(x: USize, p: Promise[USize]) =>
    let newVal = x * x
    p(newVal)     // fulfil the promise
