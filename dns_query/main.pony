use "net"

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    let dnsResolver = DNS 
    try
      let dnsAuth = DNSAuth(env.root as AmbientAuth)
      let addresses = recover val dnsResolver.ip4(
        dnsAuth,
        "www.kame.net",
        "80" // port 80
      ) end
      for address in addresses.values() do getAddrName(address) end
    else
      env.err.print("Not authorized to access DNS")
    end
  
  fun getByteAsStr(addr: U32, byte: U32): String =>
    (addr >> (byte * 8)).u8().string()

  fun getAddrName(addr: NetAddress) =>
    if addr.ip4() then
      let addr' = addr.ipv4_addr()
      let first = getByteAsStr(addr', 0)
      let second = getByteAsStr(addr', 1)
      let third = getByteAsStr(addr', 2)
      let fourth = getByteAsStr(addr', 3)
      let s = fourth + "." + third + "." + second + "." + first
      _env.out.print(s)
    else
      _env.out.print("IPv6")
    end
