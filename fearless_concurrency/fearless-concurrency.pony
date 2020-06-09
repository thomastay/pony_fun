// This program will take the array [1, 2, 3, 4, ..., 10]
// and add 10 to each element
// using two actors, each on half of the array in parallel
// then prints the array
use "itertools"
use "assert"
use "collections"
primitive Helpers
  fun createRange(n: USize): Array[USize] iso^ =>
    let a = recover Array[USize](n) end
    for i in Range(0, n) do
      a.push(i)
    end
    consume a

  fun addN(arr: Array[USize] iso, n: USize): Array[USize] iso^ =>
    recover iso
      let a: Array[USize] trn = consume arr
      for (i, item) in a.pairs() do
        try a.update(i, item + n)? end
      end
      a
    end

actor Adder
  let _runner: Main

  new create(runner: Main) =>
    _runner = runner

  be addN(array: Array[USize] iso, n: USize) =>
    let arr = Helpers.addN(consume array, n)
    _runner.checkIn(consume arr)

actor Main
  let _env: Env
  var _checkedIn: Bool
  var _first: Array[USize] iso

  new create(env: Env) =>
    _env = env
    _checkedIn = false
    _first = recover Array[USize] end
    let size: USize = 100
    let n: USize = 10
    // chop the array
    (let left, let right) = Helpers.createRange(size).chop(size/2)
    // spawn a thread to work on the left half
    Adder(this).addN(consume left, n) // run in parallel
    // work on the right half
    let right' = Helpers.addN(consume right, n)
    // check in (worker thread will also check in)
    checkIn(consume right')
  
  be checkIn(arr: Array[USize] iso) =>
    if not _checkedIn then
      // the first to check in will store their result in _first
      _first = consume arr
      _checkedIn = true
    else
      // the second to check in will combine the two results
      // 1. perform a destructive read on _first, into a local variable
      let first: Array[USize] iso = _first = recover Array[USize] end
      // 2. unchop both first and arr into a single array
      // this should always work, so assert(false) otherwise
      let a = recover iso
        try 
          (consume first).unchop(consume arr) as Array[USize] iso 
        else
          try Assert(false, "Unchop should always work")? end
          Array[USize]
        end
      end
      // finally, print the result to stdout
      finish(consume a)
    end

  be finish(arr: Array[USize] val) =>
    let strs = Iter[USize](arr.values()).map[String]({(x) => x.string() })
    let result = ",".join(strs)
    _env.out.print(consume result)
