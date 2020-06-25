// showcase assert false
use "assert"
actor Main
  new create(env: Env) =>
    Fact(false)?
